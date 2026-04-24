import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:diamond_clean/core/constants/firebase_constants.dart';
import 'package:diamond_clean/core/models/treasury_transaction_model.dart';
import 'package:diamond_clean/features/cashbox/data/datasources/treasury_ledger_remote_data_source.dart';
import 'package:diamond_clean/features/cashbox/data/datasources/treasury_ledger_remote_data_source_impl.dart';
import 'package:diamond_clean/features/cashbox/data/models/expense_category.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late TreasuryLedgerRemoteDataSourceImpl ledger;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    ledger = TreasuryLedgerRemoteDataSourceImpl(firestore);
  });

  Future<double> runningBalance() async {
    final snapshot = await firestore
        .collection(FirebaseConstants.treasuryTransactionsCollection)
        .get();
    return snapshot.docs
        .map(TreasuryTransactionModel.fromFirestore)
        .fold<double>(0, (acc, e) => acc + e.amount);
  }

  Future<void> seedOrder({
    required String orderId,
    required double itemTotal,
    double deliveryFee = 0,
    double paidAmount = 0,
    String status = 'pending',
  }) async {
    await firestore
        .collection(FirebaseConstants.ordersCollection)
        .doc(orderId)
        .set({
      'status': status,
      'deliveryFee': deliveryFee,
      'paidAmount': paidAmount,
      'isFullyPaid': false,
      'items': [
        {'itemTotal': itemTotal, 'pricePerUnit': itemTotal, 'quantity': 1},
      ],
      'createdAt': Timestamp.now(),
    });
  }

  group('appendOpeningBalance', () {
    test('writes a positive ledger entry and sets running balance', () async {
      await ledger.appendOpeningBalance(amount: 500, actorUid: 'user-1');
      expect(await runningBalance(), closeTo(500, 0.001));
    });

    test('rejects negative amount', () {
      expect(
        () => ledger.appendOpeningBalance(amount: -10, actorUid: 'user-1'),
        throwsArgumentError,
      );
    });

    test('rejects empty actor', () {
      expect(
        () => ledger.appendOpeningBalance(amount: 100, actorUid: ''),
        throwsArgumentError,
      );
    });
  });

  group('appendExpense', () {
    test('writes a negative ledger entry', () async {
      await ledger.appendOpeningBalance(amount: 500, actorUid: 'user-1');
      await ledger.appendExpense(
        amount: 80,
        category: ExpenseCategory.other,
        actorUid: 'user-1',
      );
      expect(await runningBalance(), closeTo(420, 0.001));
    });

    test('rejects non-positive amount', () {
      expect(
        () => ledger.appendExpense(
          amount: 0,
          category: ExpenseCategory.other,
          actorUid: 'user-1',
        ),
        throwsArgumentError,
      );
    });
  });

  group('recordOrderPaymentAtomic', () {
    test('adds full payment entry and marks order completed', () async {
      await seedOrder(orderId: 'o1', itemTotal: 200);
      await ledger.recordOrderPaymentAtomic(
        orderId: 'o1',
        amount: 200,
        paymentMethod: 'cash',
        markCompleted: true,
        actorUid: 'user-1',
      );

      final orderDoc = await firestore
          .collection(FirebaseConstants.ordersCollection)
          .doc('o1')
          .get();
      expect(orderDoc.data()!['status'], 'completed');
      expect(orderDoc.data()!['isFullyPaid'], true);
      expect(orderDoc.data()!['paidAmount'], 200);
      expect(await runningBalance(), closeTo(200, 0.001));
    });

    test('supports partial payment without completing the order', () async {
      await seedOrder(orderId: 'o1', itemTotal: 300);
      await ledger.recordOrderPaymentAtomic(
        orderId: 'o1',
        amount: 100,
        paymentMethod: 'cash',
        markCompleted: false,
        actorUid: 'user-1',
      );

      final orderDoc = await firestore
          .collection(FirebaseConstants.ordersCollection)
          .doc('o1')
          .get();
      expect(orderDoc.data()!['status'], 'pending');
      expect(orderDoc.data()!['isFullyPaid'], false);
      expect(orderDoc.data()!['paidAmount'], 100);
      expect(await runningBalance(), closeTo(100, 0.001));
    });

    test('accumulates partial payments to reach fully paid state', () async {
      await seedOrder(orderId: 'o1', itemTotal: 300);
      await ledger.recordOrderPaymentAtomic(
        orderId: 'o1',
        amount: 100,
        paymentMethod: 'cash',
        markCompleted: false,
        actorUid: 'user-1',
      );
      await ledger.recordOrderPaymentAtomic(
        orderId: 'o1',
        amount: 200,
        paymentMethod: 'cash',
        markCompleted: true,
        actorUid: 'user-1',
      );

      final orderDoc = await firestore
          .collection(FirebaseConstants.ordersCollection)
          .doc('o1')
          .get();
      expect(orderDoc.data()!['isFullyPaid'], true);
      expect(orderDoc.data()!['status'], 'completed');
      expect(await runningBalance(), closeTo(300, 0.001));
    });

    test('rejects payment exceeding remaining amount', () async {
      await seedOrder(orderId: 'o1', itemTotal: 200);
      await expectLater(
        ledger.recordOrderPaymentAtomic(
          orderId: 'o1',
          amount: 250,
          paymentMethod: 'cash',
          markCompleted: true,
          actorUid: 'user-1',
        ),
        throwsA(isA<OrderPaymentExceedsTotalException>()),
      );
      expect(await runningBalance(), closeTo(0, 0.001));
    });

    test('rejects when order does not exist', () async {
      await expectLater(
        ledger.recordOrderPaymentAtomic(
          orderId: 'missing',
          amount: 50,
          paymentMethod: 'cash',
          markCompleted: true,
          actorUid: 'user-1',
        ),
        throwsA(isA<OrderNotFoundException>()),
      );
    });
  });

  group('cancelCompletedOrderAtomic', () {
    test('reverses a completed order and zeroes its ledger contribution',
        () async {
      await seedOrder(orderId: 'o1', itemTotal: 200);
      await ledger.recordOrderPaymentAtomic(
        orderId: 'o1',
        amount: 200,
        paymentMethod: 'cash',
        markCompleted: true,
        actorUid: 'user-1',
      );
      await ledger.appendOpeningBalance(amount: 500, actorUid: 'user-1');
      expect(await runningBalance(), closeTo(700, 0.001));

      await ledger.cancelCompletedOrderAtomic(
        orderId: 'o1',
        reason: 'customer changed mind',
        actorUid: 'user-1',
      );

      final orderDoc = await firestore
          .collection(FirebaseConstants.ordersCollection)
          .doc('o1')
          .get();
      expect(orderDoc.data()!['status'], 'cancelled');
      expect(await runningBalance(), closeTo(500, 0.001));
    });

    test('reversing twice is idempotent after first reversal', () async {
      await seedOrder(orderId: 'o1', itemTotal: 100);
      await ledger.recordOrderPaymentAtomic(
        orderId: 'o1',
        amount: 100,
        paymentMethod: 'cash',
        markCompleted: true,
        actorUid: 'user-1',
      );
      await ledger.cancelCompletedOrderAtomic(
        orderId: 'o1',
        reason: 'test',
        actorUid: 'user-1',
      );

      await expectLater(
        ledger.cancelCompletedOrderAtomic(
          orderId: 'o1',
          reason: 'test again',
          actorUid: 'user-1',
        ),
        throwsA(isA<OrderNotCompletedException>()),
      );
    });

    test('requires non-empty reason', () async {
      await seedOrder(orderId: 'o1', itemTotal: 100);
      expect(
        () => ledger.cancelCompletedOrderAtomic(
          orderId: 'o1',
          reason: '   ',
          actorUid: 'user-1',
        ),
        throwsArgumentError,
      );
    });
  });

  group('closeSessionAtomic', () {
    test('zeroes the running balance via a negative closure entry', () async {
      await ledger.appendOpeningBalance(amount: 500, actorUid: 'user-1');
      await seedOrder(orderId: 'o1', itemTotal: 200);
      await ledger.recordOrderPaymentAtomic(
        orderId: 'o1',
        amount: 200,
        paymentMethod: 'cash',
        markCompleted: true,
        actorUid: 'user-1',
      );
      await ledger.appendExpense(
        amount: 50,
        category: ExpenseCategory.other,
        actorUid: 'user-1',
      );
      expect(await runningBalance(), closeTo(650, 0.001));

      final closure = await ledger.closeSessionAtomic(actorUid: 'user-1');
      expect(closure.closingBalance, closeTo(650, 0.001));
      expect(closure.openingBalance, closeTo(0, 0.001));
      expect(closure.totalRevenue, closeTo(200, 0.001));
      expect(closure.totalExpenses, closeTo(50, 0.001));
      expect(await runningBalance(), closeTo(0, 0.001));
    });

    test('second session starts from zero and closes to its own balance',
        () async {
      await ledger.appendOpeningBalance(amount: 100, actorUid: 'user-1');
      await ledger.closeSessionAtomic(actorUid: 'user-1');

      await ledger.appendOpeningBalance(amount: 300, actorUid: 'user-1');
      await ledger.appendExpense(
        amount: 100,
        category: ExpenseCategory.other,
        actorUid: 'user-1',
      );
      final closure = await ledger.closeSessionAtomic(actorUid: 'user-1');

      expect(closure.openingBalance, closeTo(0, 0.001));
      expect(closure.closingBalance, closeTo(200, 0.001));
      expect(await runningBalance(), closeTo(0, 0.001));
    });
  });

  group('reversal accounting', () {
    test('cancelling an order does not double-count or undershoot', () async {
      await ledger.appendOpeningBalance(amount: 500, actorUid: 'user-1');
      await seedOrder(orderId: 'o1', itemTotal: 200);
      await seedOrder(orderId: 'o2', itemTotal: 300);
      await ledger.recordOrderPaymentAtomic(
        orderId: 'o1',
        amount: 200,
        paymentMethod: 'cash',
        markCompleted: true,
        actorUid: 'user-1',
      );
      await ledger.recordOrderPaymentAtomic(
        orderId: 'o2',
        amount: 300,
        paymentMethod: 'cash',
        markCompleted: true,
        actorUid: 'user-1',
      );
      await ledger.cancelCompletedOrderAtomic(
        orderId: 'o1',
        reason: 'mistake',
        actorUid: 'user-1',
      );
      expect(await runningBalance(), closeTo(800, 0.001));
    });
  });

  group('watchRange', () {
    test('filters by occurredAt range', () async {
      final now = DateTime(2026, 4, 10, 12);
      await ledger.appendOpeningBalance(
        amount: 100,
        actorUid: 'user-1',
        occurredAt: now.subtract(const Duration(days: 2)),
      );
      await ledger.appendExpense(
        amount: 40,
        category: ExpenseCategory.other,
        actorUid: 'user-1',
        occurredAt: now,
      );
      await ledger.appendExpense(
        amount: 20,
        category: ExpenseCategory.other,
        actorUid: 'user-1',
        occurredAt: now.add(const Duration(days: 5)),
      );

      final entries = await ledger.getRange(
        now.subtract(const Duration(days: 1)),
        now.add(const Duration(days: 1)),
      );
      expect(entries, hasLength(1));
      expect(entries.single.type, TreasuryTransactionType.expense);
      expect(entries.single.amount, closeTo(-40, 0.001));
    });
  });
}
