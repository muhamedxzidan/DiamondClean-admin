import 'package:flutter/material.dart';

import 'package:diamond_clean/core/constants/app_strings.dart';

import '../../data/models/order_model.dart';

enum OrderFilterMode {
  all,
  pending,
  confirmed,
  completed,
  cancelled,
  outstanding,
}

class OrdersStatusFilter extends StatelessWidget {
  final OrderFilterMode selectedFilter;
  final ValueChanged<OrderFilterMode> onChanged;

  const OrdersStatusFilter({
    required this.selectedFilter,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: OrderFilterMode.values.expand((filter) {
          return [
            _buildChip(
              label: _filterLabel(filter),
              isSelected: selectedFilter == filter,
              onTap: () => onChanged(filter),
              isHighlighted: filter == OrderFilterMode.outstanding,
            ),
            const SizedBox(width: 8),
          ];
        }).toList(),
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    bool isHighlighted = false,
  }) {
    return ChoiceChip(
      avatar: isHighlighted && !isSelected
          ? Icon(Icons.warning_amber_rounded, size: 14, color: Colors.red[700])
          : null,
      label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      selected: isSelected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  String _filterLabel(OrderFilterMode filter) => switch (filter) {
    OrderFilterMode.all => AppStrings.statusAll,
    OrderFilterMode.pending => AppStrings.statusPending,
    OrderFilterMode.confirmed => AppStrings.statusConfirmed,
    OrderFilterMode.completed => AppStrings.statusCompleted,
    OrderFilterMode.cancelled => AppStrings.statusCancelled,
    OrderFilterMode.outstanding => AppStrings.outstandingOrders,
  };

  static bool matchesFilter(OrderModel order, OrderFilterMode filter) =>
      switch (filter) {
        OrderFilterMode.all => true,
        OrderFilterMode.pending => order.status == OrderStatus.pending,
        OrderFilterMode.confirmed => order.status == OrderStatus.confirmed,
        OrderFilterMode.completed => order.status == OrderStatus.completed,
        OrderFilterMode.cancelled => order.status == OrderStatus.cancelled,
        OrderFilterMode.outstanding => order.hasOutstandingBalance,
      };
}
