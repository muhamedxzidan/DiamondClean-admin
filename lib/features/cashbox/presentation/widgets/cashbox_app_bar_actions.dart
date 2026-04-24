import 'package:flutter/material.dart';

import 'package:diamond_clean/core/constants/app_strings.dart';

class CashboxAppBarActions extends StatelessWidget {
  final bool hasPin;
  final bool isUnlocked;
  final VoidCallback onPinPressed;
  final VoidCallback onPickDayPressed;
  final VoidCallback onOpeningBalancePressed;
  final VoidCallback onClosuresLogPressed;
  final VoidCallback onTreasuryLogPressed;
  final VoidCallback onClearDataPressed;

  const CashboxAppBarActions({
    super.key,
    required this.hasPin,
    required this.isUnlocked,
    required this.onPinPressed,
    required this.onPickDayPressed,
    required this.onOpeningBalancePressed,
    required this.onClosuresLogPressed,
    required this.onTreasuryLogPressed,
    required this.onClearDataPressed,
  });

  @override
  Widget build(BuildContext context) {
    final locked = hasPin && !isUnlocked;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: isUnlocked || !hasPin ? onPinPressed : null,
          icon: Icon(hasPin ? Icons.lock_outlined : Icons.lock_open_outlined),
          tooltip: hasPin
              ? AppStrings.cashboxPinChange
              : AppStrings.cashboxPinSet,
        ),
        IconButton(
          onPressed: locked ? null : onPickDayPressed,
          icon: const Icon(Icons.calendar_month_outlined),
        ),
        IconButton(
          onPressed: locked ? null : onOpeningBalancePressed,
          icon: const Icon(Icons.account_balance_wallet_outlined),
          tooltip: AppStrings.cashboxSetOpeningBalance,
        ),
        IconButton(
          onPressed: locked ? null : onClosuresLogPressed,
          icon: const Icon(Icons.history_outlined),
          tooltip: AppStrings.cashboxClosuresLog,
        ),
        IconButton(
          onPressed: locked ? null : onTreasuryLogPressed,
          icon: const Icon(Icons.receipt_long_outlined),
          tooltip: AppStrings.cashboxTreasuryLog,
        ),
        if (!locked)
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'clear_data') onClearDataPressed();
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'clear_data',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_forever,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'تصفير الخزنة ومسح كل السجلات',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }
}
