import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../utils/theme_config.dart';
import '../utils/app_colors.dart';

enum ThemeModeOption {
  light,
  dark,
  system,
}

extension ThemeModeExtension on ThemeModeOption {
  String get displayName {
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
  bool _isDark = false;

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
  bool get isDark => _isDark;

  Color get primaryColor => AppColors.primary(_selectedLicense, false);

  Color get accentColor => AppColors.accent(_selectedLicense, false);

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

  ThemeData get lightTheme => ThemeConfig.lightTheme(_selectedLicense);

  ThemeData get darkTheme => ThemeConfig.darkTheme(_selectedLicense);

  Brightness resolveBrightness(BuildContext context) {
    if (_themeMode == ThemeModeOption.system) {
      return MediaQuery.platformBrightnessOf(context);
    }
    return _themeMode == ThemeModeOption.dark ? Brightness.dark : Brightness.light;
  }

  bool isDarkMode(BuildContext context) {
    return resolveBrightness(context) == Brightness.dark;
  }

  Future<void> initialize(BuildContext context) async {
    final initialBrightness = resolveBrightness(context);

    final prefs = await SharedPreferences.getInstance();

    final licenseStr = prefs.getString(_keyLicense) ?? 'A1';
    _selectedLicense = licenseStr == 'A2' ? LicenseType.a2 : LicenseType.a1;

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

    _autoAdvance = prefs.getBool(_keyAutoAdvance) ?? false;
    _showExplanation = prefs.getBool(_keyShowExplanation) ?? true;
    _gradeImmediately = prefs.getBool(_keyGradeImmediately) ?? true;

    _questionsStudiedToday = prefs.getInt(_keyQuestionsToday) ?? 0;
    _streakDays = prefs.getInt(_keyStreakDays) ?? 0;

    final lastStudyDate = prefs.getString(_keyLastStudyDate);
    final today = DateTime.now();
    if (lastStudyDate != null) {
      final lastDate = DateTime.parse(lastStudyDate);
      final diff = today.difference(lastDate).inDays;
      if (diff > 1) {
        _streakDays = 0;
        _questionsStudiedToday = 0;
      } else if (diff == 1) {
        _questionsStudiedToday = 0;
      }
    }

    _isDark = initialBrightness == Brightness.dark;

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

  void updateDarkModeState(BuildContext context) {
    final wasDark = _isDark;
    _isDark = resolveBrightness(context) == Brightness.dark;
    if (wasDark != _isDark) {
      notifyListeners();
    }
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
