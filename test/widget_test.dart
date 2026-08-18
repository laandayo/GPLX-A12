import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gplx_app/models/models.dart';
import 'package:gplx_app/data/data.dart';
import 'package:gplx_app/providers/providers.dart';
import 'package:gplx_app/screens/question_screen.dart';
import 'package:provider/provider.dart';
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

  test('Study activity uses stable, understandable question ranges', () {
    expect(StatisticsProvider.activityLevel(0), 0);
    expect(StatisticsProvider.activityLevel(1), 1);
    expect(StatisticsProvider.activityLevel(10), 1);
    expect(StatisticsProvider.activityLevel(11), 2);
    expect(StatisticsProvider.activityLevel(20), 2);
    expect(StatisticsProvider.activityLevel(21), 3);
    expect(StatisticsProvider.activityLevel(40), 3);
    expect(StatisticsProvider.activityLevel(41), 4);
  });

  test('Every color palette provides distinct light and dark theme colors', () {
    for (final palette in AppThemePalette.values) {
      AppColors.activePalette = palette;
      expect(
        AppColors.primary(LicenseType.a1, false),
        isNot(AppColors.primary(LicenseType.a1, true)),
      );
      expect(
        AppColors.background(LicenseType.a1, false),
        isNot(AppColors.background(LicenseType.a1, true)),
      );
      expect(
        AppColors.surface(LicenseType.a1, false),
        isNot(AppColors.surface(LicenseType.a1, true)),
      );
    }
    AppColors.activePalette = AppThemePalette.blue;
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

  test(
    'Exam answers can be changed before submission only in deferred scoring',
    () async {
      await QuestionRepository().initializeAsync();

      final provider = QuestionProvider()..loadShuffledExam(LicenseType.a1);

      expect(
        provider.selectAnswer(0, LicenseType.a1, gradeImmediately: false),
        isTrue,
      );
      expect(provider.currentQuestion!.selectedAnswerIndex, 0);
      expect(provider.currentQuestion!.isEvaluated, isFalse);

      expect(
        provider.selectAnswer(1, LicenseType.a1, gradeImmediately: false),
        isTrue,
      );
      expect(provider.currentQuestion!.selectedAnswerIndex, 1);

      provider.resetCurrentExam();

      expect(
        provider.selectAnswer(0, LicenseType.a1, gradeImmediately: true),
        isTrue,
      );
      expect(provider.currentQuestion!.selectedAnswerIndex, 0);
      expect(provider.currentQuestion!.isEvaluated, isTrue);

      expect(
        provider.selectAnswer(1, LicenseType.a1, gradeImmediately: true),
        isFalse,
      );
      expect(provider.currentQuestion!.selectedAnswerIndex, 0);
    },
  );

  testWidgets('Catalog lookup shows all answer options', (tester) async {
    await QuestionRepository().initializeAsync();

    final appProvider = AppProvider();
    final questionProvider = QuestionProvider();
    questionProvider.loadAllQuestionsForCatalog(LicenseType.a1);
    questionProvider.jumpToQuestion(0);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AppProvider>.value(value: appProvider),
          ChangeNotifierProvider<QuestionProvider>.value(
            value: questionProvider,
          ),
        ],
        child: const MaterialApp(home: QuestionScreen(isCatalogLookup: true)),
      ),
    );
    await tester.pumpAndSettle();

    final question = questionProvider.currentQuestion!;
    for (final answer in question.answers) {
      expect(find.text(answer), findsOneWidget);
    }
  });
}
