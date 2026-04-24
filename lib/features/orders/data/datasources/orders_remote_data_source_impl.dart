import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diamond_clean/core/constants/firebase_constants.dart';

import '../models/item_unit_model.dart';
import '../models/order_item_model.dart';
import '../models/order_model.dart';
import 'orders_remote_data_source.dart';

class OrdersRemoteDataSourceImpl implements OrdersRemoteDataSource {
  final FirebaseFirestore _firestore;

  OrdersRemoteDataSourceImpl(this._firestore);

  CollectionReference get _collection =>
      _firestore.collection(FirebaseConstants.ordersCollection);

  @override
  Stream<List<OrderModel>> watchOrders() => _collection
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map(OrderModel.fromFirestore).toList());

  @override
  Future<void> updateItemPricing(
    String orderId,
    int itemIndex,
    double width,
    double height,
    double unitPrice,
  ) async {
    final doc = await _collection.doc(orderId).get();
    final data = doc.data() as Map<String, dynamic>;
    final rawItems = OrderModel.parseItems(data['items']);

    if (rawItems.isEmpty || itemIndex >= rawItems.length) {
      throw Exception('الصنف غير موجود');
    }

    final updatedItems = List<OrderItemModel>.from(rawItems);
    final item = updatedItems[itemIndex];

    final updatedUnits = List.generate(
      item.quantity,
      (_) => ItemUnitModel(width: width, height: height, unitPrice: unitPrice),
    );
    updatedItems[itemIndex] = item.copyWith(units: updatedUnits);

    await _collection.doc(orderId).update({
      'items': updatedItems.map((e) => e.toMap()).toList(),
    });
  }

  @override
  Future<void> updateOrderItems(
    String orderId,
    List<OrderItemModel> items, {
    required double deliveryFee,
  }) async {
    await _collection.doc(orderId).update({
      'items': items.map((e) => e.toMap()).toList(),
      'deliveryFee': deliveryFee,
    });
  }

  @override
  Future<void> updateStatus(
    String id,
    OrderStatus status, {
    String? paymentMethod,
    double? paidAmount,
    bool? isFullyPaid,
  }) => _collection.doc(id).update({
    'status': status.name,
    'paymentMethod': paymentMethod,
    // ignore: use_null_aware_elements
    if (paidAmount != null) 'paidAmount': paidAmount,
    // ignore: use_null_aware_elements
    if (isFullyPaid != null) 'isFullyPaid': isFullyPaid,
  });

  @override
  Future<void> recordRemainingPayment(
    String orderId, {
    required double paidAmount,
    required String paymentMethod,
  }) async {
    final doc = await _collection.doc(orderId).get();
    final data = doc.data() as Map<String, dynamic>;
    final currentPaid = (data['paidAmount'] as num?)?.toDouble() ?? 0;
    final newTotal = currentPaid + paidAmount;

    final items = OrderModel.parseItems(data['items']);
    final itemsTotal = items.fold<double>(
      0,
      (acc, item) => acc + (item.itemTotal ?? 0),
    );
    final deliveryFee = (data['deliveryFee'] as num?)?.toDouble() ?? 0;
    final totalPrice = itemsTotal + deliveryFee;

    await _collection.doc(orderId).update({
      'paidAmount': newTotal,
      'isFullyPaid': newTotal >= totalPrice,
      'paymentMethod': paymentMethod,
    });
  }

  @override
  Future<void> assignInvoiceNumber(String orderId) async {
    final counterRef = _firestore
        .collection(FirebaseConstants.countersCollection)
        .doc('invoiceNumber');
    final orderRef = _collection.doc(orderId);

    await _firestore.runTransaction((tx) async {
      final counterSnap = await tx.get(counterRef);
      final nextNumber =
          ((counterSnap.data()?['count'] as num?)?.toInt() ?? 0) + 1;
      tx.set(counterRef, {'count': nextNumber}, SetOptions(merge: true));
      tx.update(orderRef, {'invoiceNumber': nextNumber});
    });
  }
}
