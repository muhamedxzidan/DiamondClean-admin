import 'package:diamond_clean/features/orders/data/models/order_item_model.dart';

/// Pure calculation logic for order pricing — no UI dependencies
class OrderPricingCalculator {
  static double? calculateTotal(
    List<OrderItemModel> items,
    double? deliveryFee,
  ) {
    double total = 0;
    for (final item in items) {
      for (final unit in item.units) {
        final t = unit.total;
        if (t == null) return null;
        total += t;
      }
    }
    return deliveryFee != null ? total + deliveryFee : null;
  }
}
