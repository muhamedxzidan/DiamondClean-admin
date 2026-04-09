import 'package:flutter/material.dart';

import '../../data/models/category_model.dart';
import 'category_list_item.dart';

class CategoryListView extends StatelessWidget {
  final List<CategoryModel> categories;
  final Function(CategoryModel) onEdit;
  final Function(String) onDelete;

  const CategoryListView({
    required this.categories,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: categories.length,
      itemBuilder: (_, index) {
        final category = categories[index];
        return CategoryListItem(
          category: category,
          onEdit: () => onEdit(category),
          onDelete: () => onDelete(category.id),
        );
      },
    );
  }
}
