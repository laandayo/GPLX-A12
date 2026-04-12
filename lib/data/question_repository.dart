import '../models/models.dart';
import 'sample_data.dart';

class QuestionRepository {
  static final QuestionRepository _instance = QuestionRepository._internal();
  factory QuestionRepository() => _instance;
  QuestionRepository._internal();

  final Map<LicenseType, List<Question>> _questions = {};
  final Map<LicenseType, List<Chapter>> _chapters = {};

  void initialize() {
    for (var type in LicenseType.values) {
      _questions[type] = SampleData.getQuestions(type);
      _chapters[type] = SampleData.getChapters(type);
    }
  }

  List<Question> getQuestions(LicenseType type) {
    return _questions[type] ?? [];
  }

  List<Chapter> getChapters(LicenseType type) {
    return _chapters[type] ?? [];
  }

  Question? getQuestionById(LicenseType type, int id) {
    final questions = _questions[type] ?? [];
    try {
      return questions.firstWhere((q) => q.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Question> getQuestionsByChapter(LicenseType type, int chapterId) {
    final questions = _questions[type] ?? [];
    final chapter = _chapters[type]?.firstWhere((c) => c.id == chapterId);
    if (chapter == null) return [];
    
    return questions.where((q) => chapter.questionIds.contains(q.id)).toList();
  }

  List<Question> getWrongQuestions(LicenseType type) {
    final questions = _questions[type] ?? [];
    return questions.where((q) => q.wrongCount > 0).toList();
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
    final answered = questions.where((q) => q.isAnswered).toList();
    if (answered.isEmpty) return 0.0;
    
    final correct = answered.where((q) => q.isCorrect).length;
    return correct / answered.length;
  }
}
