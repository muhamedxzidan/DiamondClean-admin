import 'package:diamond_clean/features/cashbox/cubit/cashbox_calculation_service.dart';
import 'package:diamond_clean/features/cashbox/data/models/cashbox_closure_model.dart';
import 'package:diamond_clean/features/cashbox/data/models/cashbox_expense_model.dart';
import 'package:diamond_clean/features/cashbox/data/models/cashbox_income_model.dart';
import 'package:diamond_clean/features/cashbox/data/models/cashbox_settings_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = CashboxCalculationService();

  test('sessionSummary uses opening + cash income - session expenses', () {
    final selectedDay = DateTime(2026, 4, 11);
    final settings = CashboxSettingsModel(
      openingBalance: 100,
      openedAt: DateTime(2026, 4, 11, 9),
    );

    final incomeEntries = [
      CashboxIncomeModel(
        orderId: 'cash-1',
        orderTotal: 200,
        deliveryFee: 0,
        customerName: 'A',
        customerPhone: '1',
        paymentMethod: 'cash',
        includeInCashbox: true,
        createdAt: DateTime(2026, 4, 11, 10),
      ),
      CashboxIncomeModel(
        orderId: 'card-1',
        orderTotal: 120,
        deliveryFee: 0,
        customerName: 'B',
        customerPhone: '2',
        paymentMethod: 'card',
        includeInCashbox: true,
        createdAt: DateTime(2026, 4, 11, 10, 30),
      ),
      CashboxIncomeModel(
        orderId: 'before-open',
        orderTotal: 50,
        deliveryFee: 0,
        customerName: 'C',
        customerPhone: '3',
        paymentMethod: 'cash',
        includeInCashbox: true,
        createdAt: DateTime(2026, 4, 11, 8),
      ),
      CashboxIncomeModel(
        orderId: 'excluded',
        orderTotal: 75,
        deliveryFee: 0,
        customerName: 'D',
        customerPhone: '4',
        paymentMethod: 'cash',
        includeInCashbox: false,
        createdAt: DateTime(2026, 4, 11, 10),
      ),
    ];

    final expenseEntries = [
      CashboxExpenseModel(
        id: 'e1',
        title: 'expense-session',
        amount: 40,
        createdAt: DateTime(2026, 4, 11, 11),
      ),
      CashboxExpenseModel(
        id: 'e2',
        title: 'expense-before-open',
        amount: 30,
        createdAt: DateTime(2026, 4, 11, 8),
      ),
    ];

    final summary = service.sessionSummary(
      incomeEntries: incomeEntries,
      expenses: expenseEntries,
      selectedDay: selectedDay,
      settings: settings,
      todayStart: DateTime(2026, 4, 11),
    );

    expect(summary.incomeEntries.length, 2);
    expect(summary.expenseEntries.length, 1);
    expect(summary.revenue, 320);
    expect(summary.expensesTotal, 40);
    expect(summary.balance, 260);
  });

  test('daily lists include all same-day entries regardless of openedAt', () {
    final selectedDay = DateTime(2026, 4, 11);

    final incomeEntries = [
      CashboxIncomeModel(
        orderId: 'before-open',
        orderTotal: 60,
        deliveryFee: 0,
        customerName: 'A',
        customerPhone: '1',
        includeInCashbox: true,
        createdAt: DateTime(2026, 4, 11, 8),
      ),
      CashboxIncomeModel(
        orderId: 'next-day',
        orderTotal: 70,
        deliveryFee: 0,
        customerName: 'B',
        customerPhone: '2',
        includeInCashbox: true,
        createdAt: DateTime(2026, 4, 12, 9),
      ),
    ];

    final expenses = [
      CashboxExpenseModel(
        id: 'e1',
        title: 'same-day',
        amount: 10,
        createdAt: DateTime(2026, 4, 11, 9),
      ),
      CashboxExpenseModel(
        id: 'e2',
        title: 'next-day',
        amount: 20,
        createdAt: DateTime(2026, 4, 12, 9),
      ),
    ];

    final closures = [
      CashboxClosureModel(
        id: 'c1',
        closedBy: 'admin',
        openingBalance: 100,
        totalRevenue: 60,
        totalExpenses: 10,
        closingBalance: 150,
        ordersCount: 1,
        expenses: const [],
        closedAt: DateTime(2026, 4, 11, 18),
      ),
      CashboxClosureModel(
        id: 'c2',
        closedBy: 'admin',
        openingBalance: 100,
        totalRevenue: 70,
        totalExpenses: 20,
        closingBalance: 150,
        ordersCount: 1,
        expenses: const [],
        closedAt: DateTime(2026, 4, 12, 18),
      ),
    ];

    expect(
      service
          .dailyIncomeEntries(
            incomeEntries: incomeEntries,
            selectedDay: selectedDay,
          )
          .length,
      1,
    );

    expect(
      service
          .dailyExpenses(expenses: expenses, selectedDay: selectedDay)
          .length,
      1,
    );

    expect(
      service
          .dailyClosures(closures: closures, selectedDay: selectedDay)
          .length,
      1,
    );
  });
}
