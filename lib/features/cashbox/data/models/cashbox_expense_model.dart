import 'package:cloud_firestore/cloud_firestore.dart';

import 'expense_category.dart';

class CashboxExpenseModel {
  final String id;
  final String title;
  final double amount;
  final ExpenseCategory category;
  final String? createdBy;
  final DateTime createdAt;

  const CashboxExpenseModel({
    required this.id,
    required this.title,
    required this.amount,
    this.category = ExpenseCategory.other,
    required this.createdAt,
    this.createdBy,
  });

  factory CashboxExpenseModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CashboxExpenseModel(
      id: doc.id,
      title: data['title'] as String? ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      category: ExpenseCategory.fromValue(data['category'] as String?),
      createdBy: data['createdBy'] as String?,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'title': title,
    'amount': amount,
    'category': category.value,
    'createdBy': createdBy,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  CashboxExpenseModel copyWith({
    String? title,
    double? amount,
    ExpenseCategory? category,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return CashboxExpenseModel(
      id: id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
