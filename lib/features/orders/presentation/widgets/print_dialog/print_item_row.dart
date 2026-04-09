import 'package:diamond_clean/features/orders/data/models/order_item_model.dart';
import 'package:flutter/material.dart';

import 'package:diamond_clean/core/constants/app_strings.dart';

class PrintItemRow extends StatelessWidget {
  final OrderItemModel item;

  const PrintItemRow({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${item.name} × ${item.quantity}',
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (item.hasPricing)
                Text(
                  '${item.itemTotal!.toStringAsFixed(2)} ${AppStrings.currency}',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                )
              else
                Text(
                  AppStrings.notPricedYet,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.outline,
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
          if (item.hasPricing && item.quantity > 1)
            ...item.units
                .where((u) => u.hasPricing)
                .toList()
                .asMap()
                .entries
                .map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(top: 2, right: 16),
                    child: Text(
                      '  ${AppStrings.unitLabel} ${entry.key + 1}: '
                      '${entry.value.width} × ${entry.value.height} ${AppStrings.meter} '
                      '@ ${entry.value.unitPrice} ${AppStrings.currency} '
                      '= ${entry.value.total!.toStringAsFixed(2)} ${AppStrings.currency}',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.outline,
                      ),
                    ),
                  ),
                ),
          if (item.hasPricing &&
              item.quantity == 1 &&
              item.units.first.hasPricing)
            Padding(
              padding: const EdgeInsets.only(top: 2, right: 16),
              child: Text(
                '  ${item.units.first.width} × ${item.units.first.height} ${AppStrings.meter} '
                '@ ${item.units.first.unitPrice} ${AppStrings.currency}',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.outline,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
