import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:diamond_clean/core/constants/firebase_constants.dart';
import 'package:diamond_clean/features/cashbox/data/models/cashbox_expense_model.dart';
import 'package:diamond_clean/features/cashbox/data/models/expense_category.dart';

import '../models/employee_advance_model.dart';
import '../models/employee_model.dart';
import '../models/salary_cycle.dart';

class EmployeeAdvanceLimitExceededException implements Exception {
  final double requestedAmount;
  final double remainingAmount;

  const EmployeeAdvanceLimitExceededException({
    required this.requestedAmount,
    required this.remainingAmount,
  });
}

class EmployeeSalaryPayoutLimitExceededException implements Exception {
  final double requestedAmount;
  final double remainingAmount;

  const EmployeeSalaryPayoutLimitExceededException({
    required this.requestedAmount,
    required this.remainingAmount,
  });
}

abstract class EmployeesRemoteDataSource {
  Stream<List<EmployeeModel>> watchEmployees();
  Stream<List<EmployeeAdvanceModel>> watchEmployeeAdvances(String employeeId);
  Future<void> addEmployee(EmployeeModel employee);
  Future<void> updateEmployee(EmployeeModel employee);
  Future<void> deleteEmployee(String employeeId);
  Future<void> addAdvance({
    required String employeeId,
    required double amount,
    required String note,
    String? createdBy,
  });
  Future<void> registerSalaryPayout({
    required String employeeId,
    required double amount,
    String? note,
    String? createdBy,
  });
}

class EmployeesRemoteDataSourceImpl implements EmployeesRemoteDataSource {
  final FirebaseFirestore _firestore;

  EmployeesRemoteDataSourceImpl(this._firestore);

  CollectionReference<Map<String, dynamic>> get _employeesRef =>
      _firestore.collection(FirebaseConstants.employeesCollection);

  CollectionReference<Map<String, dynamic>> _advancesRef(String employeeId) {
    return _employeesRef
        .doc(employeeId)
        .collection(FirebaseConstants.employeeAdvancesCollection);
  }

