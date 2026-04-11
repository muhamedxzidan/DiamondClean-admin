import 'package:diamond_clean/features/cashbox/data/models/cashbox_audit_log_model.dart';
import 'package:diamond_clean/features/cashbox/data/models/cashbox_expense_model.dart';
import 'package:diamond_clean/features/cashbox/data/models/cashbox_income_model.dart';
import 'package:diamond_clean/features/orders/data/models/order_model.dart';

import '../models/treasury_report_model.dart';

abstract class TreasuryReportRemoteDataSource {
  Stream<TreasuryReportModel> watchReport(DateTime startDate, DateTime endDate);

  Future<List<OrderModel>> getOrdersByDateRange(
    DateTime startDate,
    DateTime endDate,
  );
  Future<List<CashboxExpenseModel>> getExpensesByDateRange(
    DateTime startDate,
    DateTime endDate,
  );
  Future<List<CashboxIncomeModel>> getIncomeByDateRange(
    DateTime startDate,
    DateTime endDate,
  );
  Future<TreasuryReportModel> generateReport(
    DateTime startDate,
    DateTime endDate,
  );

  /// Get audit logs for a date range.
  Future<List<CashboxAuditLogModel>> getAuditLogsByDateRange(
    DateTime startDate,
    DateTime endDate,
  );
}
