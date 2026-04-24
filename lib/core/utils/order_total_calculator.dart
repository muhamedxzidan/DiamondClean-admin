import 'package:diamond_clean/features/orders/data/models/order_item_model.dart';

/// Single source of truth for computing order totals.
///
/// Eliminates the inconsistency of three different calculation methods
/// scattered across the codebase.
class OrderTotalCalculator {
  const OrderTotalCalculator._();

  /// Computes total from parsed items + delivery fee.
  static double compute({
    required List<OrderItemModel> items,
    required double deliveryFee,
  }) {
    final itemsTotal = items.fold<double>(
      0,
      (acc, item) => acc + (item.itemTotal ?? 0),
    );
    return itemsTotal + deliveryFee;
  }

  /// Computes from raw Firestore data map (uses OrderModel.parseItems).
  static double computeFromMap(Map<String, dynamic> data) {
    final items = _parseItems(data['items']);
    final deliveryFee = (data['deliveryFee'] as num?)?.toDouble() ?? 0;
    return compute(items: items, deliveryFee: deliveryFee);
  }

  static List<OrderItemModel> _parseItems(dynamic raw) {
    if (raw == null) return [];
    if (raw is List) {
      return raw
          .cast<Map<String, dynamic>>()
          .map(OrderItemModel.fromMap)
          .toList();
    }
    return [];
  }
}
