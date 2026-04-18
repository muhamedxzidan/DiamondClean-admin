import 'package:diamond_clean/core/constants/app_strings.dart';
import 'package:diamond_clean/core/models/treasury_log_entry.dart';
import 'package:diamond_clean/features/cashbox/data/models/cashbox_closure_model.dart';
import 'package:diamond_clean/features/cashbox/data/models/cashbox_expense_model.dart';
import 'package:diamond_clean/features/cashbox/data/models/cashbox_income_model.dart';

class TreasuryLogEntryMapper {
  const TreasuryLogEntryMapper();

  List<TreasuryLogEntry> buildEntries({
    required List<CashboxIncomeModel> dailyIncomeEntries,
    required List<CashboxExpenseModel> dailyExpenses,
    required List<CashboxClosureModel> dailyClosures,
  }) {
    final entries = <TreasuryLogEntry>[];

    for (final income in dailyIncomeEntries) {
      entries.add(
        TreasuryLogEntry(
          type: _incomeType(income),
          dateTime: income.createdAt,
          amount: income.orderTotal,
          note: income.customerName,
          paymentMethod: income.paymentMethod,
        ),
      );
    }

    for (final expense in dailyExpenses) {
      entries.add(
        TreasuryLogEntry(
          type: expense.category.label,
          dateTime: expense.createdAt,
          amount: -expense.amount,
          note: expense.title,
        ),
      );
    }

    for (final closure in dailyClosures) {
      entries.add(
        TreasuryLogEntry(
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

  String _incomeType(CashboxIncomeModel income) {
    if (income.orderId.endsWith('_remaining')) {
      return AppStrings.cashboxEventOrderRemainingPayment;
    }

    if (income.remainingAmount > 0) {
      return AppStrings.cashboxEventOrderPartialPayment;
    }

    return AppStrings.cashboxEventOrderFullPayment;
  }
}
