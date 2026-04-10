import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:diamond_clean/core/constants/app_strings.dart';
import 'package:diamond_clean/features/auth/cubit/auth_cubit.dart';
import 'package:diamond_clean/features/cars/cubit/car_cubit.dart';
import 'package:diamond_clean/features/cars/data/datasources/cars_remote_data_source_impl.dart';
import 'package:diamond_clean/features/cars/presentation/screens/cars_screen.dart';
import 'package:diamond_clean/features/cashbox/cubit/cashbox_cubit.dart';
import 'package:diamond_clean/features/cashbox/data/datasources/cashbox_remote_data_source_impl.dart';
import 'package:diamond_clean/features/cashbox/presentation/screens/cashbox_screen.dart';
import 'package:diamond_clean/features/categories/cubit/category_cubit.dart';
import 'package:diamond_clean/features/categories/data/datasources/categories_remote_data_source_impl.dart';
import 'package:diamond_clean/features/categories/presentation/screens/categories_screen.dart';
import 'package:diamond_clean/features/customers/cubit/customers_cubit.dart';
import 'package:diamond_clean/features/customers/data/datasources/customers_remote_data_source.dart';
import 'package:diamond_clean/features/customers/presentation/screens/customers_screen.dart';
import 'package:diamond_clean/features/home/presentation/widgets/developer_info_dialog.dart';
import 'package:diamond_clean/features/orders/cubit/orders_cubit.dart';
import 'package:diamond_clean/features/orders/data/datasources/orders_remote_data_source_impl.dart';
import 'package:diamond_clean/features/orders/presentation/screens/orders_screen.dart';

class DashboardShell extends StatefulWidget {
  const DashboardShell({super.key});

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  int _selectedIndex = 0;

  late final CustomersCubit _customersCubit;
  late final OrdersCubit _ordersCubit;
  late final CategoryCubit _categoryCubit;
  late final CarCubit _carCubit;
  late final CashboxCubit _cashboxCubit;

  static const _navItems = [
    _NavItem(icon: Icons.receipt_long_outlined, label: AppStrings.orders),
    _NavItem(icon: Icons.people_outlined, label: AppStrings.customers),
    _NavItem(icon: Icons.category_outlined, label: AppStrings.categories),
    _NavItem(icon: Icons.directions_car_outlined, label: AppStrings.cars),
    _NavItem(
      icon: Icons.account_balance_wallet_outlined,
      label: AppStrings.cashbox,
    ),
  ];

  @override
  void initState() {
    super.initState();
    final firestore = FirebaseFirestore.instance;
    _customersCubit = CustomersCubit(CustomersRemoteDataSourceImpl(firestore));
    _categoryCubit = CategoryCubit(CategoriesRemoteDataSourceImpl(firestore));
    _carCubit = CarCubit(CarsRemoteDataSourceImpl(firestore));
    _cashboxCubit = CashboxCubit(CashboxRemoteDataSourceImpl(firestore));
    _ordersCubit = OrdersCubit(
      OrdersRemoteDataSourceImpl(firestore),
      _customersCubit,
      cashboxDataSource: CashboxRemoteDataSourceImpl(firestore),
    );
  }

  @override
  void dispose() {
    _customersCubit.close();
    _ordersCubit.close();
    _categoryCubit.close();
    _carCubit.close();
    _cashboxCubit.close();
    super.dispose();
  }

  Widget _buildTabsContent() => IndexedStack(
    index: _selectedIndex,
    children: const [
      OrdersScreen(),
      CustomersScreen(),
      CategoriesScreen(),
      CarsScreen(),
      CashboxScreen(),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width > 600;

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _customersCubit),
        BlocProvider.value(value: _ordersCubit),
        BlocProvider.value(value: _categoryCubit),
        BlocProvider.value(value: _carCubit),
        BlocProvider.value(value: _cashboxCubit),
      ],
      child: isWideScreen
          ? _buildWideLayout(context)
          : _buildCompactLayout(context),
    );
  }

  Widget _buildWideLayout(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) =>
                setState(() => _selectedIndex = index),
            extended: MediaQuery.of(context).size.width > 800,
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'DC',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.person_outline),
                        tooltip: AppStrings.developerTitle,
                        onPressed: () => showDeveloperDialog(context),
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout),
                        tooltip: AppStrings.logout,
                        onPressed: () => context.read<AuthCubit>().logout(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            destinations: _navItems
                .map(
                  (item) => NavigationRailDestination(
                    icon: Icon(item.icon),
                    label: Text(item.label),
                  ),
                )
                .toList(),
          ),
          const VerticalDivider(width: 1),
          Expanded(child: _buildTabsContent()),
        ],
      ),
    );
  }

  Widget _buildCompactLayout(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diamond Clean'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: AppStrings.developerTitle,
            onPressed: () => showDeveloperDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: AppStrings.logout,
            onPressed: () => context.read<AuthCubit>().logout(),
          ),
        ],
      ),
      body: _buildTabsContent(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        items: _navItems
            .map(
              (item) => BottomNavigationBarItem(
                icon: Icon(item.icon),
                label: item.label,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
