import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:diamond_clean/core/constants/app_strings.dart';
import 'package:diamond_clean/features/categories/cubit/category_cubit.dart';
import 'package:diamond_clean/features/categories/data/datasources/categories_remote_data_source.dart';
import 'package:diamond_clean/features/categories/data/models/category_model.dart';
import 'package:diamond_clean/features/customers/cubit/customers_cubit.dart';
import 'package:diamond_clean/features/customers/data/datasources/customers_remote_data_source.dart';
import 'package:diamond_clean/features/customers/data/models/customer_model.dart';
import 'package:diamond_clean/features/customers/data/models/customer_transaction_model.dart';
import 'package:diamond_clean/features/orders/cubit/orders_cubit.dart';
import 'package:diamond_clean/features/orders/data/datasources/orders_remote_data_source.dart';
import 'package:diamond_clean/features/orders/data/models/order_item_model.dart';
import 'package:diamond_clean/features/orders/data/models/order_model.dart';
import 'package:diamond_clean/features/orders/presentation/screens/orders_screen.dart';

class _FakeOrdersRemoteDataSource implements OrdersRemoteDataSource {
  _FakeOrdersRemoteDataSource(this._orders);

  final List<OrderModel> _orders;

  @override
  Stream<List<OrderModel>> watchOrders() =>
      Stream<List<OrderModel>>.value(_orders);

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
      Stream<List<CustomerModel>>.value(const <CustomerModel>[]);

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

class _FakeCategoriesRemoteDataSource implements CategoriesRemoteDataSource {
  @override
  Future<List<CategoryModel>> getCategories() async => const <CategoryModel>[];

  @override
  Future<void> addCategory(String name, bool hasDimensions) async {}

  @override
  Future<void> updateCategory(
    String id,
    String name,
    bool hasDimensions,
  ) async {}

  @override
  Future<void> deleteCategory(String id) async {}
}

void main() {
  testWidgets('Orders screen renders the first loaded batch without crashing', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 2000));

    final now = DateTime.now();
    final order = OrderModel(
      id: 'order-1',
      customerCode: 'C-001',
      customerName: 'Test Customer',
      customerPhone: '01000000000',
      address: 'Test Address',
      categoryName: 'Wash',
      carNumber: '12',
      driverName: 'Driver',
      items: const [],
      status: OrderStatus.pending,
      createdAt: now,
    );

    final customersCubit = CustomersCubit(_FakeCustomersRemoteDataSource());
    final categoryCubit = CategoryCubit(_FakeCategoriesRemoteDataSource());
    final ordersCubit = OrdersCubit(
      _FakeOrdersRemoteDataSource([order]),
      customersCubit,
    );

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider.value(value: customersCubit),
          BlocProvider.value(value: categoryCubit),
          BlocProvider.value(value: ordersCubit),
        ],
        child: const MaterialApp(home: OrdersScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text(AppStrings.ordersTitle), findsOneWidget);
    expect(find.text(AppStrings.noItemsFound), findsOneWidget);

    await tester.binding.setSurfaceSize(null);
  });
}
