# Requirements Document

## Introduction

This feature enhances the Hometown Quiz app by adding answer feedback on the quiz page and a results page at the end of each quiz. When users answer questions, they will see visual feedback indicating whether their answer was correct or incorrect, with the correct answer highlighted in green. After completing all questions, users are navigated to a results page showing their total score, accuracy, time bonus, and other statistics.

## Glossary

- **Quiz Page**: The screen where users answer quiz questions one at a time
- **Results Page**: The screen displayed after completing all quiz questions showing final score and statistics
- **Answer Feedback**: Visual indication showing whether the selected answer was correct or incorrect
- **Time Bonus**: Additional points awarded for answering quickly (under 5 seconds)
- **Correct Answer**: The answer option that matches the `correct_answer` field in the question data
- **Base Points**: The standard points (10) awarded for each correct answer

## Requirements

### Requirement 1

**User Story:** As a quiz player, I want to see immediate feedback after submitting my answer, so that I know whether I answered correctly and can learn from my mistakes.

#### Acceptance Criteria

1. WHEN a user clicks the "Next" button after selecting an answer THEN the Quiz Page SHALL display the correct answer highlighted in green for 1.5 seconds before advancing
2. WHEN a user selects an incorrect answer and clicks "Next" THEN the Quiz Page SHALL display the selected answer highlighted in red and the correct answer highlighted in green
3. WHEN the timer reaches zero THEN the Quiz Page SHALL display the correct answer highlighted in green for 1.5 seconds before auto-advancing
4. WHILE answer feedback is displayed THEN the Quiz Page SHALL disable answer selection and the "Next" button

### Requirement 2

**User Story:** As a quiz player, I want my score calculated based on correct answers and speed, so that I am rewarded for both accuracy and quick thinking.

#### Acceptance Criteria

1. WHEN a user answers a question correctly THEN the Quiz Page SHALL award 10 base points
2. WHEN a user answers correctly in under 5 seconds THEN the Quiz Page SHALL award a 10% time bonus (11 points total)
3. WHEN a user answers incorrectly THEN the Quiz Page SHALL award zero points with no penalty
4. WHEN the timer expires without an answer THEN the Quiz Page SHALL award zero points

### Requirement 3

**User Story:** As a quiz player, I want to see my final results after completing a quiz, so that I can understand my performance and feel accomplished.

#### Acceptance Criteria

1. WHEN a user completes all quiz questions THEN the system SHALL navigate to the Results Page
2. WHEN the Results Page loads THEN the Results Page SHALL display the total score earned
3. WHEN the Results Page loads THEN the Results Page SHALL display the number of correct answers out of total questions
4. WHEN the Results Page loads THEN the Results Page SHALL display the total time bonus points earned
5. WHEN the Results Page loads THEN the Results Page SHALL display the accuracy percentage
6. WHEN the Results Page loads THEN the Results Page SHALL display a placeholder for the rank system (marked as TODO)

### Requirement 4

**User Story:** As a quiz player, I want navigation options on the results page, so that I can continue playing or explore other features.

#### Acceptance Criteria

1. WHEN a user taps "Play Another Quiz" on the Results Page THEN the system SHALL navigate back to the category selection page
2. WHEN the Results Page loads THEN the Results Page SHALL display a "View Leaderboard" button as a placeholder (marked as TODO)
