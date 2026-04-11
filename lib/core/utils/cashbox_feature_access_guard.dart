import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:diamond_clean/core/constants/app_strings.dart';

Future<bool> requestCashboxFeatureAccess(
  BuildContext context, {
  required String? ownerPin,
}) async {
  if (ownerPin == null || ownerPin.isEmpty) {
    return true;
  }

  final controller = TextEditingController();
  var hasError = false;

  final isAllowed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: const Text(AppStrings.cashboxPinLocked),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(AppStrings.cashboxPinEnterPrompt),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
              autofocus: true,
              enableSuggestions: false,
              autocorrect: false,
              enableIMEPersonalizedLearning: false,
              autofillHints: const <String>[],
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                hintText: AppStrings.cashboxPinHint,
                counterText: '',
                errorText: hasError ? AppStrings.cashboxPinWrong : null,
              ),
              onChanged: (_) {
                if (hasError) {
                  setDialogState(() => hasError = false);
                }
              },
              onSubmitted: (_) {
                if (controller.text == ownerPin) {
                  Navigator.pop(dialogContext, true);
                  return;
                }
                setDialogState(() => hasError = true);
                controller.clear();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text(AppStrings.cancel),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text == ownerPin) {
                Navigator.pop(dialogContext, true);
                return;
              }
              setDialogState(() => hasError = true);
              controller.clear();
            },
            child: const Text(AppStrings.cashboxPinUnlock),
          ),
        ],
      ),
    ),
  );

  controller.dispose();
  return isAllowed == true;
}
