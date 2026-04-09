import 'package:flutter/material.dart';

import 'package:diamond_clean/core/constants/app_strings.dart';
import '../../data/models/order_model.dart';

class PaymentMethodDialog extends StatefulWidget {
  const PaymentMethodDialog({super.key});

  @override
  State<PaymentMethodDialog> createState() => _PaymentMethodDialogState();
}

class _PaymentMethodDialogState extends State<PaymentMethodDialog> {
  late OrderPaymentMethod _selectedMethod;

  @override
  void initState() {
    super.initState();
    _selectedMethod = OrderPaymentMethod.cash;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(AppStrings.paymentMethodTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPaymentOption(
            OrderPaymentMethod.cash,
            AppStrings.paymentMethodCash,
          ),
          _buildPaymentOption(
            OrderPaymentMethod.vodafoneCash,
            AppStrings.paymentMethodVodafoneCash,
          ),
          _buildPaymentOption(
            OrderPaymentMethod.instapay,
            AppStrings.paymentMethodInstapay,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(AppStrings.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _selectedMethod),
          child: const Text(AppStrings.confirm),
        ),
      ],
    );
  }

  Widget _buildPaymentOption(OrderPaymentMethod method, String label) {
    return RadioListTile<OrderPaymentMethod>(
      value: method,
      // ignore: deprecated_member_use
      groupValue: _selectedMethod,
      title: Text(label),
      // ignore: deprecated_member_use
      onChanged: (value) {
        if (value != null) {
          setState(() => _selectedMethod = value);
        }
      },
    );
  }
}
