import 'package:flutter/material.dart';
import '../models/models.dart';
import '../data/data.dart';

class StatisticsProvider with ChangeNotifier {
  final QuestionRepository _repository = QuestionRepository();
  final List<TestAttempt> _testAttempts = [];

  List<TestAttempt> get testAttempts => _testAttempts;

  void addTestAttempt(TestAttempt attempt) {
    _testAttempts.add(attempt);
    notifyListeners();
  }

  double getOverallAccuracy(LicenseType type) {
    return _repository.getAccuracyRate(type);
  }

  int getAnsweredCount(LicenseType type) {
    return _repository.getAnsweredCount(type);
  }

  int getTotalQuestions(LicenseType type) {
    return _repository.getTotalQuestions(type);
  }

  double getPassProbability(LicenseType type) {
    final accuracy = getOverallAccuracy(type);
    if (accuracy == 0) return 0.0;
    // Simple calculation - can be improved with more data
    return accuracy * 0.9;
  }

  int getWrongQuestionsCount(LicenseType type) {
    return _repository.getWrongQuestions(type).length;
  }

  int getMarkedQuestionsCount(LicenseType type) {
    return _repository.getMarkedQuestions(type).length;
  }

  Map<String, int> getChapterProgress(LicenseType type) {
    final chapters = _repository.getChapters(type);
    final questions = _repository.getQuestions(type);
    final progress = <String, int>{};

    for (var chapter in chapters) {
      final chapterQuestions = questions.where((q) => q.chapter == chapter.title).toList();
      final answered = chapterQuestions.where((q) => q.isAnswered).length;
      progress[chapter.title] = answered;
    }

    return progress;
  }

  List<int> getStudyHeatmap() {
    // Return last 30 days activity (placeholder)
    return List.generate(30, (index) => index % 5);
  }
}
