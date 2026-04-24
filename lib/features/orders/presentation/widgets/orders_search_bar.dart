import 'package:flutter/material.dart';

import 'package:diamond_clean/core/constants/app_strings.dart';

class OrdersSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;

  const OrdersSearchBar({
    required this.controller,
    required this.onSubmitted,
    required this.onClear,
    super.key,
  });

  @override
  State<OrdersSearchBar> createState() => _OrdersSearchBarState();
}

class _OrdersSearchBarState extends State<OrdersSearchBar> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  void _submit() => widget.onSubmitted(widget.controller.text);

  void _clear() {
    widget.controller.clear();
    widget.onClear();
  }

  @override
  Widget build(BuildContext context) {
    final hasText = widget.controller.text.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: widget.controller,
        textInputAction: TextInputAction.search,
        onSubmitted: (_) => _submit(),
        decoration: InputDecoration(
          hintText: AppStrings.ordersSearchHint,
          prefixIcon: IconButton(
            icon: const Icon(Icons.search),
            tooltip: AppStrings.ordersSearchHint,
            onPressed: _submit,
          ),
          suffixIcon: hasText
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _clear,
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }
}
