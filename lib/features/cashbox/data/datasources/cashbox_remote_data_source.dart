import 'package:diamond_clean/features/cashbox/data/models/cashbox_closure_model.dart';
import 'package:diamond_clean/features/cashbox/data/models/cashbox_income_model.dart';
import 'package:diamond_clean/features/cashbox/data/models/cashbox_expense_model.dart';
import 'package:diamond_clean/features/cashbox/data/models/cashbox_settings_model.dart';

abstract class CashboxRemoteDataSource {
  Stream<List<CashboxIncomeModel>> watchIncomeEntries();
  Stream<List<CashboxExpenseModel>> watchExpenses();
  Stream<List<CashboxClosureModel>> watchClosures();
  Stream<CashboxSettingsModel?> watchSettings();
  Future<void> recordOrderIncome(CashboxIncomeModel income);
  Future<void> saveOpeningBalance({
    required double openingBalance,
    required String openedBy,
  });
  Future<void> addExpense(CashboxExpenseModel expense);
  Future<void> updateExpense(CashboxExpenseModel expense);
  Future<void> deleteExpense(String expenseId);
  Future<void> closeCashbox({
    required String closedBy,
    required double openingBalance,
    required double totalRevenue,
    required double totalExpenses,
    required double closingBalance,
    required int ordersCount,
    required List<CashboxExpenseModel> expenses,
  });
  Future<void> savePin(String? pin);
}
