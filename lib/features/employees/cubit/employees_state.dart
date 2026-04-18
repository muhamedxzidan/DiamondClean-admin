import '../data/models/employee_model.dart';

sealed class EmployeesState {
  const EmployeesState();
}

class EmployeesInitial extends EmployeesState {
  const EmployeesInitial();
}

class EmployeesLoading extends EmployeesState {
  const EmployeesLoading();
}

class EmployeesLoaded extends EmployeesState {
  final List<EmployeeModel> employees;

  const EmployeesLoaded(this.employees);

  List<EmployeeModel> filterEmployees(String searchQuery) {
    final normalizedQuery = searchQuery.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return employees;
    }

    return employees.where((employee) {
      final nameMatch = employee.name.toLowerCase().contains(normalizedQuery);
      final phoneMatch = employee.phone.toLowerCase().contains(normalizedQuery);
      final nationalIdMatch = (employee.nationalId ?? '')
          .toLowerCase()
          .contains(normalizedQuery);
      final cityMatch = (employee.city ?? '').toLowerCase().contains(
        normalizedQuery,
      );
      return nameMatch || phoneMatch || nationalIdMatch || cityMatch;
    }).toList();
  }
}

class EmployeesError extends EmployeesState {
  final String message;

  const EmployeesError(this.message);
}

class SavingEmployee extends EmployeesState {
  const SavingEmployee();
}

class EmployeeSaved extends EmployeesState {
  const EmployeeSaved();
}

class EmployeeDeleted extends EmployeesState {
  const EmployeeDeleted();
}

class AddingEmployeeAdvance extends EmployeesState {
  const AddingEmployeeAdvance();
}

class EmployeeAdvanceAdded extends EmployeesState {
  const EmployeeAdvanceAdded();
}

class EmployeeAdvanceRejected extends EmployeesState {
  final double requestedAmount;
  final double remainingAmount;

  const EmployeeAdvanceRejected({
    required this.requestedAmount,
    required this.remainingAmount,
  });
}

class PayingEmployeeSalary extends EmployeesState {
  const PayingEmployeeSalary();
}

class EmployeeSalaryPaid extends EmployeesState {
  const EmployeeSalaryPaid();
}

class EmployeeSalaryPayoutRejected extends EmployeesState {
  final double requestedAmount;
  final double remainingAmount;

  const EmployeeSalaryPayoutRejected({
    required this.requestedAmount,
    required this.remainingAmount,
  });
}
