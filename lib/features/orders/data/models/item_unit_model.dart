class ItemUnitModel {
  final double? width;
  final double? height;
  final double? unitPrice;

  const ItemUnitModel({this.width, this.height, this.unitPrice});

  double? get total {
    if (width == null || height == null || unitPrice == null) return null;
    return width! * height! * unitPrice!;
  }

  bool get hasPricing => width != null && height != null && unitPrice != null;

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
