import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:diamond_clean/core/constants/app_strings.dart';
import '../../cubit/car_cubit.dart';
import '../../cubit/car_state.dart';
import '../../data/models/car_model.dart';
import '../widgets/car_empty_state.dart';
import '../widgets/car_error_state.dart';
import '../widgets/car_form_dialog.dart';
import '../widgets/car_list_view.dart';
import '../widgets/car_loading_state.dart';

class CarsScreen extends StatefulWidget {
  const CarsScreen({super.key});

  @override
  State<CarsScreen> createState() => _CarsScreenState();
}

class _CarsScreenState extends State<CarsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CarCubit>().loadCars();
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<CarCubit>(),
        child: const CarFormDialog(),
      ),
    );
  }

  void _showEditDialog(CarModel car) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<CarCubit>(),
        child: CarFormDialog(car: car),
      ),
    );
  }

  Future<void> _confirmDelete(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(AppStrings.deleteCar),
        content: const Text(AppStrings.confirmDeleteMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(AppStrings.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      context.read<CarCubit>().deleteCar(id);
    }
  }

  Future<void> _confirmToggleStatus(CarModel car) async {
    final isDeactivating = car.isActive;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          isDeactivating ? AppStrings.deactivateCar : AppStrings.activateCar,
        ),
        content: Text(
          isDeactivating
              ? AppStrings.confirmDeactivateCar
              : AppStrings.confirmActivateCar,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(AppStrings.cancel),
          ),
          FilledButton(
            style: isDeactivating
                ? FilledButton.styleFrom(backgroundColor: Colors.orange)
                : null,
            onPressed: () => Navigator.pop(context, true),
            child: const Text(AppStrings.confirm),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      context.read<CarCubit>().toggleCarStatus(car.id, !car.isActive);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.carsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<CarCubit>().loadCars(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        icon: const Icon(Icons.add),
        label: const Text(AppStrings.addCar),
      ),
      body: BlocConsumer<CarCubit, CarState>(
        listener: (context, state) {
          if (state is CarError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) => switch (state) {
          CarInitial() || CarLoading() => const CarLoadingState(),
          CarOperationLoading() => const CarLoadingState(),
          CarLoaded(:final cars) when cars.isEmpty => const CarEmptyState(),
          CarLoaded(:final cars) => CarListView(
              cars: cars,
              onEdit: _showEditDialog,
              onDelete: _confirmDelete,
              onToggleStatus: _confirmToggleStatus,
            ),
          CarOperationSuccess() => const CarLoadingState(),
          CarError(:final message) => CarErrorState(
              message: message,
              onRetry: () => context.read<CarCubit>().loadCars(),
            ),
        },
      ),
    );
  }
}
