import 'package:flutter/material.dart';
import 'package:hometown_quiz/pages/home.dart';
import 'package:hometown_quiz/pages/leaderboard_page.dart';
import 'package:hometown_quiz/score_service.dart';
import 'package:hometown_quiz/achievement_service.dart';
import 'package:hometown_quiz/profile_service.dart';
import 'package:hometown_quiz/models/user_stats.dart';
import 'package:hometown_quiz/models/achievement.dart';

/// Results page displayed after completing a quiz.
/// Shows total score, correct answers, time bonus, accuracy, and navigation options.
/// Saves quiz score to database on load.
/// (Requirements: 1.1, 1.2, 1.3, 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 4.1, 4.2, 5.1)
class ResultsPage extends StatefulWidget {
  final int totalScore;
  final int correctAnswers;
  final int totalQuestions;
  final int timeBonus;
  final String category;

  const ResultsPage({
    super.key,
    required this.totalScore,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.timeBonus,
    required this.category,
  });

  /// Calculates accuracy percentage from correct answers and total questions.
  /// Returns (correctAnswers / totalQuestions) * 100.
  /// **Validates: Requirements 3.5**
  static double calculateAccuracy(int correctAnswers, int totalQuestions) {
    if (totalQuestions == 0) return 0.0;
    return (correctAnswers / totalQuestions) * 100;
  }

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  bool _scoreSaved = false;
  bool _savingScore = false;

  @override
  void initState() {
    super.initState();
    _saveScore();
  }

  /// Saves the quiz score to the database.
  /// (Requirements: 1.1, 1.2, 1.3)
  Future<void> _saveScore() async {
    if (_scoreSaved || _savingScore) return;

    setState(() {
      _savingScore = true;
    });

    final scoreData = QuizScoreData(
      category: widget.category,
      score: widget.totalScore,
      timeBonus: widget.timeBonus,
      correctAnswers: widget.correctAnswers,
      totalQuestions: widget.totalQuestions,
    );

    final success = await ScoreService.saveQuizScore(scoreData);

    if (mounted) {
      setState(() {
        _savingScore = false;
        _scoreSaved = success;
      });

      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to save score. Tap to retry.'),
            action: SnackBarAction(label: 'Retry', onPressed: _saveScore),
            duration: const Duration(seconds: 5),
          ),
        );
      } else {
        // If score saved successfully, check for new achievements
        await _checkForNewAchievements(scoreData);
      }
    }
  }

  /// Check for new achievements and show dialog if any unlocked
  Future<void> _checkForNewAchievements(QuizScoreData sessionData) async {
    try {
      // Get updated stats
      final stats = await ProfileService.getUserStats();
      if (stats != null) {
        final newAchievements = await AchievementService.checkAndUnlockAchievements(
          totalStats: stats,
          sessionData: sessionData,
        );

        if (newAchievements.isNotEmpty && mounted) {
          _showAchievementUnlockDialog(newAchievements);
        }
      }
    } catch (e) {
      debugPrint('Error checking achievements: $e');
    }
  }

  /// Show dialog for unlocked achievements
  void _showAchievementUnlockDialog(List<Achievement> newAchievements) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎉 Achievements Unlocked!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: newAchievements.map((achievement) {
            return ListTile(
              leading: Icon(achievement.icon, color: achievement.color, size: 32),
              title: Text(achievement.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(achievement.description),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Awesome!'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accuracy = ResultsPage.calculateAccuracy(
      widget.correctAnswers,
      widget.totalQuestions,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F5),
      body: SafeArea(
        child: Column(
          children: [
            // Main content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const SizedBox(height: 32),

                      // Celebration header section (Requirement 3.1)
                      _buildCelebrationHeader(),

                      const SizedBox(height: 24),

                      // Score display card (Requirement 3.2)
                      _buildScoreCard(widget.totalScore),

                      const SizedBox(height: 24),

                      // Stats grid (Requirements 3.3, 3.4, 3.5, 3.6)
                      _buildStatsGrid(
                        accuracy,
                        widget.correctAnswers,
                        widget.totalQuestions,
                        widget.timeBonus,
                      ),

                      const SizedBox(height: 32),

                      // Navigation buttons (Requirements 4.1, 4.2, 5.1)
                      _buildNavigationButtons(context),
                    ],
                  ),
                ),
              ),
            ),

            // Footer text
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  /// Builds the celebration header with sparkle emoji and title.
  /// (Requirement 3.1)
  Widget _buildCelebrationHeader() {
    return Column(
      children: const [
        Text('✨', style: TextStyle(fontSize: 48)),
        SizedBox(height: 8),
        Text(
          'Fantastic Effort!',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: Color(0xFFF47B25),
          ),
        ),
      ],
    );
  }

  /// Builds the score display card with total score.
  /// (Requirement 3.2)
  Widget _buildScoreCard(int totalScore) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF47B25).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            'TOTAL SCORE EARNED',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: const Color(0xFFF47B25).withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatScore(totalScore),
            style: const TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.w800,
              color: Color(0xFFF47B25),
            ),
          ),
        ],
      ),
    );
  }

  /// Formats score with comma separators for thousands.
  String _formatScore(int score) {
    if (score < 1000) return score.toString();
    return score.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  /// Builds the 2x2 stats grid.
  /// (Requirements 3.3, 3.4, 3.5, 3.6)
  Widget _buildStatsGrid(
    double accuracy,
    int correctAnswers,
    int totalQuestions,
    int timeBonus,
  ) {
    return Column(
      children: [
        // First row
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.check_circle,
                label: 'Correct Answers',
                value: '$correctAnswers of $totalQuestions',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                icon: Icons.timer,
                label: 'Time Bonus',
                value: '$timeBonus Points',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Second row
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.ads_click,
                label: 'Accuracy',
                value: '${accuracy.toStringAsFixed(0)}%',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                icon: Icons.military_tech,
                label: 'New Rank',
                value: _scoreSaved
                    ? 'Saved!'
                    : (_savingScore ? '...' : 'Pending'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Builds an individual stat card with icon, label, and value.
  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F7F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFF47B25).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFF47B25), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: const Color(0xFF221710).withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF221710),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds navigation buttons section.
  /// (Requirements 4.1, 4.2)
  Widget _buildNavigationButtons(BuildContext context) {
    return Column(
      children: [
        // Play Another Quiz button (Requirement 4.1)
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // Navigate back to home page where categories are now displayed
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF47B25),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  'Play Another Quiz',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, size: 24),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // View Leaderboard button (Requirement 5.1)
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LeaderboardPage(),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFF47B25),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              side: const BorderSide(color: Color(0xFFF47B25), width: 2),
            ),
            child: const Text(
              'View Leaderboard',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the footer with encouraging message.
  /// (Requirement 3.1)
  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Text(
        'Keep playing to unlock new ranks and challenge your friends!',
        style: TextStyle(
          fontSize: 12,
          color: const Color(0xFF221710).withValues(alpha: 0.5),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
