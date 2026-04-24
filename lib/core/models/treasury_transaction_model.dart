import 'package:cloud_firestore/cloud_firestore.dart';

enum TreasuryTransactionType {
  openingBalance('openingBalance', 1),
  orderPayment('orderPayment', 1),
  expense('expense', -1),
  employeeAdvance('employeeAdvance', -1),
  employeeSalary('employeeSalary', -1),
  withdrawal('withdrawal', -1),
  reversal('reversal', 0),
  closure('closure', -1);

  final String value;
  final int signHint;

  const TreasuryTransactionType(this.value, this.signHint);

  static TreasuryTransactionType fromValue(String value) => switch (value) {
    'openingBalance' => TreasuryTransactionType.openingBalance,
    'orderPayment' => TreasuryTransactionType.orderPayment,
    'expense' => TreasuryTransactionType.expense,
    'employeeAdvance' => TreasuryTransactionType.employeeAdvance,
    'employeeSalary' => TreasuryTransactionType.employeeSalary,
    'withdrawal' => TreasuryTransactionType.withdrawal,
    'reversal' => TreasuryTransactionType.reversal,
    'closure' => TreasuryTransactionType.closure,
    _ => throw FormatException('Unknown treasury transaction type: $value'),
  };
}

class TreasuryTransactionModel {
  final String id;
  final TreasuryTransactionType type;
  final double amount;
  final DateTime occurredAt;
  final DateTime createdAt;
  final String actorUid;
  final String? orderId;
  final String? employeeId;
  final String? reversalOfId;
  final String? closureId;
  final String? expenseCategory;
  final String? paymentMethod;
  final String? note;

  const TreasuryTransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.occurredAt,
    required this.createdAt,
    required this.actorUid,
    this.orderId,
    this.employeeId,
    this.reversalOfId,
    this.closureId,
    this.expenseCategory,
    this.paymentMethod,
    this.note,
  });

  factory TreasuryTransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw FormatException('Treasury transaction ${doc.id} has no data');
    }

    final typeRaw = data['type'];
    if (typeRaw is! String) {
      throw FormatException(
        'Treasury transaction ${doc.id} is missing type (got $typeRaw)',
      );
    }

    final amountRaw = data['amount'];
    if (amountRaw is! num) {
      throw FormatException(
        'Treasury transaction ${doc.id} is missing amount (got $amountRaw)',
      );
    }

    final occurredAtRaw = data['occurredAt'];
    if (occurredAtRaw is! Timestamp) {
      throw FormatException(
        'Treasury transaction ${doc.id} is missing occurredAt',
      );
    }

    final createdAtRaw = data['createdAt'];
    if (createdAtRaw is! Timestamp) {
      throw FormatException(
        'Treasury transaction ${doc.id} is missing createdAt',
      );
    }

    final actorRaw = data['actorUid'];
    if (actorRaw is! String || actorRaw.isEmpty) {
      throw FormatException(
        'Treasury transaction ${doc.id} is missing actorUid',
      );
    }

    return TreasuryTransactionModel(
      id: doc.id,
      type: TreasuryTransactionType.fromValue(typeRaw),
      amount: amountRaw.toDouble(),
      occurredAt: occurredAtRaw.toDate(),
      createdAt: createdAtRaw.toDate(),
      actorUid: actorRaw,
      orderId: data['orderId'] as String?,
      employeeId: data['employeeId'] as String?,
      reversalOfId: data['reversalOfId'] as String?,
      closureId: data['closureId'] as String?,
      expenseCategory: data['expenseCategory'] as String?,
      paymentMethod: data['paymentMethod'] as String?,
      note: data['note'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'type': type.value,
    'amount': amount,
    'occurredAt': Timestamp.fromDate(occurredAt),
    'createdAt': Timestamp.fromDate(createdAt),
    'actorUid': actorUid,
    if (orderId != null) 'orderId': orderId,
    if (employeeId != null) 'employeeId': employeeId,
    if (reversalOfId != null) 'reversalOfId': reversalOfId,
    if (closureId != null) 'closureId': closureId,
    if (expenseCategory != null) 'expenseCategory': expenseCategory,
    if (paymentMethod != null) 'paymentMethod': paymentMethod,
    if (note != null) 'note': note,
  };

  bool get isIncome => amount > 0;
  bool get isOutflow => amount < 0;
}
