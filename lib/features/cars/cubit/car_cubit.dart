import 'package:bloc/bloc.dart';

import '../data/datasources/cars_remote_data_source.dart';
import 'car_state.dart';

class CarCubit extends Cubit<CarState> {
  final CarsRemoteDataSource _dataSource;

  CarCubit(this._dataSource) : super(const CarInitial());

  Future<void> loadCars() async {
    emit(const CarLoading());
    try {
      final cars = await _dataSource.getCars();
      emit(CarLoaded(cars));
    } catch (e) {
      emit(CarError(e.toString()));
    }
  }

  Future<void> addCar(String carNumber, String password, String driverName) async {
    emit(const CarOperationLoading());
    try {
      await _dataSource.addCar(carNumber, password, driverName);
      emit(const CarOperationSuccess());
      await loadCars();
    } catch (e) {
      emit(CarError(e.toString()));
    }
  }

  Future<void> updateCar(
    String id,
    String carNumber,
    String password,
    String driverName,
  ) async {
    emit(const CarOperationLoading());
    try {
      await _dataSource.updateCar(id, carNumber, password, driverName);
      emit(const CarOperationSuccess());
      await loadCars();
    } catch (e) {
      emit(CarError(e.toString()));
    }
  }

  Future<void> deleteCar(String id) async {
    emit(const CarOperationLoading());
    try {
      await _dataSource.deleteCar(id);
      emit(const CarOperationSuccess());
      await loadCars();
    } catch (e) {
      emit(CarError(e.toString()));
    }
  }

  Future<void> toggleCarStatus(String id, bool isActive) async {
    emit(const CarOperationLoading());
    try {
      await _dataSource.toggleCarStatus(id, isActive);
      emit(const CarOperationSuccess());
      await loadCars();
    } catch (e) {
      emit(CarError(e.toString()));
    }
  }
}
