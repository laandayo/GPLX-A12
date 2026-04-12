class Answer {
  final String content;
  final bool isCorrect;

  Answer({
    required this.content,
    required this.isCorrect,
  });

  Map<String, dynamic> toJson() => {
        'content': content,
        'isCorrect': isCorrect,
      };

  factory Answer.fromJson(Map<String, dynamic> json) => Answer(
        content: json['content'] as String,
        isCorrect: json['isCorrect'] as bool,
      );
}

class Question {
  final int id;
  final int chapter;
  final String content;
  final List<Answer> answers;
  final String explanation;
  final String? image;
  final bool isImportant;

  // User interaction state
  bool isAnswered;
  int selectedAnswerIndex;
  int wrongCount;
  int correctCount;
  bool isMarked;
  DateTime? lastAnsweredAt;

  Question({
    required this.id,
    required this.chapter,
    required this.content,
    required this.answers,
    required this.explanation,
    this.image,
    this.isImportant = false,
    this.isAnswered = false,
    this.selectedAnswerIndex = -1,
    this.wrongCount = 0,
    this.correctCount = 0,
    this.isMarked = false,
    this.lastAnsweredAt,
  });

  int get correctAnswerIndex {
    for (int i = 0; i < answers.length; i++) {
      if (answers[i].isCorrect) return i;
    }
    return 0;
  }

  bool get isCorrect {
    if (!isAnswered) return false;
    return selectedAnswerIndex == correctAnswerIndex;
  }

  QuestionStatus get status {
    if (!isAnswered) return QuestionStatus.unanswered;
    if (isCorrect) return QuestionStatus.correct;
    return QuestionStatus.wrong;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'chapter': chapter,
        'content': content,
        'answers': answers.map((a) => a.toJson()).toList(),
        'explanation': explanation,
        'image': image,
        'isImportant': isImportant,
        'isAnswered': isAnswered,
        'selectedAnswerIndex': selectedAnswerIndex,
        'wrongCount': wrongCount,
        'correctCount': correctCount,
        'isMarked': isMarked,
        'lastAnsweredAt': lastAnsweredAt?.toIso8601String(),
      };

  factory Question.fromJson(Map<String, dynamic> json) => Question(
        id: json['id'] as int,
        chapter: json['chapter'] as int,
        content: json['content'] as String,
        answers: (json['answers'] as List)
            .map((a) => Answer.fromJson(a as Map<String, dynamic>))
            .toList(),
        explanation: json['explanation'] as String,
        image: json['image'] as String?,
        isImportant: json['isImportant'] as bool? ?? false,
        isAnswered: json['isAnswered'] as bool? ?? false,
        selectedAnswerIndex: json['selectedAnswerIndex'] as int? ?? -1,
        wrongCount: json['wrongCount'] as int? ?? 0,
        correctCount: json['correctCount'] as int? ?? 0,
        isMarked: json['isMarked'] as bool? ?? false,
        lastAnsweredAt: json['lastAnsweredAt'] != null
            ? DateTime.parse(json['lastAnsweredAt'] as String)
            : null,
      );
}

enum QuestionStatus {
  unanswered,
  correct,
  wrong,
}
