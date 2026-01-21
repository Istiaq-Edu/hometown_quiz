# Requirements Document

## Introduction

This feature adds a leaderboard system to the Hometown Quiz app. It includes storing quiz scores to Supabase (both individual attempts and cumulative totals), and a leaderboard page that displays top players globally and by hometown. Users can see their own rank and compare with others.

## Glossary

- **Leaderboard Page**: The screen displaying ranked users by their total scores
- **Quiz Score**: Points earned from a single quiz attempt
- **Total Score**: Cumulative sum of all quiz scores for a user
- **Global Leaderboard**: Rankings of all users across Bangladesh
- **Hometown Leaderboard**: Rankings filtered to users from the same hometown as the current user
- **User Rank**: The position of a user in the leaderboard based on total score
- **quiz_scores Table**: Supabase table storing individual quiz attempt records
- **Top 50**: The maximum number of users displayed in the leaderboard list

## Requirements

### Requirement 1

**User Story:** As a quiz player, I want my quiz scores saved to the database, so that my progress is tracked and contributes to my ranking.

#### Acceptance Criteria

1. WHEN a user completes a quiz THEN the system SHALL create a record in the quiz_scores table with user_id, category, score, time_bonus, correct_answers, total_questions, and timestamp
2. WHEN a quiz score is saved THEN the system SHALL update the user's total_score in the users table by adding the new score
3. WHEN saving scores fails THEN the system SHALL display an error message and allow the user to retry or continue without saving

### Requirement 2

**User Story:** As a quiz player, I want to view a leaderboard of top players, so that I can see how I compare to others.

#### Acceptance Criteria

1. WHEN a user opens the Leaderboard Page THEN the system SHALL display the top 50 users ranked by total_score in descending order
2. WHEN the Leaderboard Page loads THEN the system SHALL display each user's rank, name, hometown, and total points
3. WHEN displaying the top 3 users THEN the Leaderboard Page SHALL show them with special styling (gold, silver, bronze gradients)
4. WHEN displaying users ranked 4-50 THEN the Leaderboard Page SHALL show them with standard list styling

### Requirement 3

**User Story:** As a quiz player, I want to see my own rank prominently displayed, so that I know my standing without scrolling.

#### Acceptance Criteria

1. WHEN the Leaderboard Page loads THEN the system SHALL display the current user's rank, name, and total score in a highlighted card at the top
2. WHEN the current user is not in the top 50 THEN the Leaderboard Page SHALL still display their rank and score in the highlighted card

### Requirement 4

**User Story:** As a quiz player, I want to filter the leaderboard by scope, so that I can compare myself to relevant groups.

#### Acceptance Criteria

1. WHEN a user selects "Global" filter THEN the Leaderboard Page SHALL display rankings of all users
2. WHEN a user selects "My Town" filter THEN the Leaderboard Page SHALL display rankings of users from the same hometown as the current user
3. WHEN switching between filters THEN the Leaderboard Page SHALL update the displayed rankings and recalculate the current user's rank within that scope

### Requirement 5

**User Story:** As a quiz player, I want to navigate to the leaderboard from the results page, so that I can check my ranking after completing a quiz.

#### Acceptance Criteria

1. WHEN a user taps "View Leaderboard" on the Results Page THEN the system SHALL navigate to the Leaderboard Page
2. WHEN a user taps the back button on the Leaderboard Page THEN the system SHALL navigate to the previous screen
