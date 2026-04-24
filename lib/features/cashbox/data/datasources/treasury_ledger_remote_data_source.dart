import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:diamond_clean/core/models/treasury_transaction_model.dart';
import 'package:diamond_clean/features/cashbox/data/models/cashbox_closure_model.dart';
import 'package:diamond_clean/features/cashbox/data/models/expense_category.dart';

class OrderNotFoundException implements Exception {
  final String orderId;
  const OrderNotFoundException(this.orderId);
  @override
  String toString() => 'Order $orderId not found';
}

class OrderPaymentExceedsTotalException implements Exception {
  final String orderId;
  final double attempted;
  final double remaining;
  const OrderPaymentExceedsTotalException({
    required this.orderId,
    required this.attempted,
    required this.remaining,
  });
  @override
  String toString() =>
      'Payment $attempted exceeds remaining $remaining for order $orderId';
}

class OrderNotCompletedException implements Exception {
  final String orderId;
  const OrderNotCompletedException(this.orderId);
  @override
  String toString() => 'Order $orderId is not completed — nothing to reverse';
}

abstract class TreasuryLedgerRemoteDataSource {
  Stream<List<TreasuryTransactionModel>> watchAll();
  Stream<List<TreasuryTransactionModel>> watchRange(
    DateTime startInclusive,
    DateTime endExclusive,
  );
  Future<List<TreasuryTransactionModel>> getRange(
    DateTime startInclusive,
    DateTime endExclusive,
  );
  Future<double> computeBalanceBefore(DateTime moment);

  Future<void> appendOpeningBalance({
    required double amount,
    required String actorUid,
    DateTime? occurredAt,
  });

  Future<void> appendExpense({
    required double amount,
    required ExpenseCategory category,
    required String actorUid,
    String? note,
    DateTime? occurredAt,
  });

  Future<void> appendWithdrawal({
    required double amount,
    required String actorUid,
    String? note,
    DateTime? occurredAt,
  });

  /// Atomic: updates order + appends ledger entry in a single Firestore
  /// transaction. Throws [OrderNotFoundException],
  /// [OrderPaymentExceedsTotalException] on guard failures.
  Future<void> recordOrderPaymentAtomic({
    required String orderId,
    required double amount,
    required String paymentMethod,
    required bool markCompleted,
    required String actorUid,
  });

  /// Atomic: reverses every non-reversed orderPayment entry for the given
  /// order and flips the order status to cancelled. Throws
  /// [OrderNotFoundException] or [OrderNotCompletedException] on guard
  /// failures.
  Future<void> cancelCompletedOrderAtomic({
    required String orderId,
    required String reason,
    required String actorUid,
  });

  /// Composition hook: append an entry inside an existing Firestore
  /// transaction owned by the caller. Used by other data sources (e.g.
  /// employees) that already run their own transactions.
  void appendInTransaction(
    Transaction transaction,
    TreasuryTransactionModel entry,
  );

  /// Generate a new ledger document id without writing.
  String newTransactionId();

  /// Close the current session: writes a `closure` ledger entry that zeroes
  /// the running balance, plus a closure snapshot doc, in one transaction.
  Future<CashboxClosureModel> closeSessionAtomic({
    required String actorUid,
  });
}
