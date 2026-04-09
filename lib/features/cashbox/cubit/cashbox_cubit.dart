import 'dart:async';

import 'package:bloc/bloc.dart';

import '../data/datasources/cashbox_remote_data_source.dart';
import '../data/models/cashbox_closure_model.dart';
import '../data/models/cashbox_expense_model.dart';
import '../data/models/cashbox_income_model.dart';
import '../data/models/cashbox_settings_model.dart';
import 'cashbox_state.dart';

class CashboxCubit extends Cubit<CashboxState> {
  final CashboxRemoteDataSource _dataSource;
  final List<StreamSubscription<dynamic>> _subscriptions = [];

  List<CashboxIncomeModel> _incomeEntries = [];
  List<CashboxExpenseModel> _expenses = [];
  List<CashboxClosureModel> _closures = [];
  CashboxSettingsModel _settings = CashboxSettingsModel.initial();
  DateTime _selectedDay = _todayStart();

  CashboxCubit(this._dataSource) : super(const CashboxInitial());

  static DateTime _todayStart() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  void listen() {
    emit(const CashboxLoading());
    _cancelSubscriptions();

    _subscribeToStream(_dataSource.watchSettings(), _updateSettings);
    _subscribeToStream(_dataSource.watchIncomeEntries(), _updateIncomeEntries);
    _subscribeToStream(_dataSource.watchExpenses(), _updateExpenses);
    _subscribeToStream(_dataSource.watchClosures(), _updateClosures);
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
    await _performMutation(() {
      return _dataSource.saveOpeningBalance(
        openingBalance: openingBalance,
        openedBy: openedBy,
      );
    });
  }

  Future<void> addExpense({
    required String title,
    required double amount,
    String? createdBy,
  }) async {
    await _performMutation(() async {
      final now = DateTime.now();
      final expense = CashboxExpenseModel(
        id: now.microsecondsSinceEpoch.toString(),
        title: title,
        amount: amount,
        createdBy: createdBy,
        createdAt: now,
      );
      await _dataSource.addExpense(expense);
    });
  }

  Future<void> updateExpense(CashboxExpenseModel expense) async {
    await _performMutation(() {
      return _dataSource.updateExpense(expense);
    });
  }

  Future<void> deleteExpense(String expenseId) async {
    await _performMutation(() {
      return _dataSource.deleteExpense(expenseId);
    });
  }

  Future<void> savePin(String? pin) async {
    await _performMutation(() {
      return _dataSource.savePin(pin);
    });
  }

  Future<void> closeCashbox(String closedBy) async {
    await _performMutation(() async {
      final sessionSummary = _sessionSummary();
      await _dataSource.closeCashbox(
        closedBy: closedBy,
        openingBalance: _settings.openingBalance,
        totalRevenue: sessionSummary.revenue,
        totalExpenses: sessionSummary.expensesTotal,
        closingBalance: sessionSummary.balance,
        ordersCount: sessionSummary.incomeEntries.length,
        expenses: sessionSummary.expenseEntries,
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
    _rebuild();
  }

  void _cancelSubscriptions() {
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
      ),
    );
  }

  @override
  Future<void> close() async {
    _cancelSubscriptions();
    return super.close();
  }
}
