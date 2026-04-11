import 'dart:async';

import 'package:bloc/bloc.dart';

import 'package:diamond_clean/core/utils/cashbox_validator.dart';

import '../data/datasources/cashbox_remote_data_source.dart';
import '../data/models/cashbox_audit_log_model.dart';
import '../data/models/cashbox_closure_model.dart';
import '../data/models/cashbox_expense_model.dart';
import '../data/models/cashbox_income_model.dart';
import '../data/models/cashbox_settings_model.dart';
import '../data/models/expense_category.dart';
import 'cashbox_state.dart';

class CashboxCubit extends Cubit<CashboxState> {
  final CashboxRemoteDataSource _dataSource;
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  bool _isListening = false;

  List<CashboxIncomeModel> _incomeEntries = [];
  List<CashboxExpenseModel> _expenses = [];
  List<CashboxClosureModel> _closures = [];
  List<CashboxAuditLogModel> _auditLogs = [];
  CashboxSettingsModel _settings = CashboxSettingsModel.initial();
  DateTime _selectedDay = _todayStart();

  CashboxCubit(this._dataSource) : super(const CashboxInitial());

  static DateTime _todayStart() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  void listen({bool restart = false}) {
    if (_isListening && !restart) {
      return;
    }

    emit(const CashboxLoading());
    _cancelSubscriptions();

    _subscribeToStream(_dataSource.watchSettings(), _updateSettings);
    _subscribeToStream(_dataSource.watchIncomeEntries(), _updateIncomeEntries);
    _subscribeToStream(_dataSource.watchExpenses(), _updateExpenses);
    _subscribeToStream(_dataSource.watchClosures(), _updateClosures);
    _subscribeToStream(_dataSource.watchAuditLogs(), _updateAuditLogs);
    _isListening = true;
  }

  StreamSubscription<T> _subscribeToStream<T>(
    Stream<T> stream,
    void Function(T) onData,
  ) {
    final subscription = stream.listen((data) {
      onData(data);
      _rebuild();
    }, onError: (Object error) => _emitStreamError(error));
    _subscriptions.add(subscription);
    return subscription;
  }

  void selectDay(DateTime day) {
    final normalizedDay = _dayStart(day);
    if (_isSameDay(_selectedDay, normalizedDay)) {
      return;
    }

    _selectedDay = normalizedDay;
    _rebuild();
  }

  Future<void> saveOpeningBalance(
    double openingBalance,
    String openedBy,
  ) async {
    // Validate inputs
    final amountValidation = CashboxValidator.validateOpeningBalance(
      openingBalance,
    );
    if (amountValidation is CashboxValidationFailure) {
      await _logAuditEvent(
        eventType: AuditEventType.validationFailed,
        operationId: 'opening_balance',
        performedBy: openedBy,
        amount: openingBalance,
        description: 'Failed: ${amountValidation.reason}',
        isValid: false,
        validationError: amountValidation.reason,
      );
      throw Exception(amountValidation.reason);
    }

    final userValidation = CashboxValidator.validateUserName(openedBy);
    if (userValidation is CashboxValidationFailure) {
      await _logAuditEvent(
        eventType: AuditEventType.validationFailed,
        operationId: 'opening_balance',
        performedBy: openedBy,
        amount: openingBalance,
        description: 'Failed: ${userValidation.reason}',
        isValid: false,
        validationError: userValidation.reason,
      );
      throw Exception(userValidation.reason);
    }

    await _performMutation(() async {
      await _dataSource.saveOpeningBalance(
        openingBalance: openingBalance,
        openedBy: openedBy,
      );

      // Log successful operation
      await _logAuditEvent(
        eventType: AuditEventType.openingBalanceSet,
        operationId: 'opening_balance_${DateTime.now().microsecondsSinceEpoch}',
        performedBy: openedBy,
        amount: openingBalance,
        description: 'Opened cashbox with balance',
        isValid: true,
      );
    });
  }

