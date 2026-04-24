import 'package:flutter/material.dart';

import 'package:diamond_clean/core/constants/app_strings.dart';

import '../../cubit/cashbox_state.dart';
import 'cashbox_sheet_row.dart';

/// A dialog shown at midnight to remind the user to close the cashbox.
/// Offers two options:
/// 1. Close & carry over the balance as the next day's opening balance
/// 2. Dismiss and continue working
class CashboxDayEndedDialog extends StatelessWidget {
  final CashboxLoaded state;
  final VoidCallback onCloseAndCarryOver;
  final VoidCallback onCloseAndZero;
  final VoidCallback onDismiss;

  const CashboxDayEndedDialog({
    super.key,
    required this.state,
    required this.onCloseAndCarryOver,
    required this.onCloseAndZero,
    required this.onDismiss,
  });

  static Future<void> show(
    BuildContext context, {
    required CashboxLoaded state,
    required VoidCallback onCloseAndCarryOver,
    required VoidCallback onCloseAndZero,
    required VoidCallback onDismiss,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => CashboxDayEndedDialog(
        state: state,
        onCloseAndCarryOver: onCloseAndCarryOver,
        onCloseAndZero: onCloseAndZero,
        onDismiss: onDismiss,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      icon: const Icon(Icons.nights_stay_rounded, size: 48),
      iconColor: theme.colorScheme.primary,
      title: const Text('انتهى اليوم! 🌙'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'اليوم انتهى الساعة 12 منتصف الليل.\n'
            'يُفضل إقفال الخزنة وترحيل الرصيد لليوم الجديد.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                CashboxSheetRow(
                  label: AppStrings.cashboxOpeningBalance,
                  value: state.settings.openingBalance.toStringAsFixed(2),
                ),
                const SizedBox(height: 6),
                CashboxSheetRow(
                  label: 'إجمالي الإيرادات',
                  value: state.sessionRevenue.toStringAsFixed(2),
                ),
                const SizedBox(height: 6),
                CashboxSheetRow(
                  label: AppStrings.cashboxDailyExpenses,
                  value: state.sessionExpenses.toStringAsFixed(2),
                ),
                const Divider(height: 16),
                CashboxSheetRow(
                  label: 'الرصيد الحالي (يُرحّل)',
                  value: state.sessionBalance.toStringAsFixed(2),
                  bold: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.info_outline, size: 14, color: theme.hintColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'الرصيد الحالي سيكون رصيد الافتتاح لليوم الجديد',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actionsOverflowDirection: VerticalDirection.down,
      actions: [
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: onCloseAndCarryOver,
            icon: const Icon(Icons.arrow_forward, size: 18),
            label: const Text('إقفال وترحيل الرصيد'),
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onCloseAndZero,
            icon: const Icon(Icons.restart_alt, size: 18),
            label: const Text('تصفير الخزنة'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.orange.shade700,
            ),
          ),
        ),
        const SizedBox(height: 4),
        TextButton(
          onPressed: onDismiss,
          child: const Text('لاحقاً'),
        ),
      ],
    );
  }
}
