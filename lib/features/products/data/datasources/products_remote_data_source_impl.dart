import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import 'products_remote_data_source.dart';

class ProductsRemoteDataSourceImpl implements ProductsRemoteDataSource {
  // ignore: unused_field
  final FirebaseFirestore _firebaseFirestore;

  ProductsRemoteDataSourceImpl(this._firebaseFirestore);

  @override
  Future<List<ProductModel>> getProducts() async {
    // TODO: Implement Firestore query
    throw UnimplementedError();
  }

  @override
  Future<List<ProductModel>> getProductsByCategory(String categoryId) async {
    // TODO: Implement Firestore query with filter
    throw UnimplementedError();
  }

  @override
  Future<ProductModel> addProduct(
    String name,
    String categoryId,
    double price,
    String? description,
  ) async {
    // TODO: Implement Firestore add
    throw UnimplementedError();
  }

  @override
  Future<void> updateProduct(
    String id,
    String name,
    String categoryId,
    double price,
    String? description,
  ) async {
    // TODO: Implement Firestore update
    throw UnimplementedError();
  }

  @override
  Future<void> deleteProduct(String id) async {
    // TODO: Implement Firestore delete
    throw UnimplementedError();
  }
}
