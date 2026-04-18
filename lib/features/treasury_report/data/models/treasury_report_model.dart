import 'package:diamond_clean/features/cashbox/data/models/expense_category.dart';

class TreasuryReportModel {
  final DateTime startDate;
  final DateTime endDate;

  // Order statistics
  final int totalOrdersCount;
  final int completedOrdersCount;
  final int pendingOrdersCount;
  final int confirmedOrdersCount;
  final int cancelledOrdersCount;

  // Revenue breakdown
  final double completedOrdersRevenue;
  final double deliveryFeesRevenue;
  final double cashRevenue;
  final double electronicRevenue;

  // Expenses breakdown by category
  final Map<ExpenseCategory, double> expensesByCategory;

  // Balance
  final double openingBalance;
  final double remainingOrdersValue;
  final double totalWithdrawn;

  const TreasuryReportModel({
    required this.startDate,
    required this.endDate,
    required this.totalOrdersCount,
    required this.completedOrdersCount,
    required this.pendingOrdersCount,
    required this.confirmedOrdersCount,
    required this.cancelledOrdersCount,
    required this.completedOrdersRevenue,
    required this.deliveryFeesRevenue,
    required this.cashRevenue,
    required this.electronicRevenue,
    required this.expensesByCategory,
    required this.openingBalance,
    required this.remainingOrdersValue,
    this.totalWithdrawn = 0,
  });

  double get totalIncome => cashRevenue + electronicRevenue;

  double get explicitWithdrawals =>
      expensesByCategory[ExpenseCategory.withdrawal] ?? 0;

  double get totalExpenses =>
      expensesByCategory.entries
          .where((e) => e.key != ExpenseCategory.withdrawal)
          .fold(0.0, (sum, e) => sum + e.value);

  double get totalSalaries =>
      expensesByCategory[ExpenseCategory.salary] ?? 0;

  double get totalNonSalaryExpenses => totalExpenses - totalSalaries;

  double get netProfit => totalIncome - totalExpenses;

  double get closingCashBalance =>
      openingBalance + cashRevenue - totalExpenses - explicitWithdrawals - totalWithdrawn;
}
