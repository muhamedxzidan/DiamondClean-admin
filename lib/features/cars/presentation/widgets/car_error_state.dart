import 'package:flutter/material.dart';

import 'package:diamond_clean/core/constants/app_strings.dart';

class CarErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const CarErrorState({
    required this.message,
    required this.onRetry,
    super.key,
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
          FilledButton(
            onPressed: onRetry,
            child: const Text(AppStrings.tryAgain),
          ),
        ],
      ),
    );
  }
}
