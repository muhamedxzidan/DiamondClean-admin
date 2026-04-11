import 'package:flutter/material.dart';

import 'package:diamond_clean/core/constants/app_strings.dart';

enum ReportDateFilter { today, week, month, threeMonths, custom }

class ReportQuickDateFilter extends StatelessWidget {
  final ReportDateFilter selectedFilter;
  final ValueChanged<ReportDateFilter> onFilterSelected;
  final VoidCallback onCustomTap;

  const ReportQuickDateFilter({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
    required this.onCustomTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ReportDateFilter.values.map((filter) {
          final isSelected = filter == selectedFilter;
          return Padding(
            padding: const EdgeInsetsDirectional.only(end: 8),
            child: FilterChip(
              selected: isSelected,
              label: Text(_filterLabel(filter)),
              onSelected: (_) {
                if (filter == ReportDateFilter.custom) {
                  onCustomTap();
                } else {
                  onFilterSelected(filter);
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  String _filterLabel(ReportDateFilter filter) => switch (filter) {
    ReportDateFilter.today => AppStrings.treasuryReportToday,
    ReportDateFilter.week => AppStrings.treasuryReportWeek,
    ReportDateFilter.month => AppStrings.treasuryReportMonth,
    ReportDateFilter.threeMonths => AppStrings.treasuryReportThreeMonths,
    ReportDateFilter.custom => AppStrings.treasuryReportCustom,
  };
}
