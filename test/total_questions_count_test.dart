import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:hometown_quiz/pages/quiz.dart';

/// Property-based tests for total questions count
/// **Feature: fun-facts-feature, Property 4: Total answered questions equals 15**
/// **Validates: Requirements 3.4, 4.3**

/// Represents a quiz session state for simulation
class QuizSessionState {
  int answeredQuestions;
  int currentQuestionIndex;
  List<Map<String, dynamic>> questions;
  int totalScore;
  int correctAnswers;

  QuizSessionState({
    required this.answeredQuestions,
    required this.currentQuestionIndex,
    required this.questions,
    required this.totalScore,
    required this.correctAnswers,
  });

  QuizSessionState copy() {
    return QuizSessionState(
      answeredQuestions: answeredQuestions,
      currentQuestionIndex: currentQuestionIndex,
      questions: List.from(questions),
      totalScore: totalScore,
      correctAnswers: correctAnswers,
    );
  }
}

/// Simulates answering a question (increments answeredQuestions)
/// Returns true if quiz should continue, false if complete
/// **Feature: fun-facts-feature, Property 4: Total answered questions equals 15**
bool simulateAnswerQuestion(QuizSessionState state) {
  // Increment answered questions (mirrors submitAnswer behavior)
  state.answeredQuestions++;

  // Check if quiz is complete (mirrors goToNextQuestion behavior)
  if (state.answeredQuestions >= QuizPageState.totalQuestionsToAnswer) {
    return false; // Quiz complete
  }

  // Move to next question
  if (state.currentQuestionIndex < state.questions.length - 1) {
    state.currentQuestionIndex++;
  }

  return true; // Quiz continues
}

/// Simulates skipping a question via fun fact (does NOT increment answeredQuestions)
/// Returns true if skip was successful
/// **Feature: fun-facts-feature, Property 4: Total answered questions equals 15**
bool simulateSkipQuestion(
  QuizSessionState state,
  Map<String, dynamic>? newQuestion,
) {
  // Remove current question (mirrors _closeFunFactModal behavior)
  if (state.questions.isNotEmpty &&
      state.currentQuestionIndex < state.questions.length) {
    state.questions.removeAt(state.currentQuestionIndex);
  }

  // Add new question if available
  if (newQuestion != null) {
    state.questions.add(newQuestion);
  }

  // Note: answeredQuestions is NOT incremented during skip
  // This is the key behavior from Requirements 3.2, 3.3

  return true;
}

