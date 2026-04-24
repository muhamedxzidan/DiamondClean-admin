import 'package:diamond_clean/core/constants/app_strings.dart';
import 'package:diamond_clean/features/cashbox/cubit/cashbox_state.dart';
import 'package:diamond_clean/features/cashbox/data/models/cashbox_closure_model.dart';
import 'package:diamond_clean/features/cashbox/data/models/cashbox_expense_model.dart';
import 'package:diamond_clean/features/cashbox/data/models/cashbox_income_model.dart';
import 'package:diamond_clean/features/cashbox/data/models/cashbox_settings_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CashboxLoaded treasuryLogEntries merges and sorts daily data', () {
    final state = CashboxLoaded(
      selectedDay: DateTime(2026, 4, 9),
      settings: CashboxSettingsModel.initial(),
      sessionIncomeEntries: const [],
      sessionExpenseEntries: const [],
      sessionRevenue: 0,
      sessionCashRevenue: 0,
      sessionElectronicRevenue: 0,
      sessionExpenses: 0,
      sessionBalance: 0,
      dailyIncomeEntries: [
        CashboxIncomeModel(
          orderId: 'order-1',
          orderTotal: 120,
          deliveryFee: 10,
          customerName: 'أحمد',
          customerPhone: '01000000000',
          includeInCashbox: true,
          createdAt: DateTime(2026, 4, 9, 14, 0),
        ),
      ],
      dailyExpenses: [
        CashboxExpenseModel(
          id: 'expense-1',
          title: 'صيانة',
          amount: 30,
          createdAt: DateTime(2026, 4, 9, 16, 0),
        ),
      ],
      dailyClosures: [
        CashboxClosureModel(
          id: 'closure-1',
          closedBy: 'مدير الخزنة',
          openingBalance: 50,
          totalRevenue: 120,
          totalExpenses: 30,
          closingBalance: 140,
          ordersCount: 1,
          expenses: const [],
          closedAt: DateTime(2026, 4, 9, 18, 0),
        ),
      ],
    );

    final entries = state.treasuryLogEntries;

    expect(entries, hasLength(3));
    expect(entries.map((entry) => entry.type), [
      AppStrings.cashboxEventClosure,
      'أخرى',
      AppStrings.cashboxEventOrderFullPayment,
    ]);
    expect(entries.map((entry) => entry.amount), [140, -30, 120]);
  });
}
