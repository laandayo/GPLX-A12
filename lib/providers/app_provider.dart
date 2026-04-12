import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

enum ThemeModeOption {
  light,
  dark,
  system,
}

extension ThemeModeExtension on ThemeModeOption {
  String get name {
    switch (this) {
      case ThemeModeOption.light:
        return 'Sáng';
      case ThemeModeOption.dark:
        return 'Tối';
      case ThemeModeOption.system:
        return 'Theo hệ thống';
    }
  }

  IconData get icon {
    switch (this) {
      case ThemeModeOption.light:
        return Icons.light_mode;
      case ThemeModeOption.dark:
        return Icons.dark_mode;
      case ThemeModeOption.system:
        return Icons.brightness_auto;
    }
  }
}

class AppProvider with ChangeNotifier {
  LicenseType _selectedLicense = LicenseType.a1;
  int _questionsStudiedToday = 0;
  int _streakDays = 0;
  ThemeModeOption _themeMode = ThemeModeOption.system;
  bool _autoAdvance = false;
  bool _showExplanation = true;
  bool _gradeImmediately = true;

  // SharedPreferences keys
  static const _keyLicense = 'license_type';
  static const _keyTheme = 'theme_mode';
  static const _keyAutoAdvance = 'auto_advance';
  static const _keyShowExplanation = 'show_explanation';
  static const _keyGradeImmediately = 'grade_immediately';
  static const _keyQuestionsToday = 'questions_today';
  static const _keyStreakDays = 'streak_days';
  static const _keyLastStudyDate = 'last_study_date';

  LicenseType get selectedLicense => _selectedLicense;
  int get questionsStudiedToday => _questionsStudiedToday;
  int get streakDays => _streakDays;
  ThemeModeOption get themeMode => _themeMode;
  bool get autoAdvance => _autoAdvance;
  bool get showExplanation => _showExplanation;
  bool get gradeImmediately => _gradeImmediately;

  Color get primaryColor {
    return _selectedLicense == LicenseType.a1
        ? const Color(0xFF2196F3)
        : const Color(0xFF4CAF50);
  }

  Color get primaryColorLight {
    return _selectedLicense == LicenseType.a1
        ? const Color(0xFFBBDEFB)
        : const Color(0xFFC8E6C9);
  }

  Color get primaryColorDark {
    return _selectedLicense == LicenseType.a1
        ? const Color(0xFF1976D2)
        : const Color(0xFF388E3C);
  }

  ThemeMode get flutterThemeMode {
    switch (_themeMode) {
      case ThemeModeOption.light:
        return ThemeMode.light;
      case ThemeModeOption.dark:
        return ThemeMode.dark;
      case ThemeModeOption.system:
        return ThemeMode.system;
    }
  }

  ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

  ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();

    // Load license type
    final licenseStr = prefs.getString(_keyLicense) ?? 'A1';
    _selectedLicense =
        licenseStr == 'A2' ? LicenseType.a2 : LicenseType.a1;

    // Load theme mode
    final themeStr = prefs.getString(_keyTheme) ?? 'system';
    switch (themeStr) {
      case 'light':
        _themeMode = ThemeModeOption.light;
        break;
      case 'dark':
        _themeMode = ThemeModeOption.dark;
        break;
      default:
        _themeMode = ThemeModeOption.system;
    }

    // Load settings
    _autoAdvance = prefs.getBool(_keyAutoAdvance) ?? false;
    _showExplanation = prefs.getBool(_keyShowExplanation) ?? true;
    _gradeImmediately = prefs.getBool(_keyGradeImmediately) ?? true;

    // Load study stats
    _questionsStudiedToday = prefs.getInt(_keyQuestionsToday) ?? 0;
    _streakDays = prefs.getInt(_keyStreakDays) ?? 0;

    // Check if we need to reset daily count
    final lastStudyDate = prefs.getString(_keyLastStudyDate);
    final today = DateTime.now();
    if (lastStudyDate != null) {
      final lastDate = DateTime.parse(lastStudyDate);
      final diff = today.difference(lastDate).inDays;
      if (diff > 1) {
        // Streak broken
        _streakDays = 0;
        _questionsStudiedToday = 0;
      } else if (diff == 1) {
        // New day, reset count but keep streak
        _questionsStudiedToday = 0;
      }
    }

    notifyListeners();
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _keyLicense, _selectedLicense == LicenseType.a2 ? 'A2' : 'A1');
    await prefs.setString(_keyTheme, _themeMode.name.toLowerCase());
    await prefs.setBool(_keyAutoAdvance, _autoAdvance);
    await prefs.setBool(_keyShowExplanation, _showExplanation);
    await prefs.setBool(_keyGradeImmediately, _gradeImmediately);
    await prefs.setInt(_keyQuestionsToday, _questionsStudiedToday);
    await prefs.setInt(_keyStreakDays, _streakDays);
    await prefs.setString(_keyLastStudyDate, DateTime.now().toIso8601String());
  }

  Future<void> switchLicenseType(LicenseType type) async {
    _selectedLicense = type;
    await _savePrefs();
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeModeOption mode) async {
    _themeMode = mode;
    await _savePrefs();
    notifyListeners();
  }

  Future<void> toggleAutoAdvance() async {
    _autoAdvance = !_autoAdvance;
    await _savePrefs();
    notifyListeners();
  }

  Future<void> setShowExplanation(bool value) async {
    _showExplanation = value;
    await _savePrefs();
    notifyListeners();
  }

  Future<void> setGradeImmediately(bool value) async {
    _gradeImmediately = value;
    await _savePrefs();
    notifyListeners();
  }

  Future<void> incrementQuestionsStudied() async {
    _questionsStudiedToday++;
    await _savePrefs();
    notifyListeners();
  }

  Future<void> updateStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final lastStudyDate = prefs.getString(_keyLastStudyDate);
    final today = DateTime.now();

    if (lastStudyDate != null) {
      final lastDate = DateTime.parse(lastStudyDate);
      final diff = today.difference(lastDate).inDays;
      if (diff == 1) {
        _streakDays++;
      } else if (diff > 1) {
        _streakDays = 1;
      }
    } else {
      _streakDays = 1;
    }

    await _savePrefs();
    notifyListeners();
  }
}
