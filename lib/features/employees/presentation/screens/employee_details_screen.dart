import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:diamond_clean/core/constants/app_strings.dart';
import 'package:diamond_clean/core/utils/date_formatter.dart';
import 'package:diamond_clean/features/employees/cubit/employee_details_cubit.dart';
import 'package:diamond_clean/features/employees/cubit/employee_details_state.dart';
import 'package:diamond_clean/features/employees/cubit/employees_cubit.dart';
import 'package:diamond_clean/features/employees/cubit/employees_state.dart';
import 'package:diamond_clean/features/employees/data/models/employee_model.dart';
import 'package:diamond_clean/features/employees/data/models/salary_cycle.dart';

class EmployeeDetailsScreen extends StatelessWidget {
  final EmployeeModel employee;

  const EmployeeDetailsScreen({super.key, required this.employee});

  Future<void> _showAddAdvanceDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    final amountController = TextEditingController();
    final noteController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(AppStrings.employeesAddAdvance),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: AppStrings.employeesAdvanceAmount,
                    ),
                    validator: (value) {
                      final amount = double.tryParse(value ?? '');
                      if (amount == null || amount <= 0) {
                        return AppStrings.employeesAdvanceValidation;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: noteController,
                    decoration: const InputDecoration(
                      labelText: AppStrings.employeesAdvanceNote,
                    ),
                    maxLines: 2,
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
                await context.read<EmployeesCubit>().addAdvance(
                  employeeId: employee.id,
                  amount: double.parse(amountController.text.trim()),
                  note: noteController.text.trim(),
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

    amountController.dispose();
    noteController.dispose();
  }

  Future<void> _showSalaryPayoutDialog(
    BuildContext context,
    EmployeeModel loadedEmployee,
  ) async {
    final employeesCubit = context.read<EmployeesCubit>();
    final formKey = GlobalKey<FormState>();
    final amountController = TextEditingController(
      text: loadedEmployee.remainingSalary.toStringAsFixed(2),
    );
    final noteController = TextEditingController();
    var isFullPayout = true;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: const Text(AppStrings.employeesPaySalary),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '${AppStrings.employeesSalaryOutstanding}: '
                          '${loadedEmployee.remainingSalary.toStringAsFixed(2)} ${AppStrings.currency}',
                        ),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(AppStrings.employeesPayoutMode),
                      ),
                      RadioListTile<bool>(
                        title: const Text(AppStrings.employeesPayoutFull),
                        value: true,
                        // ignore: deprecated_member_use
                        groupValue: isFullPayout,
                        // ignore: deprecated_member_use
                        onChanged: (value) {
                          if (value == null) return;
                          setModalState(() {
                            isFullPayout = value;
                            amountController.text = loadedEmployee
                                .remainingSalary
                                .toStringAsFixed(2);
                          });
                        },
                      ),
                      RadioListTile<bool>(
                        title: const Text(AppStrings.employeesPayoutPartial),
                        value: false,
                        // ignore: deprecated_member_use
                        groupValue: isFullPayout,
                        // ignore: deprecated_member_use
                        onChanged: (value) {
                          if (value == null) return;
                          setModalState(() {
                            isFullPayout = value;
                            amountController.clear();
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: amountController,
                        enabled: !isFullPayout,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: AppStrings.employeesPayoutAmount,
                        ),
                        validator: (value) {
                          final amount = double.tryParse(value ?? '');
                          if (amount == null || amount <= 0) {
                            return AppStrings.employeesPayoutAmountValidation;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: noteController,
                        decoration: const InputDecoration(
                          labelText: AppStrings.employeesPayoutNote,
                        ),
                        maxLines: 2,
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
                    final amount = isFullPayout
                        ? loadedEmployee.remainingSalary
                        : double.parse(amountController.text.trim());
                    await employeesCubit.payEmployeeSalary(
                      employeeId: loadedEmployee.id,
                      amount: amount,
                      note: noteController.text.trim(),
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

    amountController.dispose();
    noteController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EmployeesCubit, EmployeesState>(
      listener: (context, state) {
        if (state is EmployeeAdvanceAdded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(AppStrings.employeesAdvanceAdded),
              backgroundColor: Colors.green,
            ),
          );
        }

        if (state is EmployeeAdvanceRejected) {
          showDialog<void>(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: const Text(AppStrings.employeesWarningTitle),
              content: Text(
                AppStrings.employeesAdvanceRejected(
                  state.requestedAmount,
                  state.remainingAmount,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text(AppStrings.confirm),
                ),
              ],
            ),
          );
        }

        if (state is EmployeeSalaryPaid) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(AppStrings.employeesPayoutAdded),
              backgroundColor: Colors.green,
            ),
          );
        }

        if (state is EmployeeSalaryPayoutRejected) {
          showDialog<void>(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: const Text(AppStrings.employeesWarningTitle),
              content: Text(
                AppStrings.employeesSalaryPayoutRejected(
                  state.requestedAmount,
                  state.remainingAmount,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text(AppStrings.confirm),
                ),
              ],
            ),
          );
        }

        if (state is EmployeesError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(employee.name)),
        floatingActionButton:
            BlocBuilder<EmployeeDetailsCubit, EmployeeDetailsState>(
              buildWhen: (previous, current) {
                if (previous.runtimeType != current.runtimeType) return true;
                if (previous is EmployeeDetailsLoaded &&
                    current is EmployeeDetailsLoaded) {
                  return previous.employee != current.employee;
                }
                return false;
              },
              builder: (context, detailsState) {
                final loadedEmployee = detailsState is EmployeeDetailsLoaded
                    ? detailsState.employee
                    : employee;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    FloatingActionButton.extended(
                      heroTag: 'employee_payout_fab',
                      onPressed: () =>
                          _showSalaryPayoutDialog(context, loadedEmployee),
                      icon: const Icon(Icons.payments_outlined),
                      label: const Text(AppStrings.employeesPaySalary),
                    ),
                    const SizedBox(height: 10),
                    FloatingActionButton.extended(
                      heroTag: 'employee_advance_fab',
                      onPressed: () => _showAddAdvanceDialog(context),
                      icon: const Icon(Icons.add_card_outlined),
                      label: const Text(AppStrings.employeesAddAdvance),
                    ),
                  ],
                );
              },
            ),
        body: BlocBuilder<EmployeeDetailsCubit, EmployeeDetailsState>(
          buildWhen: (previous, current) {
            if (previous.runtimeType != current.runtimeType) return true;
            if (previous is EmployeeDetailsLoaded &&
                current is EmployeeDetailsLoaded) {
              return previous.employee != current.employee ||
                  previous.advances != current.advances;
            }
            return false;
          },
          builder: (context, state) {
            if (state is EmployeeDetailsLoading ||
                state is EmployeeDetailsInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is EmployeeDetailsError) {
              return Center(child: Text(state.message));
            }

            if (state is EmployeeDetailsLoaded) {
              final loadedEmployee = state.employee;
              final remaining = loadedEmployee.remainingSalary;

              return RepaintBoundary(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if ((loadedEmployee.nationalId ?? '')
                                .isNotEmpty) ...[
                              Text(
                                '${AppStrings.employeesNationalId}: ${loadedEmployee.nationalId}',
                              ),
                              const SizedBox(height: 8),
                            ],
                            if ((loadedEmployee.city ?? '').isNotEmpty) ...[
                              Text(
                                '${AppStrings.employeesCity}: ${loadedEmployee.city}',
                              ),
                              const SizedBox(height: 8),
                            ],
                            Text(
                              '${AppStrings.employeesSalaryCycle}: ${loadedEmployee.salaryCycle.arabicLabel}',
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${AppStrings.employeesSalaryAmount}: ${loadedEmployee.salaryAmount.toStringAsFixed(2)} ${AppStrings.currency}',
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${AppStrings.employeesAdvancesTotal}: ${loadedEmployee.currentCycleAdvancesTotal.toStringAsFixed(2)} ${AppStrings.currency}',
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${AppStrings.employeesPaidTotal}: ${loadedEmployee.currentCyclePaidTotal.toStringAsFixed(2)} ${AppStrings.currency}',
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${AppStrings.employeesSalaryOutstanding}: ${remaining.toStringAsFixed(2)} ${AppStrings.currency}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${AppStrings.employeesAdvancesCount}: ${loadedEmployee.totalAdvancesCount}',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      AppStrings.employeesAdvanceHistory,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    if (state.advances.isEmpty)
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(14),
                          child: Text(AppStrings.employeesNoAdvances),
                        ),
                      )
                    else
                      ...state.advances.map(
                        (advance) => Card(
                          child: ListTile(
                            title: Text(
                              '${advance.amount.toStringAsFixed(2)} ${AppStrings.currency}',
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(formatDateTime(advance.createdAt)),
                                Text(
                                  advance.note.isEmpty
                                      ? AppStrings.employeesNoNote
                                      : advance.note,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
