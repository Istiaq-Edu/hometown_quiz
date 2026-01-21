/// Aggregated user statistics model
/// (Requirements: 3.2, 3.3, 3.4, 3.5)
class UserStats {
  final int quizzesPlayed;
  final int highestScore;
  final double accuracy;
  final int timeBonuses;
  final int distinctCategories;

  const UserStats({
    required this.quizzesPlayed,
    required this.highestScore,
    required this.accuracy,
    required this.timeBonuses,
    required this.distinctCategories,
  });

  /// Calculates accuracy percentage from correct answers and total questions.
  /// Returns 0.0 if totalQuestions is 0 to avoid division by zero.
  /// (Requirements: 3.4)
  static double calculateAccuracy(int correctAnswers, int totalQuestions) {
    if (totalQuestions <= 0) {
      return 0.0;
    }
    return (correctAnswers / totalQuestions) * 100;
  }

  /// Factory constructor to create UserStats from JSON
  /// Expects JSON with: quizzes_played, highest_score, total_correct,
  /// total_questions, time_bonuses
  factory UserStats.fromJson(Map<String, dynamic> json) {
    final totalCorrect = json['total_correct'] as int? ?? 0;
    final totalQuestions = json['total_questions'] as int? ?? 0;

    return UserStats(
      quizzesPlayed: json['quizzes_played'] as int? ?? 0,
      highestScore: json['highest_score'] as int? ?? 0,
      accuracy: calculateAccuracy(totalCorrect, totalQuestions),
      timeBonuses: json['time_bonuses'] as int? ?? 0,
      distinctCategories: json['distinct_categories'] as int? ?? 0,
    );
  }

  /// Convert UserStats to JSON
  Map<String, dynamic> toJson() => {
    'quizzes_played': quizzesPlayed,
    'highest_score': highestScore,
    'accuracy': accuracy,
    'time_bonuses': timeBonuses,
    'distinct_categories': distinctCategories,
  };
}
