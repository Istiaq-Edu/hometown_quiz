import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:hometown_quiz/pages/quiz.dart';

/// Property-based tests for score calculation
/// **Feature: quiz-feedback-results, Property 1: Score calculation correctness**
/// **Feature: quiz-feedback-results, Property 2: Zero points for incorrect answers**
/// **Validates: Requirements 2.1, 2.2, 2.3**
void main() {
  group('Score Calculation Property Tests', () {
    final random = Random(42); // Fixed seed for reproducibility

    /// **Feature: quiz-feedback-results, Property 1: Score calculation correctness**
    /// *For any* correct answer with time taken under 5 seconds, the points awarded
    /// SHALL equal 11 (base 10 + 10% bonus rounded).
    /// **Validates: Requirements 2.1, 2.2**
    test(
      'Property 1: Correct answers under 5 seconds always yield 11 points',
      () {
        // Run 100 iterations with random time values under 5 seconds
        for (int i = 0; i < 100; i++) {
          final timeTaken = random.nextInt(5); // 0, 1, 2, 3, or 4 seconds
          final points = QuizPageState.calculatePoints(true, timeTaken);

          expect(
            points,
            equals(11),
            reason:
                'Correct answer in $timeTaken seconds should yield 11 points (10 base + 10% bonus)',
          );
        }
      },
    );

    /// **Feature: quiz-feedback-results, Property 1: Score calculation correctness**
    /// *For any* correct answer with time taken 5 seconds or more, the points awarded
    /// SHALL equal 10 (base points only).
    /// **Validates: Requirements 2.1**
    test('Property 1: Correct answers at 5+ seconds always yield 10 points', () {
      // Run 100 iterations with random time values >= 5 seconds
      for (int i = 0; i < 100; i++) {
        final timeTaken = 5 + random.nextInt(11); // 5 to 15 seconds
        final points = QuizPageState.calculatePoints(true, timeTaken);

        expect(
          points,
          equals(10),
          reason:
              'Correct answer in $timeTaken seconds should yield 10 base points',
        );
      }
    });

    /// **Feature: quiz-feedback-results, Property 2: Zero points for incorrect answers**
    /// *For any* incorrect answer regardless of time taken, the points awarded SHALL equal 0.
    /// **Validates: Requirements 2.3**
    test(
      'Property 2: Incorrect answers always yield 0 points regardless of time',
      () {
        // Run 100 iterations with random time values
        for (int i = 0; i < 100; i++) {
          final timeTaken = random.nextInt(16); // 0 to 15 seconds
          final points = QuizPageState.calculatePoints(false, timeTaken);

          expect(
            points,
            equals(0),
            reason:
                'Incorrect answer in $timeTaken seconds should yield 0 points',
          );
        }
      },
    );

    /// Edge case: Boundary at exactly 5 seconds
    test('Boundary: Correct answer at exactly 5 seconds yields 10 points', () {
      final points = QuizPageState.calculatePoints(true, 5);
      expect(points, equals(10));
    });

    /// Edge case: Boundary at exactly 4 seconds (just under threshold)
    test('Boundary: Correct answer at exactly 4 seconds yields 11 points', () {
      final points = QuizPageState.calculatePoints(true, 4);
      expect(points, equals(11));
    });
  });
}
