import 'package:diamond_clean/features/cashbox/data/models/cashbox_audit_log_model.dart';
import 'package:diamond_clean/features/treasury_report/data/models/treasury_report_model.dart';

sealed class TreasuryReportState {
  const TreasuryReportState();
}

final class TreasuryReportInitial extends TreasuryReportState {
  const TreasuryReportInitial();
}

final class TreasuryReportLoading extends TreasuryReportState {
  const TreasuryReportLoading();
}

final class TreasuryReportLoaded extends TreasuryReportState {
  final TreasuryReportModel report;
  final List<CashboxAuditLogModel> auditLogs;

  const TreasuryReportLoaded(this.report, {this.auditLogs = const []});
}

final class TreasuryReportError extends TreasuryReportState {
  final String message;

  const TreasuryReportError(this.message);
}
