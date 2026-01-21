import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase client reference
final _supabase = Supabase.instance.client;

/// Data model for saving a quiz score
/// (Requirements: 1.1)
class QuizScoreData {
  final String category;
  final int score;
  final int timeBonus;
  final int correctAnswers;
  final int totalQuestions;

  const QuizScoreData({
    required this.category,
    required this.score,
    required this.timeBonus,
    required this.correctAnswers,
    required this.totalQuestions,
  });

  Map<String, dynamic> toJson() => {
    'category': category,
    'score': score,
    'time_bonus': timeBonus,
    'correct_answers': correctAnswers,
    'total_questions': totalQuestions,
  };
}

/// Data model for a leaderboard entry
/// (Requirements: 2.2)
class LeaderboardEntry {
  final int rank;
  final String userId;
  final String name;
  final String hometown;
  final int totalScore;

  const LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.name,
    required this.hometown,
    required this.totalScore,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json, int rank) {
    return LeaderboardEntry(
      rank: rank,
      userId: json['id'] as String,
      name: json['name'] as String? ?? 'Unknown',
      hometown: json['hometown'] as String? ?? 'Unknown',
      totalScore: json['total_score'] as int? ?? 0,
    );
  }
}

/// Data model for current user's rank information
/// (Requirements: 3.1, 3.2)
class UserRankData {
  final int rank;
  final String name;
  final int totalScore;

  const UserRankData({
    required this.rank,
    required this.name,
    required this.totalScore,
  });
}

/// Service class for score-related database operations
class ScoreService {
  /// Saves a quiz score to the database and updates user's total score.
  /// Uses atomic RPC function to ensure data consistency.
  /// Returns true on success, false on failure.
  /// (Requirements: 1.1, 1.2)
  static Future<bool> saveQuizScore(QuizScoreData data) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      // Use atomic RPC function to save score and update total in one transaction
      final response = await _supabase.rpc(
        'save_quiz_score',
        params: {
          'p_user_id': user.id,
          'p_category': data.category,
          'p_score': data.score,
          'p_time_bonus': data.timeBonus,
          'p_correct_answers': data.correctAnswers,
          'p_total_questions': data.totalQuestions,
        },
      );

      // Handle the JSON response from the function
      if (response is Map<String, dynamic>) {
        return response['success'] == true;
      }

      // If response is not a map, assume success (older Supabase versions)
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Gets the global leaderboard with top users ranked by total_score.
  /// (Requirements: 2.1, 2.2)
  static Future<List<LeaderboardEntry>> getGlobalLeaderboard({
    int limit = 50,
  }) async {
    try {
      final response = await _supabase
          .from('users')
          .select('id, name, hometown, total_score')
          .order('total_score', ascending: false)
          .limit(limit);

      final List<dynamic> data = response as List<dynamic>;
      return data.asMap().entries.map((entry) {
        return LeaderboardEntry.fromJson(
          entry.value as Map<String, dynamic>,
          entry.key + 1, // Rank starts at 1
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Gets the hometown leaderboard filtered by hometown.
  /// (Requirements: 4.2)
  static Future<List<LeaderboardEntry>> getHometownLeaderboard(
    String hometown, {
    int limit = 50,
  }) async {
    try {
      final response = await _supabase
          .from('users')
          .select('id, name, hometown, total_score')
          .eq('hometown', hometown)
          .order('total_score', ascending: false)
          .limit(limit);

      final List<dynamic> data = response as List<dynamic>;
      return data.asMap().entries.map((entry) {
        return LeaderboardEntry.fromJson(
          entry.value as Map<String, dynamic>,
          entry.key + 1, // Rank starts at 1
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Gets the current user's rank and score information.
  /// Supports both global and hometown scope.
  /// (Requirements: 3.1, 3.2)
  static Future<UserRankData?> getCurrentUserRank({String? hometown}) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      // Get current user's data
      final userResponse = await _supabase
          .from('users')
          .select('name, total_score, hometown')
          .eq('id', user.id)
          .single();

      final userName = userResponse['name'] as String? ?? 'Unknown';
      final userScore = userResponse['total_score'] as int? ?? 0;

      // Count users with higher scores to determine rank
      int rank;
      if (hometown != null) {
        // Hometown scope
        final countResponse = await _supabase
            .from('users')
            .select('id')
            .eq('hometown', hometown)
            .gt('total_score', userScore);

        rank = (countResponse as List).length + 1;
      } else {
        // Global scope
        final countResponse = await _supabase
            .from('users')
            .select('id')
            .gt('total_score', userScore);

        rank = (countResponse as List).length + 1;
      }

      return UserRankData(rank: rank, name: userName, totalScore: userScore);
    } catch (e) {
      return null;
    }
  }

  /// Gets the current user's hometown.
  static Future<String?> getCurrentUserHometown() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      final response = await _supabase
          .from('users')
          .select('hometown')
          .eq('id', user.id)
          .single();

      return response['hometown'] as String?;
    } catch (e) {
      return null;
    }
  }
}
