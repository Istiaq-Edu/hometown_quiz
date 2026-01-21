import 'package:flutter/material.dart';

/// Achievement difficulty levels
enum AchievementLevel { bronze, silver, gold, diamond }

/// Achievement data model
class Achievement {
  final String id;
  final String name;
  final String description;
  final AchievementLevel level;
  final IconData icon;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final double progress; // 0.0 to 1.0

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.level,
    required this.icon,
    this.isUnlocked = false,
    this.unlockedAt,
    this.progress = 0.0,
  });

  /// Factory constructor to create Achievement from database
  factory Achievement.fromMap(Map<String, dynamic> map, {
    required String name,
    required String description,
    required AchievementLevel level,
    required IconData icon,
    required double progress,
  }) {
    return Achievement(
      id: map['achievement_id'] as String,
      name: name,
      description: description,
      level: level,
      icon: icon,
      isUnlocked: true,
      unlockedAt: DateTime.parse(map['unlocked_at'] as String),
      progress: progress,
    );
  }

  /// Color associated with the achievement level
  Color get color {
    switch (level) {
      case AchievementLevel.bronze:
        return const Color(0xFFCD7F32);
      case AchievementLevel.silver:
        return const Color(0xFFC0C0C0);
      case AchievementLevel.gold:
        return const Color(0xFFFFD700);
      case AchievementLevel.diamond:
        return const Color(0xFFB9F2FF);
    }
  }
}
