import '../data/models/employee_advance_model.dart';
import '../data/models/employee_model.dart';

sealed class EmployeeDetailsState {
  const EmployeeDetailsState();
}

class EmployeeDetailsInitial extends EmployeeDetailsState {
  const EmployeeDetailsInitial();
}

class EmployeeDetailsLoading extends EmployeeDetailsState {
  const EmployeeDetailsLoading();
}

class EmployeeDetailsLoaded extends EmployeeDetailsState {
  final EmployeeModel employee;
  final List<EmployeeAdvanceModel> advances;

  const EmployeeDetailsLoaded({required this.employee, required this.advances});
}

class EmployeeDetailsError extends EmployeeDetailsState {
  final String message;

  const EmployeeDetailsError(this.message);
}
