import 'package:flutter/material.dart';

import 'package:diamond_clean/core/constants/app_strings.dart';
import 'pricing_number_field.dart';
import 'unit_controllers.dart';

class PricingUnitRow extends StatelessWidget {
  final UnitControllers controllers;
  final int unitIndex;
  final int totalUnits;
  final FormFieldValidator<String> validator;
  final ValueChanged<String> onChanged;

  const PricingUnitRow({
    super.key,
    required this.controllers,
    required this.unitIndex,
    required this.totalUnits,
    required this.validator,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (totalUnits > 1)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              '${AppStrings.unitLabel} ${unitIndex + 1}',
              style: textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.secondary,
              ),
            ),
          ),
        Row(
          children: [
            Expanded(
              child: PricingNumberField(
                controller: controllers.width,
                label: AppStrings.itemWidth,
                suffix: AppStrings.meter,
                validator: validator,
                onChanged: onChanged,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                'x',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: PricingNumberField(
                controller: controllers.height,
                label: AppStrings.itemHeight,
                suffix: AppStrings.meter,
                validator: validator,
                onChanged: onChanged,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                '@',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: PricingNumberField(
                controller: controllers.price,
                label: AppStrings.itemUnitPrice,
                suffix: AppStrings.currency,
                validator: validator,
                onChanged: onChanged,
              ),
            ),
            const SizedBox(width: 8),
            _buildUnitTotal(controllers, textTheme, colorScheme),
          ],
        ),
      ],
    );
  }

  Widget _buildUnitTotal(
    UnitControllers c,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    final w = double.tryParse(c.width.text.trim());
    final h = double.tryParse(c.height.text.trim());
    final p = double.tryParse(c.price.text.trim());
    final total = (w != null && h != null && p != null) ? w * h * p : null;

    return SizedBox(
      width: 80,
      child: Text(
        total != null
            ? '${total.toStringAsFixed(2)} ${AppStrings.currency}'
            : '—',
        style: textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: total != null ? colorScheme.primary : colorScheme.outline,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

