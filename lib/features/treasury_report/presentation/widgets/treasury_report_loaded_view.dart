import 'package:flutter/material.dart';

import 'package:diamond_clean/features/cashbox/data/models/cashbox_audit_log_model.dart';
import 'package:diamond_clean/features/treasury_report/data/models/treasury_report_model.dart';

import 'report_audit_log_section.dart';
import 'report_cashbox_settlement_section.dart';
import 'report_expenses_section.dart';
import 'report_orders_section.dart';
import 'report_profit_section.dart';
import 'report_revenue_section.dart';

class TreasuryReportLoadedView extends StatelessWidget {
  final TreasuryReportModel report;
  final List<CashboxAuditLogModel> auditLogs;
  final Future<void> Function() onRefresh;

  const TreasuryReportLoadedView({
    super.key,
    required this.report,
    required this.auditLogs,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final sections = <Widget>[
      RepaintBoundary(child: ReportCashboxSettlementSection(report: report)),
      RepaintBoundary(child: ReportRevenueSection(report: report)),
      RepaintBoundary(child: ReportExpensesSection(report: report)),
      RepaintBoundary(child: ReportOrdersSection(report: report)),
      RepaintBoundary(child: ReportProfitSection(report: report)),
      if (auditLogs.isNotEmpty)
        RepaintBoundary(child: ReportAuditLogSection(auditLogs: auditLogs)),
    ];

    final itemCount = sections.length * 2 + 1;

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          if (index == itemCount - 1) {
            return const SizedBox(height: 40);
          }

          if (index.isOdd) {
            return const SizedBox(height: 20);
          }

          return sections[index ~/ 2];
        },
      ),
    );
  }
}
