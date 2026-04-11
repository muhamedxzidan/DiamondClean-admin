enum SalaryCycle { daily, weekly, monthly }

extension SalaryCycleX on SalaryCycle {
  String get value => switch (this) {
    SalaryCycle.daily => 'daily',
    SalaryCycle.weekly => 'weekly',
    SalaryCycle.monthly => 'monthly',
  };

  String get arabicLabel => switch (this) {
    SalaryCycle.daily => 'يومي',
    SalaryCycle.weekly => 'أسبوعي',
    SalaryCycle.monthly => 'شهري',
  };

  DateTime nextCycleStart(DateTime start) {
    return switch (this) {
      SalaryCycle.daily => start.add(const Duration(days: 1)),
      SalaryCycle.weekly => start.add(const Duration(days: 7)),
      SalaryCycle.monthly => DateTime(
        start.year,
        start.month + 1,
        start.day,
        start.hour,
        start.minute,
        start.second,
        start.millisecond,
        start.microsecond,
      ),
    };
  }

  static SalaryCycle fromValue(String value) {
    return switch (value) {
      'daily' => SalaryCycle.daily,
      'weekly' => SalaryCycle.weekly,
      'monthly' => SalaryCycle.monthly,
      _ => SalaryCycle.monthly,
    };
  }
}
