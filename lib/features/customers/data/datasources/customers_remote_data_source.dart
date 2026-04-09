import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/customer_model.dart';
import '../models/customer_transaction_model.dart';

abstract class CustomersRemoteDataSource {
  Stream<List<CustomerModel>> watchCustomers();
  Future<String> generateCustomerCode();
  Future<void> addCustomer(CustomerModel customer);
  Future<void> updateCustomer(CustomerModel customer);
  Future<void> deleteCustomer(String customerId);
  Future<CustomerModel?> getCustomerById(String customerId);
  Future<CustomerModel?> getCustomerByPhone(String phone);
  Future<List<CustomerTransactionModel>> getCustomerTransactions(
    String customerId,
  );
  Future<void> saveCustomerFromOrder({
    required CustomerModel customer,
    required CustomerTransactionModel transaction,
  });
}

class CustomersRemoteDataSourceImpl implements CustomersRemoteDataSource {
  final FirebaseFirestore _firestore;

  CustomersRemoteDataSourceImpl(this._firestore);

  @override
  Stream<List<CustomerModel>> watchCustomers() {
    return _firestore
        .collection('customers')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => CustomerModel.fromFirestore(doc))
              .toList();
        });
  }

  @override
  Future<String> generateCustomerCode() async {
    try {
      final doc = await _firestore
          .collection('_metadata')
          .doc('customers')
          .get();
      final currentCount = (doc.data()?['count'] as int?) ?? 0;
      final newCount = currentCount + 1;

      await _firestore.collection('_metadata').doc('customers').set({
        'count': newCount,
      }, SetOptions(merge: true));

      return 'CPC-$newCount';
    } catch (e) {
      throw Exception('Failed to generate customer code: $e');
    }
  }

  @override
  Future<void> addCustomer(CustomerModel customer) async {
    try {
      await _firestore
          .collection('customers')
          .doc(customer.id)
          .set(customer.toFirestore());
    } catch (e) {
      throw Exception('Failed to add customer: $e');
    }
  }

  @override
  Future<void> updateCustomer(CustomerModel customer) async {
    try {
      await _firestore
          .collection('customers')
          .doc(customer.id)
          .update(customer.toFirestore());
    } catch (e) {
      throw Exception('Failed to update customer: $e');
    }
  }

  @override
  Future<void> deleteCustomer(String customerId) async {
    try {
      await _firestore.collection('customers').doc(customerId).delete();
    } catch (e) {
      throw Exception('Failed to delete customer: $e');
    }
  }

  @override
  Future<CustomerModel?> getCustomerById(String customerId) async {
    try {
      final doc = await _firestore
          .collection('customers')
          .doc(customerId)
          .get();
      if (!doc.exists) return null;
      return CustomerModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to get customer by id: $e');
    }
  }

  @override
  Future<CustomerModel?> getCustomerByPhone(String phone) async {
    try {
      final query = await _firestore
          .collection('customers')
          .where('phone', isEqualTo: phone)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return null;
      return CustomerModel.fromFirestore(query.docs.first);
    } catch (e) {
      throw Exception('Failed to get customer: $e');
    }
  }

  @override
  Future<List<CustomerTransactionModel>> getCustomerTransactions(
    String customerId,
  ) async {
    try {
      final query = await _firestore
          .collection('customers')
          .doc(customerId)
          .collection('transactions')
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs
          .map((doc) => CustomerTransactionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get customer transactions: $e');
    }
  }

  @override
  Future<void> saveCustomerFromOrder({
    required CustomerModel customer,
    required CustomerTransactionModel transaction,
  }) async {
    try {
      final customerRef = _firestore.collection('customers').doc(customer.id);
      final transactionRef = customerRef
          .collection('transactions')
          .doc(transaction.orderId);

      await _firestore.runTransaction((transactionBatch) async {
        final snapshot = await transactionBatch.get(customerRef);
        final transactionSnapshot = await transactionBatch.get(transactionRef);

        late final CustomerModel updatedCustomer;
        if (!snapshot.exists) {
          updatedCustomer = customer.copyWith(
            orderCount: 1,
            totalSpent: transaction.orderTotal,
            lastOrderTotal: transaction.orderTotal,
            lastOrderAt: transaction.createdAt,
          );
        } else {
          final existingCustomer = CustomerModel.fromFirestore(snapshot);
          final previousTransaction = transactionSnapshot.exists
              ? CustomerTransactionModel.fromFirestore(transactionSnapshot)
              : null;
          final orderCount = previousTransaction == null
              ? existingCustomer.orderCount + 1
              : existingCustomer.orderCount;
          final totalSpent = previousTransaction == null
              ? existingCustomer.totalSpent + transaction.orderTotal
              : existingCustomer.totalSpent -
                    previousTransaction.orderTotal +
                    transaction.orderTotal;

          updatedCustomer = existingCustomer.copyWith(
            code: customer.code,
            name: customer.name,
            phone: customer.phone,
            address: customer.address,
            orderCount: orderCount,
            totalSpent: totalSpent,
            lastOrderTotal: transaction.orderTotal,
            lastOrderAt: transaction.createdAt,
          );
        }

        transactionBatch.set(
          customerRef,
          updatedCustomer.toFirestore(),
          SetOptions(merge: true),
        );
        transactionBatch.set(
          transactionRef,
          transaction.toFirestore(),
          SetOptions(merge: true),
        );
      });
    } catch (e) {
      throw Exception('Failed to save customer history: $e');
    }
  }
}
