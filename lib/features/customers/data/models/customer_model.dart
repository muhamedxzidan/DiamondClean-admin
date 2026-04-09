import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerModel {
  final String id;
  final String code;
  final String name;
  final String phone;
  final String address;
  final int orderCount;
  final double totalSpent;
  final double lastOrderTotal;
  final DateTime lastOrderAt;
  final DateTime createdAt;

  const CustomerModel({
    required this.id,
    required this.code,
    required this.name,
    required this.phone,
    required this.address,
    this.orderCount = 0,
    this.totalSpent = 0,
    this.lastOrderTotal = 0,
    DateTime? lastOrderAt,
    required this.createdAt,
  }) : lastOrderAt = lastOrderAt ?? createdAt;

  factory CustomerModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CustomerModel(
      id: doc.id,
      code: data['code'] as String? ?? '',
      name: data['name'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      address: data['address'] as String? ?? '',
      orderCount: (data['orderCount'] as num?)?.toInt() ?? 0,
      totalSpent: (data['totalSpent'] as num?)?.toDouble() ?? 0,
      lastOrderTotal: (data['lastOrderTotal'] as num?)?.toDouble() ?? 0,
      lastOrderAt:
          (data['lastOrderAt'] as Timestamp?)?.toDate() ??
          (data['createdAt'] as Timestamp?)?.toDate() ??
          DateTime.now(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'code': code,
      'name': name,
      'phone': phone,
      'address': address,
      'orderCount': orderCount,
      'totalSpent': totalSpent,
      'lastOrderTotal': lastOrderTotal,
      'lastOrderAt': Timestamp.fromDate(lastOrderAt),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  CustomerModel copyWith({
    String? id,
    String? code,
    String? name,
    String? phone,
    String? address,
    int? orderCount,
    double? totalSpent,
    double? lastOrderTotal,
    DateTime? lastOrderAt,
    DateTime? createdAt,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      orderCount: orderCount ?? this.orderCount,
      totalSpent: totalSpent ?? this.totalSpent,
      lastOrderTotal: lastOrderTotal ?? this.lastOrderTotal,
      lastOrderAt: lastOrderAt ?? this.lastOrderAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
