import 'package:diamond_clean/features/customers/cubit/customer_details_cubit.dart';
import 'package:diamond_clean/features/customers/data/datasources/customers_remote_data_source.dart';
import 'package:diamond_clean/features/customers/data/models/customer_model.dart';
import 'package:diamond_clean/features/customers/data/models/customer_transaction_model.dart';
import 'package:diamond_clean/features/customers/presentation/screens/customer_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeCustomersRemoteDataSource implements CustomersRemoteDataSource {
  final CustomerModel customer;
  final List<CustomerTransactionModel> transactions;

  _FakeCustomersRemoteDataSource({
    required this.customer,
    required this.transactions,
  });

  @override
  Future<void> addCustomer(CustomerModel customer) =>
      throw UnimplementedError();

  @override
  Future<void> deleteCustomer(String customerId) => throw UnimplementedError();

  @override
  Future<String> generateCustomerCode() => throw UnimplementedError();

  @override
  Future<CustomerModel?> getCustomerById(String customerId) async => customer;

  @override
  Future<CustomerModel?> getCustomerByPhone(String phone) =>
      throw UnimplementedError();

  @override
  Future<List<CustomerTransactionModel>> getCustomerTransactions(
    String customerId,
  ) async => transactions;

  @override
  Future<void> saveCustomerFromOrder({
    required CustomerModel customer,
    required CustomerTransactionModel transaction,
  }) => throw UnimplementedError();

  @override
  Stream<List<CustomerModel>> watchCustomers() => const Stream.empty();

  @override
  Future<void> updateCustomer(CustomerModel customer) =>
      throw UnimplementedError();
}

void main() {
  testWidgets('customer details show loaded transactions', (tester) async {
    final customer = CustomerModel(
      id: 'customer-1',
      code: 'CPC-1',
      name: 'أحمد علي',
      phone: '01000000000',
      address: 'القاهرة',
      orderCount: 2,
      totalSpent: 450,
      lastOrderTotal: 250,
      lastOrderAt: DateTime(2026, 4, 9),
      createdAt: DateTime(2026, 4, 1),
    );

    final transactions = [
      CustomerTransactionModel(
        orderId: 'order-2',
        orderTotal: 250,
        deliveryFee: 20,
        itemCount: 3,
        status: 'completed',
        createdAt: DateTime(2026, 4, 9),
      ),
      CustomerTransactionModel(
        orderId: 'order-1',
        orderTotal: 200,
        deliveryFee: 15,
        itemCount: 2,
        status: 'confirmed',
        createdAt: DateTime(2026, 4, 1),
      ),
    ];

    final cubit = CustomerDetailsCubit(
      _FakeCustomersRemoteDataSource(
        customer: customer,
        transactions: transactions,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: cubit..loadCustomerDetails(customer),
          child: CustomerDetailsScreen(customer: customer),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('أحمد علي'), findsNWidgets(2));
    expect(find.text('CPC-1'), findsNWidgets(2));
    expect(find.text('01000000000'), findsNWidgets(2));
    expect(find.text('450.00 ج.م'), findsOneWidget);
  });

  testWidgets('customer list item responds to tap', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Card(
            child: InkWell(
              onTap: () => tapped = true,
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Text('أحمد علي'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('أحمد علي'));
    await tester.pump();

    expect(tapped, isTrue);
  });
}
