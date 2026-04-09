import '../data/models/customer_model.dart';

sealed class CustomersState {
  const CustomersState();
}

class CustomersInitial extends CustomersState {
  const CustomersInitial();
}

class CustomersLoading extends CustomersState {
  const CustomersLoading();
}

class CustomersLoaded extends CustomersState {
  final List<CustomerModel> customers;

  const CustomersLoaded(this.customers);

  List<CustomerModel> filterCustomers(String searchQuery) {
    final normalizedQuery = searchQuery.trim().toLowerCase();

    if (normalizedQuery.isEmpty) {
      return customers;
    }

    return customers.where((customer) {
      final codeMatch = customer.code.toLowerCase().contains(normalizedQuery);
      final phoneMatch = customer.phone.toLowerCase().contains(normalizedQuery);
      return codeMatch || phoneMatch;
    }).toList();
  }
}

class CustomersError extends CustomersState {
  final String message;

  const CustomersError(this.message);
}

class GeneratingCustomerCode extends CustomersState {
  const GeneratingCustomerCode();
}

class CustomerCodeGenerated extends CustomersState {
  final String code;

  const CustomerCodeGenerated(this.code);
}

class SavingCustomer extends CustomersState {
  const SavingCustomer();
}

class CustomerSaved extends CustomersState {
  const CustomerSaved();
}
