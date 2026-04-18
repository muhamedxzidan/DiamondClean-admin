import 'package:flutter/material.dart';

import 'package:diamond_clean/features/treasury_report/presentation/widgets/report_quick_date_filter.dart';

class TreasuryReportDateRangeCalculator {
  const TreasuryReportDateRangeCalculator();

  DateTimeRange? rangeFor(ReportDateFilter filter, DateTime now) {
    final today = _dayStart(now);

    return switch (filter) {
      ReportDateFilter.today => DateTimeRange(start: today, end: today),
      ReportDateFilter.week => DateTimeRange(
        start: today.subtract(const Duration(days: 7)),
        end: today,
      ),
      ReportDateFilter.month => DateTimeRange(
        start: DateTime(now.year, now.month - 1, now.day),
        end: today,
      ),
      ReportDateFilter.threeMonths => DateTimeRange(
        start: DateTime(now.year, now.month - 3, now.day),
        end: today,
      ),
      ReportDateFilter.custom => null,
    };
  }

  DateTime _dayStart(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}
