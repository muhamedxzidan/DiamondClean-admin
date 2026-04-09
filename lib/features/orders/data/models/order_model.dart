import 'package:cloud_firestore/cloud_firestore.dart';

import 'order_item_model.dart';

enum OrderStatus { pending, confirmed, completed, cancelled }

enum OrderPaymentMethod { cash, vodafoneCash, instapay }

class OrderModel {
  final String id;
  final String customerCode;
  final String customerName;
  final String customerPhone;
  final String address;
  final String categoryName;
  final String carNumber;
  final String driverName;
  final List<OrderItemModel> items;
  final OrderStatus status;
  final String? notes;
  final double deliveryFee;
  final bool includeInCashbox;
  final OrderPaymentMethod? paymentMethod;
  final DateTime createdAt;

  const OrderModel({
    required this.id,
    required this.customerCode,
    required this.customerName,
    required this.customerPhone,
    required this.address,
    required this.categoryName,
    required this.carNumber,
    required this.driverName,
    required this.items,
    required this.status,
    this.notes,
    this.deliveryFee = 0,
    this.includeInCashbox = true,
    this.paymentMethod,
    required this.createdAt,
  });

  double? get totalPrice {
    if (items.isEmpty && deliveryFee <= 0) return null;
    final totals = items.map((e) => e.itemTotal);
    if (totals.any((t) => t == null)) return null;
    return totals.fold<double>(0, (acc, t) => acc + t!) + deliveryFee;
  }

  bool get allItemsPriced =>
      items.isNotEmpty && items.every((e) => e.hasPricing);

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final categoryName = data['categoryName'] as String? ?? '';

    final items = parseItems(data['items']);

    return OrderModel(
      id: doc.id,
      customerCode: data['customerCode'] as String? ?? '',
      customerName: data['customerName'] as String? ?? '',
      customerPhone:
          (data['customerPhone'] ?? data['customerPhoneNumber']) as String? ??
          '',
      address: (data['customerAddress'] ?? data['address']) as String? ?? '',
      categoryName: categoryName,
      carNumber: data['carNumber'] as String? ?? '',
      driverName: data['driverName'] as String? ?? '',
      items: items,
      status: _statusFromString(data['status'] as String?),
      notes: data['notes'] as String?,
      deliveryFee: (data['deliveryFee'] as num?)?.toDouble() ?? 0,
      includeInCashbox: data['includeInCashbox'] as bool? ?? true,
      paymentMethod: _paymentMethodFromString(data['paymentMethod'] as String?),
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'customerCode': customerCode,
    'customerName': customerName,
    'customerPhone': customerPhone,
    'address': address,
    'categoryName': categoryName,
    'carNumber': carNumber,
    'driverName': driverName,
    'items': items.map((e) => e.toMap()).toList(),
    'status': status.name,
    if (notes != null) 'notes': notes,
    'deliveryFee': deliveryFee,
    'includeInCashbox': includeInCashbox,
    if (paymentMethod != null) 'paymentMethod': paymentMethod!.name,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  OrderModel copyWith({
    List<OrderItemModel>? items,
    OrderStatus? status,
    double? deliveryFee,
    bool? includeInCashbox,
    OrderPaymentMethod? paymentMethod,
  }) => OrderModel(
    id: id,
    customerCode: customerCode,
    customerName: customerName,
    customerPhone: customerPhone,
    address: address,
    categoryName: categoryName,
    carNumber: carNumber,
    driverName: driverName,
    items: items ?? this.items,
    status: status ?? this.status,
    deliveryFee: deliveryFee ?? this.deliveryFee,
    includeInCashbox: includeInCashbox ?? this.includeInCashbox,
    paymentMethod: paymentMethod ?? this.paymentMethod,
    createdAt: createdAt,
    notes: notes,
  );

  static List<OrderItemModel> parseItems(dynamic raw) {
    if (raw == null) return [];
    if (raw is List) {
      return raw
          .cast<Map<String, dynamic>>()
          .map(OrderItemModel.fromMap)
          .toList();
    }
    if (raw is Map) {
      final map = Map<String, dynamic>.from(raw);
      final sortedKeys = map.keys.toList()..sort();

      // Check if values are maps (structured items) or primitives (name→quantity)
      if (sortedKeys.isNotEmpty && map[sortedKeys.first] is Map) {
        return sortedKeys
            .map(
              (k) => OrderItemModel.fromMap(Map<String, dynamic>.from(map[k])),
            )
            .toList();
      }

      // Handle {itemName: quantity} format from Firestore
      return sortedKeys
          .map(
            (k) => OrderItemModel(
              name: k,
              quantity: (map[k] as num?)?.toInt() ?? 1,
            ),
          )
          .toList();
    }
    return [];
  }

  static OrderStatus _statusFromString(String? value) => switch (value) {
    'confirmed' => OrderStatus.confirmed,
    'completed' => OrderStatus.completed,
    'cancelled' => OrderStatus.cancelled,
    _ => OrderStatus.pending,
  };

  static OrderPaymentMethod? _paymentMethodFromString(String? value) {
    return switch (value) {
      'cash' => OrderPaymentMethod.cash,
      'vodafoneCash' => OrderPaymentMethod.vodafoneCash,
      'instapay' => OrderPaymentMethod.instapay,
      _ => null,
    };
  }
}
