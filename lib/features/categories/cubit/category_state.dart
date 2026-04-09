import '../data/models/category_model.dart';

sealed class CategoryState {
  const CategoryState();
}

final class CategoryInitial extends CategoryState {
  const CategoryInitial();
}

final class CategoryLoading extends CategoryState {
  const CategoryLoading();
}

final class CategoryLoaded extends CategoryState {
  final List<CategoryModel> categories;
  const CategoryLoaded(this.categories);
}

final class CategoryOperationLoading extends CategoryState {
  const CategoryOperationLoading();
}

final class CategoryOperationSuccess extends CategoryState {
  const CategoryOperationSuccess();
}

final class CategoryError extends CategoryState {
  final String message;
  const CategoryError(this.message);
}
