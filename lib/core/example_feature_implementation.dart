// ignore: file_names
// ignore: file_names
// 📌 THIS IS A REFERENCE EXAMPLE — Not real code to run
// Copy this pattern into your actual feature files

import 'package:diamond_clean/core/constants/app_dimensions.dart';
import 'package:diamond_clean/core/constants/app_strings.dart';
import 'package:diamond_clean/core/extensions/extensions.dart';
import 'package:diamond_clean/core/widgets/custom_button.dart';
import 'package:diamond_clean/core/widgets/custom_card.dart';
import 'package:diamond_clean/core/widgets/custom_text_field.dart';
import 'package:diamond_clean/core/widgets/state_widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide ErrorWidget;
import 'package:flutter_bloc/flutter_bloc.dart';

// When implementing in your features, use these imports:
// import 'package:diamond_clean/core/constants/constants.dart';
// import 'package:diamond_clean/core/extensions/extensions.dart';
// import 'package:diamond_clean/core/widgets/widgets.dart';
// import 'package:diamond_clean/features/categories/cubit/categories_cubit.dart';

// ==========================================
// STEP 1: Define your State classes
// ==========================================
// File: features/categories/presentation/cubit/categories_state.dart

sealed class CategoriesState {}

class CategoriesInitial extends CategoriesState {}

class CategoriesLoading extends CategoriesState {}

class CategoriesSuccess extends CategoriesState {
  final List<Category> categories;
  CategoriesSuccess(this.categories);
}

class CategoriesError extends CategoriesState {
  final String message;
  CategoriesError(this.message);
}

// ==========================================
// STEP 2: Define your Cubit
// ==========================================
// File: features/categories/presentation/cubit/categories_cubit.dart

class CategoriesCubit extends Cubit<CategoriesState> {
  CategoriesCubit(this._dataSource) : super(CategoriesInitial());

  final CategoriesRemoteDataSource _dataSource;

  Future<void> getCategories() async {
    try {
      emit(CategoriesLoading());
      final categories = await _dataSource.getCategories();
      emit(CategoriesSuccess(categories));
    } catch (e) {
      emit(CategoriesError(e.toString()));
    }
  }

  Future<void> addCategory(String name, String? description) async {
    try {
      emit(CategoriesLoading());
      await _dataSource.addCategory(name, description);
      await getCategories();
    } catch (e) {
      emit(CategoriesError(e.toString()));
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      emit(CategoriesLoading());
      await _dataSource.deleteCategory(id);
      await getCategories();
    } catch (e) {
      emit(CategoriesError(e.toString()));
    }
  }
}

