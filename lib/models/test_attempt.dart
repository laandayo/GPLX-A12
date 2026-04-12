class TestAttempt {
  final DateTime date;
  final int totalQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final List<int> questionIds;

  TestAttempt({
    required this.date,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.questionIds,
  });

  double get accuracy =>
      totalQuestions > 0 ? correctAnswers / totalQuestions : 0.0;

  bool get passed => accuracy >= 0.8;

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'totalQuestions': totalQuestions,
        'correctAnswers': correctAnswers,
        'wrongAnswers': wrongAnswers,
        'questionIds': questionIds,
      };

  factory TestAttempt.fromJson(Map<String, dynamic> json) => TestAttempt(
        date: DateTime.parse(json['date'] as String),
        totalQuestions: json['totalQuestions'] as int,
        correctAnswers: json['correctAnswers'] as int,
        wrongAnswers: json['wrongAnswers'] as int,
        questionIds: List<int>.from(json['questionIds'] as List),
      );
}
