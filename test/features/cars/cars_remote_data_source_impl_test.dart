import 'package:diamond_clean/features/cars/data/datasources/cars_remote_data_source_impl.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CarsRemoteDataSourceImpl', () {
    test('stores a new car using the car number as the document id', () async {
      final firestore = FakeFirebaseFirestore();
      final dataSource = CarsRemoteDataSourceImpl(firestore);

      await dataSource.addCar('1', '123456', 'محمد');

      final snapshot = await firestore.collection('cars').get();
      expect(snapshot.docs, hasLength(1));
      expect(snapshot.docs.first.id, '1');
      expect(snapshot.docs.first.data()['carNumber'], '1');
      expect(snapshot.docs.first.data()['password'], '123456');
      expect(snapshot.docs.first.data()['driverName'], 'محمد');
      expect(snapshot.docs.first.data()['isActive'], isTrue);
    });

    test('renames the document when the car number changes', () async {
      final firestore = FakeFirebaseFirestore();
      final dataSource = CarsRemoteDataSourceImpl(firestore);

      await dataSource.addCar('1', '123456', 'محمد');
      await dataSource.updateCar('1', '2', '654321', 'أحمد');

      final snapshot = await firestore.collection('cars').get();
      expect(snapshot.docs, hasLength(1));
      expect(snapshot.docs.first.id, '2');
      expect(snapshot.docs.first.data()['carNumber'], '2');
      expect(snapshot.docs.first.data()['password'], '654321');
      expect(snapshot.docs.first.data()['driverName'], 'أحمد');

      final oldDoc = await firestore.collection('cars').doc('1').get();
      expect(oldDoc.exists, isFalse);
    });
  });
}
