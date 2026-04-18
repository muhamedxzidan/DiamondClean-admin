import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:diamond_clean/core/constants/app_strings.dart';

import '../../cubit/cashbox_cubit.dart';

typedef _CashboxPinDialogResult = ({bool? shouldSavePin, String? newPin});

Future<void> showCashboxPinDialog(
  BuildContext context,
  String? currentPin,
  CashboxCubit cubit,
) async {
  final result = await _showCashboxPinDialog(context, currentPin);

  if (!context.mounted || result == null) {
    return;
  }

  final messenger = ScaffoldMessenger.of(context);

  if (result.shouldSavePin == null) {
    await cubit.savePin(null);
    messenger.showSnackBar(
      const SnackBar(content: Text(AppStrings.cashboxPinRemoved)),
    );
    return;
  }

  if (result.shouldSavePin == true) {
    await cubit.savePin(result.newPin);
    messenger.showSnackBar(
      const SnackBar(content: Text(AppStrings.cashboxPinSaved)),
    );
  }
}

Future<_CashboxPinDialogResult?> _showCashboxPinDialog(
  BuildContext context,
  String? currentPin,
) {
  final completer = Completer<_CashboxPinDialogResult?>();

  WidgetsBinding.instance.addPostFrameCallback((_) async {
    if (!context.mounted) {
      if (!completer.isCompleted) {
        completer.complete(null);
      }
      return;
    }

    final result = await showDialog<_CashboxPinDialogResult>(
      context: context,
      builder: (_) => _CashboxPinDialog(currentPin: currentPin),
    );

    if (!completer.isCompleted) {
      completer.complete(result);
    }
  });

  return completer.future;
}

class _CashboxPinDialog extends StatefulWidget {
  final String? currentPin;

  const _CashboxPinDialog({required this.currentPin});

  @override
  State<_CashboxPinDialog> createState() => _CashboxPinDialogState();
}

class _CashboxPinDialogState extends State<_CashboxPinDialog> {
  late final TextEditingController _currentController;
  late final TextEditingController _newController;
  late final TextEditingController _confirmController;
  late final FocusNode _newPinFocusNode;
  String? _errorText;

  bool get _isSettingNew => widget.currentPin == null;

  @override
  void initState() {
    super.initState();
    _currentController = TextEditingController();
    _newController = TextEditingController();
    _confirmController = TextEditingController();
    _newPinFocusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _newPinFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    _newPinFocusNode.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_isSettingNew && _currentController.text != widget.currentPin) {
      setState(() => _errorText = AppStrings.cashboxPinWrong);
      return;
    }

    if (_newController.text.length != 4) {
      setState(() => _errorText = AppStrings.cashboxPinHint);
      return;
    }

    if (_newController.text != _confirmController.text) {
      setState(() => _errorText = AppStrings.cashboxPinMismatch);
      return;
    }

    Navigator.of(
      context,
    ).pop((shouldSavePin: true, newPin: _newController.text.trim()));
  }

  void _removePin() {
    if (_currentController.text != widget.currentPin) {
      setState(() => _errorText = AppStrings.cashboxPinWrong);
      return;
    }

    Navigator.of(context).pop((shouldSavePin: null, newPin: null));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        _isSettingNew ? AppStrings.cashboxPinSet : AppStrings.cashboxPinChange,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!_isSettingNew) ...[
            TextField(
              controller: _currentController,
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
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 12),
          ],
          TextField(
            controller: _newController,
            focusNode: _newPinFocusNode,
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
            onChanged: (_) {
              if (_errorText != null) {
                setState(() => _errorText = null);
              }
            },
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _confirmController,
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
              errorText: _errorText,
            ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (_) {
              if (_errorText != null) {
                setState(() => _errorText = null);
              }
            },
            onSubmitted: (_) => _submit(),
          ),
        ],
      ),
      actions: [
        if (!_isSettingNew)
          TextButton(
            onPressed: _removePin,
            child: const Text(AppStrings.cashboxPinRemove),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text(AppStrings.cancel),
        ),
        FilledButton(onPressed: _submit, child: const Text(AppStrings.save)),
      ],
    );
  }
}
