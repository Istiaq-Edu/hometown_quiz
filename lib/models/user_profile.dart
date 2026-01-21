/// User profile data model
/// (Requirements: 1.3)
class UserProfile {
  final String id;
  final String name;
  final String hometown;
  final String? photoUrl;
  final int totalScore;

  const UserProfile({
    required this.id,
    required this.name,
    required this.hometown,
    this.photoUrl,
    required this.totalScore,
  });

  /// Factory constructor to create UserProfile from JSON
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Unknown',
      hometown: json['hometown'] as String? ?? 'Unknown',
      photoUrl: json['photo_url'] as String?,
      totalScore: json['total_score'] as int? ?? 0,
    );
  }

  /// Convert UserProfile to JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'hometown': hometown,
    'photo_url': photoUrl,
    'total_score': totalScore,
  };
}
