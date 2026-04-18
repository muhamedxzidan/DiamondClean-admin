import 'package:flutter/material.dart';

import 'package:diamond_clean/core/constants/app_strings.dart';

import '../../core/orders_grouping.dart';
import '../../data/models/order_model.dart';
import '../widgets/orders_day_group.dart';
import '../widgets/orders_status_filter.dart';

class OrdersLoadedContent extends StatefulWidget {
  final List<OrderModel> orders;
  final String searchQuery;
  final OrderFilterMode selectedFilter;
  final void Function(OrderModel order) onOpenPricing;
  final Future<void> Function(OrderModel order) onSendInvoice;
  final Future<void> Function(OrderModel order, OrderStatus status)
  onStatusChanged;
  final Future<void> Function(OrderModel order) onPayRemaining;

  const OrdersLoadedContent({
    super.key,
    required this.orders,
    required this.searchQuery,
    required this.selectedFilter,
    required this.onOpenPricing,
    required this.onSendInvoice,
    required this.onStatusChanged,
    required this.onPayRemaining,
  });

  @override
  State<OrdersLoadedContent> createState() => _OrdersLoadedContentState();
}

class _OrdersLoadedContentState extends State<OrdersLoadedContent> {
  late Set<DateTime> expandedDays;

  @override
  void initState() {
    super.initState();
    expandedDays = {};
    _initializeExpandedDays();
  }

  @override
  void didUpdateWidget(covariant OrdersLoadedContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.orders != widget.orders) {
      _initializeExpandedDays();
    }
  }

  void _initializeExpandedDays() {
    if (expandedDays.isNotEmpty) {
      return;
    }

    final now = DateTime.now();
    expandedDays = {DateTime(now.year, now.month, now.day)};
  }

  List<OrderModel> _filterOrders() {
    return widget.orders.where((order) {
      final matchesSearch =
          widget.searchQuery.isEmpty ||
          _matches(order.customerCode) ||
          _matches(order.customerPhone);
      final matchesFilter = OrdersStatusFilter.matchesFilter(
        order,
        widget.selectedFilter,
      );
      return matchesSearch && matchesFilter;
    }).toList();
  }

  bool _matches(String value) =>
      value.toLowerCase().contains(widget.searchQuery);

  bool get _hasActiveFilters =>
      widget.searchQuery.isNotEmpty ||
      widget.selectedFilter != OrderFilterMode.all;

  void _toggleDayExpansion(DateTime day) {
    setState(() {
      if (expandedDays.contains(day)) {
        expandedDays.remove(day);
      } else {
        expandedDays.add(day);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredOrders = _filterOrders();

    if (filteredOrders.isEmpty) {
      return Center(
        child: Text(
          _hasActiveFilters
              ? AppStrings.noMatchingOrders
              : AppStrings.noOrdersFound,
        ),
      );
    }

    final grouped = OrdersGrouping.groupOrdersByDay(filteredOrders);
    final days = grouped.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: days.length,
      itemBuilder: (_, dayIndex) {
        final day = days[dayIndex];
        final dayOrders = grouped[day]!;
        final isExpanded = expandedDays.contains(day);

        return RepaintBoundary(
          child: OrdersDayGroup(
            day: day,
            orders: dayOrders,
            isExpanded: isExpanded,
            onToggleExpansion: () => _toggleDayExpansion(day),
            onOpenPricing: widget.onOpenPricing,
            onSendInvoice: widget.onSendInvoice,
            onStatusChanged: widget.onStatusChanged,
            onPayRemaining: widget.onPayRemaining,
            showSpacing: dayIndex < days.length - 1,
          ),
        );
      },
    );
  }
}
