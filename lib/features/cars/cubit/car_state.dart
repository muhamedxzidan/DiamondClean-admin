import '../data/models/car_model.dart';

sealed class CarState {
  const CarState();
}

final class CarInitial extends CarState {
  const CarInitial();
}

final class CarLoading extends CarState {
  const CarLoading();
}

final class CarLoaded extends CarState {
  final List<CarModel> cars;
  const CarLoaded(this.cars);
}

final class CarOperationLoading extends CarState {
  const CarOperationLoading();
}

final class CarOperationSuccess extends CarState {
  const CarOperationSuccess();
}

final class CarError extends CarState {
  final String message;
  const CarError(this.message);
}
