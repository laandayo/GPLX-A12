class Exam {
  final int id;
  final String name;
  final List<int> questionIds;
  final String licenseType;

  Exam({
    required this.id,
    required this.name,
    required this.questionIds,
    required this.licenseType,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'questionIds': questionIds,
        'licenseType': licenseType,
      };

  factory Exam.fromJson(Map<String, dynamic> json, String licenseType) => Exam(
        id: json['id'] as int,
        name: json['name'] as String,
        questionIds: List<int>.from(json['questionIds'] as List),
        licenseType: licenseType,
      );
}
