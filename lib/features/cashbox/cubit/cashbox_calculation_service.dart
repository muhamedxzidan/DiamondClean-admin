import '../data/models/cashbox_closure_model.dart';
import '../data/models/cashbox_expense_model.dart';
import '../data/models/cashbox_income_model.dart';
import '../data/models/cashbox_settings_model.dart';

typedef CashboxSessionSummary = ({
  List<CashboxIncomeModel> incomeEntries,
  List<CashboxExpenseModel> expenseEntries,
  double revenue,
  double expensesTotal,
  double balance,
});

class CashboxCalculationService {
  const CashboxCalculationService();

  DateTime dayStart(DateTime date) => DateTime(date.year, date.month, date.day);

  bool isSameDay(DateTime left, DateTime right) {
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }

  bool isViewingToday(DateTime selectedDay, DateTime todayStart) {
    return isSameDay(selectedDay, todayStart);
  }

  bool isWithinSession({
    required DateTime createdAt,
    required DateTime selectedDay,
    required DateTime openedAt,
    required DateTime todayStart,
  }) {
    final normalizedSelectedDay = dayStart(selectedDay);
    final sessionStart = isViewingToday(normalizedSelectedDay, todayStart)
        ? openedAt
        : normalizedSelectedDay;

    return !createdAt.isBefore(sessionStart) &&
        isSameDay(createdAt, normalizedSelectedDay);
  }

  List<CashboxIncomeModel> sessionIncomeEntries({
    required List<CashboxIncomeModel> incomeEntries,
    required DateTime selectedDay,
    required CashboxSettingsModel settings,
    required DateTime todayStart,
  }) {
    return incomeEntries.where((income) {
      return income.includeInCashbox &&
          isWithinSession(
            createdAt: income.createdAt,
            selectedDay: selectedDay,
            openedAt: settings.openedAt,
            todayStart: todayStart,
          );
    }).toList();
  }

  List<CashboxExpenseModel> sessionExpenseEntries({
    required List<CashboxExpenseModel> expenses,
    required DateTime selectedDay,
    required CashboxSettingsModel settings,
    required DateTime todayStart,
  }) {
    return expenses.where((expense) {
      return isWithinSession(
        createdAt: expense.createdAt,
        selectedDay: selectedDay,
        openedAt: settings.openedAt,
        todayStart: todayStart,
      );
    }).toList();
  }

  List<CashboxIncomeModel> dailyIncomeEntries({
    required List<CashboxIncomeModel> incomeEntries,
    required DateTime selectedDay,
  }) {
    return incomeEntries.where((income) {
      return income.includeInCashbox &&
          isSameDay(income.createdAt, selectedDay);
    }).toList();
  }

  List<CashboxExpenseModel> dailyExpenses({
    required List<CashboxExpenseModel> expenses,
    required DateTime selectedDay,
  }) {
    return expenses.where((expense) {
      return isSameDay(expense.createdAt, selectedDay);
    }).toList();
  }

  List<CashboxClosureModel> dailyClosures({
    required List<CashboxClosureModel> closures,
    required DateTime selectedDay,
  }) {
    return closures.where((closure) {
      return isSameDay(closure.closedAt, selectedDay);
    }).toList();
  }

  double sumIncome(List<CashboxIncomeModel> incomeEntries) {
    return incomeEntries.fold<double>(
      0,
      (sum, income) => sum + income.orderTotal,
    );
  }

  double sumCashIncome(List<CashboxIncomeModel> incomeEntries) {
    return incomeEntries
        .where(
          (income) =>
              income.paymentMethod == 'cash' || income.paymentMethod == null,
        )
        .fold<double>(0, (sum, income) => sum + income.orderTotal);
  }

  double sumExpenses(List<CashboxExpenseModel> expenseEntries) {
    return expenseEntries.fold<double>(
      0,
      (sum, expense) => sum + expense.amount,
    );
  }

  CashboxSessionSummary sessionSummary({
    required List<CashboxIncomeModel> incomeEntries,
    required List<CashboxExpenseModel> expenses,
    required DateTime selectedDay,
    required CashboxSettingsModel settings,
    required DateTime todayStart,
  }) {
    final filteredIncomeEntries = sessionIncomeEntries(
      incomeEntries: incomeEntries,
      selectedDay: selectedDay,
      settings: settings,
      todayStart: todayStart,
    );
    final filteredExpenseEntries = sessionExpenseEntries(
      expenses: expenses,
      selectedDay: selectedDay,
      settings: settings,
      todayStart: todayStart,
    );
    final revenue = sumIncome(filteredIncomeEntries);
    final cashRevenue = sumCashIncome(filteredIncomeEntries);
    final expensesTotal = sumExpenses(filteredExpenseEntries);

    return (
      incomeEntries: filteredIncomeEntries,
      expenseEntries: filteredExpenseEntries,
      revenue: revenue,
      expensesTotal: expensesTotal,
      balance: settings.openingBalance + cashRevenue - expensesTotal,
    );
  }
}
