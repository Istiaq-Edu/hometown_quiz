import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:hometown_quiz/pages/quiz.dart';

/// Property-based tests for fun facts button visibility logic
/// **Feature: fun-facts-feature, Property 1: Fun facts button visibility based on question number**
/// **Validates: Requirements 1.1, 1.2**
void main() {
  group('Fun Facts Button Visibility Property Tests', () {
    final random = Random(42); // Fixed seed for reproducibility

    /// **Feature: fun-facts-feature, Property 1: Fun facts button visibility based on question number**
    /// *For any* question number N (where N = answeredQuestions + 1), the fun facts button
    /// SHALL be visible if and only if N equals 5, 10, or 15.
    /// **Validates: Requirements 1.1, 1.2**
    test(
      'Property 1: Fun facts button visible only on questions 5, 10, and 15',
      () {
        // Test all valid answeredQuestions values (0 to 14)
        for (
          int answeredQuestions = 0;
          answeredQuestions < 15;
          answeredQuestions++
        ) {
          final result = QuizPageState.isFunFactButtonVisible(
            answeredQuestions,
          );
          final questionNumber = answeredQuestions + 1;

          // Button should be visible only on questions 5, 10, 15
          final expectedVisible =
              questionNumber == 5 ||
              questionNumber == 10 ||
              questionNumber == 15;

          expect(
            result,
            equals(expectedVisible),
            reason:
                'When answeredQuestions=$answeredQuestions (question $questionNumber), '
                'button visibility should be $expectedVisible but got $result',
          );
        }
      },
    );

    /// Property test with 100 random iterations
    test(
      'Property 1: Fun facts button visibility is correct for random valid values',
      () {
        for (int i = 0; i < 100; i++) {
          // Generate random answeredQuestions value (0 to 14)
          final answeredQuestions = random.nextInt(15);
          final result = QuizPageState.isFunFactButtonVisible(
            answeredQuestions,
          );
          final questionNumber = answeredQuestions + 1;

          // Button should be visible only on questions 5, 10, 15
          final expectedVisible =
              questionNumber == 5 ||
              questionNumber == 10 ||
              questionNumber == 15;

          expect(
            result,
            equals(expectedVisible),
            reason:
                'When answeredQuestions=$answeredQuestions (question $questionNumber), '
                'button visibility should be $expectedVisible but got $result',
          );
        }
      },
    );

    /// Verify specific milestone questions show the button
    test('Button is visible on milestone questions (5, 10, 15)', () {
      // Question 5 (answeredQuestions = 4)
      expect(
        QuizPageState.isFunFactButtonVisible(4),
        isTrue,
        reason: 'Button should be visible on question 5',
      );

      // Question 10 (answeredQuestions = 9)
      expect(
        QuizPageState.isFunFactButtonVisible(9),
        isTrue,
        reason: 'Button should be visible on question 10',
      );

      // Question 15 (answeredQuestions = 14)
      expect(
        QuizPageState.isFunFactButtonVisible(14),
        isTrue,
        reason: 'Button should be visible on question 15',
      );
    });

    /// Verify non-milestone questions hide the button
    test('Button is hidden on non-milestone questions', () {
      // Test questions 1-4 (answeredQuestions 0-3)
      for (int i = 0; i < 4; i++) {
        expect(
          QuizPageState.isFunFactButtonVisible(i),
          isFalse,
          reason: 'Button should be hidden on question ${i + 1}',
        );
      }

      // Test questions 6-9 (answeredQuestions 5-8)
      for (int i = 5; i < 9; i++) {
        expect(
          QuizPageState.isFunFactButtonVisible(i),
          isFalse,
          reason: 'Button should be hidden on question ${i + 1}',
        );
      }

      // Test questions 11-14 (answeredQuestions 10-13)
      for (int i = 10; i < 14; i++) {
        expect(
          QuizPageState.isFunFactButtonVisible(i),
          isFalse,
          reason: 'Button should be hidden on question ${i + 1}',
        );
      }
    });
  });
}
