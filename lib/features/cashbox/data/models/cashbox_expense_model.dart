import 'package:cloud_firestore/cloud_firestore.dart';

class CashboxExpenseModel {
  final String id;
  final String title;
  final double amount;
  final String? createdBy;
  final DateTime createdAt;

  const CashboxExpenseModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.createdAt,
    this.createdBy,
  });

  factory CashboxExpenseModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CashboxExpenseModel(
      id: doc.id,
      title: data['title'] as String? ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      createdBy: data['createdBy'] as String?,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'title': title,
    'amount': amount,
    'createdBy': createdBy,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  CashboxExpenseModel copyWith({
    String? title,
    double? amount,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return CashboxExpenseModel(
      id: id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
