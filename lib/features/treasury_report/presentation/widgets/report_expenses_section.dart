import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:diamond_clean/core/constants/app_strings.dart';
import 'package:diamond_clean/features/cashbox/data/models/expense_category.dart';

import '../../data/models/treasury_report_model.dart';

class ReportExpensesSection extends StatelessWidget {
  final TreasuryReportModel report;

  const ReportExpensesSection({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,##0.00');
    final theme = Theme.of(context);
    final sortedCategories = report.expensesByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.treasuryReportExpenses,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${formatter.format(report.totalExpenses)} ${AppStrings.currency}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (sortedCategories.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                AppStrings.treasuryReportExpensesByCategory,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 10),
              ...sortedCategories.map((entry) {
                final percentage = report.totalExpenses > 0
                    ? (entry.value / report.totalExpenses)
                    : 0.0;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            _categoryIcon(entry.key),
                            size: 16,
                            color: _categoryColor(entry.key),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              entry.key.label,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                          Text(
                            '${formatter.format(entry.value)} ${AppStrings.currency}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.red.shade600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: percentage,
                          backgroundColor: Colors.grey.shade100,
                          valueColor: AlwaysStoppedAnimation(
                            _categoryColor(entry.key),
                          ),
                          minHeight: 4,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ] else
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    'لا توجد مصاريف في هذه الفترة',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _categoryIcon(ExpenseCategory category) => switch (category) {
    ExpenseCategory.salary => Icons.person_outline,
    ExpenseCategory.advance => Icons.money_off_outlined,
    ExpenseCategory.laundry => Icons.local_laundry_service_outlined,
    ExpenseCategory.transport => Icons.local_shipping_outlined,
    ExpenseCategory.rent => Icons.home_outlined,
    ExpenseCategory.utilities => Icons.electrical_services_outlined,
    ExpenseCategory.other => Icons.receipt_outlined,
  };

  Color _categoryColor(ExpenseCategory category) => switch (category) {
    ExpenseCategory.salary => Colors.deepPurple,
    ExpenseCategory.advance => Colors.purple.shade300,
    ExpenseCategory.laundry => Colors.blue,
    ExpenseCategory.transport => Colors.orange,
    ExpenseCategory.rent => Colors.brown,
    ExpenseCategory.utilities => Colors.amber.shade700,
    ExpenseCategory.other => Colors.grey,
  };
}
