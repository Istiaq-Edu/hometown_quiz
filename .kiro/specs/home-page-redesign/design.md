# Design Document: Home Page Redesign

## Overview

This design document outlines the redesign of the Hometown Quiz app's home page to improve user experience by integrating quiz categories directly into the main screen. The redesign eliminates the separate CategoryPage, adds a progress section placeholder, and implements a "Play Now" random quiz feature.

## Architecture

The redesign follows the existing Flutter architecture pattern:
- Single `HomePage` widget handles all home screen functionality
- Direct navigation to `QuizPage` with category parameter
- Stateful widget for managing user data and UI state

```
┌─────────────────────────────────────────┐
│              HomePage                    │
│  ┌─────────────────────────────────┐    │
│  │ Header (Logo, Title, Avatar)    │    │
│  ├─────────────────────────────────┤    │
│  │ Welcome Message                 │    │
│  ├─────────────────────────────────┤    │
│  │ Play Now Button (Random Quiz)   │    │
│  ├─────────────────────────────────┤    │
│  │ Progress Section (Placeholder)  │    │
│  ├─────────────────────────────────┤    │
│  │ Category Cards (3 + Events)     │    │
│  │  - Places & History             │    │
│  │  - Culture & Traditions         │    │
│  │  - Everyday Bangladesh          │    │
│  │  - Events (Coming Soon)         │    │
│  ├─────────────────────────────────┤    │
│  │ Bottom Navigation               │    │
│  └─────────────────────────────────┘    │
└─────────────────────────────────────────┘
           │
           ▼
┌─────────────────────────────────────────┐
│              QuizPage                    │
│  (receives category parameter)          │
└─────────────────────────────────────────┘
```

## Components and Interfaces

### HomePage Widget

**State Variables:**
- `userName: String` - User's display name from Supabase (existing)

**Methods:**
- `getUserName()` - Fetches user name from Supabase (existing)
- `_startRandomQuiz()` - Randomly selects a category and navigates to QuizPage
- `_startCategoryQuiz(String category)` - Navigates to QuizPage with specific category
- `_showComingSoon()` - Displays snackbar for placeholder features

**Constants:**
- `categories: List<Map<String, String>>` - List of category data (name, description, image path)

### Category Card Widget

A reusable horizontal card component for displaying quiz categories.

**Properties:**
- `title: String` - Category name
- `description: String` - Category description
- `imagePath: String` - Path to category image
- `onStartQuiz: VoidCallback` - Callback when "Start Quiz" is tapped

### Progress Section Widget

A placeholder component showing user progress.

**Properties:**
- `rankTitle: String` - Hardcoded "Dhaka Dynamo"
- `progressPercent: int` - Hardcoded 75
- `onViewProgress: VoidCallback` - Shows "Coming Soon" message

## Data Models

### Category Data Structure

```dart
final List<Map<String, String>> categories = [
  {
    'name': 'Places & History',
    'description': "Explore landmarks and Bangladesh's rich past. Difficulty adapts to you.",
    'image': 'lib/images/Place and History.png',
  },
  {
    'name': 'Culture & Traditions',
    'description': 'Quizzes on festivals, customs, and local life. Your skills determine the challenge.',
    'image': 'lib/images/Culture and Traditions.png',
  },
  {
    'name': 'Everyday Bangladesh',
    'description': 'Fun facts about daily life in our towns. Test your knowledge, watch it grow!',
    'image': 'lib/images/Everyday Bangladesh.png',
  },
];
```

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*



### Property 1: Random category selection produces valid category

*For any* invocation of the random category selection function, the result SHALL be one of the three valid category strings: "Places & History", "Culture & Traditions", or "Everyday Bangladesh".

**Validates: Requirements 2.1**

### Property 2: Category card contains all required elements

*For any* category data (name, description, image path), the rendered category card SHALL contain the category title, description text, image widget, and a "Start Quiz" button.

**Validates: Requirements 1.2**

### Property 3: Navigation receives valid category string

*For any* quiz start action (either direct category tap or random selection), the navigation to QuizPage SHALL receive a category string that matches one of the three valid categories.

**Validates: Requirements 1.3, 2.2**

### Property 4: Welcome message contains user name

*For any* non-empty user name string, the welcome message displayed on the home page SHALL contain that user name.

**Validates: Requirements 4.3**

## Error Handling

| Scenario | Handling |
|----------|----------|
| User name fetch fails | Display default "User" name |
| Category image not found | Flutter handles with error widget |
| Navigation fails | Standard Flutter navigation error handling |

## Testing Strategy

### Property-Based Testing

The project will use the `dart_quickcheck` package for property-based testing. Each property test will run a minimum of 100 iterations.

**Property Tests:**
1. **Random Category Selection Test** - Generate random seeds and verify output is always a valid category
2. **Category Card Rendering Test** - Generate various category data and verify all elements present
3. **Navigation Category Test** - Verify all navigation paths pass valid category strings
4. **Welcome Message Test** - Generate various user names and verify inclusion in greeting

### Unit Tests

1. **HomePage Widget Tests**
   - Verify category cards are rendered
   - Verify progress section is displayed
   - Verify "Play Now" button is present
   - Verify bottom navigation is present

2. **Navigation Tests**
   - Verify tapping category card navigates to QuizPage
   - Verify "Play Now" triggers navigation
   - Verify "View Full Progress" shows snackbar

### Integration Tests

1. **End-to-end flow**: Home page → Category tap → Quiz page loads with correct category
2. **Random quiz flow**: Home page → Play Now → Quiz page loads with valid category
