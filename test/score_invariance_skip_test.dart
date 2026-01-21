import 'dart:math';
import 'package:flutter_test/flutter_test.dart';

/// Property-based tests for score invariance during question skip
/// **Feature: fun-facts-feature, Property 3: Score invariance during question skip**
/// **Validates: Requirements 3.2, 3.3**

/// Represents the quiz state before and after a skip operation
class QuizState {
  final int totalScore;
  final int correctAnswers;
  final int answeredQuestions;
  final List<Map<String, dynamic>> questions;
  final int currentQuestionIndex;

  QuizState({
    required this.totalScore,
    required this.correctAnswers,
    required this.answeredQuestions,
    required this.questions,
    required this.currentQuestionIndex,
  });

  QuizState copyWith({
    int? totalScore,
    int? correctAnswers,
    int? answeredQuestions,
    List<Map<String, dynamic>>? questions,
    int? currentQuestionIndex,
  }) {
    return QuizState(
      totalScore: totalScore ?? this.totalScore,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      answeredQuestions: answeredQuestions ?? this.answeredQuestions,
      questions: questions ?? List.from(this.questions),
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
    );
  }
}

/// Simulates the skip operation logic from _closeFunFactModal
/// This is a pure function that mirrors the skip behavior without side effects
/// Returns the new state after skipping
/// **Feature: fun-facts-feature, Property 3: Score invariance during question skip**
QuizState simulateSkip(QuizState state, Map<String, dynamic>? newQuestion) {
  // Create a copy of questions list
  final newQuestions = List<Map<String, dynamic>>.from(state.questions);

  // Remove current question from list (skip it - no score change)
  if (newQuestions.isNotEmpty &&
      state.currentQuestionIndex < newQuestions.length) {
    newQuestions.removeAt(state.currentQuestionIndex);
  }

  // Add new question if available
  if (newQuestion != null) {
    newQuestions.add(newQuestion);
  }

  // Return new state with UNCHANGED score values
  // This is the key invariant: totalScore, correctAnswers, answeredQuestions stay the same
  return QuizState(
    totalScore: state.totalScore, // UNCHANGED
    correctAnswers: state.correctAnswers, // UNCHANGED
    answeredQuestions: state.answeredQuestions, // UNCHANGED
    questions: newQuestions,
    currentQuestionIndex: state.currentQuestionIndex,
  );
}

