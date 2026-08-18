import 'package:flutter/material.dart';
import '../models/license_type.dart';

enum AppThemePalette {
  blue,
  green,
  teal,
  purple,
  amber,
  rose,
  indigo,
  cyan,
  coral,
  ruby,
  coffee,
  graphite,
}

extension AppThemePaletteExtension on AppThemePalette {
  String get displayName {
    switch (this) {
      case AppThemePalette.blue:
        return 'Xanh biển';
      case AppThemePalette.green:
        return 'Xanh lá';
      case AppThemePalette.teal:
        return 'Xanh ngọc';
      case AppThemePalette.purple:
        return 'Tím';
      case AppThemePalette.amber:
        return 'Vàng cam';
      case AppThemePalette.rose:
        return 'Hồng đỏ';
      case AppThemePalette.indigo:
        return 'Xanh chàm';
      case AppThemePalette.cyan:
        return 'Xanh cyan';
      case AppThemePalette.coral:
        return 'Cam san hô';
      case AppThemePalette.ruby:
        return 'Đỏ ruby';
      case AppThemePalette.coffee:
        return 'Nâu cà phê';
      case AppThemePalette.graphite:
        return 'Xám graphite';
    }
  }

  IconData get icon {
    switch (this) {
      case AppThemePalette.blue:
        return Icons.water_drop;
      case AppThemePalette.green:
        return Icons.eco;
      case AppThemePalette.teal:
        return Icons.spa;
      case AppThemePalette.purple:
        return Icons.auto_awesome;
      case AppThemePalette.amber:
        return Icons.wb_sunny;
      case AppThemePalette.rose:
        return Icons.favorite;
      case AppThemePalette.indigo:
        return Icons.nights_stay_outlined;
      case AppThemePalette.cyan:
        return Icons.waves_rounded;
      case AppThemePalette.coral:
        return Icons.local_fire_department_outlined;
      case AppThemePalette.ruby:
        return Icons.diamond_outlined;
      case AppThemePalette.coffee:
        return Icons.coffee_outlined;
      case AppThemePalette.graphite:
        return Icons.contrast_rounded;
    }
  }
}

class AppColors {
  AppColors._();

