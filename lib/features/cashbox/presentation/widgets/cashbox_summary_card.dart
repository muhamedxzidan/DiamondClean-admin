import 'package:flutter/material.dart';

import 'package:diamond_clean/core/widgets/custom_card.dart';

class CashboxSummaryCard extends StatelessWidget {
  final String title;
  final double value;
  final double width;

  const CashboxSummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: CustomCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Text(
              value.toStringAsFixed(2),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
      ),
    );
  }
}
