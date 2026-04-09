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

    return total != null
        ? Text(
            '${AppStrings.orderTotal}: ${total.toStringAsFixed(2)} ${AppStrings.currency}',
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          )
        : Text(
            order.items.isEmpty
                ? AppStrings.noItemsFound
                : AppStrings.notPricedYet,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.outline,
              fontStyle: FontStyle.italic,
            ),
          );
  }
}
