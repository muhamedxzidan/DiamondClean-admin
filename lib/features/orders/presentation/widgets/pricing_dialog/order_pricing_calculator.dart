import 'package:diamond_clean/features/orders/data/models/item_unit_model.dart';
import 'package:diamond_clean/features/orders/data/models/order_item_model.dart';

import 'unit_controllers.dart';

/// Pure calculation logic for order pricing — no UI dependencies
class OrderPricingCalculator {
  static List<OrderItemModel> buildItems(
    List<OrderItemModel> originalItems,
    List<List<UnitControllers>> controllers,
  ) {
    final items = <OrderItemModel>[];
    for (var i = 0; i < originalItems.length; i++) {
      final original = originalItems[i];
      final units = <ItemUnitModel>[];
      for (var u = 0; u < original.quantity; u++) {
        final c = controllers[i][u];
        final width = double.tryParse(c.width.text.trim());
        final height = double.tryParse(c.height.text.trim());
        final price = double.tryParse(c.price.text.trim());
        units.add(
          ItemUnitModel(width: width, height: height, unitPrice: price),
        );
      }
      items.add(original.copyWith(units: units));
    }
    return items;
  }

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
