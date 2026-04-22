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
  ScoringMode _scoringMode = ScoringMode.gradeAfterSubmission;
  List<Question> _currentQuestions = [];
  int _currentIndex = 0;
  Exam? _currentExam;
  bool _isExamMode = false;
  bool _hasSubmittedSession = false;

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
  bool get hasSubmittedSession => _hasSubmittedSession;

  double get progress {
    if (_currentQuestions.isEmpty) return 0.0;
    return answeredCount / _currentQuestions.length;
  }

  int get answeredCount => _currentQuestions.where((q) => q.isAnswered).length;

  int get correctCount =>
      _currentQuestions.where((q) => q.isEvaluated && q.isCorrect).length;

  int get wrongCount =>
      _currentQuestions.where((q) => q.isEvaluated && !q.isCorrect).length;

  void setStudyMode(StudyMode mode) {
    _studyMode = mode;
    _isExamMode = mode == StudyMode.exam;
    notifyListeners();
  }

  void setScoringMode(ScoringMode mode) {
    _scoringMode = mode;
    notifyListeners();
  }

  void loadAllQuestions(LicenseType type) {
    _startSession(
      questions: _repository.getQuestions(type),
      mode: StudyMode.all,
      isExamMode: false,
    );
  }

  void loadExam(LicenseType type, int examId) {
    final exam = _repository.getExamById(type, examId);
    if (exam == null) return;

    _startSession(
      questions: _repository.getQuestionsByIds(type, exam.questionIds),
      mode: StudyMode.exam,
      isExamMode: true,
      exam: exam,
    );
  }

  void loadRandomExam(LicenseType type) {
    final exams = _repository.getExams(type);
    if (exams.isEmpty) return;

    exams.shuffle();
    loadExam(type, exams.first.id);
  }

  void loadQuestionsByChapter(LicenseType type, String chapterName) {
    _startSession(
      questions: _repository.getQuestionsByChapter(type, chapterName),
      mode: StudyMode.practice,
      isExamMode: false,
    );
  }

  void loadFilteredQuestions(LicenseType type, StudyMode mode) {
    switch (mode) {
      case StudyMode.all:
        _startSession(
          questions: _repository.getQuestions(type),
          mode: mode,
          isExamMode: false,
        );
        break;
      case StudyMode.unanswered:
        _startSession(
          questions: _repository.getUnansweredQuestions(type),
          mode: mode,
          isExamMode: false,
        );
        break;
      case StudyMode.wrong:
        _startSession(
          questions: _repository.getWrongQuestions(type),
          mode: mode,
          isExamMode: false,
        );
        break;
      case StudyMode.marked:
        _startSession(
          questions: _repository.getMarkedQuestions(type),
          mode: mode,
          isExamMode: false,
        );
        break;
      case StudyMode.random:
        _startSession(
          questions: _repository.getRandomQuestions(type, count: 50),
          mode: mode,
          isExamMode: false,
        );
        break;
      case StudyMode.important:
        _startSession(
          questions: _repository.getImportantQuestions(type),
          mode: mode,
          isExamMode: false,
        );
        break;
      case StudyMode.practice:
      case StudyMode.exam:
        break;
    }
  }

  void loadAllQuestionsForCatalog(LicenseType type) {
    _startSession(
      questions: _repository.getQuestions(type),
      mode: StudyMode.all,
      isExamMode: false,
    );
  }

  void selectAnswer(
    int answerIndex,
    LicenseType type, {
    required bool gradeImmediately,
  }) {
    final question = currentQuestion;
    if (question == null || question.isAnswered) return;

    question.isAnswered = true;
    question.selectedAnswerIndex = answerIndex;

    if (gradeImmediately) {
      _evaluateQuestion(question, type);
    }

    notifyListeners();
  }

  void toggleMark(LicenseType type) {
    final sessionQuestion = currentQuestion;
    if (sessionQuestion == null) return;

    final sourceQuestion = _repository.getQuestionById(type, sessionQuestion.id);
    final nextValue = !sessionQuestion.isMarked;
    sessionQuestion.isMarked = nextValue;
    if (sourceQuestion != null) {
      sourceQuestion.isMarked = nextValue;
      QuestionStatePersistence().saveQuestionState(type, sourceQuestion);
    }
    notifyListeners();
  }

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

  ExamResult submitExam(LicenseType type) {
    if (_hasSubmittedSession) {
      return _buildResult();
    }

    for (final question in _currentQuestions) {
      if (question.isAnswered && !question.isEvaluated) {
        _evaluateQuestion(question, type);
      }
    }

    _hasSubmittedSession = true;

    final result = _buildResult();

    if (_currentExam != null) {
      final attempt = ExamAttemptRecord(
        date: DateTime.now(),
        totalQuestions: _currentQuestions.length,
        correctAnswers: result.correctAnswers,
        wrongAnswers: result.wrongAnswers,
        unansweredQuestions: result.unansweredQuestions,
        passed: result.passed,
      );
      ExamPersistenceService().saveExamAttempt(type, _currentExam!.id, attempt);
    }

    notifyListeners();
    return result;
  }

  void resetCurrentExam() {
    for (final question in _currentQuestions) {
      question.resetSessionState();
    }
    _currentIndex = 0;
    _hasSubmittedSession = false;
    notifyListeners();
  }

  void toggleMarkQuestion(Question question, LicenseType type) {
    final sourceQuestion = _repository.getQuestionById(type, question.id);
    if (sourceQuestion == null) return;

    final nextValue = !sourceQuestion.isMarked;
    sourceQuestion.isMarked = nextValue;
    question.isMarked = nextValue;
    for (final current in _currentQuestions.where((q) => q.id == question.id)) {
      current.isMarked = nextValue;
    }
    QuestionStatePersistence().saveQuestionState(type, sourceQuestion);
    notifyListeners();
  }

  void resetState() {
    _studyMode = StudyMode.all;
    _currentQuestions = [];
    _currentIndex = 0;
    _currentExam = null;
    _isExamMode = false;
    _hasSubmittedSession = false;
    _scoringMode = ScoringMode.gradeAfterSubmission;
    notifyListeners();
  }

  void _startSession({
    required List<Question> questions,
    required StudyMode mode,
    required bool isExamMode,
    Exam? exam,
  }) {
    _studyMode = mode;
    _isExamMode = isExamMode;
    _currentExam = exam;
    _currentQuestions = questions.map((question) => question.copyForSession()).toList();
    _currentIndex = 0;
    _hasSubmittedSession = false;
    notifyListeners();
  }

  void _evaluateQuestion(Question sessionQuestion, LicenseType type) {
    if (sessionQuestion.isEvaluated) return;

    sessionQuestion.isEvaluated = true;
    final sourceQuestion = _repository.getQuestionById(type, sessionQuestion.id);
    if (sourceQuestion == null) return;

    sourceQuestion.isAnswered = true;
    sourceQuestion.selectedAnswerIndex = sessionQuestion.selectedAnswerIndex;
    sourceQuestion.lastAnsweredAt = DateTime.now();

    if (sessionQuestion.isCorrect) {
      sourceQuestion.correctCount++;
      sourceQuestion.wrongCount = 0;
    } else {
      sourceQuestion.wrongCount++;
    }

    QuestionStatePersistence().saveQuestionState(type, sourceQuestion);
  }

  ExamResult _buildResult() {
    final correct = _currentQuestions.where((q) => q.isEvaluated && q.isCorrect).length;
    final wrong = _currentQuestions.where((q) => q.isEvaluated && !q.isCorrect).length;
    final unanswered = _currentQuestions.where((q) => !q.isAnswered).length;
    final failedImportantQuestions = _currentQuestions
        .where((q) => q.isImportant && q.isEvaluated && !q.isCorrect)
        .toList(growable: false);

    return ExamResult(
      totalQuestions: _currentQuestions.length,
      correctAnswers: correct,
      wrongAnswers: wrong,
      unansweredQuestions: unanswered,
      passed: correct >= 23 && failedImportantQuestions.isEmpty,
      failedImportantQuestions: failedImportantQuestions,
    );
  }
}

class ExamResult {
  final int totalQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final int unansweredQuestions;
  final bool passed;
  final List<Question> failedImportantQuestions;

  ExamResult({
    required this.totalQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.unansweredQuestions,
    required this.passed,
    this.failedImportantQuestions = const [],
  });

  double get accuracy =>
      totalQuestions > 0 ? correctAnswers / totalQuestions : 0.0;

  bool get failedByImportantQuestion => failedImportantQuestions.isNotEmpty;
}
