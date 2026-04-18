import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:diamond_clean/features/customers/cubit/customers_cubit.dart';
import 'package:diamond_clean/features/customers/data/datasources/customers_remote_data_source.dart';
import 'package:diamond_clean/features/customers/data/models/customer_model.dart';
import 'package:diamond_clean/features/customers/data/models/customer_transaction_model.dart';
import 'package:diamond_clean/features/orders/cubit/orders_cubit.dart';
import 'package:diamond_clean/features/orders/data/datasources/orders_remote_data_source.dart';
import 'package:diamond_clean/features/orders/data/models/order_item_model.dart';
import 'package:diamond_clean/features/orders/data/models/order_model.dart';

class _FakeOrdersRemoteDataSource implements OrdersRemoteDataSource {
  _FakeOrdersRemoteDataSource(this._streams);

  final List<StreamController<List<OrderModel>>> _streams;
  var watchCalls = 0;

  StreamController<List<OrderModel>> get firstController => _streams.first;

  @override
  Stream<List<OrderModel>> watchOrders() {
    final controller = _streams[watchCalls++];
    return controller.stream;
  }

  @override
  Future<void> assignInvoiceNumber(String orderId) async {}

  @override
  Future<void> updateItemPricing(
    String orderId,
    int itemIndex,
    double width,
    double height,
    double unitPrice,
  ) async {}

  @override
  Future<void> updateOrderItems(
    String orderId,
    List<OrderItemModel> items, {
    required double deliveryFee,
  }) async {}

  @override
  Future<void> updateStatus(
    String id,
    OrderStatus status, {
    String? paymentMethod,
    double? paidAmount,
    bool? isFullyPaid,
  }) async {}

  @override
  Future<void> recordRemainingPayment(
    String orderId, {
    required double paidAmount,
    required String paymentMethod,
  }) async {}
}

class _FakeCustomersRemoteDataSource implements CustomersRemoteDataSource {
  @override
  Stream<List<CustomerModel>> watchCustomers() =>
      const Stream<List<CustomerModel>>.empty();

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
    'listenToOrders cancels the previous subscription before relistening',
    () async {
      var firstCancelled = 0;
      var secondCancelled = 0;

      final source = _FakeOrdersRemoteDataSource([
        StreamController<List<OrderModel>>(
          onCancel: () {
            firstCancelled++;
          },
        ),
        StreamController<List<OrderModel>>(
          onCancel: () {
            secondCancelled++;
          },
        ),
      ]);
      final customersCubit = CustomersCubit(_FakeCustomersRemoteDataSource());
      final cubit = OrdersCubit(source, customersCubit);

      await cubit.listenToOrders();
      expect(source.firstController.hasListener, isTrue);

      await cubit.listenToOrders();

      expect(firstCancelled, 1);
      expect(source.firstController.hasListener, isFalse);
      expect(secondCancelled, 0);

      await cubit.close();
      await customersCubit.close();
      expect(secondCancelled, 1);

      for (final controller in source._streams) {
        await controller.close();
      }
    },
  );
}
