import 'package:diamond_clean/core/constants/app_strings.dart';
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
  final DateTime selectedDay;
  final CashboxSettingsModel settings;

  /// Session-filtered data (current session only — for main screen display).
  final List<CashboxIncomeModel> sessionIncomeEntries;
  final List<CashboxExpenseModel> sessionExpenseEntries;
  final double sessionRevenue;
  final double sessionExpenses;
  final double sessionBalance;

  /// Full-day data (for treasury log & closures log).
  final List<CashboxIncomeModel> dailyIncomeEntries;
  final List<CashboxExpenseModel> dailyExpenses;
  final List<CashboxClosureModel> dailyClosures;

  const CashboxLoaded({
    required this.selectedDay,
    required this.settings,
    required this.sessionIncomeEntries,
    required this.sessionExpenseEntries,
    required this.sessionRevenue,
    required this.sessionExpenses,
    required this.sessionBalance,
    required this.dailyIncomeEntries,
    required this.dailyExpenses,
    required this.dailyClosures,
  });

  List<CashboxTreasuryLogEntry> get treasuryLogEntries {
    final entries = <CashboxTreasuryLogEntry>[];

    for (final income in dailyIncomeEntries) {
      entries.add(
        CashboxTreasuryLogEntry(
          type: AppStrings.cashboxEventOrderIncome,
          dateTime: income.createdAt,
          amount: income.orderTotal,
          note: income.customerName,
        ),
      );
    }

    for (final expense in dailyExpenses) {
      entries.add(
        CashboxTreasuryLogEntry(
          type: AppStrings.cashboxEventExpense,
          dateTime: expense.createdAt,
          amount: -expense.amount,
          note: expense.title,
        ),
      );
    }

    for (final closure in dailyClosures) {
      entries.add(
        CashboxTreasuryLogEntry(
          type: AppStrings.cashboxEventClosure,
          dateTime: closure.closedAt,
          amount: closure.closingBalance,
          note: closure.closedBy,
        ),
      );
    }

    entries.sort((left, right) => right.dateTime.compareTo(left.dateTime));
    return entries;
  }
}

class CashboxTreasuryLogEntry {
  final String type;
  final DateTime dateTime;
  final double amount;
  final String note;

  const CashboxTreasuryLogEntry({
    required this.type,
    required this.dateTime,
    required this.amount,
    required this.note,
  });
}

class CashboxError extends CashboxState {
  final String message;

  const CashboxError(this.message);
}
