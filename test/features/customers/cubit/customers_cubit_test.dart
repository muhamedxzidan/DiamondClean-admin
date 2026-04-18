import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:diamond_clean/features/customers/cubit/customers_cubit.dart';
import 'package:diamond_clean/features/customers/data/datasources/customers_remote_data_source.dart';
import 'package:diamond_clean/features/customers/data/models/customer_model.dart';
import 'package:diamond_clean/features/customers/data/models/customer_transaction_model.dart';

class _FakeCustomersRemoteDataSource implements CustomersRemoteDataSource {
  _FakeCustomersRemoteDataSource(this._streams);

  final List<StreamController<List<CustomerModel>>> _streams;
  var watchCalls = 0;

  StreamController<List<CustomerModel>> get firstController => _streams.first;

  @override
  Stream<List<CustomerModel>> watchCustomers() {
    final controller = _streams[watchCalls++];
    return controller.stream;
  }

  @override
  Future<String> generateCustomerCode() async => 'CPC-1';

  @override
  Future<void> addCustomer(CustomerModel customer) async {}

  @override
  Future<void> updateCustomer(CustomerModel customer) async {}

  @override
  Future<void> deleteCustomer(String customerId) async {}

  @override
  Future<CustomerModel?> getCustomerById(String customerId) async => null;

  @override
  Future<CustomerModel?> getCustomerByPhone(String phone) async => null;

  @override
  Future<List<CustomerTransactionModel>> getCustomerTransactions(
    String customerId,
  ) async => const <CustomerTransactionModel>[];

  @override
  Future<void> saveCustomerFromOrder({
    required CustomerModel customer,
    required CustomerTransactionModel transaction,
  }) async {}
}

void main() {
  test(
    'listenToCustomers cancels the previous subscription before relistening',
    () async {
      var firstCancelled = 0;
      var secondCancelled = 0;

      final source = _FakeCustomersRemoteDataSource([
        StreamController<List<CustomerModel>>(
          onCancel: () {
            firstCancelled++;
          },
        ),
        StreamController<List<CustomerModel>>(
          onCancel: () {
            secondCancelled++;
          },
        ),
      ]);
      final cubit = CustomersCubit(source);

      await cubit.listenToCustomers();
      expect(source.firstController.hasListener, isTrue);

      await cubit.listenToCustomers();

      expect(firstCancelled, 1);
      expect(source.firstController.hasListener, isFalse);
      expect(secondCancelled, 0);

      await cubit.close();
      expect(secondCancelled, 1);

      for (final controller in source._streams) {
        await controller.close();
      }
    },
  );
}
