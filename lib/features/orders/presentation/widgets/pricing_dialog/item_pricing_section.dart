import 'package:diamond_clean/features/orders/data/models/order_item_model.dart';
import 'package:diamond_clean/features/orders/data/models/item_unit_model.dart';
import 'package:flutter/material.dart';

import 'package:diamond_clean/core/constants/app_strings.dart';
import 'pricing_number_field.dart';
import 'pricing_unit_row.dart';
import 'unit_controllers.dart';

class ItemPricingSection extends StatefulWidget {
  final OrderItemModel item;
  final FormFieldValidator<String> validator;
  final VoidCallback onChanged;

  const ItemPricingSection({
    super.key,
    required this.item,
    required this.validator,
    required this.onChanged,
  });

  @override
  ItemPricingSectionState createState() => ItemPricingSectionState();
}

class ItemPricingSectionState extends State<ItemPricingSection> {
  late bool _isDimensional;
  late List<UnitControllers> _controllers;

  @override
  void initState() {
    super.initState();
    // Infer initial mode from existing unit data
    _isDimensional = widget.item.units.isNotEmpty &&
        widget.item.units.any((u) => u.isDimensional);
    // Always create per-unit controllers
    _controllers = List.generate(widget.item.quantity, (unitIdx) {
      final unit = unitIdx < widget.item.expandedUnits.length
          ? widget.item.expandedUnits[unitIdx]
          : null;
      return UnitControllers(
        width: TextEditingController(text: unit?.width?.toString() ?? ''),
        height: TextEditingController(text: unit?.height?.toString() ?? ''),
        price: TextEditingController(text: unit?.unitPrice?.toString() ?? ''),
      );
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _onModeChanged(bool isDimensional) {
    setState(() {
      _isDimensional = isDimensional;
      // Clear all controllers when switching mode
      for (final c in _controllers) {
        c.width.clear();
        c.height.clear();
        c.price.clear();
      }
    });
    widget.onChanged();
  }

  OrderItemModel buildItem() {
    final units = <ItemUnitModel>[];
    if (!_isDimensional) {
      // Flat price: same price for all units
      final price = double.tryParse(_controllers[0].price.text.trim());
      for (var u = 0; u < widget.item.quantity; u++) {
        units.add(ItemUnitModel(unitPrice: price));
      }
    } else {
      // Dimensional: per-unit width/height/price
      for (var u = 0; u < widget.item.quantity; u++) {
        final c = _controllers[u];
        final width = double.tryParse(c.width.text.trim());
        final height = double.tryParse(c.height.text.trim());
        final price = double.tryParse(c.price.text.trim());
        units.add(ItemUnitModel(
          width: width,
          height: height,
          unitPrice: price,
        ));
      }
    }
    return widget.item.copyWith(units: units);
  }

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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildModeToggle(colorScheme),
                const SizedBox(height: 12),
                _isDimensional
                    ? _buildDimensionalPricing()
                    : _buildFlatPricing(textTheme, colorScheme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeToggle(ColorScheme colorScheme) {
    return SegmentedButton<bool>(
      segments: const [
        ButtonSegment(
          value: false,
          label: Text('سعر ثابت'),
          icon: Icon(Icons.sell_outlined),
        ),
        ButtonSegment(
          value: true,
          label: Text('بمقاسات'),
          icon: Icon(Icons.straighten),
        ),
      ],
      selected: {_isDimensional},
      onSelectionChanged: (v) => _onModeChanged(v.first),
      style: SegmentedButton.styleFrom(
        selectedBackgroundColor: colorScheme.primaryContainer,
      ),
    );
  }

  Widget _buildDimensionalPricing() {
    return Column(
      children: List.generate(widget.item.quantity, (unitIdx) {
        return Padding(
          padding: EdgeInsets.only(top: unitIdx > 0 ? 10 : 0),
          child: PricingUnitRow(
            controllers: _controllers[unitIdx],
            unitIndex: unitIdx,
            totalUnits: widget.item.quantity,
            validator: widget.validator,
            onChanged: (_) => widget.onChanged(),
          ),
        );
      }),
    );
  }

  Widget _buildFlatPricing(TextTheme textTheme, ColorScheme colorScheme) {
    final c = _controllers[0];
    final price = double.tryParse(c.price.text.trim());
    final total = price != null ? price * widget.item.quantity : null;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: PricingNumberField(
                controller: c.price,
                label: AppStrings.itemUnitPrice,
                suffix: AppStrings.currency,
                validator: widget.validator,
                onChanged: (_) => widget.onChanged(),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
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
            ),
          ],
        ),
      ],
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
            '${widget.item.name} — ${widget.item.quantity} ${AppStrings.piece}',
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
