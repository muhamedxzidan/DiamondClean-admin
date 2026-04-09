import '../models/order_item_model.dart';
import '../models/order_model.dart';

abstract class OrdersRemoteDataSource {
  Stream<List<OrderModel>> watchOrders();
  Future<void> updateItemPricing(
    String orderId,
    int itemIndex,
    double width,
    double height,
    double unitPrice,
  );
  Future<void> updateOrderItems(
    String orderId,
    List<OrderItemModel> items, {
    required double deliveryFee,
  });
  Future<void> updateStatus(
    String id,
    OrderStatus status, {
    String? paymentMethod,
  });
}