  Future<void> addExpense({
    required String title,
    required double amount,
    ExpenseCategory category = ExpenseCategory.other,
    String? createdBy,
  }) async {
    // Validate inputs
    final validation = CashboxValidator.validateExpense(
      amount: amount,
      title: title,
    );
    if (validation is CashboxValidationFailure) {
      await _logAuditEvent(
        eventType: AuditEventType.validationFailed,
        operationId: 'expense_add',
        performedBy: createdBy ?? 'System',
        amount: amount,
        description: 'Failed: ${validation.reason}',
        isValid: false,
        validationError: validation.reason,
      );
      throw Exception(validation.reason);
    }

    await _performMutation(() async {
      final now = DateTime.now();
      final expenseId = now.microsecondsSinceEpoch.toString();
      final expense = CashboxExpenseModel(
        id: expenseId,
        title: title,
        amount: amount,
        category: category,
        createdBy: createdBy,
        createdAt: now,
      );
      await _dataSource.addExpense(expense);

      // Log successful operation
      await _logAuditEvent(
        eventType: AuditEventType.expenseAdded,
        operationId: expenseId,
        performedBy: createdBy ?? 'System',
        amount: amount,
        description: 'Added expense: $title',
        metadata: {'category': category.value, 'title': title},
        isValid: true,
      );
    });
  }

  Future<void> updateExpense(CashboxExpenseModel expense) async {
    await _performMutation(() {
      return _dataSource.updateExpense(expense);
    });
  }

  Future<void> deleteExpense(String expenseId) async {
    await _performMutation(() async {
      // Find the expense to log it
      final expense = _expenses.firstWhere(
        (e) => e.id == expenseId,
        orElse: () => CashboxExpenseModel(
          id: expenseId,
          title: 'Unknown',
          amount: 0,
          createdAt: DateTime.now(),
        ),
      );

      await _dataSource.deleteExpense(expenseId);

      // Log deletion
      await _logAuditEvent(
        eventType: AuditEventType.expenseDeleted,
        operationId: expenseId,
        performedBy: 'System',
        amount: expense.amount,
        description: 'Deleted expense: ${expense.title}',
        metadata: {
          'original_title': expense.title,
          'original_amount': expense.amount,
          'original_category': expense.category.value,
        },
        isValid: true,
      );
    });
  }

  Future<void> savePin(String? pin) async {
    await _performMutation(() {
      return _dataSource.savePin(pin);
    });
  }

  Future<void> closeCashbox(String closedBy) async {
    // Validate user name
    final userValidation = CashboxValidator.validateUserName(closedBy);
    if (userValidation is CashboxValidationFailure) {
      throw Exception(userValidation.reason);
    }

    await _performMutation(() async {
      final sessionSummary = _sessionSummary();

      // Validate closing balance
      final balanceValidation = CashboxValidator.validateClosingBalance(
        _settings.openingBalance,
        sessionSummary.revenue,
        sessionSummary.expensesTotal,
      );
      if (balanceValidation is CashboxValidationFailure) {
        await _logAuditEvent(
          eventType: AuditEventType.validationFailed,
          operationId: 'cashbox_close',
          performedBy: closedBy,
          amount: sessionSummary.balance,
          description: 'Failed: ${balanceValidation.reason}',
          isValid: false,
          validationError: balanceValidation.reason,
        );
        throw Exception(balanceValidation.reason);
      }

      await _dataSource.closeCashbox(
        closedBy: closedBy,
        openingBalance: _settings.openingBalance,
        totalRevenue: sessionSummary.revenue,
        totalExpenses: sessionSummary.expensesTotal,
        closingBalance: sessionSummary.balance,
        ordersCount: sessionSummary.incomeEntries.length,
        expenses: sessionSummary.expenseEntries,
      );

      // Log successful closure
      await _logAuditEvent(
        eventType: AuditEventType.cashboxClosed,
        operationId: 'cashbox_close_${DateTime.now().microsecondsSinceEpoch}',
        performedBy: closedBy,
        amount: sessionSummary.balance,
        description: 'Closed cashbox',
        metadata: {
          'opening_balance': _settings.openingBalance,
          'total_revenue': sessionSummary.revenue,
          'total_expenses': sessionSummary.expensesTotal,
          'closing_balance': sessionSummary.balance,
          'orders_count': sessionSummary.incomeEntries.length,
        },
        isValid: true,
      );
    });
  }

