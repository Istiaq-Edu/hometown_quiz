import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:hometown_quiz/models/user_stats.dart';

/// Property-based tests for accuracy calculation
/// **Feature: profile-page, Property 4: Accuracy calculation correctness**
/// **Validates: Requirements 3.4**
void main() {
  group('Accuracy Calculation Property Tests', () {
    final random = Random(42); // Fixed seed for reproducibility

    /// **Feature: profile-page, Property 4: Accuracy calculation correctness**
    /// *For any* pair of (correct answers, total questions) where total questions > 0,
    /// the accuracy SHALL equal (correct answers / total questions) * 100.
    /// **Validates: Requirements 3.4**
    test(
      'Property 4: Accuracy equals (correct / total) * 100 for valid inputs',
      () {
        // Run 100 iterations with random values
        for (int i = 0; i < 100; i++) {
          // Generate random total questions (1 to 100)
          final totalQuestions = 1 + random.nextInt(100);
          // Generate random correct answers (0 to totalQuestions)
          final correctAnswers = random.nextInt(totalQuestions + 1);

          final accuracy = UserStats.calculateAccuracy(
            correctAnswers,
            totalQuestions,
          );
          final expectedAccuracy = (correctAnswers / totalQuestions) * 100;

          expect(
            accuracy,
            closeTo(expectedAccuracy, 0.0001),
            reason:
                'Accuracy for $correctAnswers/$totalQuestions should be $expectedAccuracy%',
          );
        }
      },
    );

    /// Edge case: Zero total questions should return 0.0 accuracy
    test('Edge case: Zero total questions returns 0.0 accuracy', () {
      final accuracy = UserStats.calculateAccuracy(0, 0);
      expect(accuracy, equals(0.0));
    });

    /// Edge case: All correct answers should return 100% accuracy
    test('Edge case: All correct answers returns 100% accuracy', () {
      for (int i = 0; i < 100; i++) {
        final totalQuestions = 1 + random.nextInt(100);
        final accuracy = UserStats.calculateAccuracy(
          totalQuestions,
          totalQuestions,
        );
        expect(accuracy, equals(100.0));
      }
    });

    /// Edge case: Zero correct answers should return 0% accuracy
    test('Edge case: Zero correct answers returns 0% accuracy', () {
      for (int i = 0; i < 100; i++) {
        final totalQuestions = 1 + random.nextInt(100);
        final accuracy = UserStats.calculateAccuracy(0, totalQuestions);
        expect(accuracy, equals(0.0));
      }
    });
  });
}
