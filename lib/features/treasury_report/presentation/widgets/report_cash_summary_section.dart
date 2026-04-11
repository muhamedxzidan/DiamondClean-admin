import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:diamond_clean/core/constants/app_strings.dart';

import '../../data/models/treasury_report_model.dart';
import 'report_summary_card.dart';

class ReportCashSummarySection extends StatelessWidget {
  final TreasuryReportModel report;

  const ReportCashSummarySection({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,##0.00');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.treasuryReportCashSummary,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = constraints.maxWidth < 500
                ? (constraints.maxWidth - 12) / 2
                : (constraints.maxWidth - 36) / 4;

            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ReportSummaryCard(
                  title: AppStrings.treasuryReportOpeningBalance,
                  value: '${formatter.format(report.openingBalance)} ${AppStrings.currency}',
                  backgroundColor: Colors.blue.shade50,
                  textColor: Colors.blue.shade700,
                  icon: Icons.account_balance_wallet_outlined,
                  width: cardWidth,
                ),
                ReportSummaryCard(
                  title: AppStrings.treasuryReportTotalIncome,
                  value: '${formatter.format(report.cashRevenue)} ${AppStrings.currency}',
                  backgroundColor: Colors.green.shade50,
                  textColor: Colors.green.shade700,
                  icon: Icons.arrow_downward,
                  width: cardWidth,
                ),
                ReportSummaryCard(
                  title: AppStrings.treasuryReportTotalOutgoing,
                  value: '${formatter.format(report.totalExpenses)} ${AppStrings.currency}',
                  backgroundColor: Colors.red.shade50,
                  textColor: Colors.red.shade700,
                  icon: Icons.arrow_upward,
                  width: cardWidth,
                ),
                ReportSummaryCard(
                  title: AppStrings.treasuryReportClosingBalance,
                  value: '${formatter.format(report.closingCashBalance)} ${AppStrings.currency}',
                  backgroundColor: report.closingCashBalance >= 0
                      ? Colors.teal.shade50
                      : Colors.red.shade50,
                  textColor: report.closingCashBalance >= 0
                      ? Colors.teal.shade700
                      : Colors.red.shade700,
                  icon: Icons.lock_outlined,
                  width: cardWidth,
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
