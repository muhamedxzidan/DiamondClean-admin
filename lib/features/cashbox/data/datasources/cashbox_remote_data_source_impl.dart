import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:diamond_clean/core/constants/firebase_constants.dart';

import '../models/cashbox_closure_model.dart';
import '../models/cashbox_income_model.dart';
import '../models/cashbox_expense_model.dart';
import '../models/cashbox_settings_model.dart';
import 'cashbox_remote_data_source.dart';

class CashboxRemoteDataSourceImpl implements CashboxRemoteDataSource {
  final FirebaseFirestore _firestore;

  CashboxRemoteDataSourceImpl(this._firestore);

  DocumentReference<Map<String, dynamic>> get _settingsRef => _firestore
      .collection(FirebaseConstants.cashboxSettingsCollection)
      .doc('current');

  @override
  Stream<List<CashboxIncomeModel>> watchIncomeEntries() => _firestore
      .collection(FirebaseConstants.cashboxIncomeCollection)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.docs.map(CashboxIncomeModel.fromFirestore).toList(),
      );

  @override
  Stream<List<CashboxExpenseModel>> watchExpenses() => _firestore
      .collection(FirebaseConstants.cashboxExpensesCollection)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.docs.map(CashboxExpenseModel.fromFirestore).toList(),
      );

  @override
  Stream<List<CashboxClosureModel>> watchClosures() => _firestore
      .collection(FirebaseConstants.cashboxClosuresCollection)
      .orderBy('closedAt', descending: true)
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.docs.map(CashboxClosureModel.fromFirestore).toList(),
      );

  @override
  Stream<CashboxSettingsModel?> watchSettings() => _settingsRef.snapshots().map(
    (snapshot) => snapshot.exists
        ? CashboxSettingsModel.fromFirestore(snapshot)
        : CashboxSettingsModel.initial(),
  );

  @override
  Future<void> saveOpeningBalance({
    required double openingBalance,
    required String openedBy,
  }) async {
    await _settingsRef.set({
      'openingBalance': openingBalance,
      'openedAt': Timestamp.fromDate(DateTime.now()),
      'openedBy': openedBy,
    }, SetOptions(merge: true));
  }

  @override
  Future<void> recordOrderIncome(CashboxIncomeModel income) async {
    await _firestore
        .collection(FirebaseConstants.cashboxIncomeCollection)
        .doc(income.orderId)
        .set(income.toFirestore(), SetOptions(merge: true));
  }

  @override
  Future<void> addExpense(CashboxExpenseModel expense) async {
    await _firestore
        .collection(FirebaseConstants.cashboxExpensesCollection)
        .doc(expense.id)
        .set(expense.toFirestore());
  }

  @override
  Future<void> updateExpense(CashboxExpenseModel expense) async {
    await _firestore
        .collection(FirebaseConstants.cashboxExpensesCollection)
        .doc(expense.id)
        .update(expense.toFirestore());
  }

  @override
  Future<void> deleteExpense(String expenseId) async {
    await _firestore
        .collection(FirebaseConstants.cashboxExpensesCollection)
        .doc(expenseId)
        .delete();
  }

  @override
  Future<void> closeCashbox({
    required String closedBy,
    required double openingBalance,
    required double totalRevenue,
    required double totalExpenses,
    required double closingBalance,
    required int ordersCount,
    required List<CashboxExpenseModel> expenses,
  }) async {
    final now = DateTime.now();
    final closureId = _firestore
        .collection(FirebaseConstants.cashboxClosuresCollection)
        .doc()
        .id;
    final closure = CashboxClosureModel(
      id: closureId,
      closedBy: closedBy,
      openingBalance: openingBalance,
      totalRevenue: totalRevenue,
      totalExpenses: totalExpenses,
      closingBalance: closingBalance,
      ordersCount: ordersCount,
      expenses: expenses
          .map((e) => ClosureExpenseEntry(title: e.title, amount: e.amount))
          .toList(),
      closedAt: now,
    );

    await _firestore.runTransaction((transaction) async {
      transaction.set(
        _firestore
            .collection(FirebaseConstants.cashboxClosuresCollection)
            .doc(closureId),
        closure.toFirestore(),
      );
      transaction.set(_settingsRef, {
        'openingBalance': 0,
        'openedAt': Timestamp.fromDate(now),
        'lastClosedAt': Timestamp.fromDate(now),
        'lastClosedBy': closedBy,
        'lastClosingBalance': closingBalance,
      }, SetOptions(merge: true));
    });
  }

  @override
  Future<void> savePin(String? pin) async {
    await _settingsRef.set({'ownerPin': pin}, SetOptions(merge: true));
  }
}
