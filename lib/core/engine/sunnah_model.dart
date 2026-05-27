class Sunnah {
  final int id;
  final String title;
  final String description;
  final String category;
  final String source;
  final String authenticity;
  final int points;
  final String difficulty; // easy | medium | hard
  
  bool isCompleted;
  bool isFavorite;

  Sunnah({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.source,
    required this.authenticity,
    required this.points,
    required this.difficulty,
    this.isCompleted = false,
    this.isFavorite = false,
  });

  factory Sunnah.fromJson(Map<String, dynamic> json) {
    return Sunnah(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      source: json['source'] as String,
      authenticity: json['authenticity'] as String,
      points: json['points'] as int,
      difficulty: json['difficulty'] as String? ?? _computeDifficulty(json['points'] as int),
      isCompleted: json['isCompleted'] as bool? ?? false,
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  static String _computeDifficulty(int pts) {
    if (pts <= 5) return 'easy';
    if (pts <= 10) return 'medium';
    return 'hard';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'source': source,
      'authenticity': authenticity,
      'points': points,
      'difficulty': difficulty,
      'isCompleted': isCompleted,
      'isFavorite': isFavorite,
    };
  }

  // Helper method for deep copy to mutate state safely if needed
  Sunnah copyWith({
    int? id,
    String? title,
    String? description,
    String? category,
    String? source,
    String? authenticity,
    int? points,
    String? difficulty,
    bool? isCompleted,
    bool? isFavorite,
  }) {
    return Sunnah(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      source: source ?? this.source,
      authenticity: authenticity ?? this.authenticity,
      points: points ?? this.points,
      difficulty: difficulty ?? this.difficulty,
      isCompleted: isCompleted ?? this.isCompleted,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
