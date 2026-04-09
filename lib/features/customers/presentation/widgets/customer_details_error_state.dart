import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:diamond_clean/core/constants/app_strings.dart';
import '../../cubit/customer_details_cubit.dart';
import '../../data/models/customer_model.dart';

class CustomerDetailsErrorState extends StatelessWidget {
  final String message;
  final CustomerModel customer;

  const CustomerDetailsErrorState({
    super.key,
    required this.message,
    required this.customer,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context
                  .read<CustomerDetailsCubit>()
                  .loadCustomerDetails(customer),
              child: const Text(AppStrings.tryAgain),
            ),
          ],
        ),
      ),
    );
  }
}
