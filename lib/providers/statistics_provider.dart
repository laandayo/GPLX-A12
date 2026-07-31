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

  List<int> getStudyHeatmap(Map<String, int> activity, {int days = 30}) {
    final now = DateTime.now();
    final end = DateTime(now.year, now.month, now.day);
    final counts = List<int>.generate(days, (index) {
      final day = end.subtract(Duration(days: days - index - 1));
      final key = _dateKey(day);
      return activity[key] ?? 0;
    });
    final maxCount = counts.fold<int>(0, (max, count) => count > max ? count : max);

    return counts.map((count) {
      if (count == 0) return 0;
      if (maxCount <= 4) return count.clamp(1, 4);
      final normalized = ((count / maxCount) * 4).ceil();
      return normalized.clamp(1, 4);
    }).toList(growable: false);
  }

  void clearHistory() {
    _testAttempts.clear();
    notifyListeners();
  }

  String _dateKey(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
