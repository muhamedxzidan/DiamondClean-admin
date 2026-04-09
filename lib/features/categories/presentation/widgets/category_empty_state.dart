import 'package:flutter/material.dart';

import 'package:diamond_clean/core/constants/app_strings.dart';

class CategoryEmptyState extends StatelessWidget {
  const CategoryEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(AppStrings.noCategoriesFound),
    );
  }
}
