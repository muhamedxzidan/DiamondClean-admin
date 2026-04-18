import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diamond_clean/core/constants/firebase_constants.dart';

import '../models/car_model.dart';
import 'cars_remote_data_source.dart';

class CarsRemoteDataSourceImpl implements CarsRemoteDataSource {
  final FirebaseFirestore _firestore;

  CarsRemoteDataSourceImpl(this._firestore);

  CollectionReference get _collection =>
      _firestore.collection(FirebaseConstants.carsCollection);

  String _normalizeCarNumber(String carNumber) => carNumber.trim();

  @override
  Future<List<CarModel>> getCars() async {
    final snapshot = await _collection
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map(CarModel.fromFirestore).toList();
  }

  @override
  Future<void> addCar(
    String carNumber,
    String password,
    String driverName,
  ) async {
    final normalizedCarNumber = _normalizeCarNumber(carNumber);

    await _firestore.runTransaction((tx) async {
      final carRef = _collection.doc(normalizedCarNumber);
      final carSnap = await tx.get(carRef);

      if (carSnap.exists) {
        throw Exception('رقم السيارة موجود بالفعل');
      }

      tx.set(carRef, {
        'carNumber': normalizedCarNumber,
        'password': password,
        'driverName': driverName,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  @override
  Future<void> updateCar(
    String id,
    String carNumber,
    String password,
    String driverName,
  ) async {
    final normalizedCarNumber = _normalizeCarNumber(carNumber);

    await _firestore.runTransaction((tx) async {
      final currentRef = _collection.doc(id);
      final currentSnap = await tx.get(currentRef);

      if (!currentSnap.exists) {
        throw Exception('السيارة غير موجودة');
      }

      final currentData = currentSnap.data()! as Map<String, dynamic>;

      if (id == normalizedCarNumber) {
        tx.update(currentRef, {
          'carNumber': normalizedCarNumber,
          'password': password,
          'driverName': driverName,
        });
        return;
      }

      final targetRef = _collection.doc(normalizedCarNumber);
      final targetSnap = await tx.get(targetRef);

      if (targetSnap.exists) {
        throw Exception('رقم السيارة موجود بالفعل');
      }

      tx.set(targetRef, {
        ...currentData,
        'carNumber': normalizedCarNumber,
        'password': password,
        'driverName': driverName,
      });
      tx.delete(currentRef);
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
