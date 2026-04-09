import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diamond_clean/core/constants/firebase_constants.dart';

import '../models/car_model.dart';
import 'cars_remote_data_source.dart';

class CarsRemoteDataSourceImpl implements CarsRemoteDataSource {
  final FirebaseFirestore _firestore;

  CarsRemoteDataSourceImpl(this._firestore);

  CollectionReference get _collection =>
      _firestore.collection(FirebaseConstants.carsCollection);

  @override
  Future<List<CarModel>> getCars() async {
    final snapshot = await _collection.orderBy('createdAt', descending: true).get();
    return snapshot.docs.map(CarModel.fromFirestore).toList();
  }

  @override
  Future<void> addCar(String carNumber, String password, String driverName) async {
    await _collection.add({
      'carNumber': carNumber,
      'password': password,
      'driverName': driverName,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> updateCar(
    String id,
    String carNumber,
    String password,
    String driverName,
  ) async {
    await _collection.doc(id).update({
      'carNumber': carNumber,
      'password': password,
      'driverName': driverName,
    });
  }

  @override
  Future<void> deleteCar(String id) async {
    await _collection.doc(id).delete();
  }

  @override
  Future<void> toggleCarStatus(String id, bool isActive) async {
    await _collection.doc(id).update({'isActive': isActive});
  }
}
