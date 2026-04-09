import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:diamond_clean/core/constants/app_strings.dart';
import '../../cubit/category_cubit.dart';
import '../../cubit/category_state.dart';
import '../../data/models/category_model.dart';
import '../widgets/category_empty_state.dart';
import '../widgets/category_error_state.dart';
import '../widgets/category_form_dialog.dart';
import '../widgets/category_list_view.dart';
import '../widgets/category_loading_state.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CategoryCubit>().loadCategories();
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<CategoryCubit>(),
        child: const CategoryFormDialog(),
      ),
    );
  }

  void _showEditDialog(CategoryModel category) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<CategoryCubit>(),
        child: CategoryFormDialog(category: category),
      ),
    );
  }

  Future<void> _confirmDelete(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(AppStrings.deleteCategory),
        content: const Text(AppStrings.confirmDeleteMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(AppStrings.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      context.read<CategoryCubit>().deleteCategory(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.categoriesTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<CategoryCubit>().loadCategories(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        icon: const Icon(Icons.add),
        label: const Text(AppStrings.addCategory),
      ),
      body: BlocConsumer<CategoryCubit, CategoryState>(
        listener: (context, state) {
          if (state is CategoryError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) => switch (state) {
          CategoryInitial() ||
          CategoryLoading() => const CategoryLoadingState(),
          CategoryOperationLoading() => const CategoryLoadingState(),
          CategoryLoaded(:final categories) when categories.isEmpty =>
            const CategoryEmptyState(),
          CategoryLoaded(:final categories) => CategoryListView(
              categories: categories,
              onEdit: _showEditDialog,
              onDelete: _confirmDelete,
            ),
          CategoryOperationSuccess() => const CategoryLoadingState(),
          CategoryError(:final message) => CategoryErrorState(
              message: message,
              onRetry: () => context.read<CategoryCubit>().loadCategories(),
            ),
        },
      ),
    );
  }
}
