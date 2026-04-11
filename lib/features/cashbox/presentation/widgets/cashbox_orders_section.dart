import 'package:flutter/material.dart';

import 'package:diamond_clean/core/constants/app_strings.dart';
import 'package:diamond_clean/core/utils/date_formatter.dart';
import 'package:diamond_clean/core/widgets/custom_card.dart';
import 'package:diamond_clean/core/widgets/state_widgets.dart';

import '../../cubit/cashbox_state.dart';

class CashboxOrdersSection extends StatelessWidget {
  final CashboxLoaded state;

  const CashboxOrdersSection({super.key, required this.state});

  String _paymentMethodLabel(String? value) => switch (value) {
        'cash' => AppStrings.paymentMethodCash,
        'vodafoneCash' => AppStrings.paymentMethodVodafoneCash,
        'instapay' => AppStrings.paymentMethodInstapay,
        _ => AppStrings.cashboxUnknownPaymentMethod,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                AppStrings.cashboxDeliveredOrdersToday,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '(${state.sessionIncomeEntries.length} ${AppStrings.cashboxOrderCount})',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (state.sessionIncomeEntries.isEmpty)
            const EmptyStateWidget(message: AppStrings.noOrdersFound)
          else
            ...state.sessionIncomeEntries.map(
              (income) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: CustomCard(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(income.customerName),
                    subtitle: Text(
                      '${income.customerPhone} • ${formatDate(income.createdAt)} • ${AppStrings.cashboxPaymentMethod}: ${_paymentMethodLabel(income.paymentMethod)}${income.remainingAmount > 0 ? " • ${AppStrings.cashboxRemainingAmount}: ${income.remainingAmount.toStringAsFixed(2)}" : ""}',
                    ),
                    trailing: Text(income.orderTotal.toStringAsFixed(2)),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
