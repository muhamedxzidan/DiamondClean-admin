import 'package:flutter/material.dart';

class UnitControllers {
  final TextEditingController width;
  final TextEditingController height;
  final TextEditingController price;

  UnitControllers({
    required this.width,
    required this.height,
    required this.price,
  });

  void dispose() {
    width.dispose();
    height.dispose();
    price.dispose();
  }
}
