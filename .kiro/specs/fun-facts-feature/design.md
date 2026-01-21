# Design Document: Fun Facts Feature

## Overview

This design document outlines the implementation of a Fun Facts feature for the Hometown Quiz gameplay. The feature adds a lightbulb button that appears on every 5th question, allowing users to view random fun facts about Bangladesh. When a fun fact is viewed, the current question is skipped and replaced with a new one, ensuring users always complete 15 questions.

## Architecture

The feature integrates into the existing QuizPage with minimal architectural changes.

```
┌─────────────────────────────────────────┐
│              QuizPage                    │
│  ┌─────────────────────────────────┐    │
│  │ Header (Back, Q X of 15, Timer) │    │
│  │ + Fun Facts Button (conditional)│    │
│  ├─────────────────────────────────┤    │
│  │ Question Content                │    │
│  ├─────────────────────────────────┤    │
│  │ Answer Options                  │    │
│  ├─────────────────────────────────┤    │
│  │ Progress Bar                    │    │
│  └─────────────────────────────────┘    │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │ Fun Fact Modal (overlay)        │    │
│  │  - Lightbulb icon               │    │
│  │  - "Fun Fact!" title            │    │
│  │  - Fact content                 │    │
│  │  - Category label               │    │
│  │  - "Continue Quiz" button       │    │
│  └─────────────────────────────────┘    │
└─────────────────────────────────────────┘
           │
           ▼
┌─────────────────────────────────────────┐
│          FunFactService                  │
│  - getRandomFunFact()                    │
└─────────────────────────────────────────┘
           │
           ▼
┌─────────────────────────────────────────┐
│          Supabase                        │
│  - fun_facts table                       │
│  - questions table (fetch extra)         │
└─────────────────────────────────────────┘
```

## Components and Interfaces

### QuizPage Updates

**New State Variables:**
- `showFunFactModal: bool` - Controls modal visibility
- `currentFunFact: FunFact?` - Currently displayed fun fact
- `answeredQuestions: int` - Count of actually answered questions (not skipped)

**Updated State Variables:**
- `questions: List<Map>` - Now loads 15+ questions (extra buffer for skips)

**New Methods:**
- `_isFunFactButtonVisible()` - Returns true if current question is 5th, 10th, or 15th
- `_showFunFactModal()` - Fetches random fact and shows modal
- `_closeFunFactModal()` - Closes modal and replaces current question
- `_fetchExtraQuestion()` - Fetches one additional question from Supabase

**Updated Methods:**
- `loadQuestions()` - Now loads 15 questions (+ buffer)
- `goToNextQuestion()` - Updated to track answered vs total questions

### FunFactService

A new service class for fun fact operations.

```dart
class FunFactService {
  /// Fetches a random fun fact from Supabase
  static Future<FunFact?> getRandomFunFact();
}
```

### Data Models

```dart
/// Fun fact data model
class FunFact {
  final String id;
  final String content;
  final String category;
  
  const FunFact({
    required this.id,
    required this.content,
    required this.category,
  });
  
  factory FunFact.fromJson(Map<String, dynamic> json) {
    return FunFact(
      id: json['id'] as String,
      content: json['content'] as String,
      category: json['category'] as String,
    );
  }
}
```

### Supabase Schema

**New fun_facts table:**
```sql
CREATE TABLE fun_facts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  content TEXT NOT NULL,
  category TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE fun_facts ENABLE ROW LEVEL SECURITY;

-- Allow all authenticated users to read
CREATE POLICY "Allow read access" ON fun_facts
  FOR SELECT TO authenticated USING (true);
```

**Sample data:**
```sql
INSERT INTO fun_facts (content, category) VALUES
('Sylhet is home to the largest tea gardens in Bangladesh, producing premium quality tea for export!', 'Culture & Traditions'),
('The Sundarbans is the largest mangrove forest in the world and home to the Royal Bengal Tiger.', 'Places & History'),
('Bangladesh has over 700 rivers, earning it the nickname "Land of Rivers".', 'Everyday Bangladesh'),
-- ... more facts
```

## Fun Facts Button Logic

```dart
bool _isFunFactButtonVisible() {
  // Button visible on questions 5, 10, 15 (index 4, 9, 14)
  // answeredQuestions tracks how many questions user has actually answered
  int questionNumber = answeredQuestions + 1;
  return questionNumber == 5 || questionNumber == 10 || questionNumber == 15;
}
```

## Question Skip Flow

```
User on Question 5 → Button Visible
        │
        ▼
User taps Fun Fact Button
        │
        ▼
Timer pauses, Modal appears with random fact
        │
        ▼
User taps "Continue Quiz"
        │
        ▼
Modal closes
        │
        ▼
Current question removed from list
        │
        ▼
Fetch 1 extra question, add to list
        │
        ▼
Display next question (answeredQuestions stays same)
        │
        ▼
Timer restarts
```

## Data Models

### Question Tracking

```dart
// Track answered questions separately from current index
int answeredQuestions = 0;  // Questions actually answered (not skipped)
int currentQuestionIndex = 0;  // Current position in questions list

// When user answers a question:
answeredQuestions++;
currentQuestionIndex++;

// When user skips via fun fact:
// Remove current question, fetch new one
// currentQuestionIndex stays same (points to new question)
// answeredQuestions stays same
```

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*



### Property 1: Fun facts button visibility based on question number

*For any* question number N (where N = answeredQuestions + 1), the fun facts button SHALL be visible if and only if N equals 5, 10, or 15.

**Validates: Requirements 1.1, 1.2**

### Property 2: Fun fact modal displays all required fields

*For any* FunFact object with content and category, the modal SHALL display the lightbulb icon, "Fun Fact!" title, the fact content, and the category label.

**Validates: Requirements 2.3**

### Property 3: Score invariance during question skip

*For any* question skip via fun fact, the totalScore and correctAnswers values SHALL remain unchanged before and after the skip.

**Validates: Requirements 3.2, 3.3**

### Property 4: Total answered questions equals 15

*For any* completed quiz (regardless of number of skips), the final answeredQuestions count SHALL equal 15.

**Validates: Requirements 3.4, 4.3**

### Property 5: Progress display format correctness

*For any* answeredQuestions value N (0 to 14), the progress display SHALL show "Q {N+1} of 15" format.

**Validates: Requirements 4.2**

## Error Handling

| Scenario | Handling |
|----------|----------|
| Fun fact fetch fails | Show error snackbar, close modal, continue with current question |
| Extra question fetch fails | Show error snackbar, continue with remaining questions |
| No fun facts in database | Hide fun facts button entirely |

## Testing Strategy

### Property-Based Testing

The project will use the `dart_quickcheck` package for property-based testing. Each property test will run a minimum of 100 iterations.

**Property Tests:**
1. **Button Visibility Test** - Generate random question numbers, verify visibility logic
2. **Modal Display Test** - Generate various FunFact objects, verify all fields displayed
3. **Score Invariance Test** - Simulate skips, verify score unchanged
4. **Total Questions Test** - Simulate various skip patterns, verify final count is 15
5. **Progress Format Test** - Generate answeredQuestions values, verify display format

### Unit Tests

1. **FunFactService Tests**
   - Test getRandomFunFact returns valid FunFact object
   - Test error handling when fetch fails

2. **QuizPage Logic Tests**
   - Test _isFunFactButtonVisible for various question numbers
   - Test question skip logic
   - Test extra question fetching

### Integration Tests

1. **Fun fact flow**: Tap button → Modal appears → Tap continue → New question displayed
2. **Skip and complete**: Skip on question 5 → Complete quiz → Verify 15 questions answered
