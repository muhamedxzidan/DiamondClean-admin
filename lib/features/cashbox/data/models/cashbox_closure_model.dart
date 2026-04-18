import 'package:cloud_firestore/cloud_firestore.dart';

class CashboxClosureModel {
  final String id;
  final String closedBy;
  final double openingBalance;
  final double totalRevenue;
  final double totalExpenses;
  final double closingBalance;
  final int ordersCount;
  final List<ClosureExpenseEntry> expenses;
  final DateTime closedAt;

  const CashboxClosureModel({
    required this.id,
    required this.closedBy,
    required this.openingBalance,
    required this.totalRevenue,
    required this.totalExpenses,
    required this.closingBalance,
    required this.ordersCount,
    required this.expenses,
    required this.closedAt,
  });

  factory CashboxClosureModel.fromMap(String id, Map<String, dynamic> data) {
    final expensesList = (data['expenses'] as List<dynamic>?)
            ?.map((e) => ClosureExpenseEntry.fromMap(e as Map<String, dynamic>))
            .toList() ??
        [];

    return CashboxClosureModel(
      id: id,
      closedBy: data['closedBy'] as String? ?? '',
      openingBalance: (data['openingBalance'] as num?)?.toDouble() ?? 0,
      totalRevenue: (data['totalRevenue'] as num?)?.toDouble() ?? 0,
      totalExpenses: (data['totalExpenses'] as num?)?.toDouble() ?? 0,
      closingBalance: (data['closingBalance'] as num?)?.toDouble() ?? 0,
      ordersCount: (data['ordersCount'] as num?)?.toInt() ?? 0,
      expenses: expensesList,
      closedAt: data['closedAt'] != null
          ? (data['closedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  factory CashboxClosureModel.fromFirestore(DocumentSnapshot doc) =>
      CashboxClosureModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);

  Map<String, dynamic> toFirestore() => {
    'closedBy': closedBy,
    'openingBalance': openingBalance,
    'totalRevenue': totalRevenue,
    'totalExpenses': totalExpenses,
    'closingBalance': closingBalance,
    'ordersCount': ordersCount,
    'expenses': expenses.map((e) => e.toMap()).toList(),
    'closedAt': Timestamp.fromDate(closedAt),
  };
}

class ClosureExpenseEntry {
  final String title;
  final double amount;

  const ClosureExpenseEntry({required this.title, required this.amount});

  factory ClosureExpenseEntry.fromMap(Map<String, dynamic> map) {
    return ClosureExpenseEntry(
      title: map['title'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {'title': title, 'amount': amount};
}
