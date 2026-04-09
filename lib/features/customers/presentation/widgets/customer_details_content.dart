import 'package:flutter/material.dart';

import 'package:diamond_clean/core/constants/app_strings.dart';
import 'package:diamond_clean/core/utils/date_formatter.dart';
import '../../data/models/customer_model.dart';
import '../../data/models/customer_transaction_model.dart';
import 'customer_summary_card.dart';
import 'customer_transaction_card.dart';

class CustomerDetailsContent extends StatelessWidget {
  final CustomerModel customer;
  final List<CustomerTransactionModel> transactions;

  const CustomerDetailsContent({
    super.key,
    required this.customer,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: colorScheme.primaryContainer,
                      child: Text(
                        _avatarLabel(customer),
                        style: textTheme.titleMedium?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customer.name,
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(customer.code),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _InfoRow(
                  icon: Icons.phone_outlined,
                  label: AppStrings.customerPhone,
                  value: customer.phone,
                ),
                const SizedBox(height: 12),
                _InfoRow(
                  icon: Icons.location_on_outlined,
                  label: AppStrings.customerAddress,
                  value: customer.address,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            CustomerSummaryCard(
              label: AppStrings.customerVisits,
              value: customer.orderCount.toString(),
              icon: Icons.local_car_wash_outlined,
            ),
            CustomerSummaryCard(
              label: AppStrings.customerTotalSpent,
              value:
                  '${customer.totalSpent.toStringAsFixed(2)} ${AppStrings.currency}',
              icon: Icons.payments_outlined,
            ),
            CustomerSummaryCard(
              label: AppStrings.firstVisit,
              value: formatDateYMD(customer.createdAt),
              icon: Icons.history_outlined,
            ),
            CustomerSummaryCard(
              label: AppStrings.lastVisit,
              value: formatDateYMD(customer.lastOrderAt),
              icon: Icons.event_available_outlined,
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          AppStrings.customerTransactionHistory,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (transactions.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(AppStrings.noCustomerTransactions),
            ),
          )
        else
          ...transactions.map(
            (transaction) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: CustomerTransactionCard(
                customer: customer,
                transaction: transaction,
              ),
            ),
          ),
      ],
    );
  }
}

String _avatarLabel(CustomerModel customer) {
  final code = customer.code.trim();
  if (code.isNotEmpty) return code[0].toUpperCase();

  final name = customer.name.trim();
  if (name.isNotEmpty) return name[0].toUpperCase();

  return '?';
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: textTheme.labelMedium),
              const SizedBox(height: 4),
              Text(value, style: textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}
