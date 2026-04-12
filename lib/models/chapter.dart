class Chapter {
  final int id;
  final String title;
  final String description;
  final List<int> questionIds;
  final String? icon;

  Chapter({
    required this.id,
    required this.title,
    required this.description,
    required this.questionIds,
    this.icon,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'questionIds': questionIds,
        'icon': icon,
      };

  factory Chapter.fromJson(Map<String, dynamic> json) => Chapter(
        id: json['id'] as int,
        title: json['title'] as String,
        description: json['description'] as String,
        questionIds: List<int>.from(json['questionIds'] as List),
        icon: json['icon'] as String?,
      );
}
