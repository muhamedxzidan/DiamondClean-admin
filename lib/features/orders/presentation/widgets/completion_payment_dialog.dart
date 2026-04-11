import 'package:flutter/material.dart';

import 'package:diamond_clean/core/constants/app_strings.dart';

import '../../data/models/order_model.dart';

class CompletionPaymentResult {
  final OrderPaymentMethod paymentMethod;
  final bool isFullPayment;
  final double paidAmount;

  const CompletionPaymentResult({
    required this.paymentMethod,
    required this.isFullPayment,
    required this.paidAmount,
  });
}

Future<CompletionPaymentResult?> showCompletionPaymentDialog(
  BuildContext context, {
  required double totalPrice,
}) {
  return showDialog<CompletionPaymentResult>(
    context: context,
    builder: (_) => _CompletionPaymentDialog(totalPrice: totalPrice),
  );
}

class _CompletionPaymentDialog extends StatefulWidget {
  final double totalPrice;

  const _CompletionPaymentDialog({required this.totalPrice});

  @override
  State<_CompletionPaymentDialog> createState() =>
      _CompletionPaymentDialogState();
}

class _CompletionPaymentDialogState extends State<_CompletionPaymentDialog> {
  var _isFullPayment = true;
  var _selectedMethod = OrderPaymentMethod.cash;
  final _amountController = TextEditingController();
  String? _amountError;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _onConfirm() {
    if (_isFullPayment) {
      Navigator.pop(
        context,
        CompletionPaymentResult(
          paymentMethod: _selectedMethod,
          isFullPayment: true,
          paidAmount: widget.totalPrice,
        ),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      setState(() => _amountError = AppStrings.invalidPaidAmount);
      return;
    }
    if (amount > widget.totalPrice) {
      setState(() => _amountError = AppStrings.paidAmountExceedsTotal);
      return;
    }

    Navigator.pop(
      context,
      CompletionPaymentResult(
        paymentMethod: _selectedMethod,
        isFullPayment: amount >= widget.totalPrice,
        paidAmount: amount,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text(AppStrings.updateStatus),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total price display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${AppStrings.orderTotal}: ${widget.totalPrice.toStringAsFixed(2)} ${AppStrings.currency}',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),

            // Payment type toggle
            Text(
              AppStrings.paymentTypeLabel,
              style: theme.textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: true,
                  label: Text(AppStrings.paymentTypeFull),
                  icon: Icon(Icons.check_circle_outline, size: 18),
                ),
                ButtonSegment(
                  value: false,
                  label: Text(AppStrings.paymentTypePartial),
                  icon: Icon(Icons.pie_chart_outline, size: 18),
                ),
              ],
              selected: {_isFullPayment},
              onSelectionChanged: (selected) {
                setState(() {
                  _isFullPayment = selected.first;
                  _amountError = null;
                });
              },
            ),
            const SizedBox(height: 16),

            // Partial payment amount
            if (!_isFullPayment) ...[
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: AppStrings.paidAmountLabel,
                  hintText: AppStrings.paidAmountHint,
                  errorText: _amountError,
                  suffixText: AppStrings.currency,
                ),
                onChanged: (_) {
                  if (_amountError != null) {
                    setState(() => _amountError = null);
                  }
                },
              ),
              const SizedBox(height: 16),
            ],

            // Payment method
            Text(
              AppStrings.paymentMethodTitle,
              style: theme.textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            ...OrderPaymentMethod.values.map(
              (method) => RadioListTile<OrderPaymentMethod>(
                value: method,
                groupValue: _selectedMethod,
                title: Text(_paymentLabel(method)),
                dense: true,
                contentPadding: EdgeInsets.zero,
                onChanged: (v) {
                  if (v != null) setState(() => _selectedMethod = v);
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(AppStrings.cancel),
        ),
        FilledButton(
          onPressed: _onConfirm,
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
