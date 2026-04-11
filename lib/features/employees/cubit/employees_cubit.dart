import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/datasources/employees_remote_data_source.dart';
import '../data/models/employee_model.dart';
import '../data/models/salary_cycle.dart';
import 'employees_state.dart';

class EmployeesCubit extends Cubit<EmployeesState> {
  final EmployeesRemoteDataSource _dataSource;
  StreamSubscription<List<EmployeeModel>>? _subscription;
  List<EmployeeModel> _currentEmployees = [];

  EmployeesRemoteDataSource get dataSource => _dataSource;

  EmployeesCubit(this._dataSource) : super(const EmployeesInitial());

  void listenToEmployees() {
    emit(const EmployeesLoading());
    _subscription?.cancel();
    _subscription = _dataSource.watchEmployees().listen(
      (employees) {
        _currentEmployees = employees;
        emit(EmployeesLoaded(employees));
      },
      onError: (Object error) {
        emit(EmployeesError(error.toString()));
      },
    );
  }

  Future<void> addEmployee({
    required String name,
    required String phone,
    String? nationalId,
    String? city,
    required SalaryCycle salaryCycle,
    required double salaryAmount,
  }) async {
    try {
      emit(const SavingEmployee());
      final now = DateTime.now();
      final employeeId = FirebaseFirestore.instance
          .collection('employees')
          .doc()
          .id;
      final employee = EmployeeModel(
        id: employeeId,
        name: name,
        phone: phone,
        nationalId: nationalId,
        city: city,
        salaryCycle: salaryCycle,
        salaryAmount: salaryAmount,
        cycleStartAt: now,
        currentCycleAdvancesTotal: 0,
        currentCyclePaidTotal: 0,
        totalAdvancesCount: 0,
        createdAt: now,
        updatedAt: now,
      );
      await _dataSource.addEmployee(employee);
      emit(const EmployeeSaved());
      emit(EmployeesLoaded(_currentEmployees));
    } catch (error) {
      emit(EmployeesError(error.toString()));
      emit(EmployeesLoaded(_currentEmployees));
    }
  }

  Future<void> updateEmployee(EmployeeModel employee) async {
    try {
      emit(const SavingEmployee());
      await _dataSource.updateEmployee(
        employee.copyWith(updatedAt: DateTime.now()),
      );
      emit(const EmployeeSaved());
      emit(EmployeesLoaded(_currentEmployees));
    } catch (error) {
      emit(EmployeesError(error.toString()));
      emit(EmployeesLoaded(_currentEmployees));
    }
  }

  Future<void> addAdvance({
    required String employeeId,
    required double amount,
    required String note,
    String? createdBy,
  }) async {
    try {
      emit(const AddingEmployeeAdvance());
      await _dataSource.addAdvance(
        employeeId: employeeId,
        amount: amount,
        note: note,
        createdBy: createdBy,
      );
      emit(const EmployeeAdvanceAdded());
      emit(EmployeesLoaded(_currentEmployees));
    } on EmployeeAdvanceLimitExceededException catch (error) {
      emit(
        EmployeeAdvanceRejected(
          requestedAmount: error.requestedAmount,
          remainingAmount: error.remainingAmount,
        ),
      );
      emit(EmployeesLoaded(_currentEmployees));
    } catch (error) {
      emit(EmployeesError(error.toString()));
      emit(EmployeesLoaded(_currentEmployees));
    }
  }

  Future<void> payEmployeeSalary({
    required String employeeId,
    required double amount,
    String? note,
    String? createdBy,
  }) async {
    try {
      emit(const PayingEmployeeSalary());
      await _dataSource.registerSalaryPayout(
        employeeId: employeeId,
        amount: amount,
        note: note,
        createdBy: createdBy,
      );
      emit(const EmployeeSalaryPaid());
      emit(EmployeesLoaded(_currentEmployees));
    } on EmployeeSalaryPayoutLimitExceededException catch (error) {
      emit(
        EmployeeSalaryPayoutRejected(
          requestedAmount: error.requestedAmount,
          remainingAmount: error.remainingAmount,
        ),
      );
      emit(EmployeesLoaded(_currentEmployees));
    } catch (error) {
      emit(EmployeesError(error.toString()));
      emit(EmployeesLoaded(_currentEmployees));
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
