import 'package:flutter/material.dart';
import '../models/models.dart';
import '../data/data.dart';

class QuestionProvider with ChangeNotifier {
  final QuestionRepository _repository = QuestionRepository();

  // Study mode: all, unanswered, wrong, marked, random
  StudyMode _studyMode = StudyMode.all;
  List<Question> _currentQuestions = [];
  int _currentIndex = 0;
  bool _autoAdvance = false;
  bool _showExplanation = true;

  StudyMode get studyMode => _studyMode;
  List<Question> get currentQuestions => _currentQuestions;
  Question? get currentQuestion =>
      _currentQuestions.isEmpty ? null : _currentQuestions[_currentIndex];
  int get currentIndex => _currentIndex;
  int get totalQuestions => _currentQuestions.length;
  bool get autoAdvance => _autoAdvance;
  bool get showExplanation => _showExplanation;
  bool get hasNext => _currentIndex < _currentQuestions.length - 1;
  bool get hasPrevious => _currentIndex > 0;

  void setStudyMode(StudyMode mode) {
    _studyMode = mode;
    notifyListeners();
  }

  void loadQuestions(LicenseType type, {int? chapterId}) {
    switch (_studyMode) {
      case StudyMode.all:
        if (chapterId != null) {
          _currentQuestions = _repository.getQuestionsByChapter(type, chapterId);
        } else {
          _currentQuestions = _repository.getQuestions(type);
        }
        break;
      case StudyMode.unanswered:
        _currentQuestions = _repository.getUnansweredQuestions(type);
        break;
      case StudyMode.wrong:
        _currentQuestions = _repository.getWrongQuestions(type);
        break;
      case StudyMode.marked:
        _currentQuestions = _repository.getMarkedQuestions(type);
        break;
      case StudyMode.random:
        _currentQuestions = _repository.getRandomQuestions(type, count: 50);
        break;
      case StudyMode.important:
        _currentQuestions = _repository.getImportantQuestions(type);
        break;
    }
    _currentIndex = 0;
    notifyListeners();
  }

  void selectAnswer(int answerIndex) {
    if (currentQuestion == null) return;

    final question = currentQuestion!;
    question.isAnswered = true;
    question.selectedAnswerIndex = answerIndex;
    question.lastAnsweredAt = DateTime.now();

    if (answerIndex == question.correctAnswerIndex) {
      question.correctCount++;
    } else {
      question.wrongCount++;
    }

    notifyListeners();
  }

  void toggleMark() {
    if (currentQuestion == null) return;
    currentQuestion!.isMarked = !currentQuestion!.isMarked;
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

  void toggleAutoAdvance() {
    _autoAdvance = !_autoAdvance;
    notifyListeners();
  }

  void toggleShowExplanation() {
    _showExplanation = !_showExplanation;
    notifyListeners();
  }

  void retryWrongQuestions(LicenseType type) {
    _studyMode = StudyMode.wrong;
    loadQuestions(type);
  }

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
}

enum StudyMode {
  all,
  unanswered,
  wrong,
  marked,
  random,
  important,
}
