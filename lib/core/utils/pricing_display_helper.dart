import 'package:diamond_clean/features/orders/data/models/item_unit_model.dart';
import 'package:diamond_clean/features/orders/data/models/order_item_model.dart';

/// Helper to format pricing display based on dimension configuration
class PricingDisplayHelper {
  /// Returns formatted unit details string for display
  static String formatUnitDetails(
    ItemUnitModel unit, {
    required String meterLabel,
    required String currencyLabel,
    required bool hasDimensions,
  }) {
    if (!unit.hasPricing) return '';

    if (!hasDimensions || !unit.isDimensional) {
      // Flat price only
      return '${unit.unitPrice} $currencyLabel';
    }

    // Dimensional pricing
    return '${unit.width} × ${unit.height} $meterLabel '
        '@ ${unit.unitPrice} $currencyLabel '
        '= ${unit.total!.toStringAsFixed(2)} $currencyLabel';
  }

  /// Returns true if item should display dimensional details
  static bool shouldShowDimensions(
    OrderItemModel item, {
    required bool hasDimensions,
  }) {
    return item.hasPricing &&
        hasDimensions &&
        item.units.any((u) => u.isDimensional);
  }

  /// Returns flat-price formatted unit price
  static String formatFlatPrice(double? unitPrice, String currencyLabel) {
    if (unitPrice == null) return '—';
    return '${unitPrice.toStringAsFixed(2)} $currencyLabel';
  }

  /// Validates that unit has correct pricing for the mode
  static bool isValidUnitPricing(ItemUnitModel unit, bool hasDimensions) {
    if (!hasDimensions) {
      // For flat price, must have ONLY unitPrice
      return unit.unitPrice != null && unit.width == null && unit.height == null;
    }
    // For dimensional, must have all three
    return unit.width != null && unit.height != null && unit.unitPrice != null;
  }
}
