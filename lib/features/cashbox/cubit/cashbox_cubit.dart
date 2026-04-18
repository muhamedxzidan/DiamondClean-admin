import 'dart:async';

import 'package:bloc/bloc.dart';

import 'package:diamond_clean/core/utils/cashbox_validator.dart';

import 'cashbox_calculation_service.dart';
import '../data/datasources/cashbox_remote_data_source.dart';
import '../data/models/cashbox_audit_log_model.dart';
import '../data/models/cashbox_closure_model.dart';
import '../data/models/cashbox_expense_model.dart';
import '../data/models/cashbox_income_model.dart';
import '../data/models/cashbox_settings_model.dart';
import '../data/models/expense_category.dart';
import 'cashbox_state.dart';

part 'cashbox_cubit_actions.dart';
part 'cashbox_cubit_audit.dart';
part 'cashbox_cubit_listeners.dart';
part 'cashbox_cubit_rebuild.dart';

class CashboxCubit extends Cubit<CashboxState> {
  final CashboxRemoteDataSource _dataSource;
  final CashboxCalculationService _calculationService;
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  bool _isListening = false;
  bool _rebuildScheduled = false;

  List<CashboxIncomeModel> _incomeEntries = [];
  List<CashboxExpenseModel> _expenses = [];
  List<CashboxClosureModel> _closures = [];
  List<CashboxAuditLogModel> _auditLogs = [];
  CashboxSettingsModel _settings = CashboxSettingsModel.initial();
  DateTime _selectedDay = _todayStart();

  CashboxCubit(
    this._dataSource, {
    CashboxCalculationService calculationService =
        const CashboxCalculationService(),
  }) : _calculationService = calculationService,
       super(const CashboxInitial());

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
      _scheduleRebuild();
    }, onError: (Object error) => _emitStreamError(error));
    _subscriptions.add(subscription);
    return subscription;
  }

  void selectDay(DateTime day) {
    final normalizedDay = _calculationService.dayStart(day);
    if (_calculationService.isSameDay(_selectedDay, normalizedDay)) {
      return;
    }

    _selectedDay = normalizedDay;
    _rebuild();
  }

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

  void _scheduleRebuild() {
    if (_rebuildScheduled || isClosed) {
      return;
    }

    _rebuildScheduled = true;
    Future.microtask(() {
      _rebuildScheduled = false;
      if (!isClosed) {
        _rebuild();
      }
    });
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
    _rebuildScheduled = false;

    final subscriptions = List<StreamSubscription<dynamic>>.from(
      _subscriptions,
    );
    _subscriptions.clear();

    for (final subscription in subscriptions) {
      unawaited(subscription.cancel());
    }
  }

  Future<void> saveOpeningBalance(double openingBalance, String openedBy) {
    return _cashboxSaveOpeningBalance(this, openingBalance, openedBy);
  }

  Future<void> addExpense({
    required String title,
    required double amount,
    ExpenseCategory category = ExpenseCategory.other,
    String? createdBy,
  }) {
    return _cashboxAddExpense(
      this,
      title: title,
      amount: amount,
      category: category,
      createdBy: createdBy,
    );
  }

  Future<void> updateExpense(CashboxExpenseModel expense) {
    return _cashboxUpdateExpense(this, expense);
  }

  Future<void> deleteExpense(String expenseId) {
    return _cashboxDeleteExpense(this, expenseId);
  }

  Future<void> savePin(String? pin) {
    return _cashboxSavePin(this, pin);
  }

  Future<void> closeCashbox(String closedBy) {
    return _cashboxCloseCashbox(this, closedBy);
  }

  CashboxSessionSummary _sessionSummary() {
    return _cashboxSessionSummary(this);
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
        dailyIncomeEntries: _calculationService.dailyIncomeEntries(
          incomeEntries: _incomeEntries,
          selectedDay: _selectedDay,
        ),
        dailyExpenses: _calculationService.dailyExpenses(
          expenses: _expenses,
          selectedDay: _selectedDay,
        ),
        dailyClosures: _calculationService.dailyClosures(
          closures: _closures,
          selectedDay: _selectedDay,
        ),
        auditLogs: _auditLogs,
      ),
    );
  }

  @override
  Future<void> close() async {
    _cancelSubscriptions();
    return super.close();
  }
}
