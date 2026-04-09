import 'package:flutter/material.dart';

import 'package:diamond_clean/core/constants/app_strings.dart';

class OrderPricingFooter extends StatelessWidget {
  final double? total;
  final bool isSaving;
  final VoidCallback onSave;
  final VoidCallback? onSendWhatsapp;

  const OrderPricingFooter({
    super.key,
    required this.total,
    required this.isSaving,
    required this.onSave,
    this.onSendWhatsapp,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.orderTotal,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                total != null
                    ? '${total!.toStringAsFixed(2)} ${AppStrings.currency}'
                    : AppStrings.notPricedYet,
                style: textTheme.titleLarge?.copyWith(
                  color: total != null
                      ? colorScheme.primary
                      : colorScheme.outline,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(AppStrings.cancel),
              ),
              const Spacer(),
              OutlinedButton.icon(
                icon: const Icon(Icons.message_outlined),
                label: const Text(AppStrings.sendWhatsapp),
                onPressed: onSendWhatsapp,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF128C7E),
                  side: const BorderSide(color: Color(0xFF128C7E)),
                ),
              ),
              const SizedBox(width: 10),
              FilledButton.icon(
                icon: isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(isSaving ? AppStrings.loading : AppStrings.save),
                onPressed: isSaving ? null : onSave,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
