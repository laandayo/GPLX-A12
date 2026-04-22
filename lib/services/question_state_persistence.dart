import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/models.dart';

class QuestionStatePersistence {
  static final QuestionStatePersistence _instance = QuestionStatePersistence._internal();
  factory QuestionStatePersistence() => _instance;
  QuestionStatePersistence._internal();

  static const _keyPrefix = 'question_state_';

  String _key(LicenseType type, int questionId) {
    return '$_keyPrefix${type.name}_$questionId';
  }

  Future<void> saveQuestionState(LicenseType type, Question question) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _key(type, question.id);
    final data = {
      'isAnswered': question.isAnswered,
      'selectedAnswerIndex': question.selectedAnswerIndex,
      'wrongCount': question.wrongCount,
      'correctCount': question.correctCount,
      'isMarked': question.isMarked,
      'lastAnsweredAt': question.lastAnsweredAt?.toIso8601String(),
    };
    await prefs.setString(key, jsonEncode(data));
  }

  Future<void> loadQuestionState(LicenseType type, Question question) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _key(type, question.id);
    final dataStr = prefs.getString(key);
    if (dataStr != null) {
      try {
        final data = jsonDecode(dataStr) as Map<String, dynamic>;
        question.isAnswered = data['isAnswered'] as bool? ?? false;
        question.selectedAnswerIndex = data['selectedAnswerIndex'] as int? ?? -1;
        question.wrongCount = data['wrongCount'] as int? ?? 0;
        question.correctCount = data['correctCount'] as int? ?? 0;
        question.isMarked = data['isMarked'] as bool? ?? false;
        if (data['lastAnsweredAt'] != null) {
          question.lastAnsweredAt = DateTime.parse(data['lastAnsweredAt'] as String);
        }
      } catch (e) {
        return;
      }
    }
  }

  Future<void> loadAllQuestionStates(LicenseType type, List<Question> questions) async {
    for (var q in questions) {
      await loadQuestionState(type, q);
    }
  }

  Future<void> clearAllStates(LicenseType type) async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith(_keyPrefix) && k.contains(type.name));
    for (var key in keys) {
      await prefs.remove(key);
    }
  }
}
