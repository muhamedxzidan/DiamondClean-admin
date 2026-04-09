import 'package:flutter/material.dart';

/// Build context extensions for easy access to theme values
extension BuildContextExtensions on BuildContext {
  /// Get theme data
  ThemeData get theme => Theme.of(this);

  /// Get color scheme
  ColorScheme get colorScheme => theme.colorScheme;

  /// Get text theme
  TextTheme get textTheme => theme.textTheme;

  /// Media query extensions
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// Screen size
  Size get screenSize => mediaQuery.size;

  /// Screen width
  double get screenWidth => screenSize.width;

  /// Screen height
  double get screenHeight => screenSize.height;

  /// Is landscape
  bool get isLandscape => orientation == Orientation.landscape;

  /// Is portrait
  bool get isPortrait => orientation == Orientation.portrait;

  /// Screen orientation
  Orientation get orientation => mediaQuery.orientation;

  /// Device padding (notch/safe area)
  EdgeInsets get devicePadding => mediaQuery.padding;

  /// Is small screen (mobile)
  bool get isSmallScreen => screenWidth < 600;

  /// Is medium screen (tablet)
  bool get isMediumScreen => screenWidth >= 600 && screenWidth < 1200;

  /// Is large screen (desktop)
  bool get isLargeScreen => screenWidth >= 1200;
}

/// Text style extensions
extension TextStyleExtensions on TextStyle {
  /// Copy with bold weight
  TextStyle get bold => copyWith(fontWeight: FontWeight.bold);

  /// Copy with semi-bold weight
  TextStyle get semiBold => copyWith(fontWeight: FontWeight.w600);

  /// Copy with light weight
  TextStyle get light => copyWith(fontWeight: FontWeight.w300);
}

/// Color extensions
extension ColorExtensions on Color {
  /// Convert color to hex string
  // ignore: deprecated_member_use
  String toHex() => '#${value.toRadixString(16).padLeft(8, '0')}';

  /// Get contrasting text color (black or white)
  Color getContrastingColor() {
    final luminance = computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}

/// Widget extensions for common patterns
extension WidgetExtensions on Widget {
  /// Add symmetrical padding
  Widget paddingSymmetric({double horizontal = 0, double vertical = 0}) =>
      Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontal,
          vertical: vertical,
        ),
        child: this,
      );

  /// Add all-sides padding
  Widget paddingAll(double value) =>
      Padding(padding: EdgeInsets.all(value), child: this);

  /// Add custom padding
  Widget padding(EdgeInsetsGeometry value) =>
      Padding(padding: value, child: this);

  /// Center widget
  Widget center() => Center(child: this);

  /// Flexible with flex parameter
  Widget flexible({int flex = 1}) => Flexible(flex: flex, child: this);

  /// Expanded with flex parameter
  Widget expanded({int flex = 1}) => Expanded(flex: flex, child: this);
}

/// List extensions
extension ListExtensions<T> on List<T> {
  /// Add separator between items
  List<T> addSeparator(T separator) {
    if (isEmpty) return this;
    final result = <T>[];
    for (int i = 0; i < length; i++) {
      result.add(this[i]);
      if (i < length - 1) result.add(separator);
    }
    return result;
  }
}
