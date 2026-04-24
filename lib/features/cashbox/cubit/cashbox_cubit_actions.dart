part of 'cashbox_cubit.dart';

Future<void> _cashboxSaveOpeningBalance(
  CashboxCubit cubit,
  double openingBalance,
  String openedBy,
) async {
  final amountValidation = CashboxValidator.validateOpeningBalance(
    openingBalance,
  );
  if (amountValidation is CashboxValidationFailure) {
    await _cashboxLogAuditEvent(
      cubit,
      eventType: AuditEventType.validationFailed,
      operationId: 'opening_balance',
      performedBy: openedBy,
      amount: openingBalance,
      description: 'Failed: ${amountValidation.reason}',
      isValid: false,
      validationError: amountValidation.reason,
    );
    throw Exception(amountValidation.reason);
  }

  final userValidation = CashboxValidator.validateUserName(openedBy);
  if (userValidation is CashboxValidationFailure) {
    await _cashboxLogAuditEvent(
      cubit,
      eventType: AuditEventType.validationFailed,
      operationId: 'opening_balance',
      performedBy: openedBy,
      amount: openingBalance,
      description: 'Failed: ${userValidation.reason}',
      isValid: false,
      validationError: userValidation.reason,
    );
    throw Exception(userValidation.reason);
  }

  await _cashboxPerformMutation(cubit, () async {
    await cubit._dataSource.saveOpeningBalance(
      openingBalance: openingBalance,
      openedBy: openedBy,
    );

    await _cashboxLogAuditEvent(
      cubit,
      eventType: AuditEventType.openingBalanceSet,
      operationId: 'opening_balance_${DateTime.now().microsecondsSinceEpoch}',
      performedBy: openedBy,
      amount: openingBalance,
      description: 'Opened cashbox with balance',
      isValid: true,
    );
  });
}

Future<void> _cashboxAddExpense(
  CashboxCubit cubit, {
  required String title,
  required double amount,
  ExpenseCategory category = ExpenseCategory.other,
  String? createdBy,
}) async {
  final validation = CashboxValidator.validateExpense(
    amount: amount,
    title: title,
  );
  if (validation is CashboxValidationFailure) {
    await _cashboxLogAuditEvent(
      cubit,
      eventType: AuditEventType.validationFailed,
      operationId: 'expense_add',
      performedBy: createdBy ?? 'System',
      amount: amount,
      description: 'Failed: ${validation.reason}',
      isValid: false,
      validationError: validation.reason,
    );
    throw Exception(validation.reason);
  }

  await _cashboxPerformMutation(cubit, () async {
    final now = DateTime.now();
    final expenseId = now.microsecondsSinceEpoch.toString();
    final expense = CashboxExpenseModel(
      id: expenseId,
      title: title,
      amount: amount,
      category: category,
      createdBy: createdBy,
      createdAt: now,
    );
    await cubit._dataSource.addExpense(expense);

    await _cashboxLogAuditEvent(
      cubit,
      eventType: AuditEventType.expenseAdded,
      operationId: expenseId,
      performedBy: createdBy ?? 'System',
      amount: amount,
      description: 'Added expense: $title',
      metadata: {'category': category.value, 'title': title},
      isValid: true,
    );
  });
}

Future<void> _cashboxUpdateExpense(
  CashboxCubit cubit,
  CashboxExpenseModel expense,
) {
  return _cashboxPerformMutation(cubit, () {
    return cubit._dataSource.updateExpense(expense);
  });
}

Future<void> _cashboxDeleteExpense(CashboxCubit cubit, String expenseId) async {
  await _cashboxPerformMutation(cubit, () async {
    final expense = cubit._expenses.firstWhere(
      (e) => e.id == expenseId,
      orElse: () => CashboxExpenseModel(
        id: expenseId,
        title: 'Unknown',
        amount: 0,
        createdAt: DateTime.now(),
      ),
    );

    await cubit._dataSource.deleteExpense(expenseId);

    await _cashboxLogAuditEvent(
      cubit,
      eventType: AuditEventType.expenseDeleted,
      operationId: expenseId,
      performedBy: 'System',
      amount: expense.amount,
      description: 'Deleted expense: ${expense.title}',
      metadata: {
        'original_title': expense.title,
        'original_amount': expense.amount,
        'original_category': expense.category.value,
      },
      isValid: true,
    );
  });
}

Future<void> _cashboxSavePin(CashboxCubit cubit, String? pin) {
  return _cashboxPerformMutation(cubit, () {
    return cubit._dataSource.savePin(pin);
  });
}

Future<void> _cashboxCloseCashbox(CashboxCubit cubit, String closedBy) async {
  final userValidation = CashboxValidator.validateUserName(closedBy);
  if (userValidation is CashboxValidationFailure) {
    throw Exception(userValidation.reason);
  }

  await _cashboxPerformMutation(cubit, () async {
    final sessionSummary = _cashboxSessionSummary(cubit);

    final balanceValidation = CashboxValidator.validateClosingBalance(
      cubit._settings.openingBalance,
      sessionSummary.revenue,
      sessionSummary.expensesTotal,
    );
    if (balanceValidation is CashboxValidationFailure) {
      await _cashboxLogAuditEvent(
        cubit,
        eventType: AuditEventType.validationFailed,
        operationId: 'cashbox_close',
        performedBy: closedBy,
        amount: sessionSummary.balance,
        description: 'Failed: ${balanceValidation.reason}',
        isValid: false,
        validationError: balanceValidation.reason,
      );
      throw Exception(balanceValidation.reason);
    }

    await cubit._dataSource.closeCashbox(
      closedBy: closedBy,
      openingBalance: cubit._settings.openingBalance,
      totalRevenue: sessionSummary.revenue,
      totalExpenses: sessionSummary.expensesTotal,
      closingBalance: sessionSummary.balance,
      ordersCount: sessionSummary.incomeEntries.length,
      expenses: sessionSummary.expenseEntries,
    );

    await _cashboxLogAuditEvent(
      cubit,
      eventType: AuditEventType.cashboxClosed,
      operationId: 'cashbox_close_${DateTime.now().microsecondsSinceEpoch}',
      performedBy: closedBy,
      amount: sessionSummary.balance,
      description: 'Closed cashbox',
      metadata: {
        'opening_balance': cubit._settings.openingBalance,
        'total_revenue': sessionSummary.revenue,
        'total_expenses': sessionSummary.expensesTotal,
        'closing_balance': sessionSummary.balance,
        'orders_count': sessionSummary.incomeEntries.length,
      },
      isValid: true,
    );
  });
}

Future<void> _cashboxClearAllData(CashboxCubit cubit) async {
  await cubit._dataSource.clearAllCashboxData();
  
  await _cashboxLogAuditEvent(
    cubit,
    eventType: AuditEventType.factoryReset,
    operationId: 'clear_all_data_${DateTime.now().microsecondsSinceEpoch}',
    performedBy: 'Admin',
    amount: 0.0,
    description: 'DANGER: Factory reset of all cashbox financial data.',
    isValid: true,
  );
}