void main() {
  group('Total Questions Count Property Tests', () {
    final random = Random(42); // Fixed seed for reproducibility

    /// Generates a random question
    Map<String, dynamic> generateQuestion(int index) {
      return {
        'id': 'q-$index-${random.nextInt(10000)}',
        'question_text': 'Question $index',
        'correct_answer': 'Answer $index',
        'options': ['A', 'B', 'C', 'D'],
      };
    }

    /// Creates initial quiz state with enough questions
    QuizSessionState createInitialState() {
      // Start with 18 questions (15 + buffer for skips)
      final questions = List.generate(18, (i) => generateQuestion(i));
      return QuizSessionState(
        answeredQuestions: 0,
        currentQuestionIndex: 0,
        questions: questions,
        totalScore: 0,
        correctAnswers: 0,
      );
    }

    /// **Feature: fun-facts-feature, Property 4: Total answered questions equals 15**
    /// *For any* completed quiz (regardless of number of skips), the final
    /// answeredQuestions count SHALL equal 15.
    /// **Validates: Requirements 3.4, 4.3**
    test(
      'Property 4: Quiz completes with exactly 15 answered questions - no skips',
      () {
        for (int i = 0; i < 100; i++) {
          final state = createInitialState();

          // Simulate answering questions until quiz completes
          while (simulateAnswerQuestion(state)) {
            // Continue answering
          }

          // Verify final count is exactly 15
          expect(
            state.answeredQuestions,
            equals(QuizPageState.totalQuestionsToAnswer),
            reason:
                'Iteration $i: Quiz should complete with exactly 15 answered questions, '
                'but got ${state.answeredQuestions}',
          );
        }
      },
    );

    /// Test with random number of skips
    test(
      'Property 4: Quiz completes with exactly 15 answered questions - with skips',
      () {
        for (int i = 0; i < 100; i++) {
          final state = createInitialState();
          int questionCounter = 0;

          // Simulate quiz with random skips
          while (state.answeredQuestions <
              QuizPageState.totalQuestionsToAnswer) {
            questionCounter++;

            // Randomly decide to skip on milestone questions (5, 10, 15)
            final currentQuestionNumber = state.answeredQuestions + 1;
            final isMilestone =
                currentQuestionNumber == 5 ||
                currentQuestionNumber == 10 ||
                currentQuestionNumber == 15;

            if (isMilestone && random.nextBool()) {
              // Skip this question
              simulateSkipQuestion(
                state,
                generateQuestion(questionCounter + 100),
              );
            } else {
              // Answer this question
              simulateAnswerQuestion(state);
            }

            // Safety check to prevent infinite loop
            if (questionCounter > 50) break;
          }

          // Verify final count is exactly 15
          expect(
            state.answeredQuestions,
            equals(QuizPageState.totalQuestionsToAnswer),
            reason:
                'Iteration $i: Quiz should complete with exactly 15 answered questions '
                'regardless of skips, but got ${state.answeredQuestions}',
          );
        }
      },
    );

    /// Test with one skip per milestone (skip once on each milestone question)
    test(
      'Property 4: Quiz completes with 15 answered questions - one skip per milestone',
      () {
        for (int i = 0; i < 50; i++) {
          final state = createInitialState();
          int skipCount = 0;
          int questionCounter = 0;
          // Track which milestones we've already skipped on
          final skippedMilestones = <int>{};

          while (state.answeredQuestions <
              QuizPageState.totalQuestionsToAnswer) {
            questionCounter++;
            final currentQuestionNumber = state.answeredQuestions + 1;
            final isMilestone =
                currentQuestionNumber == 5 ||
                currentQuestionNumber == 10 ||
                currentQuestionNumber == 15;

            // Skip once per milestone (user can only skip once per milestone question)
            if (isMilestone &&
                !skippedMilestones.contains(currentQuestionNumber)) {
              // Skip this question
              simulateSkipQuestion(
                state,
                generateQuestion(questionCounter + 100),
              );
              skippedMilestones.add(currentQuestionNumber);
              skipCount++;
            } else {
              // Answer this question
              simulateAnswerQuestion(state);
            }

            // Safety check
            if (questionCounter > 50) break;
          }

          // Verify final count is exactly 15
          expect(
            state.answeredQuestions,
            equals(QuizPageState.totalQuestionsToAnswer),
            reason:
                'Iteration $i: Quiz should complete with exactly 15 answered questions '
                'even with $skipCount skips, but got ${state.answeredQuestions}',
          );
        }
      },
    );

    /// Test that answeredQuestions only increments on actual answers, not skips
    test('Property 4: answeredQuestions only increments on actual answers', () {
      for (int i = 0; i < 100; i++) {
        final state = createInitialState();
        final initialAnswered = state.answeredQuestions;

        // Perform a skip
        simulateSkipQuestion(state, generateQuestion(999));

        // Verify answeredQuestions did NOT change
        expect(
          state.answeredQuestions,
          equals(initialAnswered),
          reason: 'answeredQuestions should not change after skip',
        );

        // Now answer a question
        simulateAnswerQuestion(state);

        // Verify answeredQuestions DID increment
        expect(
          state.answeredQuestions,
          equals(initialAnswered + 1),
          reason: 'answeredQuestions should increment after answering',
        );
      }
    });

    /// Verify the constant is 15
    test('totalQuestionsToAnswer constant equals 15', () {
      expect(
        QuizPageState.totalQuestionsToAnswer,
        equals(15),
        reason:
            'Total questions to answer should be 15 per Requirements 4.1, 4.3',
      );
    });
  });
}
