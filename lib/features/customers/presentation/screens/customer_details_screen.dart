import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:diamond_clean/core/constants/app_strings.dart';
import '../../cubit/customer_details_cubit.dart';
import '../../cubit/customer_details_state.dart';
import '../../data/models/customer_model.dart';
import '../widgets/customer_details_content.dart';
import '../widgets/customer_details_error_state.dart';

class CustomerDetailsScreen extends StatelessWidget {
  final CustomerModel customer;

  const CustomerDetailsScreen({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          customer.name.isNotEmpty ? customer.name : AppStrings.customersTitle,
        ),
      ),
      body: BlocConsumer<CustomerDetailsCubit, CustomerDetailsState>(
        listener: (context, state) {
          if (state is CustomerDetailsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) => switch (state) {
          CustomerDetailsInitial() || CustomerDetailsLoading() => const Center(
            child: CircularProgressIndicator(),
          ),
          CustomerDetailsLoaded(:final customer, :final transactions) =>
            CustomerDetailsContent(
              customer: customer,
              transactions: transactions,
            ),
          CustomerDetailsError(:final message) => CustomerDetailsErrorState(
            message: message,
            customer: customer,
          ),
        },
      ),
    );
  }
}
