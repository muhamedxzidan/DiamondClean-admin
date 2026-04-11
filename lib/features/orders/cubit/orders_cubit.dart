import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';

import '../../cashbox/data/datasources/cashbox_remote_data_source.dart';
import '../../cashbox/data/models/cashbox_income_model.dart';
import '../../customers/cubit/customers_cubit.dart';
import '../data/datasources/orders_remote_data_source.dart';
import '../data/models/order_item_model.dart';
import '../data/models/order_model.dart';
import 'orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  final OrdersRemoteDataSource _dataSource;
  final CustomersCubit _customersCubit;
  final CashboxRemoteDataSource? _cashboxDataSource;
  StreamSubscription<List<OrderModel>>? _subscription;
  List<OrderModel> _currentOrders = [];
  final Set<String> _pendingInvoiceIds = {};

  OrdersCubit(
    this._dataSource,
    this._customersCubit, {
    CashboxRemoteDataSource? cashboxDataSource,
  }) : _cashboxDataSource = cashboxDataSource,
       super(const OrdersInitial());

  void listenToOrders() {
    emit(const OrdersLoading());
    _subscription = _dataSource.watchOrders().listen((orders) {
      _currentOrders = orders;
      emit(OrdersLoaded(orders));
      _assignMissingInvoiceNumbers(orders);
    }, onError: (Object e) => emit(OrdersError(e.toString())));
  }

  void _assignMissingInvoiceNumbers(List<OrderModel> orders) {
    for (final order in orders) {
      if (order.invoiceNumber == null && !_pendingInvoiceIds.contains(order.id)) {
        _pendingInvoiceIds.add(order.id);
        _dataSource.assignInvoiceNumber(order.id).catchError(
          (e) {
            _pendingInvoiceIds.remove(order.id);
            debugPrint('Invoice number assignment failed: $e');
          },
        );
      }
    }
  }

  Future<void> updateItemPricing(
    String orderId,
    int itemIndex,
    double width,
    double height,
    double unitPrice,
  ) async {
    try {
      await _dataSource.updateItemPricing(
        orderId,
        itemIndex,
        width,
        height,
        unitPrice,
      );
    } catch (e) {
      emit(OrdersError(e.toString()));
      emit(OrdersLoaded(_currentOrders));
    }
  }

  Future<void> updateOrderItems(
    String orderId,
    List<OrderItemModel> items, {
    required double deliveryFee,
    required double orderTotal,
    required int itemCount,
    required String orderStatus,
    required DateTime orderDate,
    String? customerName,
    String? customerPhone,
    String? customerAddress,
  }) async {
    try {
      await _dataSource.updateOrderItems(
        orderId,
        items,
        deliveryFee: deliveryFee,
      );
      if (customerName != null &&
          customerPhone != null &&
          customerAddress != null) {
        await _customersCubit.saveCustomerFromOrder(
          orderId: orderId,
          orderTotal: orderTotal,
          deliveryFee: deliveryFee,
          itemCount: itemCount,
          status: orderStatus,
          orderDate: orderDate,
          name: customerName,
          phone: customerPhone,
          address: customerAddress,
        );
      }
    } catch (e) {
      emit(OrdersError(e.toString()));
      emit(OrdersLoaded(_currentOrders));
    }
  }

  Future<void> updateStatus(
    String id,
    OrderStatus status, {
    String? paymentMethod,
    double? paidAmount,
    bool? isFullyPaid,
  }) async {
    try {
      await _dataSource.updateStatus(
        id,
        status,
        paymentMethod: paymentMethod,
        paidAmount: paidAmount,
        isFullyPaid: isFullyPaid,
      );
      if (status == OrderStatus.completed) {
        final order = _findOrder(id);
        if (order != null) {
          await _syncCustomer(order, status);
          await _recordIncome(
            order,
            paymentMethod: paymentMethod,
            paidAmount: paidAmount ?? order.totalPrice ?? 0,
          );
        }
      }
    } catch (e) {
      emit(OrdersError(e.toString()));
      emit(OrdersLoaded(_currentOrders));
    }
  }

  Future<void> recordRemainingPayment(
    String orderId, {
    required double amount,
    required String paymentMethod,
  }) async {
    try {
      await _dataSource.recordRemainingPayment(
        orderId,
        paidAmount: amount,
        paymentMethod: paymentMethod,
      );

      final order = _findOrder(orderId);
      if (order != null && order.includeInCashbox && _cashboxDataSource != null) {
        try {
          final total = order.totalPrice ?? 0;
          final newPaid = order.paidAmount + amount;
          final remaining = (total - newPaid).clamp(0, double.infinity).toDouble();

          await _cashboxDataSource.recordOrderIncome(
            CashboxIncomeModel(
              orderId: '${order.id}_remaining',
              orderTotal: amount,
              deliveryFee: 0,
              customerName: order.customerName,
              customerPhone: order.customerPhone,
              paymentMethod: paymentMethod,
              includeInCashbox: order.includeInCashbox,
              remainingAmount: remaining,
              createdAt: DateTime.now(),
            ),
          );
        } catch (e) {
          debugPrint('Cashbox sync failed for remaining payment $orderId: $e');
        }
      }
    } catch (e) {
      emit(OrdersError(e.toString()));
      emit(OrdersLoaded(_currentOrders));
    }
  }

  OrderModel? _findOrder(String id) {
    for (final order in _currentOrders) {
      if (order.id == id) return order;
    }
    return null;
  }

  Future<void> _syncCustomer(OrderModel order, OrderStatus status) async {
    try {
      await _customersCubit.saveCustomerFromOrder(
        orderId: order.id,
        orderTotal: order.totalPrice ?? 0,
        deliveryFee: order.deliveryFee,
        itemCount: order.items.fold<int>(
          0,
          (count, item) => count + item.quantity,
        ),
        status: status.name,
        orderDate: order.createdAt,
        name: order.customerName,
        phone: order.customerPhone,
        address: order.address,
      );
    } catch (e) {
      debugPrint('Customer sync failed for completed order ${order.id}: $e');
    }
  }

  Future<void> _recordIncome(
    OrderModel order, {
    required String? paymentMethod,
    required double paidAmount,
  }) async {
    if (!order.includeInCashbox || _cashboxDataSource == null) return;
    try {
      final total = order.totalPrice ?? 0;
      final remaining = (total - paidAmount).clamp(0, double.infinity).toDouble();
      
      await _cashboxDataSource.recordOrderIncome(
        CashboxIncomeModel(
          orderId: order.id,
          orderTotal: paidAmount,
          deliveryFee: order.deliveryFee,
          customerName: order.customerName,
          customerPhone: order.customerPhone,
          paymentMethod: paymentMethod ?? order.paymentMethod?.name,
          includeInCashbox: order.includeInCashbox,
          remainingAmount: remaining,
          createdAt: DateTime.now(),
        ),
      );
    } catch (e) {
      debugPrint('Cashbox sync failed for completed order ${order.id}: $e');
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
