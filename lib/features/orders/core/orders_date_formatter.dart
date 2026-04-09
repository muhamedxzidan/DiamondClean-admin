class OrdersDateFormatter {
  static const List<String> _arabicWeekDays = [
    'الإثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
    'الأحد',
  ];

  static String formatDayHeader(DateTime day) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (day == today) return 'اليوم';
    if (day == yesterday) return 'أمس';

    final dayName = _arabicWeekDays[day.weekday - 1];
    return '$dayName ${day.day}/${day.month}/${day.year}';
  }
}
