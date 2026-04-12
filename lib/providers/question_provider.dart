import 'package:flutter/material.dart';
import '../models/models.dart';
import '../data/data.dart';
import '../services/question_state_persistence.dart';
import '../services/exam_persistence_service.dart';

enum StudyMode {
  all,
  unanswered,
  wrong,
  marked,
  random,
  important,
  exam,
  practice,
}

enum ScoringMode {
  gradeAfterSubmission,
  gradeImmediately,
}

class QuestionProvider with ChangeNotifier {
  final QuestionRepository _repository = QuestionRepository();

  StudyMode _studyMode = StudyMode.all;
  ScoringMode _scoringMode = ScoringMode.gradeImmediately;
  List<Question> _currentQuestions = [];
  int _currentIndex = 0;
  Exam? _currentExam;
  bool _isExamMode = false;

  // Getters
  StudyMode get studyMode => _studyMode;
  ScoringMode get scoringMode => _scoringMode;
  List<Question> get currentQuestions => _currentQuestions;
  Question? get currentQuestion =>
      _currentQuestions.isEmpty ? null : _currentQuestions[_currentIndex];
  int get currentIndex => _currentIndex;
  int get totalQuestions => _currentQuestions.length;
  bool get hasNext => _currentIndex < _currentQuestions.length - 1;
  bool get hasPrevious => _currentIndex > 0;
  Exam? get currentExam => _currentExam;
  bool get isExamMode => _isExamMode;

  // Progress tracking
  double get progress {
    if (_currentQuestions.isEmpty) return 0.0;
    return (_currentIndex + 1) / _currentQuestions.length;
  }

  int get answeredCount {
    return _currentQuestions.where((q) => q.isAnswered).length;
  }

  int get correctCount {
    return _currentQuestions.where((q) => q.isCorrect).length;
  }

  int get wrongCount {
    return _currentQuestions.where((q) => q.isAnswered && !q.isCorrect).length;
  }

  // Set study mode
  void setStudyMode(StudyMode mode) {
    _studyMode = mode;
    _isExamMode = mode == StudyMode.exam;
    notifyListeners();
  }

  // Set scoring mode
  void setScoringMode(ScoringMode mode) {
    _scoringMode = mode;
    notifyListeners();
  }

  // Load all questions by license type
  void loadAllQuestions(LicenseType type) {
    _currentQuestions = List.from(_repository.getQuestions(type));
    _currentIndex = 0;
    _currentExam = null;
    _isExamMode = false;
    notifyListeners();
  }

  // Load questions for a specific exam
  void loadExam(LicenseType type, int examId) {
    final exam = _repository.getExamById(type, examId);
    if (exam == null) return;

    _currentExam = exam;
    _currentQuestions = _repository.getQuestionsByIds(type, exam.questionIds);
    _currentIndex = 0;
    _isExamMode = true;
    _studyMode = StudyMode.exam;
    notifyListeners();
  }

  // Load random exam
  void loadRandomExam(LicenseType type) {
    final exams = _repository.getExams(type);
    if (exams.isEmpty) return;

    exams.shuffle();
    final exam = exams.first;
    loadExam(type, exam.id);
  }

  // Load questions by chapter
  void loadQuestionsByChapter(LicenseType type, String chapterName) {
    _currentQuestions = _repository.getQuestionsByChapter(type, chapterName);
    _currentIndex = 0;
    _currentExam = null;
    _isExamMode = false;
    _studyMode = StudyMode.practice;
    notifyListeners();
  }

