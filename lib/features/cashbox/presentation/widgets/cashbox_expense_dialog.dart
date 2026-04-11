import 'package:flutter/material.dart';

import 'package:diamond_clean/core/constants/app_strings.dart';

import '../../cubit/cashbox_cubit.dart';
import '../../data/models/cashbox_expense_model.dart';
import '../../data/models/expense_category.dart';

Future<void> showCashboxExpenseDialog(
  BuildContext context,
  CashboxCubit cubit, {
  CashboxExpenseModel? expense,
}) async {
  final titleController = TextEditingController(text: expense?.title ?? '');
  final amountController = TextEditingController(
    text: expense?.amount.toStringAsFixed(2) ?? '',
  );
  var selectedCategory = expense?.category ?? ExpenseCategory.other;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setDialogState) => AlertDialog(
        title: Text(
          expense == null
              ? AppStrings.cashboxAddExpense
              : AppStrings.cashboxEditExpense,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<ExpenseCategory>(
              initialValue: selectedCategory,
              decoration: const InputDecoration(
                labelText: AppStrings.cashboxExpenseCategory,
              ),
              items: ExpenseCategory.values
                  .where((c) => c != ExpenseCategory.salary && c != ExpenseCategory.advance)
                  .map(
                    (c) => DropdownMenuItem(value: c, child: Text(c.label)),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setDialogState(() => selectedCategory = value);
                }
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: AppStrings.cashboxExpenseName,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: AppStrings.cashboxExpenseAmount,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text(AppStrings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(AppStrings.save),
          ),
        ],
      ),
    ),
  );

  if (confirmed == true && context.mounted) {
    final title = titleController.text.trim();
    final amount = double.tryParse(amountController.text.trim()) ?? 0;
    if (title.isEmpty || amount <= 0) return;

    if (expense == null) {
      await cubit.addExpense(
        title: title,
        amount: amount,
        category: selectedCategory,
      );
    } else {
      await cubit.updateExpense(
        expense.copyWith(
          title: title,
          amount: amount,
          category: selectedCategory,
        ),
      );
    }
  }
}
