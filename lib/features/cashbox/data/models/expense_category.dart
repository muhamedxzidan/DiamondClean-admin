enum ExpenseCategory {
  salary('salary', 'مرتبات'),
  advance('advance', 'سلفة موظف'),
  laundry('laundry', 'مصاريف مغسلة'),
  transport('transport', 'نقل وتوصيل'),
  rent('rent', 'إيجار'),
  utilities('utilities', 'كهرباء ومياه'),
  withdrawal('withdrawal', 'سحب من الخزينة'),
  other('other', 'أخرى');

  final String value;
  final String label;

  const ExpenseCategory(this.value, this.label);

  static ExpenseCategory fromValue(String? value) => switch (value) {
    'salary' => ExpenseCategory.salary,
    'advance' => ExpenseCategory.advance,
    'laundry' => ExpenseCategory.laundry,
    'transport' => ExpenseCategory.transport,
    'rent' => ExpenseCategory.rent,
    'utilities' => ExpenseCategory.utilities,
    'withdrawal' => ExpenseCategory.withdrawal,
    _ => ExpenseCategory.other,
  };
}
