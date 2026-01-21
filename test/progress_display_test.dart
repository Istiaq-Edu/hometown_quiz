import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:hometown_quiz/pages/quiz.dart';

/// Property-based tests for progress display format
/// **Feature: fun-facts-feature, Property 5: Progress display format correctness**
/// **Validates: Requirements 4.2**
void main() {
  group('Progress Display Property Tests', () {
    final random = Random(42); // Fixed seed for reproducibility

    /// **Feature: fun-facts-feature, Property 5: Progress display format correctness**
    /// *For any* answeredQuestions value N (0 to 14), the progress display SHALL
    /// show "Q {N+1} of 15" format.
    /// **Validates: Requirements 4.2**
    test(
      'Property 5: Progress display shows "Q {N+1} of 15" format for all valid values',
      () {
        // Test all valid answeredQuestions values (0 to 14)
        for (
          int answeredQuestions = 0;
          answeredQuestions < 15;
          answeredQuestions++
        ) {
          final result = QuizPageState.formatProgressDisplay(answeredQuestions);
          final expectedQuestionNumber = answeredQuestions + 1;
          final expected = 'Q$expectedQuestionNumber of 15';

          expect(
            result,
            equals(expected),
            reason:
                'When answeredQuestions=$answeredQuestions, display should be "$expected" but got "$result"',
          );
        }
      },
    );

    /// Property test with random values within valid range
    test(
      'Property 5: Progress display format is correct for random valid values',
      () {
        for (int i = 0; i < 100; i++) {
          // Generate random answeredQuestions value (0 to 14)
          final answeredQuestions = random.nextInt(15);
          final result = QuizPageState.formatProgressDisplay(answeredQuestions);

          // Verify format: "Q{number} of 15"
          expect(
            result,
            startsWith('Q'),
            reason: 'Progress display should start with "Q"',
          );
          expect(
            result,
            endsWith(' of 15'),
            reason: 'Progress display should end with " of 15"',
          );

          // Verify the question number is correct
          final expectedQuestionNumber = answeredQuestions + 1;
          expect(
            result,
            contains('$expectedQuestionNumber'),
            reason:
                'Progress display should contain question number ${expectedQuestionNumber}',
          );

          // Verify exact format
          final expected = 'Q$expectedQuestionNumber of 15';
          expect(
            result,
            equals(expected),
            reason:
                'When answeredQuestions=$answeredQuestions, display should be "$expected"',
          );
        }
      },
    );

    /// Verify the constant totalQuestionsToAnswer is 15
    test('Total questions to answer constant is 15', () {
      expect(
        QuizPageState.totalQuestionsToAnswer,
        equals(15),
        reason: 'Total questions to answer should be 15 per Requirements 4.1',
      );
    });
  });
}
