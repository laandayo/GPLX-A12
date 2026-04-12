import 'package:flutter/material.dart';
import '../models/models.dart';

class AppProvider with ChangeNotifier {
  LicenseType _selectedLicense = LicenseType.a1;
  int _questionsStudiedToday = 0;
  int _streakDays = 0;

  LicenseType get selectedLicense => _selectedLicense;

  int get questionsStudiedToday => _questionsStudiedToday;

  int get streakDays => _streakDays;

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

  ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: primaryColor,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

  void switchLicenseType(LicenseType type) {
    _selectedLicense = type;
    notifyListeners();
  }

  void incrementQuestionsStudied() {
    _questionsStudiedToday++;
    notifyListeners();
  }

  void resetDailyCount() {
    _questionsStudiedToday = 0;
    notifyListeners();
  }

  void updateStreak(int days) {
    _streakDays = days;
    notifyListeners();
  }
}