  static AppThemePalette activePalette = AppThemePalette.blue;

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
    switch (activePalette) {
      case AppThemePalette.blue:
        return isDark ? a1DarkPrimary : a1LightPrimary;
      case AppThemePalette.green:
        return isDark ? a2DarkPrimary : a2LightPrimary;
      case AppThemePalette.teal:
        return isDark ? const Color(0xFF26A69A) : const Color(0xFF00897B);
      case AppThemePalette.purple:
        return isDark ? const Color(0xFF7E57C2) : const Color(0xFF5E35B1);
      case AppThemePalette.amber:
        return isDark ? const Color(0xFFFFB74D) : const Color(0xFFF57C00);
      case AppThemePalette.rose:
        return isDark ? const Color(0xFFF06292) : const Color(0xFFC2185B);
      case AppThemePalette.indigo:
        return isDark ? const Color(0xFF7986CB) : const Color(0xFF3949AB);
      case AppThemePalette.cyan:
        return isDark ? const Color(0xFF26C6DA) : const Color(0xFF00838F);
      case AppThemePalette.coral:
        return isDark ? const Color(0xFFFF8A65) : const Color(0xFFE64A19);
      case AppThemePalette.ruby:
        return isDark ? const Color(0xFFEF6C75) : const Color(0xFFB71C35);
      case AppThemePalette.coffee:
        return isDark ? const Color(0xFFBCAAA4) : const Color(0xFF795548);
      case AppThemePalette.graphite:
        return isDark ? const Color(0xFF90A4AE) : const Color(0xFF455A64);
    }
  }

  static Color accent(LicenseType type, bool isDark) {
    switch (activePalette) {
      case AppThemePalette.blue:
        return isDark ? a1DarkAccent : a1LightAccent;
      case AppThemePalette.green:
        return isDark ? a2DarkAccent : a2LightAccent;
      case AppThemePalette.teal:
        return isDark ? const Color(0xFF80CBC4) : const Color(0xFF4DB6AC);
      case AppThemePalette.purple:
        return isDark ? const Color(0xFFB39DDB) : const Color(0xFF7E57C2);
      case AppThemePalette.amber:
        return isDark ? const Color(0xFFFFCC80) : const Color(0xFFFFA726);
      case AppThemePalette.rose:
        return isDark ? const Color(0xFFF8BBD0) : const Color(0xFFEC407A);
      case AppThemePalette.indigo:
        return isDark ? const Color(0xFFC5CAE9) : const Color(0xFF5C6BC0);
      case AppThemePalette.cyan:
        return isDark ? const Color(0xFF80DEEA) : const Color(0xFF00ACC1);
      case AppThemePalette.coral:
        return isDark ? const Color(0xFFFFCCBC) : const Color(0xFFFF7043);
      case AppThemePalette.ruby:
        return isDark ? const Color(0xFFFFCDD2) : const Color(0xFFD32F4B);
      case AppThemePalette.coffee:
        return isDark ? const Color(0xFFD7CCC8) : const Color(0xFFA1887F);
      case AppThemePalette.graphite:
        return isDark ? const Color(0xFFCFD8DC) : const Color(0xFF607D8B);
    }
  }

  static Color background(LicenseType type, bool isDark) {
    switch (activePalette) {
      case AppThemePalette.blue:
        return isDark ? a1DarkBackground : a1LightBackground;
      case AppThemePalette.green:
        return isDark ? a2DarkBackground : a2LightBackground;
      case AppThemePalette.teal:
        return isDark ? const Color(0xFF071716) : const Color(0xFFF2FBFA);
      case AppThemePalette.purple:
        return isDark ? const Color(0xFF11101A) : const Color(0xFFF8F5FF);
      case AppThemePalette.amber:
        return isDark ? const Color(0xFF18130A) : const Color(0xFFFFFAF0);
      case AppThemePalette.rose:
        return isDark ? const Color(0xFF190E14) : const Color(0xFFFFF5F8);
      case AppThemePalette.indigo:
        return isDark ? const Color(0xFF0D1020) : const Color(0xFFF5F6FF);
      case AppThemePalette.cyan:
        return isDark ? const Color(0xFF07171A) : const Color(0xFFF1FBFC);
      case AppThemePalette.coral:
        return isDark ? const Color(0xFF1A0E09) : const Color(0xFFFFF6F2);
      case AppThemePalette.ruby:
        return isDark ? const Color(0xFF190B10) : const Color(0xFFFFF5F6);
      case AppThemePalette.coffee:
        return isDark ? const Color(0xFF15100E) : const Color(0xFFFAF7F5);
      case AppThemePalette.graphite:
        return isDark ? const Color(0xFF0D1215) : const Color(0xFFF5F7F8);
    }
  }

  static Color surface(LicenseType type, bool isDark) {
    if (!isDark) {
      return Colors.white;
    }
    switch (activePalette) {
      case AppThemePalette.blue:
        return a1DarkSurface;
      case AppThemePalette.green:
        return a2DarkSurface;
      case AppThemePalette.teal:
        return const Color(0xFF102522);
      case AppThemePalette.purple:
        return const Color(0xFF1B1728);
      case AppThemePalette.amber:
        return const Color(0xFF241B10);
      case AppThemePalette.rose:
        return const Color(0xFF281720);
      case AppThemePalette.indigo:
        return const Color(0xFF181C31);
      case AppThemePalette.cyan:
        return const Color(0xFF102429);
      case AppThemePalette.coral:
        return const Color(0xFF281812);
      case AppThemePalette.ruby:
        return const Color(0xFF29151A);
      case AppThemePalette.coffee:
        return const Color(0xFF241B18);
      case AppThemePalette.graphite:
        return const Color(0xFF182126);
    }
  }

  static Color text(LicenseType type, bool isDark) {
    if (!isDark) {
      return const Color(0xFF101828);
    }
    switch (activePalette) {
      case AppThemePalette.blue:
        return a1DarkText;
      case AppThemePalette.green:
        return a2DarkText;
      case AppThemePalette.teal:
        return const Color(0xFFE0F2F1);
      case AppThemePalette.purple:
        return const Color(0xFFF1EBFF);
      case AppThemePalette.amber:
        return const Color(0xFFFFF3E0);
      case AppThemePalette.rose:
        return const Color(0xFFFFEEF4);
      case AppThemePalette.indigo:
        return const Color(0xFFF0F1FF);
      case AppThemePalette.cyan:
        return const Color(0xFFE4F9FC);
      case AppThemePalette.coral:
        return const Color(0xFFFFF0EB);
      case AppThemePalette.ruby:
        return const Color(0xFFFFEEF1);
      case AppThemePalette.coffee:
        return const Color(0xFFF5ECE8);
      case AppThemePalette.graphite:
        return const Color(0xFFECEFF1);
    }
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
