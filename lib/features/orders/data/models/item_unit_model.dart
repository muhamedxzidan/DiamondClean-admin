class ItemUnitModel {
  final double? width;
  final double? height;
  final double? unitPrice;

  const ItemUnitModel({this.width, this.height, this.unitPrice});

  double? get total {
    if (unitPrice == null) return null;
    if (width == null && height == null) return unitPrice; // flat price per unit
    if (width != null && height != null) return width! * height! * unitPrice!;
    return null;
  }

  bool get hasPricing {
    if (unitPrice == null) return false;
    if (width == null && height == null) return true; // flat price
    return width != null && height != null;
  }

  /// Returns true if this unit has dimensional pricing (width × height)
  bool get isDimensional => width != null && height != null;

  /// Returns true if this unit has flat pricing (only unitPrice)
  bool get isFlatPrice => width == null && height == null && unitPrice != null;

  factory ItemUnitModel.fromMap(Map<String, dynamic> map) => ItemUnitModel(
    width: (map['width'] as num?)?.toDouble(),
    height: (map['height'] as num?)?.toDouble(),
    unitPrice: (map['unitPrice'] as num?)?.toDouble(),
  );

  Map<String, dynamic> toMap() => {
    if (width != null) 'width': width,
    if (height != null) 'height': height,
    if (unitPrice != null) 'unitPrice': unitPrice,
  };

  ItemUnitModel copyWith({double? width, double? height, double? unitPrice}) =>
      ItemUnitModel(
        width: width ?? this.width,
        height: height ?? this.height,
        unitPrice: unitPrice ?? this.unitPrice,
      );
}
