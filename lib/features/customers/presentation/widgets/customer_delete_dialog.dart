import 'package:flutter/material.dart';

import 'package:diamond_clean/core/constants/app_strings.dart';

class CustomerDeleteDialog extends StatelessWidget {
  final String customerName;
  final VoidCallback onConfirm;

  const CustomerDeleteDialog({
    super.key,
    required this.customerName,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('حذف العميل'),
      content: Text('هل أنت متأكد من حذف "$customerName"؟'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(AppStrings.cancel),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
          child: const Text(AppStrings.delete),
        ),
      ],
    );
  }
}

class CustomerDeleteButton extends StatelessWidget {
  final String customerName;
  final VoidCallback onConfirm;

  const CustomerDeleteButton({
    super.key,
    required this.customerName,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox.square(
      dimension: 32,
      child: IconButton(
        padding: EdgeInsets.zero,
        iconSize: 18,
        icon: const Icon(Icons.delete_outline),
        color: colorScheme.error,
        onPressed: () => showDialog(
          context: context,
          builder: (_) => CustomerDeleteDialog(
            customerName: customerName,
            onConfirm: onConfirm,
          ),
        ),
      ),
    );
  }
}
