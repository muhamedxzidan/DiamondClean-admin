import 'package:cloud_firestore/cloud_firestore.dart';

class CarModel {
  final String id;
  final String carNumber;
  final String password;
  final String driverName;
  final bool isActive;
  final DateTime createdAt;

  const CarModel({
    required this.id,
    required this.carNumber,
    required this.password,
    required this.driverName,
    required this.isActive,
    required this.createdAt,
  });

  factory CarModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CarModel(
      id: doc.id,
      carNumber: data['carNumber'] as String,
      password: data['password'] as String,
      driverName: data['driverName'] as String,
      isActive: data['isActive'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'carNumber': carNumber,
    'password': password,
    'driverName': driverName,
    'isActive': isActive,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}
