/// Dua data model — represents a single dua entry.
///
/// [id] is unique per dua for fast lookups.
/// [category] enables future filtering by topic.
class DuaModel {
  final int id;
  final String text;
  final String category;
  final String? source; // المصدر (قرآن، سنة، إلخ)

  const DuaModel({
    required this.id,
    required this.text,
    required this.category,
    this.source,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DuaModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  factory DuaModel.fromJson(Map<String, dynamic> json) {
    return DuaModel(
      // Handle cases where 'id' might be a String in the JSON, or missing
      id: json['id'] is int 
          ? json['id'] as int 
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      
      // Fallback for missing text/category to prevent app crash
      text: json['text']?.toString() ?? 'دعاء غير متوفر',
      category: json['category']?.toString() ?? 'غير مصنف',
      
      // Source is already nullable, but we ensure it's treated as a String
      source: json['source']?.toString(),
    );
  }
}
