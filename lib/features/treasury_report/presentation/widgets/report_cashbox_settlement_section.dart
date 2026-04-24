import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:diamond_clean/core/constants/app_strings.dart';

import '../../data/models/treasury_report_model.dart';

class ReportCashboxSettlementSection extends StatelessWidget {
  final TreasuryReportModel report;

  const ReportCashboxSettlementSection({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,##0.00');
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تصفية الخزنة',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSettlementRow(
              context,
              label: AppStrings.treasuryReportOpeningBalance,
              value: report.openingBalance,
              formatter: formatter,
              color: Colors.blue.shade700,
              showPlus: false,
            ),
            const SizedBox(height: 12),
            _buildSettlementRow(
              context,
              label: AppStrings.treasuryReportTotalIncome,
              value: report.totalIncome,
              formatter: formatter,
              color: Colors.green.shade700,
              showPlus: true,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(thickness: 1),
            ),
            _buildSettlementRow(
              context,
              label: 'الخزنة المتاحة',
              value: report.openingBalance + report.totalIncome,
              formatter: formatter,
              color: Colors.purple.shade700,
              showPlus: false,
              isBold: true,
            ),
            const SizedBox(height: 12),
            _buildSettlementRow(
              context,
              label: AppStrings.treasuryReportTotalOutgoing,
              value: report.totalExpenses,
              formatter: formatter,
              color: Colors.red.shade700,
              showPlus: true,
              isMinus: true,
            ),
            if (report.totalWithdrawn > 0) ...[
              const SizedBox(height: 12),
              _buildSettlementRow(
                context,
                label: 'إجمالي المسحوبات (التقفيلات)',
                value: report.totalWithdrawn,
                formatter: formatter,
                color: Colors.red.shade800,
                showPlus: true,
                isMinus: true,
              ),
            ],
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(thickness: 2, height: 1),
            ),
            _buildSettlementRow(
              context,
              label: AppStrings.treasuryReportClosingBalance,
              value: report.closingCashBalance,
              formatter: formatter,
              color: report.closingCashBalance >= 0
                  ? Colors.teal.shade700
                  : Colors.red.shade700,
              showPlus: false,
              isBold: true,
              isHighlight: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettlementRow(
    BuildContext context, {
    required String label,
    required double value,
    required NumberFormat formatter,
    required Color color,
    required bool showPlus,
    bool isMinus = false,
    bool isBold = false,
    bool isHighlight = false,
  }) {
    final theme = Theme.of(context);
    final textStyle = isBold
        ? theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          )
        : theme.textTheme.bodyMedium?.copyWith(color: color);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isHighlight ? 8 : 0,
        vertical: isHighlight ? 4 : 0,
      ),
      child: Container(
        decoration: isHighlight
            ? BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              )
            : null,
        padding: isHighlight ? const EdgeInsets.symmetric(horizontal: 8) : null,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                if (showPlus)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(isMinus ? '-' : '+', style: textStyle),
                  ),
                Text(label, style: textStyle),
              ],
            ),
            Text(
              '${formatter.format(value)} ${AppStrings.currency}',
              style: textStyle,
            ),
          ],
        ),
      ),
    );
  }
}
