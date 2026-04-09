import 'package:diamond_clean/features/orders/data/models/order_item_model.dart';
import 'package:flutter/material.dart';

import 'package:diamond_clean/core/constants/app_strings.dart';
import 'pricing_unit_row.dart';
import 'unit_controllers.dart';

class ItemPricingSection extends StatelessWidget {
  final OrderItemModel item;
  final int itemIndex;
  final List<List<UnitControllers>> controllers;
  final FormFieldValidator<String> validator;
  final ValueChanged<String> onChanged;

  const ItemPricingSection({
    super.key,
    required this.item,
    required this.itemIndex,
    required this.controllers,
    required this.validator,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildItemHeader(textTheme, colorScheme),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: List.generate(item.quantity, (unitIdx) {
                return Padding(
                  padding: EdgeInsets.only(top: unitIdx > 0 ? 10 : 0),
                  child: PricingUnitRow(
                    controllers: controllers[itemIndex][unitIdx],
                    unitIndex: unitIdx,
                    totalUnits: item.quantity,
                    validator: validator,
                    onChanged: onChanged,
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemHeader(TextTheme textTheme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 20,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            '${item.name} — ${item.quantity} ${AppStrings.piece}',
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
