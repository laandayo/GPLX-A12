import 'package:flutter_test/flutter_test.dart';
import 'package:gplx_app/models/models.dart';
import 'package:gplx_app/data/data.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  test('QuestionRepository initializes correctly', () async {
    await QuestionRepository().initializeAsync();

    final a1Questions = QuestionRepository().getQuestions(LicenseType.a1);
    final a2Questions = QuestionRepository().getQuestions(LicenseType.a2);

    expect(a1Questions.length, 250);
    expect(a2Questions.length, 250);
  });

  test('Chapters load correctly', () async {
    await QuestionRepository().initializeAsync();

    final a1Chapters = QuestionRepository().getChapters(LicenseType.a1);
    final a2Chapters = QuestionRepository().getChapters(LicenseType.a2);

    expect(a1Chapters.length, 5);
    expect(a2Chapters.length, 5);
  });

  test('Shuffled exam follows question distribution', () async {
    await QuestionRepository().initializeAsync();

    final questions = QuestionRepository().getShuffledExamQuestions(
      LicenseType.a1,
    );
    final ids = questions.map((q) => q.id).toSet();
    final importantCount = questions.where((q) => q.isImportant).length;

    expect(questions.length, 25);
    expect(ids.length, 25);
    expect(questions.where((q) => q.id >= 1 && q.id <= 100).length, 9);
    expect(questions.where((q) => q.id >= 101 && q.id <= 110).length, 2);
    expect(questions.where((q) => q.id >= 111 && q.id <= 125).length, 3);
    expect(questions.where((q) => q.id >= 126 && q.id <= 215).length, 8);
    expect(questions.where((q) => q.id >= 216 && q.id <= 250).length, 3);
    expect(importantCount, inInclusiveRange(1, 2));
  });
}
