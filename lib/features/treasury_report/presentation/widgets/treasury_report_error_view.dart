import 'package:flutter/material.dart';

import 'package:diamond_clean/core/constants/app_strings.dart';

class TreasuryReportErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const TreasuryReportErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text('خطأ: $message'),
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
