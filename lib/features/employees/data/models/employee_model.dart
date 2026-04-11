import 'package:cloud_firestore/cloud_firestore.dart';

import 'salary_cycle.dart';

class EmployeeModel {
  final String id;
  final String name;
  final String phone;
  final String? nationalId;
  final String? city;
  final SalaryCycle salaryCycle;
  final double salaryAmount;
  final DateTime cycleStartAt;
  final double currentCycleAdvancesTotal;
  final double currentCyclePaidTotal;
  final int totalAdvancesCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const EmployeeModel({
    required this.id,
    required this.name,
    required this.phone,
    this.nationalId,
    this.city,
    required this.salaryCycle,
    required this.salaryAmount,
    required this.cycleStartAt,
    required this.currentCycleAdvancesTotal,
    this.currentCyclePaidTotal = 0,
    required this.totalAdvancesCount,
    required this.createdAt,
    required this.updatedAt,
  });

  double get remainingSalary {
    final remaining =
        salaryAmount - currentCycleAdvancesTotal - currentCyclePaidTotal;
    return remaining < 0 ? 0 : remaining;
  }

  factory EmployeeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EmployeeModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      nationalId: data['nationalId'] as String?,
      city: data['city'] as String?,
      salaryCycle: SalaryCycleX.fromValue(
        data['salaryCycle'] as String? ?? SalaryCycle.monthly.value,
      ),
      salaryAmount: (data['salaryAmount'] as num?)?.toDouble() ?? 0,
      cycleStartAt:
          (data['cycleStartAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      currentCycleAdvancesTotal:
          (data['currentCycleAdvancesTotal'] as num?)?.toDouble() ?? 0,
      currentCyclePaidTotal:
          (data['currentCyclePaidTotal'] as num?)?.toDouble() ?? 0,
      totalAdvancesCount: (data['totalAdvancesCount'] as int?) ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'name': name,
    'phone': phone,
    'nationalId': nationalId,
    'city': city,
    'salaryCycle': salaryCycle.value,
    'salaryAmount': salaryAmount,
    'cycleStartAt': Timestamp.fromDate(cycleStartAt),
    'currentCycleAdvancesTotal': currentCycleAdvancesTotal,
    'currentCyclePaidTotal': currentCyclePaidTotal,
    'totalAdvancesCount': totalAdvancesCount,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };

  EmployeeModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? nationalId,
    String? city,
    SalaryCycle? salaryCycle,
    double? salaryAmount,
    DateTime? cycleStartAt,
    double? currentCycleAdvancesTotal,
    double? currentCyclePaidTotal,
    int? totalAdvancesCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EmployeeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      nationalId: nationalId ?? this.nationalId,
      city: city ?? this.city,
      salaryCycle: salaryCycle ?? this.salaryCycle,
      salaryAmount: salaryAmount ?? this.salaryAmount,
      cycleStartAt: cycleStartAt ?? this.cycleStartAt,
      currentCycleAdvancesTotal:
          currentCycleAdvancesTotal ?? this.currentCycleAdvancesTotal,
      currentCyclePaidTotal:
          currentCyclePaidTotal ?? this.currentCyclePaidTotal,
      totalAdvancesCount: totalAdvancesCount ?? this.totalAdvancesCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
