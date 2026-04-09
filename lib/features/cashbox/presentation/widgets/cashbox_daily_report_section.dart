import 'package:flutter/material.dart';

import 'package:diamond_clean/core/constants/app_strings.dart';
import 'package:diamond_clean/core/utils/date_formatter.dart';

import '../../cubit/cashbox_state.dart';
import 'cashbox_summary_card.dart';

class CashboxDailyReportSection extends StatelessWidget {
  final CashboxLoaded state;

  const CashboxDailyReportSection({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${AppStrings.cashboxReport} - ${formatDate(state.selectedDay)}',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const Divider(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = constraints.maxWidth < 500
                ? constraints.maxWidth
                : (constraints.maxWidth - 12) / 2;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                CashboxSummaryCard(
                  title: AppStrings.cashboxOpeningBalance,
                  value: state.settings.openingBalance,
                  width: cardWidth,
                ),
                CashboxSummaryCard(
                  title: AppStrings.cashboxCurrentBalance,
                  value: state.sessionBalance,
                  width: cardWidth,
                ),
                CashboxSummaryCard(
                  title: AppStrings.cashboxDailyRevenue,
                  value: state.sessionRevenue,
                  width: cardWidth,
                ),
                CashboxSummaryCard(
                  title: AppStrings.cashboxDailyExpenses,
                  value: state.sessionExpenses,
                  width: cardWidth,
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
