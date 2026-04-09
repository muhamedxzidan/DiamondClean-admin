import 'package:flutter/material.dart';

class CategoryLoadingState extends StatelessWidget {
  const CategoryLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
