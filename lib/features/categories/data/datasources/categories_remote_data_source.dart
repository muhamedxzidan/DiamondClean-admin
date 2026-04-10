import '../models/category_model.dart';

abstract class CategoriesRemoteDataSource {
  Future<List<CategoryModel>> getCategories();
  Future<void> addCategory(String name, bool hasDimensions);
  Future<void> updateCategory(String id, String name, bool hasDimensions);
  Future<void> deleteCategory(String id);
}
