import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/models.dart';

class ExamPersistenceService {
  static final ExamPersistenceService _instance =
      ExamPersistenceService._internal();
  factory ExamPersistenceService() => _instance;
  ExamPersistenceService._internal();

  static const _allAttemptsKey = 'exam_attempt_history_all';

  final Map<String, List<ExamAttemptRecord>> _examAttempts = {};
  final List<ExamAttemptRecord> _allAttempts = [];

  String _attemptsKey(LicenseType type, int examId) {
    return 'attempts_${type.name}_$examId';
  }

  Future<void> initialize(LicenseType type) async {
    final prefs = await SharedPreferences.getInstance();
    _initializeWithPreferences(type, prefs);
  }

  void _initializeWithPreferences(LicenseType type, SharedPreferences prefs) {

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

  Future<void> initializeAll() async {
    _allAttempts.clear();
    final prefs = await SharedPreferences.getInstance();
    for (final type in LicenseType.values) {
      _initializeWithPreferences(type, prefs);
    }
    final attemptsStr = prefs.getString(_allAttemptsKey);
    if (attemptsStr == null) return;

    try {
      final List<dynamic> jsonList = jsonDecode(attemptsStr);
      _allAttempts.addAll(
        jsonList.map(
          (e) => ExamAttemptRecord.fromJson(e as Map<String, dynamic>),
        ),
      );
    } catch (_) {
      _allAttempts.clear();
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
    _allAttempts.add(attempt);

    final prefs = await SharedPreferences.getInstance();
    final jsonList = _examAttempts[key]!.map((a) => a.toJson()).toList();
    await prefs.setString(key, jsonEncode(jsonList));
    await prefs.setString(
      _allAttemptsKey,
      jsonEncode(_allAttempts.map((a) => a.toJson()).toList()),
    );
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

  List<ExamAttemptRecord> getAllAttempts() {
    final attempts = List<ExamAttemptRecord>.from(_allAttempts);
    attempts.sort((a, b) => b.date.compareTo(a.date));
    return attempts;
  }

  Future<void> clearAllAttempts() async {
    _examAttempts.clear();
    _allAttempts.clear();
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs
        .getKeys()
        .where((key) => key.startsWith('attempts_'))
        .toList();
    for (final key in keys) {
      await prefs.remove(key);
    }
    await prefs.remove(_allAttemptsKey);
  }
}

class ExamAttemptRecord {
  final DateTime date;
  final int? examId;
  final String? examName;
  final int totalQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final int unansweredQuestions;
  final bool passed;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final int? durationSeconds;
  final List<ExamAttemptQuestionRecord> questionDetails;

  ExamAttemptRecord({
    required this.date,
    this.examId,
    this.examName,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.unansweredQuestions,
    required this.passed,
    this.startedAt,
    this.completedAt,
    this.durationSeconds,
    this.questionDetails = const [],
  });

  int get score => correctAnswers;

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'examId': examId,
    'examName': examName,
    'totalQuestions': totalQuestions,
    'correctAnswers': correctAnswers,
    'wrongAnswers': wrongAnswers,
    'unansweredQuestions': unansweredQuestions,
    'passed': passed,
    'startedAt': startedAt?.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
    'durationSeconds': durationSeconds,
    'questionDetails': questionDetails.map((q) => q.toJson()).toList(),
  };

  factory ExamAttemptRecord.fromJson(Map<String, dynamic> json) =>
      ExamAttemptRecord(
        date: DateTime.parse(json['date'] as String),
        examId: json['examId'] as int?,
        examName: json['examName'] as String?,
        totalQuestions: json['totalQuestions'] as int,
        correctAnswers: json['correctAnswers'] as int,
        wrongAnswers: json['wrongAnswers'] as int,
        unansweredQuestions: json['unansweredQuestions'] as int,
        passed: json['passed'] as bool,
        startedAt: json['startedAt'] == null
            ? null
            : DateTime.parse(json['startedAt'] as String),
        completedAt: json['completedAt'] == null
            ? null
            : DateTime.parse(json['completedAt'] as String),
        durationSeconds: json['durationSeconds'] as int?,
        questionDetails: (json['questionDetails'] as List<dynamic>? ?? [])
            .map(
              (e) =>
                  ExamAttemptQuestionRecord.fromJson(e as Map<String, dynamic>),
            )
            .toList(growable: false),
      );
}

class ExamAttemptQuestionRecord {
  final int questionId;
  final String content;
  final int selectedAnswerIndex;
  final int correctAnswerIndex;
  final String? selectedAnswer;
  final String correctAnswer;
  final bool isCorrect;
  final bool isImportant;

  ExamAttemptQuestionRecord({
    required this.questionId,
    required this.content,
    required this.selectedAnswerIndex,
    required this.correctAnswerIndex,
    required this.selectedAnswer,
    required this.correctAnswer,
    required this.isCorrect,
    required this.isImportant,
  });

  factory ExamAttemptQuestionRecord.fromQuestion(Question question) {
    final selectedIndex = question.selectedAnswerIndex;
    return ExamAttemptQuestionRecord(
      questionId: question.id,
      content: question.content,
      selectedAnswerIndex: selectedIndex,
      correctAnswerIndex: question.correctAnswer,
      selectedAnswer:
          selectedIndex >= 0 && selectedIndex < question.answers.length
          ? question.answers[selectedIndex]
          : null,
      correctAnswer: question.answers[question.correctAnswer],
      isCorrect: question.isEvaluated && question.isCorrect,
      isImportant: question.isImportant,
    );
  }

  Map<String, dynamic> toJson() => {
    'questionId': questionId,
    'content': content,
    'selectedAnswerIndex': selectedAnswerIndex,
    'correctAnswerIndex': correctAnswerIndex,
    'selectedAnswer': selectedAnswer,
    'correctAnswer': correctAnswer,
    'isCorrect': isCorrect,
    'isImportant': isImportant,
  };

  factory ExamAttemptQuestionRecord.fromJson(Map<String, dynamic> json) =>
      ExamAttemptQuestionRecord(
        questionId: json['questionId'] as int,
        content: json['content'] as String,
        selectedAnswerIndex: json['selectedAnswerIndex'] as int,
        correctAnswerIndex: json['correctAnswerIndex'] as int,
        selectedAnswer: json['selectedAnswer'] as String?,
        correctAnswer: json['correctAnswer'] as String,
        isCorrect: json['isCorrect'] as bool,
        isImportant: json['isImportant'] as bool? ?? false,
      );
}
