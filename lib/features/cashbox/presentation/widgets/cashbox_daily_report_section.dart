import 'package:flutter/material.dart';

import 'package:diamond_clean/core/constants/app_strings.dart';
import 'package:diamond_clean/core/utils/date_formatter.dart';

import '../../cubit/cashbox_state.dart';
import 'cashbox_summary_card.dart';

class CashboxDailyReportSection extends StatelessWidget {
  final CashboxLoaded state;

  const CashboxDailyReportSection({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${AppStrings.cashboxReport} - ${formatDate(state.selectedDay)}',
          style: theme.textTheme.titleLarge,
        ),
        const Divider(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = constraints.maxWidth < 500
                ? constraints.maxWidth
                : (constraints.maxWidth - 12) / 2;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                CashboxSummaryCard(
                  title: AppStrings.cashboxOpeningBalance,
                  value: state.settings.openingBalance,
                  width: cardWidth,
                ),
                CashboxSummaryCard(
                  title: AppStrings.cashboxCurrentBalance,
                  value: state.sessionBalance,
                  width: cardWidth,
                ),
                CashboxSummaryCard(
                  title: AppStrings.cashboxDailyRevenue,
                  value: state.sessionRevenue,
                  width: cardWidth,
                ),
                CashboxSummaryCard(
                  title: AppStrings.cashboxDailyExpenses,
                  value: state.sessionExpenses,
                  width: cardWidth,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 12),
        // Payment method breakdown
        _RevenueBreakdownCard(
          cashRevenue: state.sessionCashRevenue,
          electronicRevenue: state.sessionElectronicRevenue,
          ordersCount: state.sessionIncomeEntries.length,
        ),
      ],
    );
  }
}

class _RevenueBreakdownCard extends StatelessWidget {
  final double cashRevenue;
  final double electronicRevenue;
  final int ordersCount;

  const _RevenueBreakdownCard({
    required this.cashRevenue,
    required this.electronicRevenue,
    required this.ordersCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تفاصيل الإيرادات',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _BreakdownRow(
              icon: Icons.money,
              label: AppStrings.paymentMethodCash,
              value: cashRevenue,
              color: Colors.green.shade700,
            ),
            const SizedBox(height: 4),
            _BreakdownRow(
              icon: Icons.phone_android,
              label: 'إلكتروني',
              value: electronicRevenue,
              color: Colors.blue.shade700,
            ),
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'عدد الأوردرات المسلّمة',
                  style: theme.textTheme.bodySmall,
                ),
                Text(
                  '$ordersCount',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final double value;
  final Color color;

  const _BreakdownRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
            ),
          ),
        ),
        Text(
          value.toStringAsFixed(2),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
