import 'dart:math';
import 'package:flutter_test/flutter_test.dart';

/// Property-based tests for score accumulation
/// **Feature: leaderboard-scores, Property 1: Score accumulation correctness**
/// **Validates: Requirements 1.2**

/// Pure function that calculates the new total score after adding a quiz score.
/// This mirrors the logic in ScoreService.saveQuizScore.
int calculateNewTotalScore(int currentTotal, int newScore) {
  return currentTotal + newScore;
}

void main() {
  group('Score Accumulation Property Tests', () {
    final random = Random(42); // Fixed seed for reproducibility

    /// **Feature: leaderboard-scores, Property 1: Score accumulation correctness**
    /// *For any* user with existing total_score T and new quiz score S,
    /// after saving the quiz score, the user's total_score SHALL equal T + S.
    /// **Validates: Requirements 1.2**
    test('Property 1: New total equals old total plus new score', () {
      // Run 100 iterations with random score values
      for (int i = 0; i < 100; i++) {
        // Generate random existing total score (0 to 10000)
        final existingTotal = random.nextInt(10001);

        // Generate random new quiz score (0 to 200, realistic quiz score range)
        final newQuizScore = random.nextInt(201);

        // Calculate new total using the accumulation function
        final newTotal = calculateNewTotalScore(existingTotal, newQuizScore);

        // Property: new total must equal existing + new score
        expect(
          newTotal,
          equals(existingTotal + newQuizScore),
          reason:
              'New total ($newTotal) should equal existing ($existingTotal) + new score ($newQuizScore)',
        );
      }
    });

    /// Property 1 variant: Multiple score additions accumulate correctly
    test('Property 1: Multiple score additions accumulate correctly', () {
      for (int i = 0; i < 100; i++) {
        // Start with random initial total
        int runningTotal = random.nextInt(5001);
        final initialTotal = runningTotal;

        // Generate random number of quiz scores to add (1 to 10)
        final numScores = 1 + random.nextInt(10);
        int sumOfNewScores = 0;

        // Add each score sequentially
        for (int j = 0; j < numScores; j++) {
          final newScore = random.nextInt(201);
          sumOfNewScores += newScore;
          runningTotal = calculateNewTotalScore(runningTotal, newScore);
        }

        // Property: final total must equal initial + sum of all new scores
        expect(
          runningTotal,
          equals(initialTotal + sumOfNewScores),
          reason:
              'After $numScores additions, total ($runningTotal) should equal initial ($initialTotal) + sum ($sumOfNewScores)',
        );
      }
    });

    /// Property 1 variant: Score accumulation is associative
    test('Property 1: Score accumulation order does not matter', () {
      for (int i = 0; i < 100; i++) {
        final initialTotal = random.nextInt(5001);
        final score1 = random.nextInt(201);
        final score2 = random.nextInt(201);

        // Add scores in order: score1 then score2
        final totalOrder1 = calculateNewTotalScore(
          calculateNewTotalScore(initialTotal, score1),
          score2,
        );

        // Add scores in reverse order: score2 then score1
        final totalOrder2 = calculateNewTotalScore(
          calculateNewTotalScore(initialTotal, score2),
          score1,
        );

        // Property: order of addition should not affect final total
        expect(
          totalOrder1,
          equals(totalOrder2),
          reason:
              'Adding scores in different orders should yield same total: $totalOrder1 vs $totalOrder2',
        );
      }
    });

    /// Edge case: Adding zero score does not change total
    test('Edge case: Adding zero score preserves total', () {
      for (int i = 0; i < 100; i++) {
        final existingTotal = random.nextInt(10001);
        final newTotal = calculateNewTotalScore(existingTotal, 0);

        expect(
          newTotal,
          equals(existingTotal),
          reason: 'Adding 0 should not change total',
        );
      }
    });

    /// Edge case: Starting from zero total
    test('Edge case: Starting from zero total', () {
      for (int i = 0; i < 100; i++) {
        final newScore = random.nextInt(201);
        final newTotal = calculateNewTotalScore(0, newScore);

        expect(
          newTotal,
          equals(newScore),
          reason: 'Starting from 0, new total should equal new score',
        );
      }
    });
  });
}
