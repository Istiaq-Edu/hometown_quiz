import 'package:flutter/material.dart';
import 'package:hometown_quiz/models/achievement.dart';
import 'package:hometown_quiz/achievement_service.dart';
import 'package:hometown_quiz/profile_service.dart';

class AchievementsPage extends StatefulWidget {
  const AchievementsPage({super.key});

  @override
  State<AchievementsPage> createState() => _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage> {
  List<Achievement> achievements = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    setState(() => isLoading = true);
    
    // Sync achievements: Check if any should be unlocked based on current stats
    // This allows retroactively unlocking achievements for existing users
    try {
      final stats = await ProfileService.getUserStats();
      if (stats != null) {
        await AchievementService.checkAndUnlockAchievements(totalStats: stats);
      }
    } catch (e) {
      debugPrint('Error syncing achievements: $e');
    }

    final results = await AchievementService.getAchievements();
    setState(() {
      achievements = results;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F5),
      appBar: AppBar(
        title: const Text('Achievements', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFF8F7F5),
        elevation: 0,
        foregroundColor: const Color(0xFF221710),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFF47B25)))
          : achievements.isEmpty
              ? _buildEmptyState()
              : _buildAchievementsGrid(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.military_tech_outlined, size: 80, color: const Color(0xFFF47B25).withOpacity(0.3)),
          const SizedBox(height: 16),
          const Text('No achievements found', style: TextStyle(fontSize: 18, color: Color(0xFF221710))),
          const SizedBox(height: 8),
          const Text('Play quizzes to earn badges!', style: TextStyle(color: Color(0x99221710))),
        ],
      ),
    );
  }

  Widget _buildAchievementsGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        return _buildAchievementCard(achievement);
      },
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          if (achievement.isUnlocked)
            BoxShadow(
              color: achievement.color.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 2,
            )
          else
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
        border: achievement.isUnlocked
            ? Border.all(color: achievement.color.withOpacity(0.5), width: 2)
            : null,
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon with level background
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: achievement.isUnlocked
                        ? achievement.color.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.1),
                    shape: BoxShape.circle,
                    boxShadow: achievement.isUnlocked
                        ? [
                            BoxShadow(
                              color: achievement.color.withOpacity(0.5),
                              blurRadius: 12,
                              spreadRadius: 2,
                            )
                          ]
                        : null,
                  ),
                  child: Icon(
                    achievement.icon,
                    size: 32,
                    color:
                        achievement.isUnlocked ? achievement.color : Colors.grey,
                  ),
                ),
                const SizedBox(height: 12),
                // Name
                Text(
                  achievement.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: achievement.isUnlocked ? const Color(0xFF221710) : Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                // Description
                Text(
                  achievement.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    color: achievement.isUnlocked ? const Color(0x99221710) : Colors.grey.withOpacity(0.8),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                // Progress
                if (!achievement.isUnlocked)
                  Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: achievement.progress,
                          backgroundColor: Colors.grey.withOpacity(0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            achievement.color.withOpacity(0.5),
                          ),
                          minHeight: 4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(achievement.progress * 100).toInt()}%',
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  )
                else
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
              ],
            ),
          ),
          // Level badge
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: achievement.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                achievement.level.name.toUpperCase(),
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: achievement.color,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
