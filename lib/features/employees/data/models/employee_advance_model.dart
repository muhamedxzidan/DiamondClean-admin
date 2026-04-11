import 'package:cloud_firestore/cloud_firestore.dart';

class EmployeeAdvanceModel {
  final String id;
  final String employeeId;
  final String employeeName;
  final double amount;
  final String note;
  final String? createdBy;
  final DateTime createdAt;

  const EmployeeAdvanceModel({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.amount,
    required this.note,
    required this.createdAt,
    this.createdBy,
  });

  factory EmployeeAdvanceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EmployeeAdvanceModel(
      id: doc.id,
      employeeId: data['employeeId'] as String? ?? '',
      employeeName: data['employeeName'] as String? ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      note: data['note'] as String? ?? '',
      createdBy: data['createdBy'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'employeeId': employeeId,
    'employeeName': employeeName,
    'amount': amount,
    'note': note,
    'createdBy': createdBy,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}
