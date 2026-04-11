import 'dart:async';

import 'package:diamond_clean/features/cashbox/data/models/cashbox_audit_log_model.dart';
import 'package:diamond_clean/features/cashbox/data/models/cashbox_expense_model.dart';
import 'package:diamond_clean/features/cashbox/data/models/cashbox_income_model.dart';
import 'package:diamond_clean/features/treasury_report/cubit/treasury_report_cubit.dart';
import 'package:diamond_clean/features/treasury_report/cubit/treasury_report_state.dart';
import 'package:diamond_clean/features/treasury_report/data/datasources/treasury_report_remote_data_source.dart';
import 'package:diamond_clean/features/treasury_report/data/models/treasury_report_model.dart';
import 'package:diamond_clean/features/orders/data/models/order_model.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeTreasuryReportRemoteDataSource
    implements TreasuryReportRemoteDataSource {
  final StreamController<TreasuryReportModel> controller =
      StreamController<TreasuryReportModel>.broadcast();

  @override
  Stream<TreasuryReportModel> watchReport(
    DateTime startDate,
    DateTime endDate,
  ) {
    return controller.stream;
  }

  @override
  Future<TreasuryReportModel> generateReport(
    DateTime startDate,
    DateTime endDate,
  ) async {
    throw UnimplementedError('Not used in this test');
  }

  @override
  Future<List<CashboxExpenseModel>> getExpensesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    return const <CashboxExpenseModel>[];
  }

  @override
  Future<List<CashboxIncomeModel>> getIncomeByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    return const <CashboxIncomeModel>[];
  }

  @override
  Future<List<OrderModel>> getOrdersByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    return const <OrderModel>[];
  }

  @override
  Future<List<CashboxAuditLogModel>> getAuditLogsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    return const <CashboxAuditLogModel>[];
  }

  Future<void> dispose() => controller.close();
}

void main() {
  test(
    'TreasuryReportCubit streams report updates without manual refresh',
    () async {
      final dataSource = _FakeTreasuryReportRemoteDataSource();
      final cubit = TreasuryReportCubit(dataSource);

      final states = <TreasuryReportState>[];
      final subscription = cubit.stream.listen(states.add);

      final from = DateTime(2026, 4, 1);
      final to = DateTime(2026, 4, 11);

      await cubit.generateReport(from, to);

      dataSource.controller.add(
        TreasuryReportModel(
          startDate: from,
          endDate: to,
          totalOrdersCount: 1,
          completedOrdersCount: 1,
          pendingOrdersCount: 0,
          confirmedOrdersCount: 0,
          cancelledOrdersCount: 0,
          completedOrdersRevenue: 100,
          deliveryFeesRevenue: 10,
          cashRevenue: 100,
          electronicRevenue: 0,
          expensesByCategory: const {},
          openingBalance: 50,
          remainingOrdersValue: 0,
        ),
      );

      await Future<void>.delayed(Duration.zero);

      dataSource.controller.add(
        TreasuryReportModel(
          startDate: from,
          endDate: to,
          totalOrdersCount: 2,
          completedOrdersCount: 2,
          pendingOrdersCount: 0,
          confirmedOrdersCount: 0,
          cancelledOrdersCount: 0,
          completedOrdersRevenue: 300,
          deliveryFeesRevenue: 20,
          cashRevenue: 200,
          electronicRevenue: 100,
          expensesByCategory: const {},
          openingBalance: 50,
          remainingOrdersValue: 0,
        ),
      );

      await Future<void>.delayed(Duration.zero);

      expect(states.first, isA<TreasuryReportLoading>());
      final loadedStates = states.whereType<TreasuryReportLoaded>().toList();
      expect(loadedStates, hasLength(2));
      expect(loadedStates.first.report.totalOrdersCount, 1);
      expect(loadedStates.last.report.totalOrdersCount, 2);
      expect(loadedStates.last.report.completedOrdersRevenue, 300);

      await subscription.cancel();
      await cubit.close();
      await dataSource.dispose();
    },
  );
}
