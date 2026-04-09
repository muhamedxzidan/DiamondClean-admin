import '../models/product_model.dart';

abstract class ProductsRemoteDataSource {
  Future<List<ProductModel>> getProducts();
  Future<List<ProductModel>> getProductsByCategory(String categoryId);
  Future<ProductModel> addProduct(
    String name,
    String categoryId,
    double price,
    String? description,
  );
  Future<void> updateProduct(
    String id,
    String name,
    String categoryId,
    double price,
    String? description,
  );
  Future<void> deleteProduct(String id);
}
