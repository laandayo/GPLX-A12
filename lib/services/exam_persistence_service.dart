import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/models.dart';

class ExamPersistenceService {
  static final ExamPersistenceService _instance = ExamPersistenceService._internal();
  factory ExamPersistenceService() => _instance;
  ExamPersistenceService._internal();

  final Map<String, List<ExamAttemptRecord>> _examAttempts = {};

  String _attemptsKey(LicenseType type, int examId) {
    return 'attempts_${type.name}_$examId';
  }

  Future<void> initialize(LicenseType type) async {
    final prefs = await SharedPreferences.getInstance();

    for (var examId = 1; examId <= 100; examId++) {
      final key = _attemptsKey(type, examId);
      final attemptsStr = prefs.getString(key);
      if (attemptsStr != null) {
        try {
          final List<dynamic> jsonList = jsonDecode(attemptsStr);
          _examAttempts[key] = jsonList
              .map((e) => ExamAttemptRecord.fromJson(e as Map<String, dynamic>))
              .toList();
        } catch (e) {
          _examAttempts[key] = [];
        }
      } else {
        _examAttempts[key] = [];
      }
    }
  }

  Future<void> saveExamAttempt(
    LicenseType type,
    int examId,
    ExamAttemptRecord attempt,
  ) async {
    final key = _attemptsKey(type, examId);
    if (!_examAttempts.containsKey(key)) {
      _examAttempts[key] = [];
    }
    _examAttempts[key]!.add(attempt);

    final prefs = await SharedPreferences.getInstance();
    final jsonList = _examAttempts[key]!.map((a) => a.toJson()).toList();
    await prefs.setString(key, jsonEncode(jsonList));
  }

  List<ExamAttemptRecord> getExamAttempts(LicenseType type, int examId) {
    final key = _attemptsKey(type, examId);
    return _examAttempts[key] ?? [];
  }

  int getAttemptCount(LicenseType type, int examId) {
    return getExamAttempts(type, examId).length;
  }

  int? getBestScore(LicenseType type, int examId) {
    final attempts = getExamAttempts(type, examId);
    if (attempts.isEmpty) return null;

    int best = 0;
    for (var attempt in attempts) {
      if (attempt.correctAnswers > best) {
        best = attempt.correctAnswers;
      }
    }
    return best;
  }

  bool hasAttemptedExam(LicenseType type, int examId) {
    return getExamAttempts(type, examId).isNotEmpty;
  }
}

class ExamAttemptRecord {
  final DateTime date;
  final int totalQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final int unansweredQuestions;
  final bool passed;

  ExamAttemptRecord({
    required this.date,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.unansweredQuestions,
    required this.passed,
  });

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'totalQuestions': totalQuestions,
        'correctAnswers': correctAnswers,
        'wrongAnswers': wrongAnswers,
        'unansweredQuestions': unansweredQuestions,
        'passed': passed,
      };

  factory ExamAttemptRecord.fromJson(Map<String, dynamic> json) =>
      ExamAttemptRecord(
        date: DateTime.parse(json['date'] as String),
        totalQuestions: json['totalQuestions'] as int,
        correctAnswers: json['correctAnswers'] as int,
        wrongAnswers: json['wrongAnswers'] as int,
        unansweredQuestions: json['unansweredQuestions'] as int,
        passed: json['passed'] as bool,
      );
}
