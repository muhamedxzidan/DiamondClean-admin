import 'package:diamond_clean/features/orders/data/models/order_model.dart';
import 'package:flutter/material.dart';

import 'package:diamond_clean/core/constants/app_strings.dart';

class OrderListItemHeader extends StatelessWidget {
  final OrderModel order;
  final ValueChanged<OrderStatus> onStatusChanged;

  const OrderListItemHeader({
    super.key,
    required this.order,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        CircleAvatar(
          backgroundColor: _statusColor(order.status).withValues(alpha: 0.15),
          child: Icon(
            Icons.receipt_long_outlined,
            color: _statusColor(order.status),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      order.customerName,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.tertiary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      order.displayRef,
                      style: textTheme.labelMedium?.copyWith(
                        color: colorScheme.onTertiary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                order.customerPhone,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
        _StatusChip(status: order.status, onChanged: onStatusChanged),
      ],
    );
  }

  Color _statusColor(OrderStatus status) => switch (status) {
    OrderStatus.pending => Colors.orange,
    OrderStatus.confirmed => Colors.blue,
    OrderStatus.completed => Colors.green,
    OrderStatus.cancelled => Colors.red,
  };
}

class _StatusChip extends StatelessWidget {
  final OrderStatus status;
  final ValueChanged<OrderStatus> onChanged;

  const _StatusChip({required this.status, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<OrderStatus>(
      onSelected: onChanged,
      itemBuilder: (_) => OrderStatus.values
          .map((s) => PopupMenuItem(value: s, child: Text(_statusLabel(s))))
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: _statusColor(status).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _statusColor(status).withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _statusLabel(status),
              style: TextStyle(
                fontSize: 12,
                color: _statusColor(status),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down, size: 16, color: _statusColor(status)),
          ],
        ),
      ),
    );
  }

  String _statusLabel(OrderStatus s) => switch (s) {
    OrderStatus.pending => AppStrings.statusPending,
    OrderStatus.confirmed => AppStrings.statusConfirmed,
    OrderStatus.completed => AppStrings.statusCompleted,
    OrderStatus.cancelled => AppStrings.statusCancelled,
  };

  Color _statusColor(OrderStatus s) => switch (s) {
    OrderStatus.pending => Colors.orange,
    OrderStatus.confirmed => Colors.blue,
    OrderStatus.completed => Colors.green,
    OrderStatus.cancelled => Colors.red,
  };
}
