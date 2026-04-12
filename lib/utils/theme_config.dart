import 'package:flutter/material.dart';
import '../models/license_type.dart';
import 'app_colors.dart';

/// Generates consistent ThemeData based on license type and brightness.
/// All theme generation is centralized here.
class ThemeConfig {
  ThemeConfig._();

  /// Generate the full ThemeData for the given license type and dark mode.
  static ThemeData generate(LicenseType type, bool isDark) {
    final primary = AppColors.primary(type, isDark);
    final accent = AppColors.accent(type, isDark);
    final background = AppColors.background(type, isDark);
    final surface = AppColors.surface(type, isDark);
    final text = AppColors.text(type, isDark);

    final brightness = isDark ? Brightness.dark : Brightness.light;

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primary,
        onPrimary: isDark ? Colors.white : Colors.white,
        secondary: accent,
        onSecondary: isDark ? Colors.black : Colors.white,
        surface: surface,
        onSurface: text,
        error: AppColors.wrongColor(isDark),
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
        backgroundColor: primary,
        foregroundColor: isDark ? Colors.white : Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: primary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.dividerColor(isDark)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.dividerColor(isDark)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        filled: true,
        fillColor: surface,
        hintStyle: TextStyle(color: text.withValues(alpha: 0.5)),
        labelStyle: TextStyle(color: text),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        color: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: surface,
        contentTextStyle: TextStyle(color: text),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surface,
        selectedColor: accent.withValues(alpha: 0.3),
        labelStyle: TextStyle(color: text),
        secondaryLabelStyle: TextStyle(color: text),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.dividerColor(isDark),
        thickness: 1,
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(color: text, fontSize: 32, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(color: text, fontSize: 28, fontWeight: FontWeight.bold),
        displaySmall: TextStyle(color: text, fontSize: 24, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: text, fontSize: 20, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(color: text, fontSize: 18, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(color: text, fontSize: 16, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: text, fontSize: 16),
        bodyMedium: TextStyle(color: text, fontSize: 14),
        bodySmall: TextStyle(color: text.withValues(alpha: 0.7), fontSize: 12),
        labelLarge: TextStyle(color: text, fontSize: 14, fontWeight: FontWeight.w600),
        labelMedium: TextStyle(color: text, fontSize: 12, fontWeight: FontWeight.w600),
        labelSmall: TextStyle(color: text.withValues(alpha: 0.7), fontSize: 10),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: text,
        textColor: text,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return isDark ? Colors.grey[600] : Colors.grey[400];
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary.withValues(alpha: 0.5);
          return isDark ? Colors.grey[800] : Colors.grey[300];
        }),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: AppColors.dividerColor(isDark),
      ),
    );
  }

  /// Generate light theme for the given license type.
  static ThemeData lightTheme(LicenseType type) => generate(type, false);

  /// Generate dark theme for the given license type.
  static ThemeData darkTheme(LicenseType type) => generate(type, true);
}