  // Load filtered questions
  void loadFilteredQuestions(LicenseType type, StudyMode mode) {
    _studyMode = mode;
    _isExamMode = false;
    _currentExam = null;

    switch (mode) {
      case StudyMode.all:
        _currentQuestions = List.from(_repository.getQuestions(type));
        break;
      case StudyMode.unanswered:
        _currentQuestions = List.from(_repository.getUnansweredQuestions(type));
        break;
      case StudyMode.wrong:
        _currentQuestions = List.from(_repository.getWrongQuestions(type));
        break;
      case StudyMode.marked:
        _currentQuestions = List.from(_repository.getMarkedQuestions(type));
        break;
      case StudyMode.random:
        _currentQuestions = _repository.getRandomQuestions(type, count: 50);
        break;
      case StudyMode.important:
        _currentQuestions = List.from(_repository.getImportantQuestions(type));
        break;
      case StudyMode.practice:
      case StudyMode.exam:
        break;
    }
    _currentIndex = 0;
    notifyListeners();
  }

  // Load all questions for catalog
  void loadAllQuestionsForCatalog(LicenseType type) {
    _currentQuestions = List.from(_repository.getQuestions(type));
    _currentIndex = 0;
    _currentExam = null;
    _isExamMode = false;
    _studyMode = StudyMode.all;
    notifyListeners();
  }

  // Select answer
  void selectAnswer(int answerIndex, LicenseType type) {
    if (currentQuestion == null) return;

    final question = currentQuestion!;
    question.isAnswered = true;
    question.selectedAnswerIndex = answerIndex;
    question.lastAnsweredAt = DateTime.now();

    if (answerIndex == question.correctAnswer) {
      question.correctCount++;
    } else {
      question.wrongCount++;
    }

    // Persist state
    QuestionStatePersistence().saveQuestionState(type, question);

    notifyListeners();
  }

  // Toggle bookmark
  void toggleMark(LicenseType type) {
    if (currentQuestion == null) return;
    currentQuestion!.isMarked = !currentQuestion!.isMarked;
    QuestionStatePersistence().saveQuestionState(type, currentQuestion!);
    notifyListeners();
  }

  // Navigation
  void nextQuestion() {
    if (hasNext) {
      _currentIndex++;
      notifyListeners();
    }
  }

  void previousQuestion() {
    if (hasPrevious) {
      _currentIndex--;
      notifyListeners();
    }
  }

  void jumpToQuestion(int index) {
    if (index >= 0 && index < _currentQuestions.length) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  // Submit exam (for grading)
  ExamResult submitExam(LicenseType type) {
    int correct = 0;
    int wrong = 0;
    int unanswered = 0;

    for (var q in _currentQuestions) {
      if (!q.isAnswered) {
        unanswered++;
      } else if (q.isCorrect) {
        correct++;
      } else {
        wrong++;
      }
    }

    final result = ExamResult(
      totalQuestions: _currentQuestions.length,
      correctAnswers: correct,
      wrongAnswers: wrong,
      unansweredQuestions: unanswered,
      passed: correct >= 23, // Passing score is 23
    );

    // Save exam attempt
    if (_currentExam != null) {
      final attempt = ExamAttemptRecord(
        date: DateTime.now(),
        totalQuestions: _currentQuestions.length,
        correctAnswers: correct,
        wrongAnswers: wrong,
        unansweredQuestions: unanswered,
        passed: correct >= 23,
      );
      ExamPersistenceService().saveExamAttempt(type, _currentExam!.id, attempt);
    }

    return result;
  }

  // Reset exam state (for retry)
  void resetCurrentExam() {
    for (var q in _currentQuestions) {
      q.isAnswered = false;
      q.selectedAnswerIndex = -1;
    }
    _currentIndex = 0;
    notifyListeners();
  }

  // Toggle bookmark for any question (not just current)
  void toggleMarkQuestion(Question question, LicenseType type) {
    question.isMarked = !question.isMarked;
    QuestionStatePersistence().saveQuestionState(type, question);
    notifyListeners();
  }
}

class ExamResult {
  final int totalQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final int unansweredQuestions;
  final bool passed;

  ExamResult({
    required this.totalQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.unansweredQuestions,
    required this.passed,
  });

  double get accuracy =>
      totalQuestions > 0 ? correctAnswers / totalQuestions : 0.0;
}
