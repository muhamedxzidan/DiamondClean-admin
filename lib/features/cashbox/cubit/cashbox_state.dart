import 'package:diamond_clean/core/models/treasury_log_entry.dart';
import 'package:diamond_clean/core/utils/treasury_log_entry_mapper.dart';
import 'package:diamond_clean/features/cashbox/data/models/cashbox_audit_log_model.dart';
import 'package:diamond_clean/features/cashbox/data/models/cashbox_closure_model.dart';
import 'package:diamond_clean/features/cashbox/data/models/cashbox_income_model.dart';
import 'package:diamond_clean/features/cashbox/data/models/cashbox_expense_model.dart';
import 'package:diamond_clean/features/cashbox/data/models/cashbox_settings_model.dart';

sealed class CashboxState {
  const CashboxState();
}

class CashboxInitial extends CashboxState {
  const CashboxInitial();
}

class CashboxLoading extends CashboxState {
  const CashboxLoading();
}

class CashboxLoaded extends CashboxState {
  static const TreasuryLogEntryMapper _treasuryLogEntryMapper =
      TreasuryLogEntryMapper();

  final DateTime selectedDay;
  final CashboxSettingsModel settings;

  /// Session-filtered data (current session only — for main screen display).
  final List<CashboxIncomeModel> sessionIncomeEntries;
  final List<CashboxExpenseModel> sessionExpenseEntries;
  final double sessionRevenue;
  final double sessionCashRevenue;
  final double sessionElectronicRevenue;
  final double sessionExpenses;
  final double sessionBalance;

  /// Full-day data (for treasury log & closures log).
  final List<CashboxIncomeModel> dailyIncomeEntries;
  final List<CashboxExpenseModel> dailyExpenses;
  final List<CashboxClosureModel> dailyClosures;

  /// Audit log for all operations.
  final List<CashboxAuditLogModel> auditLogs;

  /// Whether the day has ended (midnight reached) and cashbox should be closed.
  final bool isDayEnded;

  const CashboxLoaded({
    required this.selectedDay,
    required this.settings,
    required this.sessionIncomeEntries,
    required this.sessionExpenseEntries,
    required this.sessionRevenue,
    required this.sessionCashRevenue,
    required this.sessionElectronicRevenue,
    required this.sessionExpenses,
    required this.sessionBalance,
    required this.dailyIncomeEntries,
    required this.dailyExpenses,
    required this.dailyClosures,
    this.auditLogs = const [],
    this.isDayEnded = false,
  });

  List<TreasuryLogEntry> get treasuryLogEntries {
    return _treasuryLogEntryMapper.buildEntries(
      dailyIncomeEntries: dailyIncomeEntries,
      dailyExpenses: dailyExpenses,
      dailyClosures: dailyClosures,
    );
  }
}

class CashboxError extends CashboxState {
  final String message;

  const CashboxError(this.message);
}
