import 'package:flutter/material.dart';

import 'package:diamond_clean/core/constants/app_strings.dart';

import '../../data/models/treasury_report_model.dart';
import 'report_summary_card.dart';

class ReportOrdersSection extends StatelessWidget {
  final TreasuryReportModel report;

  const ReportOrdersSection({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.treasuryReportOrders,
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
                  title: AppStrings.treasuryReportCompleted,
                  value: '${report.completedOrdersCount}',
                  backgroundColor: Colors.green.shade50,
                  textColor: Colors.green.shade700,
                  icon: Icons.check_circle_outline,
                  width: cardWidth,
                ),
                ReportSummaryCard(
                  title: AppStrings.treasuryReportConfirmed,
                  value: '${report.confirmedOrdersCount}',
                  backgroundColor: Colors.blue.shade50,
                  textColor: Colors.blue.shade700,
                  icon: Icons.hourglass_bottom,
                  width: cardWidth,
                ),
                ReportSummaryCard(
                  title: AppStrings.treasuryReportPending,
                  value: '${report.pendingOrdersCount}',
                  backgroundColor: Colors.orange.shade50,
                  textColor: Colors.orange.shade700,
                  icon: Icons.pending_actions,
                  width: cardWidth,
                ),
                ReportSummaryCard(
                  title: AppStrings.treasuryReportCancelled,
                  value: '${report.cancelledOrdersCount}',
                  backgroundColor: Colors.red.shade50,
                  textColor: Colors.red.shade700,
                  icon: Icons.cancel_outlined,
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
