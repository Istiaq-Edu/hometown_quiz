/// Fun fact data model
/// (Requirements: 2.3)
class FunFact {
  final String id;
  final String content;
  final String category;

  const FunFact({
    required this.id,
    required this.content,
    required this.category,
  });

  /// Factory constructor to create FunFact from JSON
  factory FunFact.fromJson(Map<String, dynamic> json) {
    return FunFact(
      id: json['id'] as String,
      content: json['content'] as String,
      category: json['category'] as String,
    );
  }

  /// Convert FunFact to JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'content': content,
    'category': category,
  };
}
