import 'package:flutter_test/flutter_test.dart';
import 'package:gplx_app/models/models.dart';
import 'package:gplx_app/data/data.dart';

void main() {
  test('QuestionRepository initializes correctly', () {
    QuestionRepository().initialize();
    
    final a1Questions = QuestionRepository().getQuestions(LicenseType.a1);
    final a2Questions = QuestionRepository().getQuestions(LicenseType.a2);
    
    expect(a1Questions.length, 450);
    expect(a2Questions.length, 400);
  });

  test('Chapters load correctly', () {
    QuestionRepository().initialize();
    
    final a1Chapters = QuestionRepository().getChapters(LicenseType.a1);
    final a2Chapters = QuestionRepository().getChapters(LicenseType.a2);
    
    expect(a1Chapters.length, 5);
    expect(a2Chapters.length, 5);
  });
}
