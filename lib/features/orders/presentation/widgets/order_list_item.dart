import 'package:flutter/material.dart';

import '../../data/models/order_model.dart';
import 'order_item/order_list_item_header.dart';
import 'order_item/order_info_row.dart';
import 'order_item/order_items_section.dart';
import 'order_item/order_list_item_footer.dart';

class OrderListItem extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onOpenPricing;
  final Future<void> Function() onSendInvoice;
  final ValueChanged<OrderStatus> onStatusChanged;

  const OrderListItem({
    super.key,
    required this.order,
    required this.onOpenPricing,
    required this.onSendInvoice,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            OrderListItemHeader(order: order, onStatusChanged: onStatusChanged),
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 8),
            OrderInfoRow(icon: Icons.location_on_outlined, text: order.address),
            const SizedBox(height: 4),
            OrderInfoRow(
              icon: Icons.directions_car_outlined,
              text: '${order.carNumber} — ${order.driverName}',
            ),
            if (order.notes != null && order.notes!.isNotEmpty) ...[
              const SizedBox(height: 4),
              OrderInfoRow(icon: Icons.notes_outlined, text: order.notes!),
            ],
            if (order.items.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Divider(height: 1),
              const SizedBox(height: 8),
              OrderItemsSection(
                order: order,
                onOpenPricing: onOpenPricing,
                onSendInvoice: onSendInvoice,
              ),
            ],
            const SizedBox(height: 8),
            OrderListItemFooter(order: order),
          ],
        ),
      ),
    );
  }
}
