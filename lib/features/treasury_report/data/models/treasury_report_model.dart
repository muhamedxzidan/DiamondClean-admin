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
  });

  double get totalIncome => completedOrdersRevenue + deliveryFeesRevenue;

  double get totalExpenses =>
      expensesByCategory.values.fold(0, (sum, amount) => sum + amount);

  double get totalSalaries =>
      expensesByCategory[ExpenseCategory.salary] ?? 0;

  double get totalNonSalaryExpenses => totalExpenses - totalSalaries;

  double get netProfit => totalIncome - totalExpenses;

  double get closingCashBalance =>
      openingBalance + cashRevenue - totalExpenses;
}
