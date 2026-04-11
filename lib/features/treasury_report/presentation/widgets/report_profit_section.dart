import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:diamond_clean/core/constants/app_strings.dart';

import '../../data/models/treasury_report_model.dart';

class ReportProfitSection extends StatelessWidget {
  final TreasuryReportModel report;

  const ReportProfitSection({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,##0.00');
    final theme = Theme.of(context);
    final isProfit = report.netProfit >= 0;

    return Card(
      elevation: 0,
      color: isProfit ? Colors.green.shade50 : Colors.red.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isProfit ? Colors.green.shade200 : Colors.red.shade200,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              AppStrings.treasuryReportProfitLoss,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isProfit
                      ? Icons.trending_up
                      : Icons.trending_down,
                  color: isProfit
                      ? Colors.green.shade700
                      : Colors.red.shade700,
                  size: 28,
                ),
                const SizedBox(width: 8),
                Text(
                  '${formatter.format(report.netProfit)} ${AppStrings.currency}',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isProfit
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                  ),
                ),
              ],
            ),
            if (report.remainingOrdersValue > 0) ...[
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.treasuryReportPendingValue,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.amber.shade800,
                    ),
                  ),
                  Text(
                    '${formatter.format(report.remainingOrdersValue)} ${AppStrings.currency}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.amber.shade800,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
