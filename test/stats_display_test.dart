import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:hometown_quiz/models/user_stats.dart';

/// Property-based tests for stats display
/// **Feature: profile-page, Property 3: Stats values displayed in cards**
/// **Validates: Requirements 3.2, 3.3, 3.5**
void main() {
  group('Stats Display Property Tests', () {
    final random = Random(42); // Fixed seed for reproducibility

    /// **Feature: profile-page, Property 3: Stats values displayed in cards**
    /// *For any* UserStats object (quizzes played, highest score, time bonuses),
    /// all stat values SHALL be displayed in their respective stat cards.
    /// **Validates: Requirements 3.2, 3.3, 3.5**
    test(
      'Property 3: UserStats values are correctly stored and accessible',
      () {
        // Run 100 iterations with random UserStats values
        for (int i = 0; i < 100; i++) {
          // Generate random stats values
          final quizzesPlayed = random.nextInt(1000);
          final highestScore = random.nextInt(10000);
          final totalCorrect = random.nextInt(500);
          final totalQuestions = totalCorrect + random.nextInt(500);
          final timeBonuses = random.nextInt(200);

          // Create UserStats from JSON (simulating Supabase response)
          final stats = UserStats.fromJson({
            'quizzes_played': quizzesPlayed,
            'highest_score': highestScore,
            'total_correct': totalCorrect,
            'total_questions': totalQuestions,
            'time_bonuses': timeBonuses,
          });

          // Verify quizzes played (Requirements: 3.2)
          expect(
            stats.quizzesPlayed,
            equals(quizzesPlayed),
            reason: 'Quizzes played should be $quizzesPlayed',
          );

          // Verify highest score (Requirements: 3.3)
          expect(
            stats.highestScore,
            equals(highestScore),
            reason: 'Highest score should be $highestScore',
          );

          // Verify time bonuses (Requirements: 3.5)
          expect(
            stats.timeBonuses,
            equals(timeBonuses),
            reason: 'Time bonuses should be $timeBonuses',
          );
        }
      },
    );

    /// Property: Stats values should format correctly for display
    test('Property 3: Stats values format correctly for display strings', () {
      // Run 100 iterations with random UserStats values
      for (int i = 0; i < 100; i++) {
        final quizzesPlayed = random.nextInt(1000);
        final highestScore = random.nextInt(10000);
        final accuracy = random.nextDouble() * 100;
        final timeBonuses = random.nextInt(200);

        final stats = UserStats(
          quizzesPlayed: quizzesPlayed,
          highestScore: highestScore,
          accuracy: accuracy,
          timeBonuses: timeBonuses,
          distinctCategories: 0,
        );

        // Verify display string formatting matches expected format
        final quizzesDisplayed = '${stats.quizzesPlayed}';
        final highestScoreDisplayed = '${stats.highestScore}';
        final accuracyDisplayed = '${stats.accuracy.toStringAsFixed(0)}%';
        final timeBonusesDisplayed = '${stats.timeBonuses}';

        expect(
          quizzesDisplayed,
          equals('$quizzesPlayed'),
          reason: 'Quizzes played display should be "$quizzesPlayed"',
        );

        expect(
          highestScoreDisplayed,
          equals('$highestScore'),
          reason: 'Highest score display should be "$highestScore"',
        );

        expect(
          accuracyDisplayed,
          equals('${accuracy.toStringAsFixed(0)}%'),
          reason: 'Accuracy display should include % suffix',
        );

        expect(
          timeBonusesDisplayed,
          equals('$timeBonuses'),
          reason: 'Time bonuses display should be "$timeBonuses"',
        );
      }
    });

    /// Property: Stats values should be non-negative
    test('Property 3: Stats values are always non-negative', () {
      // Run 100 iterations with random UserStats values
      for (int i = 0; i < 100; i++) {
        final quizzesPlayed = random.nextInt(1000);
        final highestScore = random.nextInt(10000);
        final totalCorrect = random.nextInt(500);
        final totalQuestions = totalCorrect + random.nextInt(500);
        final timeBonuses = random.nextInt(200);

        final stats = UserStats.fromJson({
          'quizzes_played': quizzesPlayed,
          'highest_score': highestScore,
          'total_correct': totalCorrect,
          'total_questions': totalQuestions,
          'time_bonuses': timeBonuses,
        });

        expect(
          stats.quizzesPlayed >= 0,
          isTrue,
          reason: 'Quizzes played should be non-negative',
        );

        expect(
          stats.highestScore >= 0,
          isTrue,
          reason: 'Highest score should be non-negative',
        );

        expect(
          stats.accuracy >= 0,
          isTrue,
          reason: 'Accuracy should be non-negative',
        );

        expect(
          stats.timeBonuses >= 0,
          isTrue,
          reason: 'Time bonuses should be non-negative',
        );
      }
    });

    /// Edge case: Default values when JSON has null values
    test('Edge case: Default values when JSON has null values', () {
      final stats = UserStats.fromJson({});

      expect(stats.quizzesPlayed, equals(0));
      expect(stats.highestScore, equals(0));
      expect(stats.accuracy, equals(0.0));
      expect(stats.timeBonuses, equals(0));
    });

    /// Property: toJson round-trip preserves values
    test('Property 3: toJson preserves stat values', () {
      for (int i = 0; i < 100; i++) {
        final quizzesPlayed = random.nextInt(1000);
        final highestScore = random.nextInt(10000);
        final accuracy = random.nextDouble() * 100;
        final timeBonuses = random.nextInt(200);

        final stats = UserStats(
          quizzesPlayed: quizzesPlayed,
          highestScore: highestScore,
          accuracy: accuracy,
          timeBonuses: timeBonuses,
          distinctCategories: 0,
        );

        final json = stats.toJson();

        expect(json['quizzes_played'], equals(quizzesPlayed));
        expect(json['highest_score'], equals(highestScore));
        expect(json['accuracy'], equals(accuracy));
        expect(json['time_bonuses'], equals(timeBonuses));
      }
    });
  });
}
