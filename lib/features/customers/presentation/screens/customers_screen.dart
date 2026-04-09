import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:diamond_clean/core/constants/app_strings.dart';
import '../../cubit/customer_details_cubit.dart';
import '../../cubit/customers_cubit.dart';
import '../../cubit/customers_state.dart';
import '../../data/models/customer_model.dart';
import '../widgets/customer_list_item.dart';
import 'customer_details_screen.dart';
import '../widgets/customer_list_states.dart';
import '../widgets/customer_search_bar.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  late TextEditingController _searchController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    context.read<CustomersCubit>().listenToCustomers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openCustomerDetails(CustomerModel customer) {
    final dataSource = context.read<CustomersCubit>().dataSource;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) =>
              CustomerDetailsCubit(dataSource)..loadCustomerDetails(customer),
          child: CustomerDetailsScreen(customer: customer),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.customersTitle),
        elevation: 0,
      ),
      body: Column(
        children: [
          CustomerSearchBar(
            controller: _searchController,
            searchQuery: _searchQuery,
            onSearchChanged: (value) {
              setState(() => _searchQuery = value.toLowerCase());
            },
            onClear: () {
              _searchController.clear();
              setState(() => _searchQuery = '');
            },
          ),
          Expanded(
            child: BlocConsumer<CustomersCubit, CustomersState>(
              listener: (context, state) {
                if (state is CustomersError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
                if (state is CustomerSaved) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم حفظ العميل بنجاح'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              builder: (context, state) => switch (state) {
                CustomersInitial() || CustomersLoading() => const Center(
                  child: CircularProgressIndicator(),
                ),
                CustomersLoaded() => _buildCustomersList(
                  state.filterCustomers(_searchQuery),
                ),
                CustomersError(:final message) => CustomerListErrorState(
                  message: message,
                  onRetry: () =>
                      context.read<CustomersCubit>().listenToCustomers(),
                ),
                _ => const SizedBox.shrink(),
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomersList(List<CustomerModel> customers) {
    if (customers.isEmpty) {
      return const CustomerListEmptyState();
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: customers.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final customer = customers[index];
        return CustomerListItem(
          customer: customer,
          onTap: () => _openCustomerDetails(customer),
        );
      },
    );
  }
}
