import 'package:cloud_firestore/cloud_firestore.dart';

class CashboxIncomeModel {
  final String orderId;
  final double orderTotal;
  final double deliveryFee;
  final String customerName;
  final String customerPhone;
  final String? paymentMethod;
  final bool includeInCashbox;
  final double remainingAmount;
  final DateTime createdAt;

  const CashboxIncomeModel({
    required this.orderId,
    required this.orderTotal,
    required this.deliveryFee,
    required this.customerName,
    required this.customerPhone,
    this.paymentMethod,
    required this.includeInCashbox,
    this.remainingAmount = 0,
    required this.createdAt,
  });

  factory CashboxIncomeModel.fromMap(String id, Map<String, dynamic> data) {
    return CashboxIncomeModel(
      orderId: id,
      orderTotal: (data['orderTotal'] as num?)?.toDouble() ?? 0,
      deliveryFee: (data['deliveryFee'] as num?)?.toDouble() ?? 0,
      customerName: data['customerName'] as String? ?? '',
      customerPhone: data['customerPhone'] as String? ?? '',
      paymentMethod: data['paymentMethod'] as String?,
      includeInCashbox: data['includeInCashbox'] as bool? ?? true,
      remainingAmount: (data['remainingAmount'] as num?)?.toDouble() ?? 0,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  factory CashboxIncomeModel.fromFirestore(DocumentSnapshot doc) =>
      CashboxIncomeModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);

  Map<String, dynamic> toFirestore() => {
    'orderTotal': orderTotal,
    'deliveryFee': deliveryFee,
    'customerName': customerName,
    'customerPhone': customerPhone,
    if (paymentMethod != null) 'paymentMethod': paymentMethod,
    'includeInCashbox': includeInCashbox,
    'remainingAmount': remainingAmount,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}
