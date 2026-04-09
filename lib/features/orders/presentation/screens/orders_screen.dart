import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:diamond_clean/core/constants/app_strings.dart';
import 'package:diamond_clean/core/utils/whatsapp_invoice_service.dart';
import '../../core/orders_grouping.dart';
import '../../cubit/orders_cubit.dart';
import '../../cubit/orders_state.dart';
import '../../data/models/order_model.dart';
import '../widgets/order_pricing_dialog.dart';
import '../widgets/orders_day_group.dart';
import '../widgets/orders_error_view.dart';
import '../widgets/orders_search_bar.dart';
import '../widgets/payment_method_dialog.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late final TextEditingController _searchController;
  late Set<DateTime> expandedDays;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    expandedDays = {};
    context.read<OrdersCubit>().listenToOrders();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _initializeexpandedDays(List<OrderModel> orders) {
    if (expandedDays.isEmpty) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      expandedDays.add(today);
    }
  }

  void _toggleDayExpansion(DateTime day) {
    setState(() {
      if (expandedDays.contains(day)) {
        expandedDays.remove(day);
      } else {
        expandedDays.add(day);
      }
    });
  }

  void _showPricingDialog(OrderModel order) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<OrdersCubit>(),
        child: OrderPricingDialog(order: order),
      ),
    );
  }

  Future<void> _sendInvoice(OrderModel order) async {
    try {
      await WhatsappInvoiceService.sendInvoice(order);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'تعذّر إرسال الفاتورة، تأكد من تثبيت واتساب ومن صحة رقم العميل',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<OrderPaymentMethod?> _showPaymentMethodDialog() async {
    return showDialog<OrderPaymentMethod>(
      context: context,
      builder: (_) => const PaymentMethodDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.ordersTitle)),
      body: Column(
        children: [
          OrdersSearchBar(
            controller: _searchController,
            onChanged: (value) {
              setState(() => _searchQuery = value.trim().toLowerCase());
            },
            searchQuery: _searchQuery,
          ),
          Expanded(
            child: BlocConsumer<OrdersCubit, OrdersState>(
              listener: (context, state) {
                if (state is OrdersError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (context, state) => switch (state) {
                OrdersInitial() || OrdersLoading() => const Center(
                  child: CircularProgressIndicator(),
                ),
                OrdersLoaded(:final orders) => _buildOrdersResult(orders),
                OrdersError(:final message) => OrdersErrorView(
                  message: message,
                  onRetry: () => context.read<OrdersCubit>().listenToOrders(),
                ),
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersResult(List<OrderModel> orders) {
    final filteredOrders = _filterOrders(orders);

    if (filteredOrders.isEmpty) {
      return Center(
        child: Text(
          _searchQuery.isEmpty
              ? AppStrings.noOrdersFound
              : AppStrings.noMatchingOrders,
        ),
      );
    }

    return _buildGroupedOrders(filteredOrders);
  }

  List<OrderModel> _filterOrders(List<OrderModel> orders) {
    if (_searchQuery.isEmpty) return orders;

    return orders.where((order) {
      return _matches(order.customerCode) || _matches(order.customerPhone);
    }).toList();
  }

  bool _matches(String value) => value.toLowerCase().contains(_searchQuery);

  Widget _buildGroupedOrders(List<OrderModel> orders) {
    _initializeexpandedDays(orders);
    final grouped = OrdersGrouping.groupOrdersByDay(orders);
    final days = grouped.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: days.length,
      itemBuilder: (_, dayIndex) {
        final day = days[dayIndex];
        final dayOrders = grouped[day]!;
        final isExpanded = expandedDays.contains(day);

        return OrdersDayGroup(
          day: day,
          orders: dayOrders,
          isExpanded: isExpanded,
          onToggleExpansion: () => _toggleDayExpansion(day),
          onOpenPricing: _showPricingDialog,
          onSendInvoice: _sendInvoice,
          onStatusChanged: (order, status) async {
            if (status == OrderStatus.completed) {
              final paymentMethod = await _showPaymentMethodDialog();
              if (paymentMethod == null) return;
              // ignore: use_build_context_synchronously
              await context.read<OrdersCubit>().updateStatus(
                order.id,
                status,
                paymentMethod: paymentMethod.name,
              );
              return;
            }

            await context.read<OrdersCubit>().updateStatus(order.id, status);
          },
          showSpacing: dayIndex < days.length - 1,
        );
      },
    );
  }
}
