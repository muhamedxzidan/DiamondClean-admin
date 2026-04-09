import '../data/models/customer_model.dart';
import '../data/models/customer_transaction_model.dart';

sealed class CustomerDetailsState {
  const CustomerDetailsState();
}

final class CustomerDetailsInitial extends CustomerDetailsState {
  const CustomerDetailsInitial();
}

final class CustomerDetailsLoading extends CustomerDetailsState {
  const CustomerDetailsLoading();
}

final class CustomerDetailsLoaded extends CustomerDetailsState {
  final CustomerModel customer;
  final List<CustomerTransactionModel> transactions;

  const CustomerDetailsLoaded({
    required this.customer,
    required this.transactions,
  });
}

final class CustomerDetailsError extends CustomerDetailsState {
  final String message;

  const CustomerDetailsError(this.message);
}
