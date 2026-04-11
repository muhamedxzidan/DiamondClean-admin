/// Strict validation rules for all cashbox operations.
/// Every operation must pass these checks before being recorded.
sealed class CashboxValidationResult {
  const CashboxValidationResult();
}

class CashboxValidationSuccess extends CashboxValidationResult {
  const CashboxValidationSuccess();
}

class CashboxValidationFailure extends CashboxValidationResult {
  final String reason;

  const CashboxValidationFailure(this.reason);
}

class CashboxValidator {
  /// Validates opening balance amount.
  static CashboxValidationResult validateOpeningBalance(double amount) {
    if (amount < 0) {
      return const CashboxValidationFailure(
        'رصيد الافتتاح لا يمكن أن يكون سالباً',
      );
    }
    if (amount.isNaN || amount.isInfinite) {
      return const CashboxValidationFailure('قيمة رصيد الافتتاح غير صحيحة');
    }
    // Allow reasonable amounts (up to 1 million)
    if (amount > 1000000) {
      return const CashboxValidationFailure(
        'رصيد الافتتاح يتجاوز الحد الأقصى المقبول',
      );
    }
    return const CashboxValidationSuccess();
  }

  /// Validates expense amount and title.
  static CashboxValidationResult validateExpense({
    required double amount,
    required String title,
  }) {
    if (amount <= 0) {
      return const CashboxValidationFailure(
        'مبلغ المصروف يجب أن يكون أكبر من صفر',
      );
    }
    if (amount.isNaN || amount.isInfinite) {
      return const CashboxValidationFailure('مبلغ المصروف غير صحيح');
    }
    if (amount > 1000000) {
      return const CashboxValidationFailure(
        'مبلغ المصروف يتجاوز الحد الأقصى المقبول',
      );
    }
    if (title.trim().isEmpty) {
      return const CashboxValidationFailure(
        'وصف المصروف لا يمكن أن يكون فارغاً',
      );
    }
    if (title.length > 500) {
      return const CashboxValidationFailure('وصف المصروف طويل جداً');
    }
    return const CashboxValidationSuccess();
  }

  /// Validates income amount.
  static CashboxValidationResult validateIncome(double amount) {
    if (amount <= 0) {
      return const CashboxValidationFailure(
        'مبلغ الدخل يجب أن يكون أكبر من صفر',
      );
    }
    if (amount.isNaN || amount.isInfinite) {
      return const CashboxValidationFailure('مبلغ الدخل غير صحيح');
    }
    if (amount > 10000000) {
      return const CashboxValidationFailure(
        'مبلغ الدخل يتجاوز الحد الأقصى المقبول',
      );
    }
    return const CashboxValidationSuccess();
  }

  /// Validates PIN format (optional but if provided must be secure).
  static CashboxValidationResult validatePin(String? pin) {
    if (pin == null || pin.isEmpty) {
      return const CashboxValidationSuccess();
    }
    if (pin.length < 4) {
      return const CashboxValidationFailure(
        'كلمة المرور يجب أن تكون 4 أرقام على الأقل',
      );
    }
    if (pin.length > 10) {
      return const CashboxValidationFailure('كلمة المرور طويلة جداً');
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(pin)) {
      return const CashboxValidationFailure(
        'كلمة المرور يجب أن تحتوي على أرقام فقط',
      );
    }
    return const CashboxValidationSuccess();
  }

  /// Validates user/employee name.
  static CashboxValidationResult validateUserName(String? userName) {
    if (userName == null || userName.trim().isEmpty) {
      return const CashboxValidationFailure(
        'اسم المستخدم لا يمكن أن يكون فارغاً',
      );
    }
    if (userName.length > 100) {
      return const CashboxValidationFailure('اسم المستخدم طويل جداً');
    }
    return const CashboxValidationSuccess();
  }

  /// Validates closing balance makes sense (not negative).
  static CashboxValidationResult validateClosingBalance(
    double openingBalance,
    double totalRevenue,
    double totalExpenses,
  ) {
    final closingBalance = openingBalance + totalRevenue - totalExpenses;
    if (closingBalance < 0) {
      return const CashboxValidationFailure(
        'الرصيد الختامي سالب! هناك خطأ في الحسابات',
      );
    }
    return const CashboxValidationSuccess();
  }

  /// Validates that amounts don't have excessive decimal places.
  static CashboxValidationResult validateAmountPrecision(double amount) {
    // Check if amount has more than 2 decimal places (common in currency)
    final decimalPlaces = (amount * 100).toInt();
    if ((amount * 100 - decimalPlaces).abs() > 0.01) {
      return const CashboxValidationFailure(
        'المبلغ يحتوي على أرقام عشرية أكثر من اللازم',
      );
    }
    return const CashboxValidationSuccess();
  }
}
