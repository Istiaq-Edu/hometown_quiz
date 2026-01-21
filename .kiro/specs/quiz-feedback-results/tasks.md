# Implementation Plan

- [x] 1. Add score tracking and feedback state to QuizPage





  - [x] 1.1 Add new state variables for feedback and scoring


    - Add `showingFeedback`, `isCorrect`, `totalScore`, `correctAnswers`, `totalTimeBonus`, `answerTime` state variables
    - _Requirements: 1.1, 2.1_
  - [x] 1.2 Implement score calculation function


    - Create `calculatePoints(bool isCorrect, int timeTaken)` method
    - Return 11 points for correct answers under 5 seconds, 10 for correct answers 5+ seconds, 0 for incorrect
    - _Requirements: 2.1, 2.2, 2.3_
  - [x] 1.3 Write property test for score calculation


    - **Property 1: Score calculation correctness**
    - **Property 2: Zero points for incorrect answers**
    - **Validates: Requirements 2.1, 2.2, 2.3**
-

- [x] 2. Implement answer submission with feedback display




  - [x] 2.1 Create submitAnswer method


    - Stop timer, calculate answer time, check correctness against `correct_answer` field
    - Calculate and accumulate points, update correct answer count
    - Set `showingFeedback = true` and trigger 1.5 second delay before advancing
    - _Requirements: 1.1, 1.4, 2.1, 2.2, 2.3_
  - [x] 2.2 Update timer expiry handling


    - When timer reaches zero, call submitAnswer with no selection (treat as incorrect)
    - Show feedback for 1.5 seconds before auto-advancing
    - _Requirements: 1.3, 2.4_
  - [x] 2.3 Update Next button to call submitAnswer


    - Replace direct `goToNextQuestion()` call with `submitAnswer()`
    - _Requirements: 1.1_

- [x] 3. Implement visual feedback on answer options





  - [x] 3.1 Create getOptionColor method


    - Return green for correct answer when showing feedback
    - Return red for selected incorrect answer when showing feedback
    - Return normal colors when not showing feedback
    - _Requirements: 1.1, 1.2_
  - [x] 3.2 Update answer option widgets to use feedback colors


    - Apply background and border colors based on feedback state
    - Disable tap interaction while showing feedback
    - _Requirements: 1.1, 1.2, 1.4_
  - [x] 3.3 Write property test for feedback color logic


    - **Property 5: Feedback color correctness**
    - **Validates: Requirements 1.1, 1.2**

- [x] 4. Create ResultsPage widget





  - [x] 4.1 Create results_page.dart with basic structure


    - Accept parameters: totalScore, correctAnswers, totalQuestions, timeBonus, category
    - Set up Scaffold with app theme colors
    - _Requirements: 3.1_
  - [x] 4.2 Implement celebration header section

    - Add sparkle emoji and "Fantastic Effort!" title with primary color
    - _Requirements: 3.1_
  - [x] 4.3 Implement score display card

    - Show "Total Score Earned" label and formatted score value
    - Use primary color with opacity background
    - _Requirements: 3.2_

  - [x] 4.4 Implement stats grid
    - Create 2x2 grid with: Correct Answers, Time Bonus, Accuracy, New Rank (TODO placeholder)
    - Each stat card has icon, label, and value
    - _Requirements: 3.3, 3.4, 3.5, 3.6_
  - [x] 4.5 Write property test for accuracy calculation


    - **Property 3: Accuracy calculation correctness**
    - **Validates: Requirements 3.5**

- [x] 5. Implement ResultsPage navigation buttons




  - [x] 5.1 Add "Play Another Quiz" button

    - Navigate back to category selection page when tapped
    - Style with primary color, arrow icon
    - _Requirements: 4.1_
  - [x] 5.2 Add "View Leaderboard" button as TODO placeholder

    - Display button with outline style
    - Show snackbar or do nothing on tap (placeholder for future)
    - _Requirements: 4.2_
  - [x] 5.3 Add footer text

    - Display encouraging message at bottom
    - _Requirements: 3.1_

- [x] 6. Connect QuizPage to ResultsPage





  - [x] 6.1 Update quiz completion logic


    - After last question feedback, navigate to ResultsPage with accumulated stats
    - Pass totalScore, correctAnswers, questions.length, totalTimeBonus, category
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_
  - [x] 6.2 Write property test for total score consistency


    - **Property 4: Total score consistency**
    - **Validates: Requirements 3.2**

- [ ] 7. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.
