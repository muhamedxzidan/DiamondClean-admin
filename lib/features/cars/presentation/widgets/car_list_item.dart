import 'package:flutter/material.dart';

import 'package:diamond_clean/core/constants/app_strings.dart';
import '../../data/models/car_model.dart';

class CarListItem extends StatelessWidget {
  final CarModel car;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleStatus;

  const CarListItem({
    super.key,
    required this.car,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: car.isActive
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerHighest,
          child: Icon(
            Icons.directions_car_outlined,
            color: car.isActive ? colorScheme.primary : colorScheme.outline,
          ),
        ),
        title: Text(car.carNumber),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(car.driverName),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: car.isActive
                    ? Colors.green.withValues(alpha: 0.12)
                    : Colors.red.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                car.isActive ? AppStrings.carActive : AppStrings.carInactive,
                style: TextStyle(
                  fontSize: 11,
                  color: car.isActive ? Colors.green.shade700 : Colors.red.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                car.isActive ? Icons.block_outlined : Icons.check_circle_outline,
                color: car.isActive ? Colors.orange : Colors.green,
              ),
              tooltip: car.isActive ? AppStrings.deactivateCar : AppStrings.activateCar,
              onPressed: onToggleStatus,
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: AppStrings.edit,
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              tooltip: AppStrings.delete,
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
