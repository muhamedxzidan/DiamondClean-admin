import '../models/car_model.dart';

abstract class CarsRemoteDataSource {
  Future<List<CarModel>> getCars();
  Future<void> addCar(String carNumber, String password, String driverName);
  Future<void> updateCar(String id, String carNumber, String password, String driverName);
  Future<void> deleteCar(String id);
  Future<void> toggleCarStatus(String id, bool isActive);
}
