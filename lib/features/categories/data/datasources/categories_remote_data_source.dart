import '../models/category_model.dart';

abstract class CategoriesRemoteDataSource {
  Future<List<CategoryModel>> getCategories();
  Future<void> addCategory(String name);
  Future<void> updateCategory(String id, String name);
  Future<void> deleteCategory(String id);
}
