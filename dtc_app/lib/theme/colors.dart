import 'package:flutter/material.dart';

/// Matches the color palette from dtc-app-prototype.jsx exactly.
class AppColors {
  AppColors._();

  static const bg = Color(0xFF12161D);
  static const panel = Color(0xFF1B212B);
  static const panelRaised = Color(0xFF212836);
  static const border = Color(0xFF2A3240);
  static const text = Color(0xFFF5F7FA);
  static const textMuted = Color(0xFFB4BCC9);
  static const amber = Color(0xFFF2B705);
  static const amberDim = Color(0xFF8A6B10);
  static const green = Color(0xFF3FBE7A);
  static const yellow = Color(0xFFF2B705);
  static const red = Color(0xFFE5484D);

  static Color severityColor(String severity) {
    switch (severity) {
      case 'بسيط':
        return green;
      case 'متوسط':
        return yellow;
      case 'خطير':
        return red;
      default:
        return textMuted;
    }
  }
}
