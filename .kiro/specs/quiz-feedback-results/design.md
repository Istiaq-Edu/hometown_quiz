# Design Document: Quiz Feedback and Results Page

## Overview

This feature enhances the Hometown Quiz app with two main additions:
1. **Answer Feedback System**: Visual feedback on the quiz page showing correct/incorrect answers with color highlighting (green for correct, red for incorrect) displayed for 1.5 seconds after submission or timeout.
2. **Results Page**: A new page displayed after quiz completion showing total score, correct answers, time bonus, accuracy, and placeholder elements for future features (rank system, leaderboard).

## Architecture

The implementation follows Flutter's widget-based architecture with state management handled via StatefulWidget. The feature integrates with the existing quiz flow.

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  Category Page  │────▶│    Quiz Page    │────▶│  Results Page   │
│                 │     │  (with feedback)│     │                 │
└─────────────────┘     └─────────────────┘     └─────────────────┘
                              │                        │
                              │                        │
                              ▼                        ▼
                        Score Tracking           Category Page
                        Answer Validation        (Play Again)
```

## Components and Interfaces

### 1. QuizPage (Modified)

**New State Variables:**
- `bool showingFeedback` - Whether feedback is currently being displayed
- `bool? isCorrect` - Whether the last answer was correct (null if not yet answered)
- `int totalScore` - Running total of points earned
- `int correctAnswers` - Count of correct answers
- `int totalTimeBonus` - Accumulated time bonus points
- `int answerTime` - Time taken to answer current question (15 - timeLeft)

**New Methods:**
- `void submitAnswer()` - Validates answer, calculates score, shows feedback
- `Color getOptionColor(String option)` - Returns appropriate color based on feedback state
- `int calculatePoints(bool correct, int timeTaken)` - Calculates points with time bonus

### 2. ResultsPage (New)

**Constructor Parameters:**
- `int totalScore` - Final score to display
- `int correctAnswers` - Number of correct answers
- `int totalQuestions` - Total number of questions
- `int timeBonus` - Total time bonus earned
- `String category` - Quiz category (for potential future use)

**UI Elements:**
- Celebration header with emoji and title
- Score display card
- Stats grid (correct answers, time bonus, accuracy, rank placeholder)
- "Play Another Quiz" button
- "View Leaderboard" button (TODO placeholder)

## Data Models

### QuizResult
```dart
class QuizResult {
  final int totalScore;
  final int correctAnswers;
  final int totalQuestions;
  final int timeBonus;
  final double accuracy; // Computed: correctAnswers / totalQuestions * 100
  
  QuizResult({
    required this.totalScore,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.timeBonus,
  });
  
  double get accuracy => (correctAnswers / totalQuestions) * 100;
}
```

### Score Calculation Logic
```dart
int calculatePoints(bool isCorrect, int timeTaken) {
  if (!isCorrect) return 0;
  
  const int basePoints = 10;
  if (timeTaken < 5) {
    // 10% bonus for answering under 5 seconds
    return (basePoints * 1.1).round(); // 11 points
  }
  return basePoints;
}
```

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: Score calculation correctness
*For any* correct answer with time taken under 5 seconds, the points awarded SHALL equal 11 (base 10 + 10% bonus rounded).
**Validates: Requirements 2.1, 2.2**

### Property 2: Zero points for incorrect answers
*For any* incorrect answer regardless of time taken, the points awarded SHALL equal 0.
**Validates: Requirements 2.3**

### Property 3: Accuracy calculation correctness
*For any* quiz result with N correct answers out of M total questions, the accuracy SHALL equal (N/M) * 100 percent.
**Validates: Requirements 3.5**

### Property 4: Total score consistency
*For any* completed quiz, the total score SHALL equal the sum of all individual question scores.
**Validates: Requirements 3.2**

### Property 5: Feedback color correctness
*For any* question in feedback state, the correct answer option SHALL have green highlighting, and if the selected answer differs from correct, the selected answer SHALL have red highlighting.
**Validates: Requirements 1.1, 1.2**

## Error Handling

| Scenario | Handling |
|----------|----------|
| No questions loaded | Display "No questions available" message with back button |
| Timer expires without selection | Treat as incorrect (0 points), show correct answer in green |
| Navigation during feedback | Feedback completes before navigation proceeds |
| Invalid score data passed to Results | Use default values (0) and display gracefully |

## Testing Strategy

### Unit Tests
- Score calculation with various time values
- Accuracy percentage calculation
- Edge cases: 0 correct, all correct, single question

### Property-Based Tests
Using `flutter_test` with custom property testing:

1. **Score Calculation Property Test**
   - Generate random (isCorrect, timeTaken) pairs
   - Verify: correct + fast = 11, correct + slow = 10, incorrect = 0

2. **Accuracy Calculation Property Test**
   - Generate random (correctAnswers, totalQuestions) pairs where correctAnswers <= totalQuestions
   - Verify: accuracy = (correctAnswers / totalQuestions) * 100

3. **Total Score Consistency Property Test**
   - Generate list of random question results
   - Verify: sum of individual scores equals total score

### Widget Tests
- Feedback display shows correct colors
- Results page displays all required statistics
- Navigation works correctly from Results page
