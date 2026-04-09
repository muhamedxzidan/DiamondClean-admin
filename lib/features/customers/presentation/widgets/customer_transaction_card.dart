import 'package:flutter/material.dart';

import 'package:diamond_clean/core/constants/app_strings.dart';
import 'package:diamond_clean/core/utils/date_formatter.dart';
import '../../data/models/customer_model.dart';
import '../../data/models/customer_transaction_model.dart';

class CustomerTransactionCard extends StatelessWidget {
  final CustomerModel customer;
  final CustomerTransactionModel transaction;

  const CustomerTransactionCard({
    super.key,
    required this.customer,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.code,
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        customer.phone,
                        style: textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _StatusChip(status: transaction.status),
              ],
            ),
            const SizedBox(height: 12),
            _TransactionInfoRow(
              icon: Icons.event_outlined,
              text: formatDateYMD(transaction.createdAt),
            ),
            const SizedBox(height: 8),
            _TransactionInfoRow(
              icon: Icons.shopping_bag_outlined,
              text:
                  '${AppStrings.orderTotal}: ${transaction.orderTotal.toStringAsFixed(2)} ${AppStrings.currency}',
            ),
            const SizedBox(height: 8),
            _TransactionInfoRow(
              icon: Icons.local_car_wash_outlined,
              text:
                  '${AppStrings.orderService}: ${transaction.itemCount} ${AppStrings.piece}',
            ),
            const SizedBox(height: 8),
            _TransactionInfoRow(
              icon: Icons.delivery_dining_outlined,
              text:
                  '${AppStrings.deliveryFee}: ${transaction.deliveryFee.toStringAsFixed(2)} ${AppStrings.currency}',
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final (background, foreground, label) = switch (status) {
      'completed' => (
        colorScheme.tertiaryContainer,
        colorScheme.onTertiaryContainer,
        AppStrings.statusCompleted,
      ),
      'confirmed' => (
        colorScheme.primaryContainer,
        colorScheme.onPrimaryContainer,
        AppStrings.statusConfirmed,
      ),
      'cancelled' => (
        colorScheme.errorContainer,
        colorScheme.onErrorContainer,
        AppStrings.statusCancelled,
      ),
      _ => (
        colorScheme.secondaryContainer,
        colorScheme.onSecondaryContainer,
        AppStrings.statusPending,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(color: foreground, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _TransactionInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _TransactionInfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: 18, color: colorScheme.outline),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    );
  }
}
