import 'dart:async';

import 'package:diamond_clean/features/cashbox/cubit/cashbox_cubit.dart';
import 'package:diamond_clean/features/cashbox/cubit/cashbox_state.dart';
import 'package:diamond_clean/features/cashbox/data/datasources/cashbox_remote_data_source.dart';
import 'package:diamond_clean/features/cashbox/data/models/cashbox_audit_log_model.dart';
import 'package:diamond_clean/features/cashbox/data/models/cashbox_closure_model.dart';
import 'package:diamond_clean/features/cashbox/data/models/cashbox_expense_model.dart';
import 'package:diamond_clean/features/cashbox/data/models/cashbox_income_model.dart';
import 'package:diamond_clean/features/cashbox/data/models/cashbox_settings_model.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeCashboxRemoteDataSource implements CashboxRemoteDataSource {
  final StreamController<CashboxSettingsModel?> settingsController =
      StreamController<CashboxSettingsModel?>.broadcast();
  final StreamController<List<CashboxIncomeModel>> incomeController =
      StreamController<List<CashboxIncomeModel>>.broadcast();
  final StreamController<List<CashboxExpenseModel>> expenseController =
      StreamController<List<CashboxExpenseModel>>.broadcast();
  final StreamController<List<CashboxClosureModel>> closureController =
      StreamController<List<CashboxClosureModel>>.broadcast();
  final StreamController<List<CashboxAuditLogModel>> auditController =
      StreamController<List<CashboxAuditLogModel>>.broadcast();

  @override
  Stream<List<CashboxAuditLogModel>> watchAuditLogs() => auditController.stream;

  @override
  Stream<List<CashboxClosureModel>> watchClosures() => closureController.stream;

  @override
  Stream<List<CashboxExpenseModel>> watchExpenses() => expenseController.stream;

  @override
  Stream<List<CashboxIncomeModel>> watchIncomeEntries() =>
      incomeController.stream;

  @override
  Stream<CashboxSettingsModel?> watchSettings() => settingsController.stream;

  @override
  Future<void> addExpense(CashboxExpenseModel expense) =>
      throw UnimplementedError();

  @override
  Future<void> closeCashbox({
    required String closedBy,
    required double openingBalance,
    required double totalRevenue,
    required double totalExpenses,
    required double closingBalance,
    required int ordersCount,
    required List<CashboxExpenseModel> expenses,
  }) => throw UnimplementedError();

  @override
  Future<void> deleteExpense(String expenseId) => throw UnimplementedError();

  @override
  Future<String?> getOwnerPin() => throw UnimplementedError();

  @override
  Future<void> logAuditEvent(CashboxAuditLogModel event) =>
      throw UnimplementedError();

  @override
  Future<void> recordOrderIncome(CashboxIncomeModel income) =>
      throw UnimplementedError();

  @override
  Future<void> saveOpeningBalance({
    required double openingBalance,
    required String openedBy,
  }) => throw UnimplementedError();

  @override
  Future<void> savePin(String? pin) => throw UnimplementedError();

  @override
  Future<void> updateExpense(CashboxExpenseModel expense) =>
      throw UnimplementedError();

  Future<void> dispose() async {
    await settingsController.close();
    await incomeController.close();
    await expenseController.close();
    await closureController.close();
    await auditController.close();
  }
}

void main() {
  test(
    'CashboxCubit coalesces rapid stream bursts into one rebuild per event loop',
    () async {
      final dataSource = _FakeCashboxRemoteDataSource();
      final cubit = CashboxCubit(dataSource);
      final states = <CashboxState>[];
      final subscription = cubit.stream.listen(states.add);

      cubit.listen();

      dataSource.settingsController.add(CashboxSettingsModel.initial());
      dataSource.incomeController.add(const <CashboxIncomeModel>[]);
      dataSource.expenseController.add(const <CashboxExpenseModel>[]);
      dataSource.closureController.add(const <CashboxClosureModel>[]);
      dataSource.auditController.add(const <CashboxAuditLogModel>[]);

      await Future<void>.delayed(Duration.zero);

      final loadedStatesAfterFirstBurst = states
          .whereType<CashboxLoaded>()
          .length;
      expect(loadedStatesAfterFirstBurst, 1);

      dataSource.settingsController.add(CashboxSettingsModel.initial());
      dataSource.incomeController.add(const <CashboxIncomeModel>[]);
      dataSource.expenseController.add(const <CashboxExpenseModel>[]);
      dataSource.closureController.add(const <CashboxClosureModel>[]);
      dataSource.auditController.add(const <CashboxAuditLogModel>[]);

      await Future<void>.delayed(Duration.zero);

      final loadedStatesAfterSecondBurst = states
          .whereType<CashboxLoaded>()
          .length;
      expect(loadedStatesAfterSecondBurst, 2);

      await subscription.cancel();
      await cubit.close();
      await dataSource.dispose();
    },
  );
}
