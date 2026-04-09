import 'package:flutter/material.dart';

import '../../data/models/car_model.dart';
import 'car_list_item.dart';

class CarListView extends StatelessWidget {
  final List<CarModel> cars;
  final Function(CarModel) onEdit;
  final Function(String) onDelete;
  final Function(CarModel) onToggleStatus;

  const CarListView({
    required this.cars,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleStatus,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: cars.length,
      itemBuilder: (_, index) {
        final car = cars[index];
        return CarListItem(
          car: car,
          onEdit: () => onEdit(car),
          onDelete: () => onDelete(car.id),
          onToggleStatus: () => onToggleStatus(car),
        );
      },
    );
  }
}
