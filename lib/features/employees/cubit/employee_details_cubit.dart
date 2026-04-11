import 'dart:async';

import 'package:bloc/bloc.dart';

import '../data/datasources/employees_remote_data_source.dart';
import '../data/models/employee_advance_model.dart';
import '../data/models/employee_model.dart';
import 'employee_details_state.dart';

class EmployeeDetailsCubit extends Cubit<EmployeeDetailsState> {
  final EmployeesRemoteDataSource _dataSource;
  final String _employeeId;
  EmployeeModel? _currentEmployee;
  List<EmployeeAdvanceModel> _currentAdvances = const [];

  StreamSubscription<List<EmployeeModel>>? _employeeSubscription;
  StreamSubscription<List<EmployeeAdvanceModel>>? _advancesSubscription;

  EmployeeDetailsCubit(this._dataSource, EmployeeModel employee)
    : _employeeId = employee.id,
      _currentEmployee = employee,
      super(const EmployeeDetailsInitial());

  void listen() {
    emit(const EmployeeDetailsLoading());
    _employeeSubscription?.cancel();
    _advancesSubscription?.cancel();

    _employeeSubscription = _dataSource.watchEmployees().listen(
      (employees) {
        final index = employees.indexWhere(
          (employee) => employee.id == _employeeId,
        );
        if (index == -1) {
          emit(const EmployeeDetailsError('لم يتم العثور على بيانات الموظف'));
          return;
        }
        _currentEmployee = employees[index];
        _emitLoaded();
      },
      onError: (Object error) {
        emit(EmployeeDetailsError(error.toString()));
      },
    );

    _advancesSubscription = _dataSource
        .watchEmployeeAdvances(_employeeId)
        .listen(
          (advances) {
            _currentAdvances = advances;
            _emitLoaded();
          },
          onError: (Object error) {
            emit(EmployeeDetailsError(error.toString()));
          },
        );
  }

  void _emitLoaded() {
    final employee = _currentEmployee;
    if (employee == null) {
      return;
    }
    emit(EmployeeDetailsLoaded(employee: employee, advances: _currentAdvances));
  }

  @override
  Future<void> close() async {
    await _employeeSubscription?.cancel();
    await _advancesSubscription?.cancel();
    return super.close();
  }
}
