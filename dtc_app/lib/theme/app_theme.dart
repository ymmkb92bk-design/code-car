import 'package:flutter/material.dart';
import 'colors.dart';

/// Arabic script needs slightly larger sizing than Latin text to feel
/// equally readable at a glance (PROJECT_SPEC.md Section 10.5).
class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bg,
      fontFamily: 'Segoe UI',
      colorScheme: const ColorScheme.dark(
        primary: AppColors.amber,
        surface: AppColors.panel,
        error: AppColors.red,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.text, fontSize: 17, height: 1.7),
        bodyMedium: TextStyle(color: AppColors.text, fontSize: 16, height: 1.7),
        titleLarge: TextStyle(color: AppColors.text, fontSize: 22, fontWeight: FontWeight.w700),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.amber,
          foregroundColor: const Color(0xFF1A1300),
          disabledBackgroundColor: AppColors.panelRaised,
          disabledForegroundColor: AppColors.textMuted,
          textStyle: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