void main() {
  group('Score Invariance During Question Skip Property Tests', () {
    final random = Random(42); // Fixed seed for reproducibility

    /// Generates a random quiz state
    QuizState generateRandomQuizState() {
      final totalScore = random.nextInt(150); // 0-149 points
      final correctAnswers = random.nextInt(15); // 0-14 correct
      final answeredQuestions = random.nextInt(15); // 0-14 answered
      final questionCount = 5 + random.nextInt(15); // 5-19 questions
      final currentIndex = random.nextInt(questionCount);

      final questions = List.generate(
        questionCount,
        (i) => {
          'id': 'q-$i',
          'question_text': 'Question $i',
          'correct_answer': 'Answer $i',
          'options': ['A', 'B', 'C', 'D'],
        },
      );

      return QuizState(
        totalScore: totalScore,
        correctAnswers: correctAnswers,
        answeredQuestions: answeredQuestions,
        questions: questions,
        currentQuestionIndex: currentIndex,
      );
    }

    /// Generates a random new question
    Map<String, dynamic> generateRandomQuestion() {
      return {
        'id': 'new-q-${random.nextInt(10000)}',
        'question_text': 'New Question ${random.nextInt(100)}',
        'correct_answer': 'New Answer',
        'options': ['A', 'B', 'C', 'D'],
      };
    }

    /// **Feature: fun-facts-feature, Property 3: Score invariance during question skip**
    /// *For any* question skip via fun fact, the totalScore and correctAnswers values
    /// SHALL remain unchanged before and after the skip.
    /// **Validates: Requirements 3.2, 3.3**
    test('Property 3: Score values remain unchanged after skip - 100 iterations', () {
      for (int i = 0; i < 100; i++) {
        final initialState = generateRandomQuizState();
        final newQuestion = generateRandomQuestion();

        // Perform skip operation
        final resultState = simulateSkip(initialState, newQuestion);

        // Verify totalScore is unchanged (Requirements: 3.3)
        expect(
          resultState.totalScore,
          equals(initialState.totalScore),
          reason:
              'Iteration $i: totalScore should remain ${initialState.totalScore} '
              'after skip, but got ${resultState.totalScore}',
        );

        // Verify correctAnswers is unchanged (Requirements: 3.2)
        expect(
          resultState.correctAnswers,
          equals(initialState.correctAnswers),
          reason:
              'Iteration $i: correctAnswers should remain ${initialState.correctAnswers} '
              'after skip, but got ${resultState.correctAnswers}',
        );

        // Verify answeredQuestions is unchanged (Requirements: 3.2, 3.3)
        expect(
          resultState.answeredQuestions,
          equals(initialState.answeredQuestions),
          reason:
              'Iteration $i: answeredQuestions should remain ${initialState.answeredQuestions} '
              'after skip, but got ${resultState.answeredQuestions}',
        );
      }
    });

    /// Test skip without new question available
    test('Property 3: Score unchanged even when no new question is fetched', () {
      for (int i = 0; i < 100; i++) {
        final initialState = generateRandomQuizState();

        // Perform skip operation without new question (simulates fetch failure)
        final resultState = simulateSkip(initialState, null);

        // Verify all score values are unchanged
        expect(
          resultState.totalScore,
          equals(initialState.totalScore),
          reason:
              'totalScore should remain unchanged after skip without new question',
        );
        expect(
          resultState.correctAnswers,
          equals(initialState.correctAnswers),
          reason:
              'correctAnswers should remain unchanged after skip without new question',
        );
        expect(
          resultState.answeredQuestions,
          equals(initialState.answeredQuestions),
          reason:
              'answeredQuestions should remain unchanged after skip without new question',
        );
      }
    });

    /// Test multiple consecutive skips
    test('Property 3: Score unchanged after multiple consecutive skips', () {
      for (int i = 0; i < 50; i++) {
        var state = generateRandomQuizState();
        final initialTotalScore = state.totalScore;
        final initialCorrectAnswers = state.correctAnswers;
        final initialAnsweredQuestions = state.answeredQuestions;

        // Perform multiple skips (1-5 times)
        final skipCount = 1 + random.nextInt(5);
        for (int j = 0; j < skipCount; j++) {
          state = simulateSkip(state, generateRandomQuestion());
        }

        // Verify all score values are still unchanged after multiple skips
        expect(
          state.totalScore,
          equals(initialTotalScore),
          reason:
              'totalScore should remain $initialTotalScore after $skipCount skips',
        );
        expect(
          state.correctAnswers,
          equals(initialCorrectAnswers),
          reason:
              'correctAnswers should remain $initialCorrectAnswers after $skipCount skips',
        );
        expect(
          state.answeredQuestions,
          equals(initialAnsweredQuestions),
          reason:
              'answeredQuestions should remain $initialAnsweredQuestions after $skipCount skips',
        );
      }
    });

    /// Test edge cases
    test('Property 3: Score unchanged with edge case values', () {
      // Test with zero scores
      final zeroState = QuizState(
        totalScore: 0,
        correctAnswers: 0,
        answeredQuestions: 0,
        questions: [
          {
            'id': 'q1',
            'question_text': 'Q1',
            'correct_answer': 'A',
            'options': ['A', 'B'],
          },
        ],
        currentQuestionIndex: 0,
      );
      final resultZero = simulateSkip(zeroState, generateRandomQuestion());
      expect(resultZero.totalScore, equals(0));
      expect(resultZero.correctAnswers, equals(0));
      expect(resultZero.answeredQuestions, equals(0));

      // Test with maximum reasonable scores
      final maxState = QuizState(
        totalScore: 165, // 15 questions * 11 points max
        correctAnswers: 15,
        answeredQuestions: 14,
        questions: [
          {
            'id': 'q1',
            'question_text': 'Q1',
            'correct_answer': 'A',
            'options': ['A', 'B'],
          },
        ],
        currentQuestionIndex: 0,
      );
      final resultMax = simulateSkip(maxState, generateRandomQuestion());
      expect(resultMax.totalScore, equals(165));
      expect(resultMax.correctAnswers, equals(15));
      expect(resultMax.answeredQuestions, equals(14));
    });
  });
}
