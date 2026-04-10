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
  }) async {
    try {
      await _dataSource.updateStatus(id, status, paymentMethod: paymentMethod);
      if (status == OrderStatus.completed) {
        OrderModel? order;
        for (final currentOrder in _currentOrders) {
          if (currentOrder.id == id) {
            order = currentOrder;
            break;
          }
        }

        if (order != null) {
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
            debugPrint('Customer sync failed for completed order $id: $e');
          }

          if (order.includeInCashbox && _cashboxDataSource != null) {
            try {
              await _cashboxDataSource.recordOrderIncome(
                CashboxIncomeModel(
                  orderId: order.id,
                  orderTotal: order.totalPrice ?? 0,
                  deliveryFee: order.deliveryFee,
                  customerName: order.customerName,
                  customerPhone: order.customerPhone,
                  paymentMethod: paymentMethod ?? order.paymentMethod?.name,
                  includeInCashbox: order.includeInCashbox,
                  createdAt: order.createdAt,
                ),
              );
            } catch (e) {
              debugPrint('Cashbox sync failed for completed order $id: $e');
            }
          }
        }
      }
    } catch (e) {
      emit(OrdersError(e.toString()));
      emit(OrdersLoaded(_currentOrders));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
