import 'package:bloc/bloc.dart';

import '../data/datasources/categories_remote_data_source.dart';
import 'category_state.dart';

class CategoryCubit extends Cubit<CategoryState> {
  final CategoriesRemoteDataSource _dataSource;

  CategoryCubit(this._dataSource) : super(const CategoryInitial());

  Future<void> loadCategories() async {
    emit(const CategoryLoading());
    try {
      final categories = await _dataSource.getCategories();
      emit(CategoryLoaded(categories));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> addCategory(String name) async {
    emit(const CategoryOperationLoading());
    try {
      await _dataSource.addCategory(name);
      emit(const CategoryOperationSuccess());
      await loadCategories();
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> updateCategory(String id, String name) async {
    emit(const CategoryOperationLoading());
    try {
      await _dataSource.updateCategory(id, name);
      emit(const CategoryOperationSuccess());
      await loadCategories();
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> deleteCategory(String id) async {
    emit(const CategoryOperationLoading());
    try {
      await _dataSource.deleteCategory(id);
      emit(const CategoryOperationSuccess());
      await loadCategories();
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }
}
