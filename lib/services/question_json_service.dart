import 'dart:convert';
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

  bool get isInitialized => _initialized;

  Future<void> initialize() async {
    if (_initialized) return;

    for (var type in LicenseType.values) {
      await _loadDataForType(type);
    }

    _initialized = true;
    if (kDebugMode) {
      for (var type in LicenseType.values) {
        debugPrint(
            '[QuestionJsonService] ${type.name}: ${_questions[type]?.length ?? 0} questions, '
            '${_chapters[type]?.length ?? 0} chapters, ${_exams[type]?.length ?? 0} exams');
      }
    }
  }

  Future<void> _loadDataForType(LicenseType type) async {
    final fileName = type == LicenseType.a1
        ? 'assets/questions/questions_a1.json'
        : 'assets/questions/questions_a2.json';

    try {
      if (kDebugMode) {
        debugPrint('[QuestionJsonService] Loading $fileName...');
      }
      final jsonString = await rootBundle.loadString(fileName);
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      // Load chapters
      final chaptersJson = data['chapters'] as List;
      _chapters[type] = chaptersJson
          .map((c) => Chapter.fromJson(c as Map<String, dynamic>))
          .toList();

      if (kDebugMode) {
        debugPrint('[QuestionJsonService] Loaded ${_chapters[type]!.length} chapters');
      }

      // Load questions
      final questionsJson = data['questions'] as List;
      _questions[type] = questionsJson
          .map((q) => Question.fromJsonSimple(q as Map<String, dynamic>))
          .toList();

      if (kDebugMode) {
        debugPrint('[QuestionJsonService] Loaded ${_questions[type]!.length} questions');
      }

      // Load persisted question states
      await QuestionStatePersistence().loadAllQuestionStates(type, _questions[type]!);

      // Load exams
      final examsJson = data['exams'] as List;
      final licenseStr = type == LicenseType.a1 ? 'A1' : 'A2';
      _exams[type] = examsJson
          .map((e) => Exam.fromJson(e as Map<String, dynamic>, licenseStr))
          .toList();

      if (kDebugMode) {
        debugPrint('[QuestionJsonService] Loaded ${_exams[type]!.length} exams');
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

    final totalCorrect = questions.fold<int>(0, (sum, q) => sum + q.correctCount);
    return totalCorrect / totalAttempts;
  }

  /// Search questions by text content (not ID).
  List<Question> searchQuestions(LicenseType type, String query) {
    if (query.trim().isEmpty) return [];
    final lowerQuery = query.toLowerCase().trim();
    final questions = _questions[type] ?? [];
    return questions
        .where((q) => q.content.toLowerCase().contains(lowerQuery))
        .toList();
  }
}
