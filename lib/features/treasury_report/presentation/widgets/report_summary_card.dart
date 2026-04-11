import 'package:flutter/material.dart';

class ReportSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final double? width;

  const ReportSummaryCard({
    super.key,
    required this.title,
    required this.value,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final card = Card(
      color: backgroundColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: (textColor ?? Colors.grey).withValues(alpha: 0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, color: textColor, size: 18),
                  const SizedBox(width: 6),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: textColor?.withValues(alpha: 0.8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: textColor ?? Colors.black87,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );

    return width != null ? SizedBox(width: width, child: card) : card;
  }
}
