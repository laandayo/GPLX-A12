class Chapter {
  final int id;
  final String title;
  final String description;
  final String? icon;

  Chapter({
    required this.id,
    required this.title,
    required this.description,
    this.icon,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'icon': icon,
      };

  factory Chapter.fromJson(Map<String, dynamic> json) => Chapter(
        id: json['id'] as int,
        title: json['title'] as String,
        description: json['description'] as String,
        icon: json['icon'] as String?,
      );
}
