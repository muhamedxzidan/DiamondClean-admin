import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:diamond_clean/core/constants/firebase_constants.dart';

import '../models/cashbox_audit_log_model.dart';
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
    if (openedBy.trim().isEmpty) {
      throw ArgumentError('openedBy cannot be empty');
    }
    if (openingBalance < 0) {
      throw ArgumentError('openingBalance cannot be negative');
    }

    try {
      await _settingsRef.set({
        'openingBalance': openingBalance,
        'openedAt': Timestamp.fromDate(DateTime.now()),
        'openedBy': openedBy,
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to save opening balance: $e');
    }
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
    if (expense.title.trim().isEmpty) {
      throw ArgumentError('Expense title cannot be empty');
    }
    if (expense.amount <= 0) {
      throw ArgumentError('Expense amount must be positive');
    }

    try {
      await _firestore
          .collection(FirebaseConstants.cashboxExpensesCollection)
          .doc(expense.id)
          .set(expense.toFirestore());
    } catch (e) {
      throw Exception('Failed to add expense: $e');
    }
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
    if (closedBy.trim().isEmpty) {
      throw ArgumentError('closedBy cannot be empty');
    }
    if (openingBalance < 0) {
      throw ArgumentError('Opening balance cannot be negative');
    }
    if (closingBalance < 0) {
      throw ArgumentError('Closing balance cannot be negative');
    }

    // Validate calculation
    final calculatedClosing = openingBalance + totalRevenue - totalExpenses;
    if ((closingBalance - calculatedClosing).abs() > 0.01) {
      throw Exception(
        'Closing balance mismatch: $closingBalance != '
        '${openingBalance} + ${totalRevenue} - ${totalExpenses} = ${calculatedClosing}',
      );
    }

    try {
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
    } catch (e) {
      throw Exception('Failed to close cashbox: $e');
    }
  }

  @override
  Future<void> savePin(String? pin) async {
    await _settingsRef.set({'ownerPin': pin}, SetOptions(merge: true));
  }

  @override
  Future<String?> getOwnerPin() async {
    final snapshot = await _settingsRef.get();
    final pin = snapshot.data()?['ownerPin'];
    if (pin is String && pin.isNotEmpty) {
      return pin;
    }
    return null;
  }

  @override
  Stream<List<CashboxAuditLogModel>> watchAuditLogs() => _firestore
      .collection(FirebaseConstants.cashboxAuditLogsCollection)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.docs.map(CashboxAuditLogModel.fromFirestore).toList(),
      );

  @override
  Future<void> logAuditEvent(CashboxAuditLogModel event) async {
    await _firestore
        .collection(FirebaseConstants.cashboxAuditLogsCollection)
        .doc(event.id)
        .set(event.toFirestore());
  }
}
