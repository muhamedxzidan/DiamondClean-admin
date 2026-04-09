import '../data/models/order_model.dart';

class OrdersGrouping {
  static Map<DateTime, List<OrderModel>> groupOrdersByDay(
    List<OrderModel> orders,
  ) {
    final grouped = <DateTime, List<OrderModel>>{};
    for (final order in orders) {
      final dayKey = DateTime(
        order.createdAt.year,
        order.createdAt.month,
        order.createdAt.day,
      );
      grouped.putIfAbsent(dayKey, () => []).add(order);
    }
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    return {for (final key in sortedKeys) key: grouped[key]!};
  }
}
