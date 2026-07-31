import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/models.dart';
import 'question_state_persistence.dart';

class QuestionJsonService {
  static final QuestionJsonService _instance = QuestionJsonService._internal();
  factory QuestionJsonService() => _instance;
  QuestionJsonService._internal();

  final Map<LicenseType, List<Question>> _questions = {};
  final Map<LicenseType, List<Chapter>> _chapters = {};
  final Map<LicenseType, List<Exam>> _exams = {};
  bool _initialized = false;
  Future<void>? _initializationFuture;

  bool get isInitialized => _initialized;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    final inFlight = _initializationFuture;
    if (inFlight != null) {
      await inFlight;
      return;
    }

    final future = _initializeInternal();
    _initializationFuture = future;
    await future;
  }

  Future<void> _initializeInternal() async {
    try {
      await _loadDataForType(LicenseType.a1);
      _questions[LicenseType.a2] = _questions[LicenseType.a1]!;
      _chapters[LicenseType.a2] = _chapters[LicenseType.a1]!;
      _exams[LicenseType.a2] = _exams[LicenseType.a1]!;

      _initialized = true;
      if (kDebugMode) {
        for (var type in LicenseType.values) {
          debugPrint(
            '[QuestionJsonService] ${type.name}: ${_questions[type]?.length ?? 0} questions, '
            '${_chapters[type]?.length ?? 0} chapters, ${_exams[type]?.length ?? 0} exams',
          );
        }
      }
    } finally {
      _initializationFuture = null;
    }
  }

  Future<void> _loadDataForType(LicenseType type) async {
    const fileName = 'assets/questions/questions_a1.json';

    try {
      if (kDebugMode) {
        debugPrint('[QuestionJsonService] Loading $fileName...');
      }
      final jsonString = await rootBundle.loadString(fileName);
      final data = await compute(_decodeQuestionAsset, jsonString);

      final chaptersJson = data['chapters'] as List;
      _chapters[type] = chaptersJson
          .map((c) => Chapter.fromJson(c as Map<String, dynamic>))
          .toList();

      if (kDebugMode) {
        debugPrint(
          '[QuestionJsonService] Loaded ${_chapters[type]!.length} chapters',
        );
      }

      final questionsJson = data['questions'] as List;
      _questions[type] = questionsJson
          .map((q) => Question.fromJsonSimple(q as Map<String, dynamic>))
          .toList();

      if (kDebugMode) {
        debugPrint(
          '[QuestionJsonService] Loaded ${_questions[type]!.length} questions',
        );
      }

      await QuestionStatePersistence().loadAllQuestionStates(
        type,
        _questions[type]!,
      );

      final examsJson = data['exams'] as List;
      final licenseStr = type == LicenseType.a1 ? 'A1' : 'A2';
      _exams[type] = examsJson
          .map((e) => Exam.fromJson(e as Map<String, dynamic>, licenseStr))
          .toList();

      if (kDebugMode) {
        debugPrint(
          '[QuestionJsonService] Loaded ${_exams[type]!.length} exams',
        );
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('[QuestionJsonService] ERROR loading $fileName: $e');
        debugPrint('[QuestionJsonService] Stack: $stackTrace');
      }
      _questions[type] = [];
      _chapters[type] = [];
      _exams[type] = [];
    }
  }

  List<Question> getQuestions(LicenseType type) {
    return _questions[type] ?? [];
  }

  List<Chapter> getChapters(LicenseType type) {
    return _chapters[type] ?? [];
  }

  List<Exam> getExams(LicenseType type) {
    return _exams[type] ?? [];
  }

  Question? getQuestionById(LicenseType type, int id) {
    final questions = _questions[type] ?? [];
    try {
      return questions.firstWhere((q) => q.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Question> getQuestionsByChapter(LicenseType type, String chapterName) {
    final questions = _questions[type] ?? [];
    return questions.where((q) => q.chapter == chapterName).toList();
  }

  List<Question> getQuestionsByIds(LicenseType type, List<int> ids) {
    final questions = _questions[type] ?? [];
    return questions.where((q) => ids.contains(q.id)).toList();
  }

  Exam? getExamById(LicenseType type, int examId) {
    final exams = _exams[type] ?? [];
    try {
      return exams.firstWhere((e) => e.id == examId);
    } catch (e) {
      return null;
    }
  }

  List<Question> getWrongQuestions(LicenseType type) {
    final questions = _questions[type] ?? [];
    return questions.where((q) => q.wrongCount >= 2).toList();
  }

  List<Question> getMarkedQuestions(LicenseType type) {
    final questions = _questions[type] ?? [];
    return questions.where((q) => q.isMarked).toList();
  }

  List<Question> getUnansweredQuestions(LicenseType type) {
    final questions = _questions[type] ?? [];
    return questions.where((q) => !q.isAnswered).toList();
  }

  List<Question> getRandomQuestions(LicenseType type, {int count = 10}) {
    final questions = List<Question>.from(_questions[type] ?? []);
    questions.shuffle();
    return questions.take(count).toList();
  }

  List<Question> getShuffledExamQuestions(LicenseType type) {
    final questions = _questions[type] ?? [];
    if (questions.length < 25) return [];

    final random = Random();
    final selected = <Question>[];
    final selectedIds = <int>{};

    final importantQuestions = questions.where((q) => q.isImportant).toList()
      ..shuffle(random);
    final importantTarget = importantQuestions.length >= 2
        ? 1 + random.nextInt(2)
        : 1;

    for (final question in importantQuestions.take(importantTarget)) {
      selected.add(question);
      selectedIds.add(question.id);
    }

    final chapterQuotas = <_QuestionIdRange>[
      const _QuestionIdRange(start: 1, end: 100, count: 9),
      const _QuestionIdRange(start: 101, end: 110, count: 2),
      const _QuestionIdRange(start: 111, end: 125, count: 3),
      const _QuestionIdRange(start: 126, end: 215, count: 8),
      const _QuestionIdRange(start: 216, end: 250, count: 3),
    ];

    for (final quota in chapterQuotas) {
      final alreadyInRange = selected.where((q) => quota.contains(q.id)).length;
      final needed = quota.count - alreadyInRange;
      if (needed <= 0) continue;

      final candidates =
          questions
              .where(
                (q) =>
                    quota.contains(q.id) &&
                    !selectedIds.contains(q.id) &&
                    !q.isImportant,
              )
              .toList()
            ..shuffle(random);
      for (final question in candidates.take(needed)) {
        selected.add(question);
        selectedIds.add(question.id);
      }
    }

    if (selected.length < 25) {
      final remaining =
          questions
              .where((q) => !selectedIds.contains(q.id) && !q.isImportant)
              .toList()
            ..shuffle(random);
      for (final question in remaining.take(25 - selected.length)) {
        selected.add(question);
        selectedIds.add(question.id);
      }
    }

    selected.shuffle(random);
    return selected.take(25).toList(growable: false);
  }

  List<Question> getImportantQuestions(LicenseType type) {
    final questions = _questions[type] ?? [];
    return questions.where((q) => q.isImportant).toList();
  }

  int getTotalQuestions(LicenseType type) {
    return (_questions[type] ?? []).length;
  }

  int getAnsweredCount(LicenseType type) {
    final questions = _questions[type] ?? [];
    return questions.where((q) => q.isAnswered).length;
  }

  double getAccuracyRate(LicenseType type) {
    final questions = _questions[type] ?? [];
    final totalAttempts = questions.fold<int>(
      0,
      (sum, q) => sum + q.correctCount + q.wrongCount,
    );
    if (totalAttempts == 0) return 0.0;

    final totalCorrect = questions.fold<int>(
      0,
      (sum, q) => sum + q.correctCount,
    );
    return totalCorrect / totalAttempts;
  }

  List<Question> searchQuestions(LicenseType type, String query) {
    if (query.trim().isEmpty) return [];
    final lowerQuery = query.toLowerCase().trim();
    final questions = _questions[type] ?? [];
    return questions
        .where((q) => q.content.toLowerCase().contains(lowerQuery))
        .toList();
  }

  void resetAllProgress() {
    for (final questions in _questions.values) {
      for (final question in questions) {
        question.isAnswered = false;
        question.selectedAnswerIndex = -1;
        question.wrongCount = 0;
        question.correctCount = 0;
        question.isMarked = false;
        question.lastAnsweredAt = null;
        question.isEvaluated = false;
      }
    }
  }
}

Map<String, dynamic> _decodeQuestionAsset(String jsonString) {
  return jsonDecode(jsonString) as Map<String, dynamic>;
}

class _QuestionIdRange {
  final int start;
  final int end;
  final int count;

  const _QuestionIdRange({
    required this.start,
    required this.end,
    required this.count,
  });

  bool contains(int id) => id >= start && id <= end;
}
