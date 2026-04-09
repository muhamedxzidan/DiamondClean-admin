import 'package:flutter/material.dart';

import '../constants/app_dimensions.dart';

/// Reusable custom card widget
class CustomCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? backgroundColor;
  final BoxBorder? border;
  final List<BoxShadow>? shadows;

  const CustomCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppDimensions.paddingMd),
    this.borderRadius = AppDimensions.radiusMd,
    this.backgroundColor,
    this.border,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        border:
            border ??
            Border.all(color: Theme.of(context).dividerColor, width: 1),
        boxShadow: shadows,
      ),
      child: child,
    );

    if (onTap == null) return card;

    return GestureDetector(onTap: onTap, child: card);
  }
}

/// Reusable dialog widget
class CustomDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String? cancelLabel;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final Color? confirmColor;
  final bool isDangerous;

  const CustomDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmLabel,
    this.cancelLabel,
    required this.onConfirm,
    this.onCancel,
    this.confirmColor,
    this.isDangerous = false,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        if (cancelLabel != null)
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onCancel?.call();
            },
            child: Text(cancelLabel!),
          ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: confirmColor ?? (isDangerous ? Colors.red : null),
            foregroundColor: isDangerous ? Colors.white : null,
          ),
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
          child: Text(confirmLabel),
        ),
      ],
    );
  }
}
