import 'package:flutter/material.dart';

import '../../data/models/order_model.dart';
import 'order_list_item.dart';
import 'orders_day_header.dart';

class OrdersDayGroup extends StatelessWidget {
  final DateTime day;
  final List<OrderModel> orders;
  final bool isExpanded;
  final VoidCallback onToggleExpansion;
  final Function(OrderModel) onOpenPricing;
  final Future<void> Function(OrderModel) onSendInvoice;
  final Function(OrderModel, OrderStatus) onStatusChanged;
  final bool showSpacing;

  const OrdersDayGroup({
    super.key,
    required this.day,
    required this.orders,
    required this.isExpanded,
    required this.onToggleExpansion,
    required this.onOpenPricing,
    required this.onSendInvoice,
    required this.onStatusChanged,
    this.showSpacing = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OrdersDayHeader(
          day: day,
          orderCount: orders.length,
          isExpanded: isExpanded,
          onTap: onToggleExpansion,
        ),
        if (isExpanded)
          ...orders.map(
            (order) => OrderListItem(
              order: order,
              onOpenPricing: () => onOpenPricing(order),
              onSendInvoice: () => onSendInvoice(order),
              onStatusChanged: (status) => onStatusChanged(order, status),
            ),
          ),
        if (showSpacing) const SizedBox(height: 8),
      ],
    );
  }
}
