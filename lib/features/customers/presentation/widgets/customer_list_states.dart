import 'package:flutter/material.dart';

import 'package:diamond_clean/core/constants/app_strings.dart';

class CustomerListEmptyState extends StatelessWidget {
  const CustomerListEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          const Text(AppStrings.customersEmptyState),
        ],
      ),
    );
  }
}

class CustomerListErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const CustomerListErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 8),
          Text(message),
          const SizedBox(height: 16),
          FilledButton(onPressed: onRetry, child: const Text('حاول مجدداً')),
        ],
      ),
    );
  }
}
