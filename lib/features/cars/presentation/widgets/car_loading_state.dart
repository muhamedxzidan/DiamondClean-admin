import 'package:flutter/material.dart';

class CarLoadingState extends StatelessWidget {
  const CarLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
