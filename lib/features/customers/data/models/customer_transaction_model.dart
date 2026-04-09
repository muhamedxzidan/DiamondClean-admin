import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerTransactionModel {
  final String orderId;
  final double orderTotal;
  final double deliveryFee;
  final int itemCount;
  final String status;
  final DateTime createdAt;

  const CustomerTransactionModel({
    required this.orderId,
    required this.orderTotal,
    required this.deliveryFee,
    required this.itemCount,
    required this.status,
    required this.createdAt,
  });

  factory CustomerTransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CustomerTransactionModel(
      orderId: doc.id,
      orderTotal: (data['orderTotal'] as num?)?.toDouble() ?? 0,
      deliveryFee: (data['deliveryFee'] as num?)?.toDouble() ?? 0,
      itemCount: (data['itemCount'] as num?)?.toInt() ?? 0,
      status: data['status'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'orderTotal': orderTotal,
      'deliveryFee': deliveryFee,
      'itemCount': itemCount,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
