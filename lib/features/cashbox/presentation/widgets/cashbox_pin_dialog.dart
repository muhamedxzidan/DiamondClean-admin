import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:diamond_clean/core/constants/app_strings.dart';

import '../../cubit/cashbox_cubit.dart';

Future<void> showCashboxPinDialog(
  BuildContext context,
  String? currentPin,
  CashboxCubit cubit,
) async {
  final isSettingNew = currentPin == null;
  final currentController = TextEditingController();
  final newController = TextEditingController();
  final confirmController = TextEditingController();
  String? errorText;

  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: Text(
          isSettingNew ? AppStrings.cashboxPinSet : AppStrings.cashboxPinChange,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isSettingNew) ...[
              TextField(
                controller: currentController,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 4,
                enableSuggestions: false,
                autocorrect: false,
                enableIMEPersonalizedLearning: false,
                autofillHints: const <String>[],
                decoration: const InputDecoration(
                  labelText: AppStrings.cashboxPinCurrentHint,
                  counterText: '',
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 12),
            ],
            TextField(
              controller: newController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
              enableSuggestions: false,
              autocorrect: false,
              enableIMEPersonalizedLearning: false,
              autofillHints: const <String>[],
              decoration: const InputDecoration(
                labelText: AppStrings.cashboxPinNewHint,
                counterText: '',
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
              enableSuggestions: false,
              autocorrect: false,
              enableIMEPersonalizedLearning: false,
              autofillHints: const <String>[],
              decoration: InputDecoration(
                labelText: AppStrings.cashboxPinConfirmHint,
                counterText: '',
                errorText: errorText,
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (_) {
                if (errorText != null) {
                  setDialogState(() => errorText = null);
                }
              },
            ),
          ],
        ),
        actions: [
          if (!isSettingNew)
            TextButton(
              onPressed: () {
                if (currentController.text != currentPin) {
                  setDialogState(() => errorText = AppStrings.cashboxPinWrong);
                  return;
                }
                Navigator.pop(dialogContext, null);
              },
              child: const Text(AppStrings.cashboxPinRemove),
            ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text(AppStrings.cancel),
          ),
          FilledButton(
            onPressed: () {
              if (!isSettingNew && currentController.text != currentPin) {
                setDialogState(() => errorText = AppStrings.cashboxPinWrong);
                return;
              }
              if (newController.text.length != 4) {
                setDialogState(() => errorText = AppStrings.cashboxPinHint);
                return;
              }
              if (newController.text != confirmController.text) {
                setDialogState(() => errorText = AppStrings.cashboxPinMismatch);
                return;
              }
              Navigator.pop(dialogContext, true);
            },
            child: const Text(AppStrings.save),
          ),
        ],
      ),
    ),
  );

  if (!context.mounted) return;

  final messenger = ScaffoldMessenger.of(context);
  if (result == null) {
    await cubit.savePin(null);
    messenger.showSnackBar(
      const SnackBar(content: Text(AppStrings.cashboxPinRemoved)),
    );
  } else if (result == true) {
    await cubit.savePin(newController.text.trim());
    messenger.showSnackBar(
      const SnackBar(content: Text(AppStrings.cashboxPinSaved)),
    );
  }
}
