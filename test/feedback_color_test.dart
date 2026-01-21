import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hometown_quiz/pages/quiz.dart';

/// Property-based tests for feedback color logic
/// **Feature: quiz-feedback-results, Property 5: Feedback color correctness**
/// **Validates: Requirements 1.1, 1.2**
void main() {
  group('Feedback Color Property Tests', () {
    final random = Random(42); // Fixed seed for reproducibility

    // Helper to generate random option strings
    String generateRandomOption(Random random) {
      const chars = 'abcdefghijklmnopqrstuvwxyz';
      final length = 3 + random.nextInt(10);
      return List.generate(
        length,
        (_) => chars[random.nextInt(chars.length)],
      ).join();
    }

    // Generate a list of unique options
    List<String> generateOptions(Random random, int count) {
      final options = <String>{};
      while (options.length < count) {
        options.add(generateRandomOption(random));
      }
      return options.toList();
    }

    /// **Feature: quiz-feedback-results, Property 5: Feedback color correctness**
    /// *For any* question in feedback state, the correct answer option SHALL have
    /// green highlighting.
    /// **Validates: Requirements 1.1**
    test(
      'Property 5a: Correct answer always shows green when showing feedback',
      () {
        for (int i = 0; i < 100; i++) {
          final options = generateOptions(random, 4);
          final correctAnswer = options[random.nextInt(options.length)];
          // Selected answer can be any option or empty
          final selectedAnswer = random.nextBool()
              ? options[random.nextInt(options.length)]
              : '';

          // Test background color
          final bgColor = QuizPageState.computeOptionBackgroundColor(
            option: correctAnswer,
            correctAnswer: correctAnswer,
            selectedAnswer: selectedAnswer,
            showingFeedback: true,
          );

          expect(
            bgColor,
            equals(QuizPageState.greenBackground),
            reason:
                'Correct answer "$correctAnswer" should have green background when showing feedback',
          );

          // Test border color
          final borderColor = QuizPageState.computeOptionBorderColor(
            option: correctAnswer,
            correctAnswer: correctAnswer,
            selectedAnswer: selectedAnswer,
            showingFeedback: true,
          );

          expect(
            borderColor,
            equals(QuizPageState.greenBorder),
            reason:
                'Correct answer "$correctAnswer" should have green border when showing feedback',
          );
        }
      },
    );

    /// **Feature: quiz-feedback-results, Property 5: Feedback color correctness**
    /// *For any* question in feedback state where the selected answer differs from
    /// correct, the selected answer SHALL have red highlighting.
    /// **Validates: Requirements 1.2**
    test(
      'Property 5b: Selected incorrect answer shows red when showing feedback',
      () {
        for (int i = 0; i < 100; i++) {
          final options = generateOptions(random, 4);
          final correctIndex = random.nextInt(options.length);
          final correctAnswer = options[correctIndex];

          // Select a different option (incorrect answer)
          int selectedIndex;
          do {
            selectedIndex = random.nextInt(options.length);
          } while (selectedIndex == correctIndex);
          final selectedAnswer = options[selectedIndex];

          // Test background color for selected incorrect answer
          final bgColor = QuizPageState.computeOptionBackgroundColor(
            option: selectedAnswer,
            correctAnswer: correctAnswer,
            selectedAnswer: selectedAnswer,
            showingFeedback: true,
          );

          expect(
            bgColor,
            equals(QuizPageState.redBackground),
            reason:
                'Selected incorrect answer "$selectedAnswer" should have red background when showing feedback',
          );

          // Test border color for selected incorrect answer
          final borderColor = QuizPageState.computeOptionBorderColor(
            option: selectedAnswer,
            correctAnswer: correctAnswer,
            selectedAnswer: selectedAnswer,
            showingFeedback: true,
          );

          expect(
            borderColor,
            equals(QuizPageState.redBorder),
            reason:
                'Selected incorrect answer "$selectedAnswer" should have red border when showing feedback',
          );
        }
      },
    );

    /// **Feature: quiz-feedback-results, Property 5: Feedback color correctness**
    /// *For any* question in feedback state, non-selected incorrect options SHALL
    /// have default (white/gray) colors.
    /// **Validates: Requirements 1.1, 1.2**
    test(
      'Property 5c: Non-selected incorrect options have default colors when showing feedback',
      () {
        for (int i = 0; i < 100; i++) {
          final options = generateOptions(random, 4);
          final correctIndex = random.nextInt(options.length);
          final correctAnswer = options[correctIndex];

          // Select an answer (could be correct or incorrect)
          final selectedAnswer = options[random.nextInt(options.length)];

          // Test each non-selected, non-correct option
          for (final option in options) {
            if (option == correctAnswer || option == selectedAnswer) continue;

            final bgColor = QuizPageState.computeOptionBackgroundColor(
              option: option,
              correctAnswer: correctAnswer,
              selectedAnswer: selectedAnswer,
              showingFeedback: true,
            );

            expect(
              bgColor,
              equals(Colors.white),
              reason:
                  'Non-selected incorrect option "$option" should have white background',
            );

            final borderColor = QuizPageState.computeOptionBorderColor(
              option: option,
              correctAnswer: correctAnswer,
              selectedAnswer: selectedAnswer,
              showingFeedback: true,
            );

            expect(
              borderColor,
              equals(QuizPageState.defaultBorder),
              reason:
                  'Non-selected incorrect option "$option" should have default border',
            );
          }
        }
      },
    );

    /// When NOT showing feedback, colors should follow normal selection logic
    test(
      'Property 5d: Normal state uses selection-based colors (not feedback colors)',
      () {
        for (int i = 0; i < 100; i++) {
          final options = generateOptions(random, 4);
          final correctAnswer = options[random.nextInt(options.length)];
          final selectedAnswer = options[random.nextInt(options.length)];

          for (final option in options) {
            final bgColor = QuizPageState.computeOptionBackgroundColor(
              option: option,
              correctAnswer: correctAnswer,
              selectedAnswer: selectedAnswer,
              showingFeedback: false,
            );

            final borderColor = QuizPageState.computeOptionBorderColor(
              option: option,
              correctAnswer: correctAnswer,
              selectedAnswer: selectedAnswer,
              showingFeedback: false,
            );

            if (option == selectedAnswer) {
              expect(
                bgColor,
                equals(QuizPageState.selectedBackground),
                reason: 'Selected option should have selected background',
              );
              expect(
                borderColor,
                equals(QuizPageState.selectedBorder),
                reason: 'Selected option should have selected border',
              );
            } else {
              expect(
                bgColor,
                equals(Colors.white),
                reason: 'Non-selected option should have white background',
              );
              expect(
                borderColor,
                equals(QuizPageState.defaultBorder),
                reason: 'Non-selected option should have default border',
              );
            }

            // Verify no green/red colors appear when not showing feedback
            expect(
              bgColor,
              isNot(equals(QuizPageState.greenBackground)),
              reason:
                  'Green background should not appear when not showing feedback',
            );
            expect(
              bgColor,
              isNot(equals(QuizPageState.redBackground)),
              reason:
                  'Red background should not appear when not showing feedback',
            );
          }
        }
      },
    );
  });
}
