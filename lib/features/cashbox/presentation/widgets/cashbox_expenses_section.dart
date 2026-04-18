import 'package:diamond_clean/features/cashbox/data/models/cashbox_expense_model.dart'
    as diamond_clean_expense;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:diamond_clean/core/constants/app_strings.dart';
import 'package:diamond_clean/core/widgets/custom_card.dart';
import 'package:diamond_clean/core/widgets/state_widgets.dart';

import '../../cubit/cashbox_cubit.dart';
import '../../cubit/cashbox_state.dart';
import 'cashbox_expense_dialog.dart';

class CashboxExpensesSection extends StatelessWidget {
  final CashboxLoaded state;

  const CashboxExpensesSection({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cubit = context.read<CashboxCubit>();
    return CustomCard(
      padding: EdgeInsets.zero,
      child: ExpansionTile(
        initiallyExpanded: false,
        shape: const Border(),
        collapsedShape: const Border(),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        title: Row(
          children: [
            Text(
              AppStrings.cashboxExpenseHistory,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                state.sessionExpenses.toStringAsFixed(2),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                ),
              ),
            ),
          ],
        ),
        children: [
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                if (state.sessionExpenseEntries.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: EmptyStateWidget(
                      message: AppStrings.cashboxNoExpenses,
                    ),
                  )
                else
                  ...state.sessionExpenseEntries.map(
                    (expense) =>
                        CashboxExpenseListItem(expense: expense, cubit: cubit),
                  ),
                const SizedBox(height: 8),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: FilledButton.icon(
                    onPressed: () => showCashboxExpenseDialog(context, cubit),
                    icon: const Icon(Icons.add),
                    label: const Text(AppStrings.cashboxAddExpense),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CashboxExpenseListItem extends StatelessWidget {
  final diamond_clean_expense.CashboxExpenseModel expense;
  final CashboxCubit cubit;

  const CashboxExpenseListItem({
    super.key,
    required this.expense,
    required this.cubit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: CustomCard(
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(expense.title),
          subtitle: Text(expense.createdBy ?? ''),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(expense.amount.toStringAsFixed(2)),
              IconButton(
                onPressed: () =>
                    showCashboxExpenseDialog(context, cubit, expense: expense),
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                onPressed: () => cubit.deleteExpense(expense.id),
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
