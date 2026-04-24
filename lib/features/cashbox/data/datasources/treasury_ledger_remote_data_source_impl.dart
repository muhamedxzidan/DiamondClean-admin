import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:diamond_clean/core/constants/firebase_constants.dart';
import 'package:diamond_clean/core/models/treasury_transaction_model.dart';
import 'package:diamond_clean/features/cashbox/data/models/cashbox_closure_model.dart';
import 'package:diamond_clean/features/cashbox/data/models/expense_category.dart';

import 'treasury_ledger_remote_data_source.dart';

class TreasuryLedgerRemoteDataSourceImpl
    implements TreasuryLedgerRemoteDataSource {
  final FirebaseFirestore _firestore;

  TreasuryLedgerRemoteDataSourceImpl(this._firestore);

  CollectionReference<Map<String, dynamic>> get _ledgerRef =>
      _firestore.collection(FirebaseConstants.treasuryTransactionsCollection);

  CollectionReference<Map<String, dynamic>> get _ordersRef =>
      _firestore.collection(FirebaseConstants.ordersCollection);

  CollectionReference<Map<String, dynamic>> get _closuresRef =>
      _firestore.collection(FirebaseConstants.cashboxClosuresCollection);

  @override
  String newTransactionId() => _ledgerRef.doc().id;

  @override
  Stream<List<TreasuryTransactionModel>> watchAll() {
    return _ledgerRef
        .orderBy('occurredAt', descending: false)
        .snapshots()
        .map(_mapDocs);
  }

  @override
  Stream<List<TreasuryTransactionModel>> watchRange(
    DateTime startInclusive,
    DateTime endExclusive,
  ) {
    return _ledgerRef
        .where(
          'occurredAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startInclusive),
        )
        .where(
          'occurredAt',
          isLessThan: Timestamp.fromDate(endExclusive),
        )
        .orderBy('occurredAt', descending: false)
        .snapshots()
        .map(_mapDocs);
  }

  @override
  Future<List<TreasuryTransactionModel>> getRange(
    DateTime startInclusive,
    DateTime endExclusive,
  ) async {
    final snapshot = await _ledgerRef
        .where(
          'occurredAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startInclusive),
        )
        .where(
          'occurredAt',
          isLessThan: Timestamp.fromDate(endExclusive),
        )
        .orderBy('occurredAt', descending: false)
        .get();
    return _mapDocs(snapshot);
  }

  @override
  Future<double> computeBalanceBefore(DateTime moment) async {
    final snapshot = await _ledgerRef
        .where('occurredAt', isLessThan: Timestamp.fromDate(moment))
        .get();
    return _sumAmounts(_mapDocs(snapshot));
  }

  @override
  Future<void> appendOpeningBalance({
    required double amount,
    required String actorUid,
    DateTime? occurredAt,
  }) async {
    _requirePositive(amount, 'Opening balance');
    _requireActor(actorUid);
    await _append(
      type: TreasuryTransactionType.openingBalance,
      signedAmount: amount,
      actorUid: actorUid,
      occurredAt: occurredAt,
    );
  }

  @override
  Future<void> appendExpense({
    required double amount,
    required ExpenseCategory category,
    required String actorUid,
    String? note,
    DateTime? occurredAt,
  }) async {
    _requirePositive(amount, 'Expense');
    _requireActor(actorUid);
    await _append(
      type: TreasuryTransactionType.expense,
      signedAmount: -amount,
      actorUid: actorUid,
      note: note,
      expenseCategory: category.value,
      occurredAt: occurredAt,
    );
  }

  @override
  Future<void> appendWithdrawal({
    required double amount,
    required String actorUid,
    String? note,
    DateTime? occurredAt,
  }) async {
    _requirePositive(amount, 'Withdrawal');
    _requireActor(actorUid);
    await _append(
      type: TreasuryTransactionType.withdrawal,
      signedAmount: -amount,
      actorUid: actorUid,
      note: note,
      expenseCategory: ExpenseCategory.withdrawal.value,
      occurredAt: occurredAt,
    );
  }

  @override
  Future<void> recordOrderPaymentAtomic({
    required String orderId,
    required double amount,
    required String paymentMethod,
    required bool markCompleted,
    required String actorUid,
  }) async {
    _requirePositive(amount, 'Order payment');
    _requireActor(actorUid);
    if (paymentMethod.trim().isEmpty) {
      throw ArgumentError('paymentMethod is required');
    }

    final orderRef = _ordersRef.doc(orderId);
    final entryRef = _ledgerRef.doc();
    final now = DateTime.now();

    await _firestore.runTransaction((transaction) async {
      final orderSnapshot = await transaction.get(orderRef);
      if (!orderSnapshot.exists) {
        throw OrderNotFoundException(orderId);
      }
      final data = orderSnapshot.data()!;
      final totalPrice = _computeOrderTotal(data);
      final paidAmount = (data['paidAmount'] as num?)?.toDouble() ?? 0;
      final remaining = (totalPrice - paidAmount);

      if (amount > remaining + 0.01) {
        throw OrderPaymentExceedsTotalException(
          orderId: orderId,
          attempted: amount,
          remaining: remaining < 0 ? 0 : remaining,
        );
      }

      final newPaid = paidAmount + amount;
      final fullyPaid = (totalPrice - newPaid).abs() < 0.01;

      final updates = <String, dynamic>{
        'paidAmount': newPaid,
        'isFullyPaid': fullyPaid,
        'paymentMethod': paymentMethod,
      };
      if (markCompleted) {
        updates['status'] = 'completed';
      }
      transaction.update(orderRef, updates);

      final entry = TreasuryTransactionModel(
        id: entryRef.id,
        type: TreasuryTransactionType.orderPayment,
        amount: amount,
        occurredAt: now,
        createdAt: now,
        actorUid: actorUid,
        orderId: orderId,
        paymentMethod: paymentMethod,
      );
      transaction.set(entryRef, entry.toFirestore());
    });
  }

  @override
  Future<void> cancelCompletedOrderAtomic({
    required String orderId,
    required String reason,
    required String actorUid,
  }) async {
    _requireActor(actorUid);
    if (reason.trim().isEmpty) {
      throw ArgumentError('reason is required');
    }

    final orderRef = _ordersRef.doc(orderId);

    final existingEntries = await _ledgerRef
        .where('orderId', isEqualTo: orderId)
        .where('type', isEqualTo: TreasuryTransactionType.orderPayment.value)
        .get();

    final alreadyReversed = await _ledgerRef
        .where('orderId', isEqualTo: orderId)
        .where('type', isEqualTo: TreasuryTransactionType.reversal.value)
        .get();
    final reversedIds = alreadyReversed.docs
        .map((d) => (d.data()['reversalOfId'] as String?) ?? '')
        .where((id) => id.isNotEmpty)
        .toSet();

    final pendingReversals = existingEntries.docs
        .where((doc) => !reversedIds.contains(doc.id))
        .toList();

    if (pendingReversals.isEmpty) {
      throw OrderNotCompletedException(orderId);
    }

    await _firestore.runTransaction((transaction) async {
      final orderSnapshot = await transaction.get(orderRef);
      if (!orderSnapshot.exists) {
        throw OrderNotFoundException(orderId);
      }

      final now = DateTime.now();
      for (final doc in pendingReversals) {
        final original = TreasuryTransactionModel.fromFirestore(doc);
        final reversalRef = _ledgerRef.doc();
        final reversal = TreasuryTransactionModel(
          id: reversalRef.id,
          type: TreasuryTransactionType.reversal,
          amount: -original.amount,
          occurredAt: now,
          createdAt: now,
          actorUid: actorUid,
          orderId: orderId,
          reversalOfId: original.id,
          paymentMethod: original.paymentMethod,
          note: reason.trim(),
        );
        transaction.set(reversalRef, reversal.toFirestore());
      }

      transaction.update(orderRef, {
        'status': 'cancelled',
      });
    });
  }

  @override
  void appendInTransaction(
    Transaction transaction,
    TreasuryTransactionModel entry,
  ) {
    final ref = _ledgerRef.doc(entry.id);
    transaction.set(ref, entry.toFirestore());
  }

  @override
  Future<CashboxClosureModel> closeSessionAtomic({
    required String actorUid,
  }) async {
    _requireActor(actorUid);

    final allSnapshot = await _ledgerRef.get();
    final allEntries = _mapDocs(allSnapshot);

    final lastClosureAt = _lastClosureAt(allEntries);
    final sessionEntries = lastClosureAt == null
        ? allEntries
        : allEntries
            .where((e) => e.occurredAt.isAfter(lastClosureAt))
            .toList();

    final openingBalance = lastClosureAt == null
        ? 0.0
        : _sumAmounts(
            allEntries.where((e) => !e.occurredAt.isAfter(lastClosureAt)),
          );
    final runningBalance = openingBalance + _sumAmounts(sessionEntries);

    final sessionRevenue = _sumAmounts(
      sessionEntries.where((e) =>
          e.amount > 0 &&
          e.type != TreasuryTransactionType.openingBalance &&
          e.type != TreasuryTransactionType.reversal),
    );
    final positiveReversals = _sumAmounts(
      sessionEntries.where(
        (e) => e.type == TreasuryTransactionType.reversal && e.amount > 0,
      ),
    );
    final negativeReversals = _sumAmounts(
      sessionEntries.where(
        (e) => e.type == TreasuryTransactionType.reversal && e.amount < 0,
      ),
    );
    final rawExpenses = _sumAmounts(
      sessionEntries.where(
        (e) =>
            e.amount < 0 && e.type != TreasuryTransactionType.reversal,
      ),
    );
    final totalExpenses = -(rawExpenses + negativeReversals);
    final totalRevenue = sessionRevenue + positiveReversals;
    final orderIdsThisSession = sessionEntries
        .where((e) => e.orderId != null)
        .map((e) => e.orderId!)
        .toSet();

    final now = DateTime.now();
    final closureRef = _closuresRef.doc();
    final entryRef = _ledgerRef.doc();

    final closure = CashboxClosureModel(
      id: closureRef.id,
      closedBy: actorUid,
      openingBalance: openingBalance,
      totalRevenue: totalRevenue,
      totalExpenses: totalExpenses,
      closingBalance: runningBalance,
      ordersCount: orderIdsThisSession.length,
      expenses: const [],
      closedAt: now,
    );

    await _firestore.runTransaction((transaction) async {
      transaction.set(closureRef, closure.toFirestore());

      final entry = TreasuryTransactionModel(
        id: entryRef.id,
        type: TreasuryTransactionType.closure,
        amount: -runningBalance,
        occurredAt: now,
        createdAt: now,
        actorUid: actorUid,
        closureId: closureRef.id,
      );
      transaction.set(entryRef, entry.toFirestore());
    });

    return closure;
  }

  Future<void> _append({
    required TreasuryTransactionType type,
    required double signedAmount,
    required String actorUid,
    DateTime? occurredAt,
    String? orderId,
    String? employeeId,
    String? reversalOfId,
    String? closureId,
    String? expenseCategory,
    String? paymentMethod,
    String? note,
  }) async {
    final now = DateTime.now();
    final ref = _ledgerRef.doc();
    final entry = TreasuryTransactionModel(
      id: ref.id,
      type: type,
      amount: signedAmount,
      occurredAt: occurredAt ?? now,
      createdAt: now,
      actorUid: actorUid,
      orderId: orderId,
      employeeId: employeeId,
      reversalOfId: reversalOfId,
      closureId: closureId,
      expenseCategory: expenseCategory,
      paymentMethod: paymentMethod,
      note: note,
    );
    await ref.set(entry.toFirestore());
  }

  List<TreasuryTransactionModel> _mapDocs(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    return snapshot.docs.map(TreasuryTransactionModel.fromFirestore).toList();
  }

  double _sumAmounts(Iterable<TreasuryTransactionModel> entries) {
    return entries.fold<double>(0, (acc, e) => acc + e.amount);
  }

  DateTime? _lastClosureAt(List<TreasuryTransactionModel> entries) {
    DateTime? latest;
    for (final e in entries) {
      if (e.type == TreasuryTransactionType.closure) {
        if (latest == null || e.occurredAt.isAfter(latest)) {
          latest = e.occurredAt;
        }
      }
    }
    return latest;
  }

  double _computeOrderTotal(Map<String, dynamic> orderData) {
    final deliveryFee = (orderData['deliveryFee'] as num?)?.toDouble() ?? 0;
    final itemsRaw = orderData['items'];
    if (itemsRaw is! List) return deliveryFee;
    double total = deliveryFee;
    for (final raw in itemsRaw) {
      if (raw is! Map) continue;
      final pricePerUnit = (raw['pricePerUnit'] as num?)?.toDouble();
      final quantity = (raw['quantity'] as num?)?.toDouble();
      final itemTotal = (raw['itemTotal'] as num?)?.toDouble();
      if (itemTotal != null) {
        total += itemTotal;
      } else if (pricePerUnit != null && quantity != null) {
        total += pricePerUnit * quantity;
      }
    }
    return total;
  }

  void _requirePositive(double amount, String label) {
    if (amount.isNaN || amount.isInfinite) {
      throw ArgumentError('$label must be a finite number');
    }
    if (amount <= 0) {
      throw ArgumentError('$label must be positive');
    }
  }

  void _requireActor(String actorUid) {
    if (actorUid.trim().isEmpty) {
      throw ArgumentError('actorUid is required');
    }
  }
}
