import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:diamond_clean/core/constants/app_strings.dart';
import 'package:diamond_clean/core/utils/whatsapp_invoice_service.dart';
import '../../core/orders_grouping.dart';
import '../../cubit/orders_cubit.dart';
import '../../cubit/orders_state.dart';
import '../../data/models/order_model.dart';
import '../widgets/completion_payment_dialog.dart';
import '../widgets/order_pricing_dialog.dart';
import '../widgets/orders_day_group.dart';
import '../widgets/orders_error_view.dart';
import '../widgets/orders_search_bar.dart';
import '../widgets/orders_status_filter.dart';
import '../widgets/remaining_payment_dialog.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late final TextEditingController _searchController;
  late Set<DateTime> expandedDays;
  String _searchQuery = '';
  OrderFilterMode _selectedFilter = OrderFilterMode.all;

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
        child: OrderPricingDialog(
          order: order,
          hasDimensions: order.hasDimensions,
        ),
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

  Future<void> _handleStatusChange(OrderModel order, OrderStatus status) async {
    if (status == OrderStatus.completed) {
      final totalPrice = order.totalPrice;
      if (totalPrice == null || totalPrice <= 0) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(AppStrings.notPricedYet),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final result = await showCompletionPaymentDialog(
        context,
        totalPrice: totalPrice,
      );
      if (result == null || !mounted) return;

      await context.read<OrdersCubit>().updateStatus(
        order.id,
        status,
        paymentMethod: result.paymentMethod.name,
        paidAmount: result.paidAmount,
        isFullyPaid: result.isFullPayment,
      );
      return;
    }

    await context.read<OrdersCubit>().updateStatus(order.id, status);
  }

  Future<void> _handlePayRemaining(OrderModel order) async {
    final result = await showRemainingPaymentDialog(
      context,
      remainingAmount: order.remainingAmount,
    );
    if (result == null || !mounted) return;

    await context.read<OrdersCubit>().recordRemainingPayment(
      order.id,
      amount: result.amount,
      paymentMethod: result.paymentMethod.name,
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
          OrdersStatusFilter(
            selectedFilter: _selectedFilter,
            onChanged: (filter) {
              setState(() => _selectedFilter = filter);
            },
          ),
          const SizedBox(height: 8),
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
          _hasActiveFilters
              ? AppStrings.noMatchingOrders
              : AppStrings.noOrdersFound,
        ),
      );
    }

    return _buildGroupedOrders(filteredOrders);
  }

  List<OrderModel> _filterOrders(List<OrderModel> orders) {
    return orders.where((order) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          _matches(order.customerCode) ||
          _matches(order.customerPhone);
      final matchesFilter =
          OrdersStatusFilter.matchesFilter(order, _selectedFilter);
      return matchesSearch && matchesFilter;
    }).toList();
  }

  bool get _hasActiveFilters =>
      _searchQuery.isNotEmpty || _selectedFilter != OrderFilterMode.all;

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
          onStatusChanged: _handleStatusChange,
          onPayRemaining: _handlePayRemaining,
          showSpacing: dayIndex < days.length - 1,
        );
      },
    );
  }
}
