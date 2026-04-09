import 'item_unit_model.dart';

class OrderItemModel {
  final String name;
  final int quantity;
  final List<ItemUnitModel> units;

  const OrderItemModel({
    required this.name,
    required this.quantity,
    this.units = const [],
  });

  double? get itemTotal {
    if (units.isEmpty) return null;
    final totals = units.map((u) => u.total);
    if (totals.any((t) => t == null)) return null;
    return totals.fold<double>(0, (acc, t) => acc + t!);
  }

  bool get hasPricing =>
      units.isNotEmpty &&
      units.length == quantity &&
      units.every((u) => u.hasPricing);

  bool get hasAnyPricing => units.any((u) => u.hasPricing);

  int get pricedCount => units.where((u) => u.hasPricing).length;

  /// Ensures units list matches quantity, filling missing slots with empty units.
  List<ItemUnitModel> get expandedUnits {
    if (units.length >= quantity) return units;
    return [
      ...units,
      ...List.generate(
        quantity - units.length,
        (_) => const ItemUnitModel(),
      ),
    ];
  }

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    final quantity = (map['quantity'] as num?)?.toInt() ?? 1;
    final rawUnits = map['units'];

    List<ItemUnitModel> units;
    if (rawUnits is List && rawUnits.isNotEmpty) {
      units = rawUnits
          .cast<Map<String, dynamic>>()
          .map(ItemUnitModel.fromMap)
          .toList();
    } else {
      // Backward compatibility: migrate old single-pricing to units
      final width = (map['width'] as num?)?.toDouble();
      final height = (map['height'] as num?)?.toDouble();
      final unitPrice = (map['unitPrice'] as num?)?.toDouble();
      if (width != null || height != null || unitPrice != null) {
        units = List.generate(
          quantity,
          (_) => ItemUnitModel(
            width: width,
            height: height,
            unitPrice: unitPrice,
          ),
        );
      } else {
        units = [];
      }
    }

    return OrderItemModel(name: map['name'] as String? ?? '', quantity: quantity, units: units);
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'quantity': quantity,
    'units': units.map((u) => u.toMap()).toList(),
  };

  OrderItemModel copyWith({List<ItemUnitModel>? units}) => OrderItemModel(
    name: name,
    quantity: quantity,
    units: units ?? this.units,
  );
}
