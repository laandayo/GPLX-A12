import '../models/models.dart';
import '../services/question_json_service.dart';

class QuestionRepository {
  static final QuestionRepository _instance = QuestionRepository._internal();
  factory QuestionRepository() => _instance;
  QuestionRepository._internal();

  final QuestionJsonService _jsonService = QuestionJsonService();

  void initialize() {}

  Future<void> initializeAsync() async {
    await _jsonService.initialize();
  }

  List<Question> getQuestions(LicenseType type) {
    return _jsonService.getQuestions(type);
  }

  List<Chapter> getChapters(LicenseType type) {
    return _jsonService.getChapters(type);
  }

  List<Exam> getExams(LicenseType type) {
    return _jsonService.getExams(type);
  }

  Question? getQuestionById(LicenseType type, int id) {
    return _jsonService.getQuestionById(type, id);
  }

  Exam? getExamById(LicenseType type, int examId) {
    return _jsonService.getExamById(type, examId);
  }

  List<Question> getQuestionsByChapter(LicenseType type, String chapterName) {
    return _jsonService.getQuestionsByChapter(type, chapterName);
  }

  List<Question> getQuestionsByIds(LicenseType type, List<int> ids) {
    return _jsonService.getQuestionsByIds(type, ids);
  }

  List<Question> getWrongQuestions(LicenseType type) {
    return _jsonService.getWrongQuestions(type);
  }

  List<Question> getMarkedQuestions(LicenseType type) {
    return _jsonService.getMarkedQuestions(type);
  }

  List<Question> getUnansweredQuestions(LicenseType type) {
    return _jsonService.getUnansweredQuestions(type);
  }

  List<Question> getRandomQuestions(LicenseType type, {int count = 10}) {
    return _jsonService.getRandomQuestions(type, count: count);
  }

  List<Question> getImportantQuestions(LicenseType type) {
    return _jsonService.getImportantQuestions(type);
  }

  int getTotalQuestions(LicenseType type) {
    return _jsonService.getTotalQuestions(type);
  }

  int getAnsweredCount(LicenseType type) {
    return _jsonService.getAnsweredCount(type);
  }

  double getAccuracyRate(LicenseType type) {
    return _jsonService.getAccuracyRate(type);
  }

  List<Question> searchQuestions(LicenseType type, String query) {
    return _jsonService.searchQuestions(type, query);
  }

  void resetAllProgress() {
    _jsonService.resetAllProgress();
  }
}
