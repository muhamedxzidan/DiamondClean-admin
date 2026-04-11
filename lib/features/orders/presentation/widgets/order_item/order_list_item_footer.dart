import 'package:diamond_clean/features/orders/data/models/order_model.dart';
import 'package:flutter/material.dart';

import 'package:diamond_clean/core/constants/app_strings.dart';

class OrderListItemFooter extends StatelessWidget {
  final OrderModel order;

  const OrderListItemFooter({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final total = order.totalPrice;

    if (total == null) {
      return Text(
        order.items.isEmpty
            ? AppStrings.noItemsFound
            : AppStrings.notPricedYet,
        style: textTheme.bodyMedium?.copyWith(
          color: colorScheme.outline,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    if (order.hasOutstandingBalance) {
      return Row(
        children: [
          Text(
            '${AppStrings.orderTotal}: ${total.toStringAsFixed(2)} ${AppStrings.currency}',
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          _PaymentBadge(
            label: AppStrings.paidLabel,
            amount: order.paidAmount,
            color: Colors.green,
          ),
          const SizedBox(width: 8),
          _PaymentBadge(
            label: AppStrings.remainingAmountLabel,
            amount: order.remainingAmount,
            color: Colors.red,
          ),
        ],
      );
    }

    return Text(
      '${AppStrings.orderTotal}: ${total.toStringAsFixed(2)} ${AppStrings.currency}',
      style: textTheme.titleMedium?.copyWith(
        color: colorScheme.primary,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _PaymentBadge extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;

  const _PaymentBadge({
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$label: ${amount.toStringAsFixed(0)}',
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