  @override
  Stream<List<EmployeeModel>> watchEmployees() {
    return _employeesRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map(EmployeeModel.fromFirestore).toList(),
        );
  }

  @override
  Stream<List<EmployeeAdvanceModel>> watchEmployeeAdvances(String employeeId) {
    return _advancesRef(employeeId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map(EmployeeAdvanceModel.fromFirestore).toList(),
        );
  }

  @override
  Future<void> addEmployee(EmployeeModel employee) async {
    await _employeesRef.doc(employee.id).set(employee.toFirestore());
  }

  @override
  Future<void> updateEmployee(EmployeeModel employee) async {
    await _employeesRef.doc(employee.id).update(employee.toFirestore());
  }

  @override
  Future<void> deleteEmployee(String employeeId) async {
    final advancesSnapshot = await _advancesRef(employeeId).get();
    final batch = _firestore.batch();
    for (final doc in advancesSnapshot.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(_employeesRef.doc(employeeId));
    await batch.commit();
  }

  @override
  Future<void> addAdvance({
    required String employeeId,
    required double amount,
    required String note,
    String? createdBy,
  }) async {
    final employeeRef = _employeesRef.doc(employeeId);
    var limitExceeded = false;
    var rejectedRemaining = 0.0;

    await _firestore.runTransaction((transaction) async {
      final employeeSnapshot = await transaction.get(employeeRef);
      if (!employeeSnapshot.exists) {
        throw Exception('Employee not found');
      }

      final employee = EmployeeModel.fromFirestore(employeeSnapshot);
      final now = DateTime.now();
      final normalizedEmployee = _normalizeEmployeeCycle(employee, now);
      final remaining = normalizedEmployee.remainingSalary;

      if (amount > remaining) {
        limitExceeded = true;
        rejectedRemaining = remaining;
        return;
      }

      final advanceRef = _advancesRef(employeeId).doc();
      final advance = EmployeeAdvanceModel(
        id: advanceRef.id,
        employeeId: employeeId,
        employeeName: normalizedEmployee.name,
        amount: amount,
        note: note,
        createdBy: createdBy,
        createdAt: now,
      );

      final cashboxExpenseRef = _firestore
          .collection(FirebaseConstants.cashboxExpensesCollection)
          .doc('employee_advance_${advance.id}');
      final cashboxExpense = CashboxExpenseModel(
        id: cashboxExpenseRef.id,
        title: 'سلفة موظف: ${normalizedEmployee.name}',
        amount: amount,
        category: ExpenseCategory.advance,
        createdBy: createdBy,
        createdAt: now,
      );

      final updatedEmployee = normalizedEmployee.copyWith(
        currentCycleAdvancesTotal:
            normalizedEmployee.currentCycleAdvancesTotal + amount,
        totalAdvancesCount: normalizedEmployee.totalAdvancesCount + 1,
        updatedAt: now,
      );

      transaction.set(advanceRef, advance.toFirestore());
      transaction.set(cashboxExpenseRef, cashboxExpense.toFirestore());
      transaction.update(employeeRef, {
        'salaryCycle': updatedEmployee.salaryCycle.value,
        'salaryAmount': updatedEmployee.salaryAmount,
        'cycleStartAt': Timestamp.fromDate(updatedEmployee.cycleStartAt),
        'currentCycleAdvancesTotal': updatedEmployee.currentCycleAdvancesTotal,
        'currentCyclePaidTotal': updatedEmployee.currentCyclePaidTotal,
        'totalAdvancesCount': updatedEmployee.totalAdvancesCount,
        'updatedAt': Timestamp.fromDate(updatedEmployee.updatedAt),
      });
    });

    if (limitExceeded) {
      throw EmployeeAdvanceLimitExceededException(
        requestedAmount: amount,
        remainingAmount: rejectedRemaining,
      );
    }
  }

  @override
  Future<void> registerSalaryPayout({
    required String employeeId,
    required double amount,
    String? note,
    String? createdBy,
  }) async {
    final employeeRef = _employeesRef.doc(employeeId);
    var limitExceeded = false;
    var rejectedRemaining = 0.0;

    await _firestore.runTransaction((transaction) async {
      final employeeSnapshot = await transaction.get(employeeRef);
      if (!employeeSnapshot.exists) {
        throw Exception('Employee not found');
      }

      final employee = EmployeeModel.fromFirestore(employeeSnapshot);
      final now = DateTime.now();
      final normalizedEmployee = _normalizeEmployeeCycle(employee, now);
      final remaining = normalizedEmployee.remainingSalary;

      if (amount > remaining) {
        limitExceeded = true;
        rejectedRemaining = remaining;
        return;
      }

      final cashboxExpenseRef = _firestore
          .collection(FirebaseConstants.cashboxExpensesCollection)
          .doc();
      final title = note == null || note.trim().isEmpty
          ? 'قبض موظف: ${normalizedEmployee.name}'
          : 'قبض موظف: ${normalizedEmployee.name} - ${note.trim()}';
      final cashboxExpense = CashboxExpenseModel(
        id: cashboxExpenseRef.id,
        title: title,
        amount: amount,
        category: ExpenseCategory.salary,
        createdBy: createdBy,
        createdAt: now,
      );

      final updatedEmployee = normalizedEmployee.copyWith(
        currentCyclePaidTotal:
            normalizedEmployee.currentCyclePaidTotal + amount,
        updatedAt: now,
      );

      transaction.set(cashboxExpenseRef, cashboxExpense.toFirestore());
      transaction.update(employeeRef, {
        'salaryCycle': updatedEmployee.salaryCycle.value,
        'salaryAmount': updatedEmployee.salaryAmount,
        'cycleStartAt': Timestamp.fromDate(updatedEmployee.cycleStartAt),
        'currentCycleAdvancesTotal': updatedEmployee.currentCycleAdvancesTotal,
        'currentCyclePaidTotal': updatedEmployee.currentCyclePaidTotal,
        'totalAdvancesCount': updatedEmployee.totalAdvancesCount,
        'updatedAt': Timestamp.fromDate(updatedEmployee.updatedAt),
      });
    });

    if (limitExceeded) {
      throw EmployeeSalaryPayoutLimitExceededException(
        requestedAmount: amount,
        remainingAmount: rejectedRemaining,
      );
    }
  }

  EmployeeModel _normalizeEmployeeCycle(EmployeeModel employee, DateTime now) {
    var cycleStart = employee.cycleStartAt;
    var advancesTotal = employee.currentCycleAdvancesTotal;
    var paidTotal = employee.currentCyclePaidTotal;

    while (true) {
      final nextCycleStart = employee.salaryCycle.nextCycleStart(cycleStart);
      if (now.isBefore(nextCycleStart)) {
        break;
      }
      cycleStart = nextCycleStart;
      advancesTotal = 0;
      paidTotal = 0;
    }

    if (cycleStart == employee.cycleStartAt &&
        advancesTotal == employee.currentCycleAdvancesTotal &&
        paidTotal == employee.currentCyclePaidTotal) {
      return employee;
    }

    return employee.copyWith(
      cycleStartAt: cycleStart,
      currentCycleAdvancesTotal: advancesTotal,
      currentCyclePaidTotal: paidTotal,
      updatedAt: now,
    );
  }
}
