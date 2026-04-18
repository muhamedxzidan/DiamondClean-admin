import 'package:diamond_clean/core/utils/treasury_report_date_range_calculator.dart';
import 'package:diamond_clean/features/treasury_report/presentation/widgets/report_quick_date_filter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const calculator = TreasuryReportDateRangeCalculator();

  test('rangeFor returns normalized week range', () {
    final now = DateTime(2026, 4, 11, 14, 30);

    final range = calculator.rangeFor(ReportDateFilter.week, now);

    expect(range, isNotNull);
    expect(range!.start, DateTime(2026, 4, 4));
    expect(range.end, DateTime(2026, 4, 11));
  });

  test('rangeFor returns null for custom', () {
    final range = calculator.rangeFor(
      ReportDateFilter.custom,
      DateTime(2026, 4, 11),
    );

    expect(range, isNull);
  });
}
