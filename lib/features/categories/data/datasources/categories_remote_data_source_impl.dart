import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diamond_clean/core/constants/firebase_constants.dart';

import '../models/category_model.dart';
import 'categories_remote_data_source.dart';

class CategoriesRemoteDataSourceImpl implements CategoriesRemoteDataSource {
  final FirebaseFirestore _firestore;

  CategoriesRemoteDataSourceImpl(this._firestore);

  CollectionReference get _collection =>
      _firestore.collection(FirebaseConstants.categoriesCollection);

  @override
  Future<List<CategoryModel>> getCategories() async {
    final snapshot = await _collection
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map(CategoryModel.fromFirestore).toList();
  }

  @override
  Future<void> addCategory(String name, bool hasDimensions) async {
    await _collection.add({
      'name': name,
      'hasDimensions': hasDimensions,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> updateCategory(
    String id,
    String name,
    bool hasDimensions,
  ) async {
    await _collection.doc(id).update({
      'name': name,
      'hasDimensions': hasDimensions,
    });
  }

  @override
  Future<void> deleteCategory(String id) async {
    await _collection.doc(id).delete();
  }
}
