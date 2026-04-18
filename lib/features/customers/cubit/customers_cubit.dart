import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/datasources/customers_remote_data_source.dart';
import '../data/models/customer_model.dart';
import '../data/models/customer_transaction_model.dart';
import 'customers_state.dart';

class CustomersCubit extends Cubit<CustomersState> {
  final CustomersRemoteDataSource _dataSource;
  StreamSubscription<List<CustomerModel>>? _subscription;
  List<CustomerModel> _currentCustomers = [];

  CustomersRemoteDataSource get dataSource => _dataSource;

  CustomersCubit(this._dataSource) : super(const CustomersInitial());

  Future<void> listenToCustomers() async {
    emit(const CustomersLoading());
    await _subscription?.cancel();
    _subscription = _dataSource.watchCustomers().listen((customers) {
      _currentCustomers = customers;
      emit(CustomersLoaded(customers));
    }, onError: (Object e) => emit(CustomersError(e.toString())));
  }

  Future<void> generateCustomerCode() async {
    try {
      emit(const GeneratingCustomerCode());
      final code = await _dataSource.generateCustomerCode();
      emit(CustomerCodeGenerated(code));
      emit(CustomersLoaded(_currentCustomers));
    } catch (e) {
      emit(CustomersError(e.toString()));
      emit(CustomersLoaded(_currentCustomers));
    }
  }

  Future<void> saveCustomer({
    required String code,
    required String name,
    required String phone,
    required String address,
  }) async {
    try {
      emit(const SavingCustomer());
      final customerId = FirebaseFirestore.instance
          .collection('customers')
          .doc()
          .id;
      final customer = CustomerModel(
        id: customerId,
        code: code,
        name: name,
        phone: phone,
        address: address,
        createdAt: DateTime.now(),
      );
      await _dataSource.addCustomer(customer);
      emit(const CustomerSaved());
      emit(CustomersLoaded(_currentCustomers));
    } catch (e) {
      emit(CustomersError(e.toString()));
      emit(CustomersLoaded(_currentCustomers));
    }
  }

  Future<void> updateCustomer(CustomerModel customer) async {
    try {
      await _dataSource.updateCustomer(customer);
    } catch (e) {
      emit(CustomersError(e.toString()));
      emit(CustomersLoaded(_currentCustomers));
    }
  }

  Future<void> deleteCustomer(String customerId) async {
    try {
      await _dataSource.deleteCustomer(customerId);
    } catch (e) {
      emit(CustomersError(e.toString()));
      emit(CustomersLoaded(_currentCustomers));
    }
  }

  Future<void> saveCustomerFromOrder({
    required String name,
    required String phone,
    required String address,
    required String orderId,
    required double orderTotal,
    required double deliveryFee,
    required int itemCount,
    required String status,
    required DateTime orderDate,
  }) async {
    try {
      final existingCustomer = await _dataSource.getCustomerByPhone(phone);
      final customer =
          existingCustomer ??
          CustomerModel(
            id: _generateCustomerId(),
            code: await _dataSource.generateCustomerCode(),
            name: name,
            phone: phone,
            address: address,
            createdAt: orderDate,
          );

      await _dataSource.saveCustomerFromOrder(
        customer: customer.copyWith(
          name: name,
          phone: phone,
          address: address,
          lastOrderAt: orderDate,
          lastOrderTotal: orderTotal,
        ),
        transaction: CustomerTransactionModel(
          orderId: orderId,
          orderTotal: orderTotal,
          deliveryFee: deliveryFee,
          itemCount: itemCount,
          status: status,
          createdAt: orderDate,
        ),
      );
    } catch (e) {
      emit(CustomersError(e.toString()));
    }
  }

  String _generateCustomerId() {
    return DateTime.now().microsecondsSinceEpoch.toString();
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
