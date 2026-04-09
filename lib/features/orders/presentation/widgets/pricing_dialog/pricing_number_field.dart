import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class PricingNumberField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String suffix;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;

  const PricingNumberField({
    super.key,
    required this.controller,
    required this.label,
    required this.suffix,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixText: suffix,
        isDense: true,
      ),
      validator: validator,
      onChanged: onChanged,
    );
  }
}
