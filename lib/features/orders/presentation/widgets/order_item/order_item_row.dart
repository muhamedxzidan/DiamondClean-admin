import 'package:diamond_clean/features/orders/data/models/order_item_model.dart';
import 'package:flutter/material.dart';

import 'package:diamond_clean/core/constants/app_strings.dart';

class OrderItemRow extends StatelessWidget {
  final OrderItemModel item;

  const OrderItemRow({
    super.key,
    required this.item,
  });

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
              const SizedBox(width: 22),
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
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                )
              else if (item.hasAnyPricing)
                Text(
                  '${item.pricedCount}/${item.quantity} ${AppStrings.piece}',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.outline,
                  ),
                ),
            ],
          ),
          if (item.hasPricing && _hasDimensionalUnits())
            Padding(
              padding: const EdgeInsets.only(right: 22),
              child: Column(
                children: [
                  for (var i = 0; i < item.units.length; i++)
                    if (item.units[i].hasPricing && item.units[i].isDimensional)
                      Padding(
                        padding: const EdgeInsets.only(top: 2, right: 28),
                        child: Text(
                          '${AppStrings.unitLabel} ${i + 1}: '
                          '${item.units[i].width} × ${item.units[i].height} ${AppStrings.meter} '
                          '@ ${item.units[i].unitPrice} ${AppStrings.currency} '
                          '= ${item.units[i].total!.toStringAsFixed(2)} ${AppStrings.currency}',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.outline,
                          ),
                        ),
                      ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  bool _hasDimensionalUnits() {
    return item.units.any((u) => u.isDimensional);
  }
}
