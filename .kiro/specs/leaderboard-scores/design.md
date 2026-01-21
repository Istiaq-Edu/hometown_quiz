# Design Document: Leaderboard and Score Storage

## Overview

This feature implements a comprehensive leaderboard system with score persistence. It includes:
1. **Score Storage**: Supabase tables to store individual quiz attempts and cumulative user scores
2. **Leaderboard Page**: A new page displaying ranked users with filtering by scope (Global/My Town)
3. **Integration**: Connecting the quiz completion flow to save scores and navigate to leaderboard

## Architecture

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   Quiz Page     │────▶│  Results Page   │────▶│ Leaderboard Page│
│                 │     │  (saves score)  │     │                 │
└─────────────────┘     └─────────────────┘     └─────────────────┘
                              │                        │
                              ▼                        ▼
                        ┌─────────────────┐     ┌─────────────────┐
                        │  quiz_scores    │     │     users       │
                        │    (table)      │     │  (total_score)  │
                        └─────────────────┘     └─────────────────┘
```

## Components and Interfaces

### 1. Database Schema

**quiz_scores table (new)**
```sql
CREATE TABLE quiz_scores (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  category TEXT NOT NULL,
  score INTEGER NOT NULL,
  time_bonus INTEGER NOT NULL DEFAULT 0,
  correct_answers INTEGER NOT NULL,
  total_questions INTEGER NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

**users table (modification)**
- Add column: `total_score INTEGER NOT NULL DEFAULT 0`

### 2. ScoreService (New)

**Methods:**
- `Future<bool> saveQuizScore(QuizScoreData data)` - Saves quiz attempt and updates total score
- `Future<List<LeaderboardEntry>> getGlobalLeaderboard(int limit)` - Gets top N users globally
- `Future<List<LeaderboardEntry>> getHometownLeaderboard(String hometown, int limit)` - Gets top N users from hometown
- `Future<UserRankData> getCurrentUserRank(String scope)` - Gets current user's rank and score

### 3. LeaderboardPage (New)

**State Variables:**
- `List<LeaderboardEntry> leaderboardEntries` - List of ranked users
- `UserRankData? currentUserRank` - Current user's rank info
- `String selectedScope` - "Global" or "My Town"
- `bool isLoading` - Loading state
- `String userHometown` - Current user's hometown

**UI Sections:**
- Header with back button and title "Hometown Heroes"
- Scope toggle (Global / My Town)
- Current user rank card (highlighted)
- Scrollable list of top 50 users

### 4. Data Models

```dart
class QuizScoreData {
  final String category;
  final int score;
  final int timeBonus;
  final int correctAnswers;
  final int totalQuestions;
}

class LeaderboardEntry {
  final int rank;
  final String oderId;
  final String name;
  final String hometown;
  final int totalScore;
}

class UserRankData {
  final int rank;
  final String name;
  final int totalScore;
}
```

## Data Models

### QuizScoreData
Used when saving a quiz result to the database.

### LeaderboardEntry
Represents a single row in the leaderboard list.

### UserRankData
Represents the current user's ranking information displayed in the highlighted card.

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: Score accumulation correctness
*For any* user with existing total_score T and new quiz score S, after saving the quiz score, the user's total_score SHALL equal T + S.
**Validates: Requirements 1.2**

### Property 2: Leaderboard ordering correctness
*For any* leaderboard result, all entries SHALL be ordered by total_score in descending order (entry[i].totalScore >= entry[i+1].totalScore for all valid i).
**Validates: Requirements 2.1**

### Property 3: Rank assignment correctness
*For any* leaderboard with N entries, ranks SHALL be assigned sequentially from 1 to N with no gaps or duplicates.
**Validates: Requirements 2.2**

### Property 4: Hometown filter correctness
*For any* hometown-filtered leaderboard, all entries SHALL have hometown matching the filter value.
**Validates: Requirements 4.2**

### Property 5: Top 50 limit correctness
*For any* leaderboard query, the result SHALL contain at most 50 entries.
**Validates: Requirements 2.1**

## Error Handling

| Scenario | Handling |
|----------|----------|
| Score save fails | Show error snackbar, allow retry or continue |
| Leaderboard fetch fails | Show error message with retry button |
| User not logged in | Redirect to login page |
| Empty leaderboard | Show "No scores yet" message |
| Network timeout | Show timeout error with retry option |

## Testing Strategy

### Unit Tests
- Score calculation and accumulation logic
- Leaderboard sorting and ranking
- Filter logic for hometown

### Property-Based Tests
Using Dart's test framework with custom generators:

1. **Score Accumulation Property Test**
   - Generate random existing scores and new scores
   - Verify: new_total = old_total + new_score

2. **Leaderboard Ordering Property Test**
   - Generate random list of user scores
   - Verify: result is sorted descending by score

3. **Rank Assignment Property Test**
   - Generate random leaderboard data
   - Verify: ranks are 1, 2, 3, ... N with no gaps

4. **Hometown Filter Property Test**
   - Generate random users with various hometowns
   - Verify: filtered result only contains matching hometown

### Widget Tests
- Leaderboard page displays correct data
- Scope toggle switches between Global and My Town
- Current user card always visible
- Top 3 have special styling
