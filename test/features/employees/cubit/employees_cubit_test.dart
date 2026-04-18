import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:diamond_clean/features/employees/cubit/employees_cubit.dart';
import 'package:diamond_clean/features/employees/cubit/employees_state.dart';
import 'package:diamond_clean/features/employees/data/datasources/employees_remote_data_source.dart';
import 'package:diamond_clean/features/employees/data/models/employee_advance_model.dart';
import 'package:diamond_clean/features/employees/data/models/employee_model.dart';
import 'package:diamond_clean/features/employees/data/models/salary_cycle.dart';

class _FakeEmployeesRemoteDataSource implements EmployeesRemoteDataSource {
  final _employeesController =
      StreamController<List<EmployeeModel>>.broadcast();
  final Map<String, StreamController<List<EmployeeAdvanceModel>>>
  _advancesControllers = {};

  bool rejectAdvance = false;
  double remainingAmount = 0;
  List<EmployeeModel> employees = const [];

  @override
  Stream<List<EmployeeModel>> watchEmployees() => _employeesController.stream;

  @override
  Stream<List<EmployeeAdvanceModel>> watchEmployeeAdvances(String employeeId) {
    return _advancesControllers
        .putIfAbsent(
          employeeId,
          () => StreamController<List<EmployeeAdvanceModel>>.broadcast(),
        )
        .stream;
  }

  @override
  Future<void> addEmployee(EmployeeModel employee) async {
    employees = [employee, ...employees];
    _employeesController.add(employees);
  }

  @override
  Future<void> updateEmployee(EmployeeModel employee) async {}

  @override
  Future<void> deleteEmployee(String employeeId) async {
    employees = employees.where((e) => e.id != employeeId).toList();
    _employeesController.add(employees);
  }

  @override
  Future<void> addAdvance({
    required String employeeId,
    required double amount,
    required String note,
    String? createdBy,
  }) async {
    if (rejectAdvance) {
      throw EmployeeAdvanceLimitExceededException(
        requestedAmount: amount,
        remainingAmount: remainingAmount,
      );
    }
  }

  @override
  Future<void> registerSalaryPayout({
    required String employeeId,
    required double amount,
    String? note,
    String? createdBy,
  }) async {}

  void seedEmployees(List<EmployeeModel> seed) {
    employees = seed;
    _employeesController.add(seed);
  }

  Future<void> dispose() async {
    await _employeesController.close();
    for (final controller in _advancesControllers.values) {
      await controller.close();
    }
  }
}

void main() {
  test('emits rejected state when advance exceeds remaining salary', () async {
    final dataSource = _FakeEmployeesRemoteDataSource();
    final cubit = EmployeesCubit(dataSource);
    final employee = EmployeeModel(
      id: 'emp-1',
      name: 'Ali',
      phone: '0100',
      salaryCycle: SalaryCycle.weekly,
      salaryAmount: 1000,
      cycleStartAt: DateTime(2026, 4, 1),
      currentCycleAdvancesTotal: 800,
      totalAdvancesCount: 2,
      createdAt: DateTime(2026, 4, 1),
      updatedAt: DateTime(2026, 4, 1),
    );

    dataSource.seedEmployees([employee]);
    dataSource.rejectAdvance = true;
    dataSource.remainingAmount = 200;

    cubit.listenToEmployees();
    await Future<void>.delayed(Duration.zero);

    final emittedStates = <EmployeesState>[];
    final subscription = cubit.stream.listen(emittedStates.add);

    await cubit.addAdvance(employeeId: employee.id, amount: 300, note: 'test');
    await Future<void>.delayed(Duration.zero);

    expect(
      emittedStates.any((state) => state is EmployeeAdvanceRejected),
      isTrue,
    );

    final rejected = emittedStates.whereType<EmployeeAdvanceRejected>().first;
    expect(rejected.remainingAmount, 200);
    expect(rejected.requestedAmount, 300);

    await subscription.cancel();
    await cubit.close();
    await dataSource.dispose();
  });
}
