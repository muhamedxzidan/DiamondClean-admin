import 'package:flutter/material.dart';

import 'package:diamond_clean/core/constants/app_strings.dart';

import '../../cubit/cashbox_cubit.dart';

Future<void> showCashboxOpeningBalanceDialog(
  BuildContext context,
  CashboxCubit cubit,
) async {
  final balanceController = TextEditingController();
  final nameController = TextEditingController();

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text(AppStrings.cashboxSetOpeningBalance),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: balanceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: AppStrings.cashboxOpeningBalance,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: AppStrings.cashboxOpenedBy,
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
  );

  if (confirmed == true && context.mounted) {
    final amount = double.tryParse(balanceController.text.trim()) ?? 0;
    await cubit.saveOpeningBalance(amount, nameController.text.trim());
  }
}
