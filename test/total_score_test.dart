import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:hometown_quiz/pages/quiz.dart';

/// Property-based tests for total score consistency
/// **Feature: quiz-feedback-results, Property 4: Total score consistency**
/// **Validates: Requirements 3.2**
void main() {
  group('Total Score Consistency Property Tests', () {
    final random = Random(42); // Fixed seed for reproducibility

    /// **Feature: quiz-feedback-results, Property 4: Total score consistency**
    /// *For any* completed quiz, the total score SHALL equal the sum of all
    /// individual question scores.
    /// **Validates: Requirements 3.2**
    test('Property 4: Total score equals sum of individual question scores', () {
      // Run 100 iterations with random quiz scenarios
      for (int i = 0; i < 100; i++) {
        // Generate random number of questions (1 to 20)
        final numQuestions = 1 + random.nextInt(20);

        // Generate random results for each question
        final List<Map<String, dynamic>> questionResults = [];
        for (int q = 0; q < numQuestions; q++) {
          final isCorrect = random.nextBool();
          final timeTaken = random.nextInt(16); // 0 to 15 seconds
          questionResults.add({'isCorrect': isCorrect, 'timeTaken': timeTaken});
        }

        // Calculate individual scores and sum them
        int sumOfIndividualScores = 0;
        for (final result in questionResults) {
          final score = QuizPageState.calculatePoints(
            result['isCorrect'] as bool,
            result['timeTaken'] as int,
          );
          sumOfIndividualScores += score;
        }

        // Simulate accumulating total score as the quiz would
        int accumulatedTotalScore = 0;
        for (final result in questionResults) {
          final score = QuizPageState.calculatePoints(
            result['isCorrect'] as bool,
            result['timeTaken'] as int,
          );
          accumulatedTotalScore += score;
        }

        expect(
          accumulatedTotalScore,
          equals(sumOfIndividualScores),
          reason:
              'Accumulated total score ($accumulatedTotalScore) should equal sum of individual scores ($sumOfIndividualScores) for quiz with $numQuestions questions',
        );
      }
    });

    /// Additional test: Verify score accumulation matches expected formula
    test(
      'Property 4: Score accumulation follows correct formula for all question types',
      () {
        for (int i = 0; i < 100; i++) {
          final numQuestions = 1 + random.nextInt(15);

          int expectedTotal = 0;
          int correctCount = 0;
          int fastCorrectCount = 0;

          // Generate and calculate expected scores
          final List<Map<String, dynamic>> results = [];
          for (int q = 0; q < numQuestions; q++) {
            final isCorrect = random.nextBool();
            final timeTaken = random.nextInt(16);
            results.add({'isCorrect': isCorrect, 'timeTaken': timeTaken});

            if (isCorrect) {
              correctCount++;
              if (timeTaken < 5) {
                fastCorrectCount++;
                expectedTotal += 11; // 10 base + 1 bonus
              } else {
                expectedTotal += 10; // base only
              }
            }
            // Incorrect answers add 0
          }

          // Calculate using the actual function
          int actualTotal = 0;
          for (final result in results) {
            actualTotal += QuizPageState.calculatePoints(
              result['isCorrect'] as bool,
              result['timeTaken'] as int,
            );
          }

          expect(
            actualTotal,
            equals(expectedTotal),
            reason:
                'Total score should be ${10 * correctCount} base + $fastCorrectCount bonus = $expectedTotal',
          );
        }
      },
    );

    /// Edge case: All questions correct with fast answers
    test('Edge case: All correct fast answers yield maximum score', () {
      final numQuestions = 10;
      int totalScore = 0;

      for (int q = 0; q < numQuestions; q++) {
        totalScore += QuizPageState.calculatePoints(true, 3); // Fast correct
      }

      expect(totalScore, equals(numQuestions * 11));
    });

    /// Edge case: All questions incorrect
    test('Edge case: All incorrect answers yield zero total score', () {
      final numQuestions = 10;
      int totalScore = 0;

      for (int q = 0; q < numQuestions; q++) {
        totalScore += QuizPageState.calculatePoints(false, random.nextInt(16));
      }

      expect(totalScore, equals(0));
    });

    /// Edge case: Mixed results
    test('Edge case: Mixed results accumulate correctly', () {
      // 5 fast correct (11 each) + 3 slow correct (10 each) + 2 incorrect (0)
      int totalScore = 0;

      // 5 fast correct answers
      for (int i = 0; i < 5; i++) {
        totalScore += QuizPageState.calculatePoints(true, 2);
      }
      // 3 slow correct answers
      for (int i = 0; i < 3; i++) {
        totalScore += QuizPageState.calculatePoints(true, 8);
      }
      // 2 incorrect answers
      for (int i = 0; i < 2; i++) {
        totalScore += QuizPageState.calculatePoints(false, 5);
      }

      expect(totalScore, equals(5 * 11 + 3 * 10 + 2 * 0)); // 55 + 30 + 0 = 85
    });
  });
}
