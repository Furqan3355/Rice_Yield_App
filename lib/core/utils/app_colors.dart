import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF132A13);
  static const Color secondary = Color(0xFF4F772D);
  static const Color background = Color(0xFFF8F8F8);

  /// Readable body text on [background].
  static const Color textPrimary = Color(0xFF132A13);
  static const Color textSecondary = Color(0xFF4F772D);
  static const Color subtitle = Color(0xFF666666);

  static const Color card = Colors.white;
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF4F772D);
  static const Color warning = Color(0xFFF57C00);

  // Legacy aliases used across the app
  static const Color primaryColor = primary;
  static const Color secondaryColor = secondary;
  static const Color backgroundColor = background;
  static const Color cardColor = card;
  static const Color textColor = textPrimary;
  static const Color subtitleColor = subtitle;
}
