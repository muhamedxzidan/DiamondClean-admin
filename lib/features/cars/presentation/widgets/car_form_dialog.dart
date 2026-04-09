import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:diamond_clean/core/constants/app_strings.dart';
import '../../cubit/car_cubit.dart';
import '../../cubit/car_state.dart';
import '../../data/models/car_model.dart';

class CarFormDialog extends StatefulWidget {
  final CarModel? car;

  const CarFormDialog({super.key, this.car});

  @override
  State<CarFormDialog> createState() => _CarFormDialogState();
}

class _CarFormDialogState extends State<CarFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _carNumberController;
  late final TextEditingController _passwordController;
  late final TextEditingController _driverNameController;

  bool _obscurePassword = true;
  bool get _isEditing => widget.car != null;

  @override
  void initState() {
    super.initState();
    _carNumberController = TextEditingController(text: widget.car?.carNumber);
    _passwordController = TextEditingController(text: widget.car?.password);
    _driverNameController = TextEditingController(text: widget.car?.driverName);
  }

  @override
  void dispose() {
    _carNumberController.dispose();
    _passwordController.dispose();
    _driverNameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final carNumber = _carNumberController.text.trim();
    final password = _passwordController.text.trim();
    final driverName = _driverNameController.text.trim();
    if (_isEditing) {
      context.read<CarCubit>().updateCar(widget.car!.id, carNumber, password, driverName);
    } else {
      context.read<CarCubit>().addCar(carNumber, password, driverName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CarCubit, CarState>(
      listener: (context, state) {
        if (state is CarOperationSuccess) Navigator.of(context).pop();
        if (state is CarError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: AlertDialog(
        title: Text(_isEditing ? AppStrings.editCar : AppStrings.addCar),
        content: SizedBox(
          width: 400,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _carNumberController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: AppStrings.carNumber,
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.directions_car_outlined),
                  ),
                  validator: (value) =>
                      (value == null || value.trim().isEmpty) ? AppStrings.fieldRequired : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: AppStrings.carPassword,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (value) =>
                      (value == null || value.trim().isEmpty) ? AppStrings.fieldRequired : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _driverNameController,
                  decoration: const InputDecoration(
                    labelText: AppStrings.driverName,
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) =>
                      (value == null || value.trim().isEmpty) ? AppStrings.fieldRequired : null,
                  onFieldSubmitted: (_) => _submit(),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(AppStrings.cancel),
          ),
          BlocBuilder<CarCubit, CarState>(
            builder: (context, state) {
              final isLoading = state is CarOperationLoading;
              return FilledButton(
                onPressed: isLoading ? null : _submit,
                child: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(AppStrings.save),
              );
            },
          ),
        ],
      ),
    );
  }
}