// ==========================================
// STEP 3: Create your Page Widget
// ==========================================
// File: features/categories/presentation/pages/categories_page.dart
class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.categoriesTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddCategoryDialog(context),
          ),
        ],
      ),
      body: BlocBuilder<CategoriesCubit, CategoriesState>(
        buildWhen: (previous, current) =>
            previous.runtimeType != current.runtimeType,
        builder: (context, state) {
          // Loading State
          if (state is CategoriesLoading) {
            return const LoadingWidget(message: AppStrings.loading);
          }

          // Error State
          if (state is CategoriesError) {
            return ErrorWidget(
              message: state.message,
              onRetry: () => context.read<CategoriesCubit>().getCategories(),
            );
          }

          // Success State
          if (state is CategoriesSuccess) {
            // Empty State
            if (state.categories.isEmpty) {
              return EmptyStateWidget(
                message: AppStrings.noCategoriesFound,
                actionLabel: AppStrings.addCategory,
                onAction: () => _showAddCategoryDialog(context),
              );
            }

            // List View
            return ListView.builder(
              padding: const EdgeInsets.all(AppDimensions.paddingLg),
              itemCount: state.categories.length,
              itemBuilder: (context, index) {
                final category = state.categories[index];
                return _CategoryCard(category: category);
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    showDialog(context: context, builder: (_) => const _AddCategoryDialog());
  }
}

// Category Card Widget (Reusable)
class _CategoryCard extends StatelessWidget {
  final Category category;

  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: () => _editCategory(context),
      padding: const EdgeInsets.all(AppDimensions.paddingMd),
      child: Row(
        children: [
          // Icon
          Icon(
            Icons.folder_outlined,
            size: AppDimensions.iconMd,
            color: context.colorScheme.primary,
          ).paddingSymmetric(horizontal: AppDimensions.paddingMd),

          // Title & Description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(category.name, style: context.textTheme.headlineSmall),
                if (category.description != null)
                  Text(
                    category.description!,
                    style: context.textTheme.bodySmall,
                  ).paddingSymmetric(vertical: AppDimensions.paddingSm),
              ],
            ),
          ),

          // Actions
          PopupMenuButton(
            itemBuilder: (_) => [
              PopupMenuItem(
                child: const Text(AppStrings.edit),
                onTap: () => _editCategory(context),
              ),
              PopupMenuItem(
                child: Text(
                  AppStrings.delete,
                  style: const TextStyle(color: Colors.red),
                ),
                onTap: () => _deleteCategory(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _editCategory(BuildContext context) {
    // Navigate to edit screen or show dialog
    if (kDebugMode) {
      if (kDebugMode) {
        print('Edit: ${category.name}');
      }
    }
  }

  void _deleteCategory(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => CustomDialog(
        title: AppStrings.deleteCategory,
        message: AppStrings.confirmDeleteMessage,
        confirmLabel: AppStrings.delete,
        cancelLabel: AppStrings.cancel,
        isDangerous: true,
        onConfirm: () =>
            context.read<CategoriesCubit>().deleteCategory(category.id),
      ),
    );
  }
}

// Add Category Dialog (Example Form)
class _AddCategoryDialog extends StatefulWidget {
  const _AddCategoryDialog();

  @override
  State<_AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<_AddCategoryDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(AppStrings.addCategory),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(
              label: AppStrings.categoryName,
              controller: _nameController,
              prefixIcon: Icons.label,
              validator: (_) => _nameController.text.isEmpty
                  ? AppStrings.fieldRequired
                  : null,
            ).paddingSymmetric(vertical: AppDimensions.paddingSm),
            CustomTextField(
              label: 'الوصف (اختياري)',
              controller: _descriptionController,
              prefixIcon: Icons.description,
              maxLines: 3,
            ).paddingSymmetric(vertical: AppDimensions.paddingSm),
          ],
        ),
      ),
      actions: [
        OutlineCustomButton(
          label: AppStrings.cancel,
          onPressed: () => Navigator.pop(context),
        ),
        BlocBuilder<CategoriesCubit, CategoriesState>(
          buildWhen: (previous, current) {
            final wasLoading = previous is CategoriesLoading;
            final isLoading = current is CategoriesLoading;
            return wasLoading != isLoading;
          },
          builder: (context, state) => CustomButton(
            label: AppStrings.save,
            isLoading: state is CategoriesLoading,
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                context.read<CategoriesCubit>().addCategory(
                  _nameController.text,
                  _descriptionController.text,
                );
                Navigator.pop(context);
              }
            },
          ),
        ),
      ],
    );
  }
}

// ==========================================
// PLACEHOLDERS (For reference)
// ==========================================

class Category {
  final String id;
  final String name;
  final String? description;

  Category({required this.id, required this.name, this.description});
}

abstract class CategoriesRemoteDataSource {
  Future<List<Category>> getCategories();
  Future<void> addCategory(String name, String? description);
  Future<void> deleteCategory(String id);
}

// ==========================================
// KEY POINTS (اتبع هذه النقاط)
// ==========================================
/*
1. ✅ استخدمت CustomButton & CustomTextField — بدون hardcoding
2. ✅ استخدمت AppDimensions لجميع الفراغات والأحجام
3. ✅ اتبعت قواعد المعمارية (Cubit → Data Layer)
4. ✅ استخدمت LoadingWidget, ErrorWidget, EmptyStateWidget للـ states
5. ✅ استخدمت extensions (context.textTheme, context.colorScheme)
6. ✅ لا business logic في UI — كل شيء في Cubit
7. ✅ State-driven rendering مع BlocBuilder
8. ✅ const constructors حيث يمكن
9. ✅ proper cleanup و disposal للـ controllers
10. ✅ اتبعت import ordering rules
*/
