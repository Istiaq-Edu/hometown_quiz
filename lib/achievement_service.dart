import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/achievement.dart';
import 'models/user_stats.dart';
import 'score_service.dart';

final _supabase = Supabase.instance.client;

class AchievementService {
  /// Defines all possible achievements in the app
  static const List<Map<String, dynamic>> achievementDefinitions = [
    {
      'id': 'first_quiz',
      'name': 'First Steps',
      'description': 'Complete your first quiz',
      'level': AchievementLevel.bronze,
      'icon': Icons.emoji_events,
    },
    {
      'id': 'quiz_enthusiast',
      'name': 'Quiz Enthusiast',
      'description': 'Complete 10 quizzes',
      'level': AchievementLevel.silver,
      'icon': Icons.military_tech,
      'target': 10,
    },
    {
      'id': 'quiz_master',
      'name': 'Hometown Expert',
      'description': 'Complete 50 quizzes',
      'level': AchievementLevel.gold,
      'icon': Icons.stars,
      'target': 50,
    },
    {
      'id': 'perfect_score',
      'name': 'Perfectionist',
      'description': 'Get 100% accuracy in any quiz',
      'level': AchievementLevel.diamond,
      'icon': Icons.diamond,
    },
    {
      'id': 'speed_demon',
      'name': 'Lightning Fast',
      'description': 'Accumulate 100 time bonus points',
      'level': AchievementLevel.silver,
      'icon': Icons.bolt,
      'target': 100,
    },
    {
      'id': 'top_scorer',
      'name': 'Centurion',
      'description': 'Score 100+ points in a single quiz',
      'level': AchievementLevel.bronze,
      'icon': Icons.workspace_premium,
      'target': 100,
    },
    {
      'id': 'district_explorer',
      'name': 'District Explorer',
      'description': 'Complete quizzes in 5 different districts',
      'level': AchievementLevel.silver,
      'icon': Icons.explore,
      'target': 5,
    },
    {
      'id': 'hometown_hero',
      'name': 'Local Hero',
      'description': 'Reach Top 5 in Hometown Leaderboard',
      'level': AchievementLevel.gold,
      'icon': Icons.shield,
      'target': 5,
    },
    {
      'id': 'global_legend',
      'name': 'Global Legend',
      'description': 'Reach Top 10 in Global Leaderboard',
      'level': AchievementLevel.diamond,
      'icon': Icons.workspace_premium, // Crown icon replacement
      'target': 10,
    },
    {
      'id': 'accuracy_king',
      'name': 'Sharp Shooter',
      'description': 'Average accuracy > 90% (after 10 quizzes)',
      'level': AchievementLevel.gold,
      'icon': Icons.track_changes,
      'target': 90,
    },
  ];

  /// Gets all achievements with their current status for the user
  static Future<List<Achievement>> getAchievements() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return [];

      // Fetch unlocked achievements from DB
      final response = await _supabase
          .from('user_achievements')
          .select()
          .eq('user_id', user.id);

      final List<dynamic> unlockedData = response as List<dynamic>;
      final Map<String, dynamic> unlockedMap = {
        for (var item in unlockedData) item['achievement_id'] as String: item
      };

      // Get current stats to calculate progress for locked ones
      // In a real app, we might want to pass these in to avoid redundant calls
      // For now, let's assume we fetch them here or they are pre-loaded
      final statsResponse = await _supabase.rpc('get_user_stats', params: {'p_user_id': user.id});
      final stats = UserStats.fromJson(statsResponse as Map<String, dynamic>);
      
      final rankData = await ScoreService.getCurrentUserRank();
      final hometown = await ScoreService.getCurrentUserHometown();
      final hometownRankData = hometown != null 
          ? await ScoreService.getCurrentUserRank(hometown: hometown)
          : null;

