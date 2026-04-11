import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:diamond_clean/core/constants/firebase_constants.dart';
import 'package:diamond_clean/features/cashbox/data/models/cashbox_audit_log_model.dart';
import 'package:diamond_clean/features/cashbox/data/models/cashbox_expense_model.dart';
import 'package:diamond_clean/features/cashbox/data/models/cashbox_income_model.dart';
import 'package:diamond_clean/features/cashbox/data/models/expense_category.dart';
import 'package:diamond_clean/features/orders/data/models/order_model.dart';

import '../models/treasury_report_model.dart';
import 'treasury_report_remote_data_source.dart';

class TreasuryReportRemoteDataSourceImpl
    implements TreasuryReportRemoteDataSource {
  final FirebaseFirestore _firestore;

  TreasuryReportRemoteDataSourceImpl(this._firestore);

  @override
  Stream<TreasuryReportModel> watchReport(
    DateTime startDate,
    DateTime endDate,
  ) {
    final startAt = _dayStart(startDate);
    final endExclusive = _nextDayStart(endDate);

    return Stream<TreasuryReportModel>.multi((multi) {
      List<OrderModel> orders = const <OrderModel>[];
      List<CashboxExpenseModel> expenses = const <CashboxExpenseModel>[];
      List<CashboxIncomeModel> incomes = const <CashboxIncomeModel>[];

      var hasOrders = false;
      var hasExpenses = false;
      var hasIncomes = false;
      var isCancelled = false;
      var generation = 0;

      Future<void> emitIfReady() async {
        if (!hasOrders || !hasExpenses || !hasIncomes || isCancelled) {
          return;
        }

        final currentGeneration = ++generation;
        try {
          final report = await _buildReport(
            startDate: startAt,
            endDate: _dayStart(endDate),
            orders: orders,
            expenses: expenses,
            incomes: incomes,
          );

          if (!isCancelled && currentGeneration == generation) {
            multi.add(report);
          }
        } catch (error, stackTrace) {
          if (!isCancelled) {
            multi.addError(error, stackTrace);
          }
        }
      }

      final subscriptions = <StreamSubscription<dynamic>>[
        _watchOrdersByDateRange(startAt, endExclusive).listen((data) {
          orders = data;
          hasOrders = true;
          unawaited(emitIfReady());
        }, onError: multi.addError),
        _watchExpensesByDateRange(startAt, endExclusive).listen((data) {
          expenses = data;
          hasExpenses = true;
          unawaited(emitIfReady());
        }, onError: multi.addError),
        _watchIncomeByDateRange(startAt, endExclusive).listen((data) {
          incomes = data;
          hasIncomes = true;
          unawaited(emitIfReady());
        }, onError: multi.addError),
      ];

      multi.onCancel = () async {
        isCancelled = true;
        for (final subscription in subscriptions) {
          await subscription.cancel();
        }
      };
    });
  }

  @override
  Future<List<OrderModel>> getOrdersByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final startAt = _dayStart(startDate);
    final endExclusive = _nextDayStart(endDate);
    final snapshot = await _ordersRangeQuery(startAt, endExclusive).get();
    return snapshot.docs.map(OrderModel.fromFirestore).toList();
  }

  @override
  Future<List<CashboxExpenseModel>> getExpensesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final startAt = _dayStart(startDate);
    final endExclusive = _nextDayStart(endDate);
    final snapshot = await _expensesRangeQuery(startAt, endExclusive).get();
    return snapshot.docs.map(CashboxExpenseModel.fromFirestore).toList();
  }

  @override
  Future<List<CashboxIncomeModel>> getIncomeByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final startAt = _dayStart(startDate);
    final endExclusive = _nextDayStart(endDate);
    final snapshot = await _incomeRangeQuery(startAt, endExclusive).get();
    return snapshot.docs.map(CashboxIncomeModel.fromFirestore).toList();
  }

  @override
  Future<TreasuryReportModel> generateReport(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final normalizedStartDate = _dayStart(startDate);
    final normalizedEndDate = _dayStart(endDate);

    final results = await Future.wait([
      getOrdersByDateRange(normalizedStartDate, normalizedEndDate),
      getExpensesByDateRange(normalizedStartDate, normalizedEndDate),
      getIncomeByDateRange(normalizedStartDate, normalizedEndDate),
    ]);

    final orders = results[0] as List<OrderModel>;
    final expenses = results[1] as List<CashboxExpenseModel>;
    final incomes = results[2] as List<CashboxIncomeModel>;

    return _buildReport(
      startDate: normalizedStartDate,
      endDate: normalizedEndDate,
      orders: orders,
      expenses: expenses,
      incomes: incomes,
    );
  }

  Future<TreasuryReportModel> _buildReport({
    required DateTime startDate,
    required DateTime endDate,
    required List<OrderModel> orders,
    required List<CashboxExpenseModel> expenses,
    required List<CashboxIncomeModel> incomes,
  }) async {
    // Order statistics
    final completedOrders = orders
        .where((o) => o.status == OrderStatus.completed)
        .toList();
    final pendingOrders = orders
        .where((o) => o.status == OrderStatus.pending)
        .toList();
    final confirmedOrders = orders
        .where((o) => o.status == OrderStatus.confirmed)
        .toList();
    final cancelledOrders = orders
        .where((o) => o.status == OrderStatus.cancelled)
        .toList();

    // Revenue from completed orders (net of delivery fees)
    final completedOrdersRevenue = completedOrders.fold<double>(
      0,
      (total, order) => total + ((order.totalPrice ?? 0) - order.deliveryFee),
    );

    // Delivery fees from income entries
    final deliveryFeesRevenue = incomes.fold<double>(
      0,
      (total, income) => total + income.deliveryFee,
    );

    // Payment method breakdown
    final cashIncomes = incomes.where(
      (i) => i.paymentMethod == 'cash' || i.paymentMethod == null,
    );
    final cashRevenue = cashIncomes.fold<double>(
      0,
      (total, i) => total + i.orderTotal,
    );

    final electronicIncomes = incomes.where(
      (i) => i.paymentMethod == 'vodafoneCash' || i.paymentMethod == 'instapay',
    );
    final electronicRevenue = electronicIncomes.fold<double>(
      0,
      (total, i) => total + i.orderTotal,
    );

    // Expenses grouped by category
    final expensesByCategory = <ExpenseCategory, double>{};
    for (final expense in expenses) {
      expensesByCategory.update(
        expense.category,
        (existing) => existing + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }

    // Remaining orders value (not completed, not cancelled)
    final remainingOrdersValue = orders
        .where(
          (o) =>
              o.status != OrderStatus.completed &&
              o.status != OrderStatus.cancelled,
        )
        .fold<double>(0, (total, order) => total + (order.totalPrice ?? 0));

    // Opening balance from the closest closure before startDate
    final openingBalance = await _getOpeningBalance(startDate);

    return TreasuryReportModel(
      startDate: startDate,
      endDate: endDate,
      totalOrdersCount: orders.length,
      completedOrdersCount: completedOrders.length,
      pendingOrdersCount: pendingOrders.length,
      confirmedOrdersCount: confirmedOrders.length,
      cancelledOrdersCount: cancelledOrders.length,
      completedOrdersRevenue: completedOrdersRevenue,
      deliveryFeesRevenue: deliveryFeesRevenue,
      cashRevenue: cashRevenue,
      electronicRevenue: electronicRevenue,
      expensesByCategory: expensesByCategory,
      openingBalance: openingBalance,
      remainingOrdersValue: remainingOrdersValue,
    );
  }

  DateTime _dayStart(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  DateTime _nextDayStart(DateTime date) =>
      _dayStart(date).add(const Duration(days: 1));

  Query<Map<String, dynamic>> _ordersRangeQuery(
    DateTime startDate,
    DateTime endExclusive,
  ) => _firestore
      .collection(FirebaseConstants.ordersCollection)
      .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
      .where('createdAt', isLessThan: Timestamp.fromDate(endExclusive));

  Query<Map<String, dynamic>> _expensesRangeQuery(
    DateTime startDate,
    DateTime endExclusive,
  ) => _firestore
      .collection(FirebaseConstants.cashboxExpensesCollection)
      .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
      .where('createdAt', isLessThan: Timestamp.fromDate(endExclusive));

  Query<Map<String, dynamic>> _incomeRangeQuery(
    DateTime startDate,
    DateTime endExclusive,
  ) => _firestore
      .collection(FirebaseConstants.cashboxIncomeCollection)
      .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
      .where('createdAt', isLessThan: Timestamp.fromDate(endExclusive));

  Stream<List<OrderModel>> _watchOrdersByDateRange(
    DateTime startDate,
    DateTime endExclusive,
  ) => _ordersRangeQuery(startDate, endExclusive).snapshots().map(
    (snapshot) => snapshot.docs.map(OrderModel.fromFirestore).toList(),
  );

  Stream<List<CashboxExpenseModel>> _watchExpensesByDateRange(
    DateTime startDate,
    DateTime endExclusive,
  ) => _expensesRangeQuery(startDate, endExclusive).snapshots().map(
    (snapshot) => snapshot.docs.map(CashboxExpenseModel.fromFirestore).toList(),
  );

  Stream<List<CashboxIncomeModel>> _watchIncomeByDateRange(
    DateTime startDate,
    DateTime endExclusive,
  ) => _incomeRangeQuery(startDate, endExclusive).snapshots().map(
    (snapshot) => snapshot.docs.map(CashboxIncomeModel.fromFirestore).toList(),
  );

  Future<double> _getOpeningBalance(DateTime startDate) async {
    final closureSnapshot = await _firestore
        .collection(FirebaseConstants.cashboxClosuresCollection)
        .where('closedAt', isLessThan: Timestamp.fromDate(startDate))
        .orderBy('closedAt', descending: true)
        .limit(1)
        .get();

    if (closureSnapshot.docs.isNotEmpty) {
      final data = closureSnapshot.docs.first.data();
      return (data['closingBalance'] as num?)?.toDouble() ?? 0;
    }

    // Fallback: check cashbox settings
    final settingsSnapshot = await _firestore
        .collection(FirebaseConstants.cashboxSettingsCollection)
        .doc('current')
        .get();

    if (settingsSnapshot.exists) {
      final data = settingsSnapshot.data();
      return (data?['openingBalance'] as num?)?.toDouble() ?? 0;
    }

    return 0;
  }

  @override
  Future<List<CashboxAuditLogModel>> getAuditLogsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final startAt = _dayStart(startDate);
    final endExclusive = _nextDayStart(endDate);
    final snapshot = await _firestore
        .collection(FirebaseConstants.cashboxAuditLogsCollection)
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startAt))
        .where('createdAt', isLessThan: Timestamp.fromDate(endExclusive))
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map(CashboxAuditLogModel.fromFirestore).toList();
  }
}
