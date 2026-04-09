import 'package:flutter/material.dart';

import 'package:diamond_clean/core/constants/app_strings.dart';
import 'package:diamond_clean/core/widgets/custom_card.dart';
import 'package:diamond_clean/core/widgets/state_widgets.dart';

import '../../data/models/cashbox_closure_model.dart';

class ClosuresLogScreen extends StatelessWidget {
  final List<CashboxClosureModel> closures;

  const ClosuresLogScreen({super.key, required this.closures});

  String _formatDateTime(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month/${date.year} $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.cashboxClosuresLog),
      ),
      body: closures.isEmpty
          ? const EmptyStateWidget(message: AppStrings.cashboxNoClosures)
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: closures.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final closure = closures[index];
                return _ClosureCard(
                  closure: closure,
                  formatDateTime: _formatDateTime,
                );
              },
            ),
    );
  }
}

class _ClosureCard extends StatelessWidget {
  final CashboxClosureModel closure;
  final String Function(DateTime) formatDateTime;

  const _ClosureCard({
    required this.closure,
    required this.formatDateTime,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoRow(
            label: AppStrings.cashboxClosedByLabel,
            value: closure.closedBy,
          ),
          const SizedBox(height: 4),
          _InfoRow(
            label: AppStrings.cashboxClosedAtLabel,
            value: formatDateTime(closure.closedAt),
          ),
          const Divider(height: 16),
          _InfoRow(
            label: AppStrings.cashboxClosureOpeningBalance,
            value: closure.openingBalance.toStringAsFixed(2),
          ),
          const SizedBox(height: 4),
          _InfoRow(
            label: AppStrings.cashboxClosureTotalRevenue,
            value: closure.totalRevenue.toStringAsFixed(2),
          ),
          const SizedBox(height: 4),
          _InfoRow(
            label: AppStrings.cashboxClosureTotalExpenses,
            value: closure.totalExpenses.toStringAsFixed(2),
          ),
          if (closure.expenses.isNotEmpty) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 16),
              child: Column(
                children: closure.expenses
                    .map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '• ${e.title}',
                              style: theme.textTheme.bodySmall,
                            ),
                            Text(
                              e.amount.toStringAsFixed(2),
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
          const SizedBox(height: 4),
          _InfoRow(
            label: AppStrings.cashboxClosureOrdersCount,
            value: '${closure.ordersCount}',
          ),
          const Divider(height: 16),
          _InfoRow(
            label: AppStrings.cashboxClosedAmountLabel,
            value: closure.closingBalance.toStringAsFixed(2),
            bold: true,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _InfoRow({required this.label, required this.value, this.bold = false});

  @override
  Widget build(BuildContext context) {
    final style = bold
        ? Theme.of(context)
              .textTheme
              .labelLarge
              ?.copyWith(fontWeight: FontWeight.bold)
        : Theme.of(context).textTheme.labelLarge;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(value, style: bold
            ? Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.bold)
            : Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
