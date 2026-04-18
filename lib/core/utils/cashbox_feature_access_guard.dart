import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:diamond_clean/core/constants/app_strings.dart';

bool _isCashboxAccessDialogOpen = false;

Future<bool> requestCashboxFeatureAccess(
  BuildContext context, {
  required String? ownerPin,
}) async {
  if (ownerPin == null || ownerPin.isEmpty) {
    return true;
  }

  if (_isCashboxAccessDialogOpen) {
    return false;
  }

  _isCashboxAccessDialogOpen = true;

  try {
    final completer = Completer<bool?>();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!context.mounted) {
        if (!completer.isCompleted) {
          completer.complete(false);
        }
        return;
      }

      final isAllowed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => _CashboxAccessDialogContent(ownerPin: ownerPin),
      );

      if (!completer.isCompleted) {
        completer.complete(isAllowed);
      }
    });

    return await completer.future == true;
  } finally {
    _isCashboxAccessDialogOpen = false;
  }
}

class _CashboxAccessDialogContent extends StatefulWidget {
  final String ownerPin;

  const _CashboxAccessDialogContent({required this.ownerPin});

  @override
  State<_CashboxAccessDialogContent> createState() => _CashboxAccessDialogContentState();
}

class _CashboxAccessDialogContentState extends State<_CashboxAccessDialogContent> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit() {
    if (_controller.text == widget.ownerPin) {
      Navigator.pop(context, true);
      return;
    }
    setState(() => _hasError = true);
    _controller.clear();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(AppStrings.cashboxPinLocked),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(AppStrings.cashboxPinEnterPrompt),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            keyboardType: TextInputType.number,
            obscureText: true,
            maxLength: 4,
            enableSuggestions: false,
            autocorrect: false,
            enableIMEPersonalizedLearning: false,
            autofillHints: const <String>[],
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              hintText: AppStrings.cashboxPinHint,
              counterText: '',
              errorText: _hasError ? AppStrings.cashboxPinWrong : null,
            ),
            onChanged: (_) {
              if (_hasError) {
                setState(() => _hasError = false);
              }
            },
            onSubmitted: (_) => _submit(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text(AppStrings.cancel),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text(AppStrings.cashboxPinUnlock),
        ),
      ],
    );
  }
}
