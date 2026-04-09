import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:diamond_clean/core/constants/app_strings.dart';

class CashboxPinOverlay extends StatefulWidget {
  final String storedPin;
  final VoidCallback onUnlocked;

  const CashboxPinOverlay({
    super.key,
    required this.storedPin,
    required this.onUnlocked,
  });

  @override
  State<CashboxPinOverlay> createState() => _CashboxPinOverlayState();
}

class _CashboxPinOverlayState extends State<CashboxPinOverlay> {
  final _controller = TextEditingController();
  bool _hasError = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _verify() {
    if (_controller.text == widget.storedPin) {
      widget.onUnlocked();
    } else {
      setState(() => _hasError = true);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Card(
        margin: const EdgeInsets.all(32),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 48,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  AppStrings.cashboxPinLocked,
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  AppStrings.cashboxPinEnterPrompt,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 4,
                  autofocus: true,
                  textAlign: TextAlign.center,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    hintText: AppStrings.cashboxPinHint,
                    counterText: '',
                    errorText: _hasError ? AppStrings.cashboxPinWrong : null,
                  ),
                  onChanged: (_) {
                    if (_hasError) setState(() => _hasError = false);
                  },
                  onSubmitted: (_) => _verify(),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _verify,
                    child: const Text(AppStrings.cashboxPinUnlock),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