  DateTime _dayStart(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  bool _isSameDay(DateTime left, DateTime right) {
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }

  bool _isWithinSession(DateTime createdAt) {
    final sessionStart = _isViewingToday
        ? _settings.openedAt
        : _dayStart(_selectedDay);
    return !createdAt.isBefore(sessionStart) &&
        _isSameDay(createdAt, _selectedDay);
  }

  bool get _isViewingToday => _isSameDay(_selectedDay, _todayStart());

  void _updateSettings(CashboxSettingsModel? settings) {
    _settings = settings ?? CashboxSettingsModel.initial();
  }

  void _updateIncomeEntries(List<CashboxIncomeModel> entries) {
    _incomeEntries = entries;
  }

  void _updateExpenses(List<CashboxExpenseModel> expenses) {
    _expenses = expenses;
  }

  void _updateClosures(List<CashboxClosureModel> closures) {
    _closures = closures;
  }

  void _updateAuditLogs(List<CashboxAuditLogModel> logs) {
    _auditLogs = logs;
  }

  Future<void> _performMutation(Future<void> Function() action) async {
    try {
      await action();
    } catch (error) {
      _emitMutationError(error);
    }
  }

  void _emitStreamError(Object error) {
    if (isClosed) {
      return;
    }

    emit(CashboxError(error.toString()));
  }

  void _emitMutationError(Object error) {
    if (isClosed) {
      return;
    }

    emit(CashboxError(error.toString()));
  }

  void _cancelSubscriptions() {
    _isListening = false;

    final subscriptions = List<StreamSubscription<dynamic>>.from(
      _subscriptions,
    );
    _subscriptions.clear();

    for (final subscription in subscriptions) {
      unawaited(subscription.cancel());
    }
  }

  // --- Session-filtered data (current session only) ---

  List<CashboxIncomeModel> _sessionIncomeEntries() =>
      _incomeEntries.where((income) {
        return income.includeInCashbox && _isWithinSession(income.createdAt);
      }).toList();

  List<CashboxExpenseModel> _sessionExpenseEntries() =>
      _expenses.where((e) => _isWithinSession(e.createdAt)).toList();

  // --- Full-day data (for logs / historical review) ---

  List<CashboxIncomeModel> _dailyIncomeEntries() =>
      _incomeEntries.where((income) {
        return income.includeInCashbox &&
            _isSameDay(income.createdAt, _selectedDay);
      }).toList();

  List<CashboxExpenseModel> _dailyExpenses() =>
      _expenses.where((e) => _isSameDay(e.createdAt, _selectedDay)).toList();

  List<CashboxClosureModel> _dailyClosures() =>
      _closures.where((c) => _isSameDay(c.closedAt, _selectedDay)).toList();

  double _sumIncome(List<CashboxIncomeModel> incomeEntries) =>
      incomeEntries.fold<double>(0, (sum, income) => sum + income.orderTotal);

  double _sumExpenses(List<CashboxExpenseModel> expenseEntries) =>
      expenseEntries.fold<double>(0, (sum, expense) => sum + expense.amount);

  ({
    List<CashboxIncomeModel> incomeEntries,
    List<CashboxExpenseModel> expenseEntries,
    double revenue,
    double expensesTotal,
    double balance,
  })
  _sessionSummary() {
    final incomeEntries = _sessionIncomeEntries();
    final expenseEntries = _sessionExpenseEntries();
    final revenue = _sumIncome(incomeEntries);
    final expensesTotal = _sumExpenses(expenseEntries);

    return (
      incomeEntries: incomeEntries,
      expenseEntries: expenseEntries,
      revenue: revenue,
      expensesTotal: expensesTotal,
      balance: _settings.openingBalance + revenue - expensesTotal,
    );
  }

  void _rebuild() {
    if (isClosed) return;

    final sessionSummary = _sessionSummary();

    emit(
      CashboxLoaded(
        selectedDay: _selectedDay,
        settings: _settings,
        sessionIncomeEntries: sessionSummary.incomeEntries,
        sessionExpenseEntries: sessionSummary.expenseEntries,
        sessionRevenue: sessionSummary.revenue,
        sessionExpenses: sessionSummary.expensesTotal,
        sessionBalance: sessionSummary.balance,
        dailyIncomeEntries: _dailyIncomeEntries(),
        dailyExpenses: _dailyExpenses(),
        dailyClosures: _dailyClosures(),
        auditLogs: _auditLogs,
      ),
    );
  }

  Future<void> _logAuditEvent({
    required AuditEventType eventType,
    required String operationId,
    required String performedBy,
    required double amount,
    String? description,
    Map<String, dynamic>? metadata,
    required bool isValid,
    String? validationError,
  }) async {
    try {
      final auditLog = CashboxAuditLogModel(
        id: '${DateTime.now().microsecondsSinceEpoch}_$operationId',
        eventType: eventType,
        operationId: operationId,
        performedBy: performedBy,
        amount: amount,
        description: description,
        metadata: metadata,
        isValid: isValid,
        validationError: validationError,
        createdAt: DateTime.now(),
      );

      await _dataSource.logAuditEvent(auditLog);
    } catch (e) {
      // Log audit failures don't stop operations, but we track them
      // Don't emit error state for audit log failures - just silently log
    }
  }

  @override
  Future<void> close() async {
    _cancelSubscriptions();
    return super.close();
  }
}
