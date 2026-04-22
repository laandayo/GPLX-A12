import 'package:flutter/material.dart';
import '../models/license_type.dart';

class AppColors {
  AppColors._();

  static const Color a1LightPrimary = Color(0xFF1E88E5);
  static const Color a1LightAccent = Color(0xFF42A5F5);
  static const Color a1LightBackground = Color(0xFFF5F9FF);
  static const Color a1LightSurface = Color(0xFFFFFFFF);
  static const Color a1LightText = Color(0xFF0D1B2A);

  static const Color a1DarkPrimary = Color(0xFF1565C0);
  static const Color a1DarkAccent = Color(0xFF64B5F6);
  static const Color a1DarkBackground = Color(0xFF0B111A);
  static const Color a1DarkSurface = Color(0xFF121A26);
  static const Color a1DarkText = Color(0xFFE3F2FD);

  static const Color a2LightPrimary = Color(0xFF2E7D32);
  static const Color a2LightAccent = Color(0xFF66BB6A);
  static const Color a2LightBackground = Color(0xFFF4FBF6);
  static const Color a2LightSurface = Color(0xFFFFFFFF);
  static const Color a2LightText = Color(0xFF102A13);

  static const Color a2DarkPrimary = Color.fromARGB(255, 74, 168, 80);
  static const Color a2DarkAccent = Color(0xFF81C784);
  static const Color a2DarkBackground = Color(0xFF0E1512);
  static const Color a2DarkSurface = Color(0xFF16201A);
  static const Color a2DarkText = Color(0xFFE8F5E9);

  static const Color correct = Color(0xFF43A047);
  static const Color correctLight = Color(0xFFE8F5E9);
  static const Color wrong = Color(0xFFE53935);
  static const Color wrongLight = Color(0xFFFFEBEE);
  static const Color bookmark = Color(0xFFFFA000);
  static const Color bookmarkLight = Color(0xFFFFF8E1);
  static const Color unanswered = Color(0xFFBDBDBD);
  static const Color divider = Color(0xFFE0E0E0);
  static const Color dividerDark = Color(0xFF37474F);

  static Color primary(LicenseType type, bool isDark) {
    if (type == LicenseType.a1) {
      return isDark ? a1DarkPrimary : a1LightPrimary;
    }
    return isDark ? a2DarkPrimary : a2LightPrimary;
  }

  static Color accent(LicenseType type, bool isDark) {
    if (type == LicenseType.a1) {
      return isDark ? a1DarkAccent : a1LightAccent;
    }
    return isDark ? a2DarkAccent : a2LightAccent;
  }

  static Color background(LicenseType type, bool isDark) {
    if (type == LicenseType.a1) {
      return isDark ? a1DarkBackground : a1LightBackground;
    }
    return isDark ? a2DarkBackground : a2LightBackground;
  }

  static Color surface(LicenseType type, bool isDark) {
    if (type == LicenseType.a1) {
      return isDark ? a1DarkSurface : a1LightSurface;
    }
    return isDark ? a2DarkSurface : a2LightSurface;
  }

  static Color text(LicenseType type, bool isDark) {
    if (type == LicenseType.a1) {
      return isDark ? a1DarkText : a1LightText;
    }
    return isDark ? a2DarkText : a2LightText;
  }

  static Color primaryWithOpacity(
    LicenseType type,
    bool isDark,
    double opacity,
  ) {
    return primary(type, isDark).withValues(alpha: opacity);
  }

  static Color accentWithOpacity(
    LicenseType type,
    bool isDark,
    double opacity,
  ) {
    return accent(type, isDark).withValues(alpha: opacity);
  }

  static Color dividerColor(bool isDark) {
    return isDark ? dividerDark : divider;
  }

  static Color correctColor(bool isDark) {
    return isDark ? Color(0xFF66BB6A) : correct;
  }

  static Color wrongColor(bool isDark) {
    return isDark ? Color(0xFFEF5350) : wrong;
  }

  static Color bookmarkColor(bool isDark) {
    return isDark ? Color(0xFFE8D26F) : bookmark;
  }
}
