import 'package:flutter/material.dart';

import 'package:diamond_clean/core/constants/app_strings.dart';

import '../../data/models/order_model.dart';

class RemainingPaymentResult {
  final OrderPaymentMethod paymentMethod;
  final double amount;

  const RemainingPaymentResult({
    required this.paymentMethod,
    required this.amount,
  });
}

Future<RemainingPaymentResult?> showRemainingPaymentDialog(
  BuildContext context, {
  required double remainingAmount,
}) {
  return showDialog<RemainingPaymentResult>(
    context: context,
    builder: (_) => _RemainingPaymentDialog(remainingAmount: remainingAmount),
  );
}

class _RemainingPaymentDialog extends StatefulWidget {
  final double remainingAmount;

  const _RemainingPaymentDialog({required this.remainingAmount});

  @override
  State<_RemainingPaymentDialog> createState() =>
      _RemainingPaymentDialogState();
}

class _RemainingPaymentDialogState extends State<_RemainingPaymentDialog> {
  var _selectedMethod = OrderPaymentMethod.cash;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text(AppStrings.confirmRemainingPayment),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${AppStrings.remainingAmountLabel}: ${widget.remainingAmount.toStringAsFixed(2)} ${AppStrings.currency}',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.paymentMethodTitle,
            style: theme.textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          ...OrderPaymentMethod.values.map(
            (method) => RadioListTile<OrderPaymentMethod>(
              value: method,
              // ignore: deprecated_member_use
              groupValue: _selectedMethod,
              title: Text(_paymentLabel(method)),
              dense: true,
              contentPadding: EdgeInsets.zero,
              // ignore: deprecated_member_use
              onChanged: (v) {
                if (v != null) setState(() => _selectedMethod = v);
              },
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(AppStrings.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(
            context,
            RemainingPaymentResult(
              paymentMethod: _selectedMethod,
              amount: widget.remainingAmount,
            ),
          ),
          child: const Text(AppStrings.confirm),
        ),
      ],
    );
  }

  String _paymentLabel(OrderPaymentMethod m) => switch (m) {
    OrderPaymentMethod.cash => AppStrings.paymentMethodCash,
    OrderPaymentMethod.vodafoneCash => AppStrings.paymentMethodVodafoneCash,
    OrderPaymentMethod.instapay => AppStrings.paymentMethodInstapay,
  };
}
