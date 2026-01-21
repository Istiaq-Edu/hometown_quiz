import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:hometown_quiz/pages/results_page.dart';

/// Property-based tests for accuracy calculation
/// **Feature: quiz-feedback-results, Property 3: Accuracy calculation correctness**
/// **Validates: Requirements 3.5**
void main() {
  group('Accuracy Calculation Property Tests', () {
    final random = Random(42); // Fixed seed for reproducibility

    /// **Feature: quiz-feedback-results, Property 3: Accuracy calculation correctness**
    /// *For any* quiz result with N correct answers out of M total questions,
    /// the accuracy SHALL equal (N/M) * 100 percent.
    /// **Validates: Requirements 3.5**
    test(
      'Property 3: Accuracy equals (correctAnswers / totalQuestions) * 100',
      () {
        // Run 100 iterations with random values
        for (int i = 0; i < 100; i++) {
          // Generate random total questions (1 to 50)
          final totalQuestions = 1 + random.nextInt(50);
          // Generate random correct answers (0 to totalQuestions)
          final correctAnswers = random.nextInt(totalQuestions + 1);

          final accuracy = ResultsPage.calculateAccuracy(
            correctAnswers,
            totalQuestions,
          );

          final expectedAccuracy = (correctAnswers / totalQuestions) * 100;

          expect(
            accuracy,
            closeTo(expectedAccuracy, 0.0001),
            reason:
                'Accuracy for $correctAnswers/$totalQuestions should be ${expectedAccuracy.toStringAsFixed(2)}%',
          );
        }
      },
    );

    /// Edge case: Perfect score (all correct)
    test('Edge case: Perfect score yields 100% accuracy', () {
      for (int totalQuestions = 1; totalQuestions <= 20; totalQuestions++) {
        final accuracy = ResultsPage.calculateAccuracy(
          totalQuestions,
          totalQuestions,
        );
        expect(accuracy, equals(100.0));
      }
    });

    /// Edge case: Zero correct answers
    test('Edge case: Zero correct answers yields 0% accuracy', () {
      for (int totalQuestions = 1; totalQuestions <= 20; totalQuestions++) {
        final accuracy = ResultsPage.calculateAccuracy(0, totalQuestions);
        expect(accuracy, equals(0.0));
      }
    });

    /// Edge case: Zero total questions (division by zero protection)
    test('Edge case: Zero total questions yields 0% accuracy', () {
      final accuracy = ResultsPage.calculateAccuracy(0, 0);
      expect(accuracy, equals(0.0));
    });
  });
}