      return achievementDefinitions.map((def) {
        final id = def['id'] as String;
        final isUnlocked = unlockedMap.containsKey(id);
        
        double progress = calculateProgress(id, stats, rankData, hometownRankData);
        if (isUnlocked) progress = 1.0;

        return Achievement(
          id: id,
          name: def['name'] as String,
          description: def['description'] as String,
          level: def['level'] as AchievementLevel,
          icon: def['icon'] as IconData,
          isUnlocked: isUnlocked,
          unlockedAt: isUnlocked 
              ? DateTime.parse(unlockedMap[id]['unlocked_at'] as String)
              : null,
          progress: progress,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error fetching achievements: $e');
      return [];
    }
  }

  /// Calculates progress (0.0 to 1.0) for a specific achievement
  static double calculateProgress(String id, UserStats stats, UserRankData? globalRank, UserRankData? hometownRank) {
    switch (id) {
      case 'first_quiz':
        return stats.quizzesPlayed >= 1 ? 1.0 : 0.0;
      case 'quiz_enthusiast':
        return (stats.quizzesPlayed / 10).clamp(0.0, 1.0);
      case 'quiz_master':
        return (stats.quizzesPlayed / 50).clamp(0.0, 1.0);
      case 'perfect_score':
        // We can't track partial progress for "any" quiz easily without more DB fields, 
        // so it's 0 or 1.
        return 0.0; 
      case 'speed_demon':
        return (stats.timeBonuses / 100).clamp(0.0, 1.0);
      case 'top_scorer':
        return (stats.highestScore / 100).clamp(0.0, 1.0);
      case 'district_explorer':
        return (stats.distinctCategories / 5).clamp(0.0, 1.0);
      case 'hometown_hero':
        if (hometownRank == null) return 0.0;
        if (hometownRank.rank <= 5) return 1.0;
        return (5 / hometownRank.rank).clamp(0.0, 0.9); // Approximate progress
      case 'global_legend':
        if (globalRank == null) return 0.0;
        if (globalRank.rank <= 10) return 1.0;
        return (10 / globalRank.rank).clamp(0.0, 0.9);
      case 'accuracy_king':
        if (stats.quizzesPlayed < 10) return (stats.quizzesPlayed / 10) * 0.5;
        return (stats.accuracy / 90).clamp(0.0, 1.0);
      default:
        return 0.0;
    }
  }

  /// Checks and unlocks new achievements based on current session and total stats
  /// [sessionData] is optional - if null, only checks cumulative stats (sync mode)
  static Future<List<Achievement>> checkAndUnlockAchievements({
    required UserStats totalStats,
    QuizScoreData? sessionData,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return [];

      final List<String> toUnlock = [];

      // 1. First Quiz
      if (totalStats.quizzesPlayed >= 1) toUnlock.add('first_quiz');
      
      // 2. Quiz Enthusiast (10)
      if (totalStats.quizzesPlayed >= 10) toUnlock.add('quiz_enthusiast');
      
      // 3. Quiz Master (50)
      if (totalStats.quizzesPlayed >= 50) toUnlock.add('quiz_master');
      
      // 4. Perfect Score (Session dependent)
      if (sessionData != null && 
          sessionData.correctAnswers == sessionData.totalQuestions && 
          sessionData.totalQuestions > 0) {
        toUnlock.add('perfect_score');
      }
      
      // 5. Speed Demon (100 time bonus)
      if (totalStats.timeBonuses >= 100) toUnlock.add('speed_demon');
      
      // 6. Top Scorer (100+ points)
      // Check total high score OR current session score
      if (totalStats.highestScore >= 100 || (sessionData?.score ?? 0) >= 100) {
        toUnlock.add('top_scorer');
      }
      
      // 7. District Explorer (5 unique)
      if (totalStats.distinctCategories >= 5) toUnlock.add('district_explorer');

      // (Leaderboard achievements usually checked on profile/leaderboard load, 
      // but we can check rank here if we fetch it)
      final globalRank = await ScoreService.getCurrentUserRank();
      if (globalRank != null && globalRank.rank <= 10) toUnlock.add('global_legend');

      final hometown = await ScoreService.getCurrentUserHometown();
      if (hometown != null) {
        final hometownRank = await ScoreService.getCurrentUserRank(hometown: hometown);
        if (hometownRank != null && hometownRank.rank <= 5) toUnlock.add('hometown_hero');
      }

      // 10. Accuracy King
      if (totalStats.quizzesPlayed >= 10 && totalStats.accuracy >= 90) toUnlock.add('accuracy_king');

      // Fetch existing achievements to avoid duplicates
      final existingResponse = await _supabase
          .from('user_achievements')
          .select('achievement_id')
          .eq('user_id', user.id);
      
      final existingIds = (existingResponse as List).map((e) => e['achievement_id'] as String).toSet();
      
      final newUnlocks = toUnlock.where((id) => !existingIds.contains(id)).toList();
      
      if (newUnlocks.isEmpty) return [];

      // Save new unlocks
      final List<Map<String, dynamic>> toInsert = newUnlocks.map((id) => {
        'user_id': user.id,
        'achievement_id': id,
      }).toList();

      await _supabase.from('user_achievements').insert(toInsert);

      // Return the newly unlocked achievements (minimal info)
      return achievementDefinitions
          .where((def) => newUnlocks.contains(def['id']))
          .map((def) => Achievement(
                id: def['id'] as String,
                name: def['name'] as String,
                description: def['description'] as String,
                level: def['level'] as AchievementLevel,
                icon: def['icon'] as IconData,
                isUnlocked: true,
                unlockedAt: DateTime.now(),
                progress: 1.0,
              ))
          .toList();
    } catch (e) {
      debugPrint('Error checking achievements: $e');
      return [];
    }
  }
  /// Gets rank title based on score and optional hometown
  static String getRankTitle(int score, {String? hometown}) {
    final city = hometown ?? 'Quiz';
    final suffix = _getRankSuffix(score);
    return '$city $suffix';
  }

  static String _getRankSuffix(int score) {
    if (score < 100) return 'Novice';
    if (score < 500) return 'Scout';
    if (score < 1000) return 'Explorer';
    if (score < 2000) return 'Captain';
    if (score < 5000) return 'Master';
    return 'Hero';
  }

  /// Gets progress to next rank (0.0 to 1.0)
  static double getRankProgress(int score) {
    if (score < 100) return score / 100.0;
    if (score < 500) return (score - 100) / 400.0;
    if (score < 1000) return (score - 500) / 500.0;
    if (score < 2000) return (score - 1000) / 1000.0;
    if (score < 5000) return (score - 2000) / 3000.0;
    return 1.0;
  }
}
