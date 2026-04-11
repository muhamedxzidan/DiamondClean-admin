import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:diamond_clean/core/constants/app_strings.dart';

import '../../data/models/treasury_report_model.dart';

class ReportRevenueSection extends StatelessWidget {
  final TreasuryReportModel report;

  const ReportRevenueSection({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,##0.00');
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.treasuryReportRevenue,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _RevenueRow(
              label: AppStrings.treasuryReportOrdersRevenue,
              value: '${formatter.format(report.completedOrdersRevenue)} ${AppStrings.currency}',
              color: Colors.green.shade700,
            ),
            const SizedBox(height: 10),
            _RevenueRow(
              label: AppStrings.treasuryReportDeliveryFees,
              value: '${formatter.format(report.deliveryFeesRevenue)} ${AppStrings.currency}',
              color: Colors.green.shade600,
            ),
            const Divider(height: 20),
            _RevenueRow(
              label: AppStrings.treasuryReportCashPayments,
              value: '${formatter.format(report.cashRevenue)} ${AppStrings.currency}',
              color: Colors.teal.shade700,
              icon: Icons.payments_outlined,
            ),
            const SizedBox(height: 10),
            _RevenueRow(
              label: AppStrings.treasuryReportElectronicPayments,
              value: '${formatter.format(report.electronicRevenue)} ${AppStrings.currency}',
              color: Colors.indigo.shade600,
              icon: Icons.phone_android_outlined,
            ),
          ],
        ),
      ),
    );
  }
}

class _RevenueRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData? icon;

  const _RevenueRow({
    required this.label,
    required this.value,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
        ],
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
