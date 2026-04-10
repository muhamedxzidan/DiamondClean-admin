import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  final String id;
  final String name;
  final bool hasDimensions;
  final DateTime createdAt;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.hasDimensions,
    required this.createdAt,
  });

  factory CategoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CategoryModel(
      id: doc.id,
      name: data['name'] as String,
      hasDimensions: (data['hasDimensions'] as bool?) ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'name': name,
    'hasDimensions': hasDimensions,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}
