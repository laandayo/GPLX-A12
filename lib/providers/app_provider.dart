import 'package:flutter/material.dart';
import 'dart:convert';
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
  final Map<String, int> _studyActivity = {};

  static const _keyLicense = 'license_type';
  static const _keyTheme = 'theme_mode';
  static const _keyAutoAdvance = 'auto_advance';
  static const _keyShowExplanation = 'show_explanation';
  static const _keyGradeImmediately = 'grade_immediately';
  static const _keyQuestionsToday = 'questions_today';
  static const _keyStreakDays = 'streak_days';
  static const _keyLastStudyDate = 'last_study_date';
  static const _keyStudyActivity = 'study_activity';

  LicenseType get selectedLicense => _selectedLicense;
  int get questionsStudiedToday => _questionsStudiedToday;
  int get streakDays => _streakDays;
  ThemeModeOption get themeMode => _themeMode;
  bool get autoAdvance => _autoAdvance;
  bool get showExplanation => _showExplanation;
  bool get gradeImmediately => _gradeImmediately;
  bool get isDark => _isDark;
  Map<String, int> get studyActivity => Map.unmodifiable(_studyActivity);

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

    _loadStudyActivity(prefs);
    _questionsStudiedToday = _studyActivity[_dateKey(DateTime.now())] ?? 0;
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

  Future<void> _savePrefs({bool persistStudyTimestamp = false}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _keyLicense, _selectedLicense == LicenseType.a2 ? 'A2' : 'A1');
    await prefs.setString(_keyTheme, _themeMode.name.toLowerCase());
    await prefs.setBool(_keyAutoAdvance, _autoAdvance);
    await prefs.setBool(_keyShowExplanation, _showExplanation);
    await prefs.setBool(_keyGradeImmediately, _gradeImmediately);
    await prefs.setInt(_keyQuestionsToday, _questionsStudiedToday);
    await prefs.setInt(_keyStreakDays, _streakDays);
    await prefs.setString(_keyStudyActivity, jsonEncode(_studyActivity));
    if (persistStudyTimestamp) {
      await prefs.setString(_keyLastStudyDate, DateTime.now().toIso8601String());
    }
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
    notifyListeners();
    await _savePrefs();
  }

  Future<void> setThemeMode(ThemeModeOption mode) async {
    _themeMode = mode;
    notifyListeners();
    await _savePrefs();
  }

  Future<void> toggleAutoAdvance() async {
    _autoAdvance = !_autoAdvance;
    notifyListeners();
    await _savePrefs();
  }

  Future<void> setShowExplanation(bool value) async {
    _showExplanation = value;
    notifyListeners();
    await _savePrefs();
  }

  Future<void> setGradeImmediately(bool value) async {
    _gradeImmediately = value;
    notifyListeners();
    await _savePrefs();
  }

  Future<void> incrementQuestionsStudied() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final todayKey = _dateKey(now);
    final lastStudyDate = prefs.getString(_keyLastStudyDate);

    if (lastStudyDate == null) {
      _streakDays = 1;
    } else {
      final diff = _dateOnly(now).difference(_dateOnly(DateTime.parse(lastStudyDate))).inDays;
      if (diff == 1) {
        _streakDays++;
      } else if (diff > 1) {
        _streakDays = 1;
      } else if (_streakDays == 0) {
        _streakDays = 1;
      }
    }

    _studyActivity[todayKey] = (_studyActivity[todayKey] ?? 0) + 1;
    _questionsStudiedToday = _studyActivity[todayKey]!;
    await _savePrefs(persistStudyTimestamp: true);
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

    await _savePrefs(persistStudyTimestamp: true);
    notifyListeners();
  }

  List<int> getStudyHeatmap({int days = 30}) {
    final now = _dateOnly(DateTime.now());
    final counts = List<int>.generate(days, (index) {
      final day = now.subtract(Duration(days: days - index - 1));
      return _studyActivity[_dateKey(day)] ?? 0;
    });
    final maxCount = counts.fold<int>(0, (max, count) => count > max ? count : max);

    return counts.map((count) {
      if (count == 0) return 0;
      if (maxCount <= 4) return count.clamp(1, 4);
      final normalized = ((count / maxCount) * 4).ceil();
      return normalized.clamp(1, 4);
    }).toList(growable: false);
  }

  Future<void> resetAppData() async {
    _selectedLicense = LicenseType.a1;
    _questionsStudiedToday = 0;
    _streakDays = 0;
    _themeMode = ThemeModeOption.system;
    _autoAdvance = false;
    _showExplanation = true;
    _gradeImmediately = true;
    _studyActivity.clear();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLicense);
    await prefs.remove(_keyTheme);
    await prefs.remove(_keyAutoAdvance);
    await prefs.remove(_keyShowExplanation);
    await prefs.remove(_keyGradeImmediately);
    await prefs.remove(_keyQuestionsToday);
    await prefs.remove(_keyStreakDays);
    await prefs.remove(_keyLastStudyDate);
    await prefs.remove(_keyStudyActivity);

    notifyListeners();
  }

  void _loadStudyActivity(SharedPreferences prefs) {
    _studyActivity.clear();
    final raw = prefs.getString(_keyStudyActivity);
    if (raw == null || raw.isEmpty) {
      return;
    }

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      for (final entry in decoded.entries) {
        final value = entry.value;
        if (value is int) {
          _studyActivity[entry.key] = value;
        }
      }
    } catch (_) {}
  }

  String _dateKey(DateTime date) {
    final normalized = _dateOnly(date);
    final year = normalized.year.toString().padLeft(4, '0');
    final month = normalized.month.toString().padLeft(2, '0');
    final day = normalized.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);
}
