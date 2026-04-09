import 'package:bloc/bloc.dart';

import '../data/datasources/customers_remote_data_source.dart';
import '../data/models/customer_model.dart';
import 'customer_details_state.dart';

class CustomerDetailsCubit extends Cubit<CustomerDetailsState> {
  final CustomersRemoteDataSource _dataSource;

  CustomerDetailsCubit(this._dataSource)
    : super(const CustomerDetailsInitial());

  Future<void> loadCustomerDetails(CustomerModel customer) async {
    try {
      emit(const CustomerDetailsLoading());

      final storedCustomer =
          await _dataSource.getCustomerById(customer.id) ?? customer;
      final transactions = await _dataSource.getCustomerTransactions(
        customer.id,
      );

      emit(
        CustomerDetailsLoaded(
          customer: storedCustomer,
          transactions: transactions,
        ),
      );
    } catch (e) {
      emit(CustomerDetailsError(e.toString()));
    }
  }
}
