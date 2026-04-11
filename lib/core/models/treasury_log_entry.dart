class TreasuryLogEntry {
  final String type;
  final DateTime dateTime;
  final double amount;
  final String note;
  final String? category;
  final String? paymentMethod;

  const TreasuryLogEntry({
    required this.type,
    required this.dateTime,
    required this.amount,
    required this.note,
    this.category,
    this.paymentMethod,
  });
}
