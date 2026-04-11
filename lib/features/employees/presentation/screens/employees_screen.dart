import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:diamond_clean/core/constants/app_strings.dart';
import 'package:diamond_clean/core/utils/cashbox_feature_access_guard.dart';
import 'package:diamond_clean/features/cashbox/data/datasources/cashbox_remote_data_source.dart';
import 'package:diamond_clean/features/cashbox/data/datasources/cashbox_remote_data_source_impl.dart';
import 'package:diamond_clean/features/employees/cubit/employee_details_cubit.dart';
import 'package:diamond_clean/features/employees/cubit/employees_cubit.dart';
import 'package:diamond_clean/features/employees/cubit/employees_state.dart';
import 'package:diamond_clean/features/employees/data/models/employee_model.dart';
import 'package:diamond_clean/features/employees/data/models/salary_cycle.dart';
import 'package:diamond_clean/features/treasury_report/presentation/screens/treasury_report_screen.dart';

import 'employee_details_screen.dart';

class EmployeesScreen extends StatefulWidget {
  const EmployeesScreen({super.key});

  @override
  State<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
  late final TextEditingController _searchController;
  late final CashboxRemoteDataSource _cashboxDataSource;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _cashboxDataSource = CashboxRemoteDataSourceImpl(
      FirebaseFirestore.instance,
    );
    context.read<EmployeesCubit>().listenToEmployees();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openEmployeeDetails(EmployeeModel employee) {
    final dataSource = context.read<EmployeesCubit>().dataSource;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<EmployeesCubit>()),
            BlocProvider(
              create: (_) =>
                  EmployeeDetailsCubit(dataSource, employee)..listen(),
            ),
          ],
          child: EmployeeDetailsScreen(employee: employee),
        ),
      ),
    );
  }

  Future<void> _showAddEmployeeDialog() async {
    final employeesCubit = context.read<EmployeesCubit>();
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final nationalIdController = TextEditingController();
    final cityController = TextEditingController();
    final salaryController = TextEditingController();
    SalaryCycle selectedCycle = SalaryCycle.monthly;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: const Text(AppStrings.employeesAddEmployee),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: AppStrings.employeesName,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return AppStrings.fieldRequired;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: phoneController,
                        decoration: const InputDecoration(
                          labelText: AppStrings.customerPhone,
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return AppStrings.fieldRequired;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: nationalIdController,
                        decoration: const InputDecoration(
                          labelText: AppStrings.employeesNationalId,
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: cityController,
                        decoration: const InputDecoration(
                          labelText: AppStrings.employeesCity,
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<SalaryCycle>(
                        initialValue: selectedCycle,
                        decoration: const InputDecoration(
                          labelText: AppStrings.employeesSalaryCycle,
                        ),
                        items: SalaryCycle.values.map((cycle) {
                          return DropdownMenuItem<SalaryCycle>(
                            value: cycle,
                            child: Text(cycle.arabicLabel),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setModalState(() => selectedCycle = value);
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: salaryController,
                        decoration: const InputDecoration(
                          labelText: AppStrings.employeesSalaryAmount,
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (value) {
                          final amount = double.tryParse(value ?? '');
                          if (amount == null || amount <= 0) {
                            return AppStrings.employeesSalaryValidation;
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text(AppStrings.cancel),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    await employeesCubit.addEmployee(
                      name: nameController.text.trim(),
                      phone: phoneController.text.trim(),
                      nationalId: nationalIdController.text.trim().isEmpty
                          ? null
                          : nationalIdController.text.trim(),
                      city: cityController.text.trim().isEmpty
                          ? null
                          : cityController.text.trim(),
                      salaryCycle: selectedCycle,
                      salaryAmount: double.parse(salaryController.text.trim()),
                    );
                    if (dialogContext.mounted) {
                      Navigator.of(dialogContext).pop();
                    }
                  },
                  child: const Text(AppStrings.save),
                ),
              ],
            );
          },
        );
      },
    );

    nameController.dispose();
    phoneController.dispose();
    nationalIdController.dispose();
    cityController.dispose();
    salaryController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.employeesTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.assessment_outlined),
            tooltip: 'تقرير الخزنة',
            onPressed: () async {
              final ownerPin = await _cashboxDataSource.getOwnerPin();
              if (!mounted) {
                return;
              }
              final granted = await requestCashboxFeatureAccess(
                context,
                ownerPin: ownerPin,
              );
              if (!granted || !mounted) {
                return;
              }
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TreasuryReportScreen()),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEmployeeDialog,
        child: const Icon(Icons.person_add_alt_1),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: AppStrings.employeesSearchHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                        icon: const Icon(Icons.clear),
                      ),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          Expanded(
            child: BlocConsumer<EmployeesCubit, EmployeesState>(
              listener: (context, state) {
                if (state is EmployeesError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
                if (state is EmployeeSaved) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(AppStrings.employeesSaved),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is EmployeesLoading || state is EmployeesInitial) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is EmployeesLoaded) {
                  final filtered = state.filterEmployees(_searchQuery);
                  if (filtered.isEmpty) {
                    return const Center(child: Text(AppStrings.employeesEmpty));
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final employee = filtered[index];
                      return ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        tileColor: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest
                            .withValues(alpha: 0.4),
                        leading: const CircleAvatar(
                          child: Icon(Icons.badge_outlined),
                        ),
                        title: Text(employee.name),
                        subtitle: Text(
                          '${employee.salaryCycle.arabicLabel} - '
                          '${employee.salaryAmount.toStringAsFixed(2)} ${AppStrings.currency}',
                        ),
                        trailing: Text(
                          '${AppStrings.employeesRemaining}: '
                          '${employee.remainingSalary.toStringAsFixed(2)} ${AppStrings.currency}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        onTap: () => _openEmployeeDetails(employee),
                      );
                    },
                  );
                }

                if (state is EmployeesError) {
                  return Center(child: Text(state.message));
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
