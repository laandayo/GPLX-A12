import 'package:flutter/material.dart';
import '../models/models.dart';
import '../data/data.dart';

class StudyActivityDay {
  final DateTime date;
  final int questionCount;

  const StudyActivityDay({required this.date, required this.questionCount});
}

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
    return getStudyActivity(activity, days: days)
        .map((day) => activityLevel(day.questionCount))
        .toList(growable: false);
  }

  List<StudyActivityDay> getStudyActivity(
    Map<String, int> activity, {
    int days = 30,
  }) {
    final now = DateTime.now();
    final end = DateTime(now.year, now.month, now.day);
    return List<StudyActivityDay>.generate(days, (index) {
      final day = end.subtract(Duration(days: days - index - 1));
      return StudyActivityDay(
        date: day,
        questionCount: activity[_dateKey(day)] ?? 0,
      );
    }, growable: false);
  }

  static int activityLevel(int questionCount) {
    if (questionCount == 0) return 0;
    if (questionCount <= 10) return 1;
    if (questionCount <= 20) return 2;
    if (questionCount <= 40) return 3;
    return 4;
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
