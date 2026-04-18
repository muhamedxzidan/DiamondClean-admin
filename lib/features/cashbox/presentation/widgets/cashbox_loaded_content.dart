import 'package:flutter/material.dart';

import 'package:diamond_clean/core/constants/app_strings.dart';

import '../../cubit/cashbox_state.dart';
import 'cashbox_daily_report_section.dart';
import 'cashbox_expenses_section.dart';
import 'cashbox_orders_section.dart';

class CashboxLoadedContent extends StatelessWidget {
  final CashboxLoaded state;
  final Future<void> Function() onRefresh;
  final VoidCallback onClosePressed;

  const CashboxLoadedContent({
    super.key,
    required this.state,
    required this.onRefresh,
    required this.onClosePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: onRefresh,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                RepaintBoundary(child: CashboxDailyReportSection(state: state)),
                const SizedBox(height: 16),
                RepaintBoundary(child: CashboxExpensesSection(state: state)),
                const SizedBox(height: 16),
                RepaintBoundary(child: CashboxOrdersSection(state: state)),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
        _CloseCta(onPressed: onClosePressed),
      ],
    );
  }
}

class _CloseCta extends StatelessWidget {
  final VoidCallback onPressed;

  const _CloseCta({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton(
            onPressed: onPressed,
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 4,
            ),
            child: const Text(
              AppStrings.cashboxCloseTodayCta,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}
