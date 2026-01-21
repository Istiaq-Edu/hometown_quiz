# Implementation Plan

- [x] 1. Create database schema for score storage





  - [x] 1.1 Create SQL migration for quiz_scores table


    - Create quiz_scores table with id, user_id, category, score, time_bonus, correct_answers, total_questions, created_at
    - Add foreign key reference to auth.users
    - Enable RLS with policy for users to insert/read their own scores
    - _Requirements: 1.1_
  - [x] 1.2 Create SQL migration to add total_score to users table


    - Add total_score INTEGER column with default 0
    - Update RLS policy to allow reading total_score for leaderboard
    - _Requirements: 1.2_
  - [x] 1.3 Create SQL file with setup instructions


    - Document the migrations in a new SQL file for easy setup
    - _Requirements: 1.1, 1.2_

- [x] 2. Implement ScoreService for database operations





  - [x] 2.1 Create score_service.dart with data models


    - Define QuizScoreData, LeaderboardEntry, UserRankData classes
    - _Requirements: 1.1, 2.2_

  - [x] 2.2 Implement saveQuizScore method
    - Insert record into quiz_scores table
    - Update users.total_score by adding new score
    - Use transaction or RPC for atomicity
    - Return success/failure status
    - _Requirements: 1.1, 1.2_
  - [x] 2.3 Write property test for score accumulation






    - **Property 1: Score accumulation correctness**
    - **Validates: Requirements 1.2**
  - [x] 2.4 Implement getGlobalLeaderboard method

    - Query users table ordered by total_score descending
    - Join with user profile data (name, hometown)
    - Limit to 50 results
    - Assign ranks 1-50
    - _Requirements: 2.1, 2.2_
  - [x] 2.5 Implement getHometownLeaderboard method

    - Query users filtered by hometown
    - Order by total_score descending, limit 50
    - Assign ranks within hometown scope
    - _Requirements: 4.2_
  - [ ]* 2.6 Write property test for leaderboard ordering
    - **Property 2: Leaderboard ordering correctness**
    - **Validates: Requirements 2.1**

  - [x] 2.7 Implement getCurrentUserRank method
    - Get current user's total_score
    - Calculate rank by counting users with higher scores
    - Support both global and hometown scope
    - _Requirements: 3.1, 3.2_

- [x] 3. Create LeaderboardPage UI



  - [x] 3.1 Create leaderboard_page.dart with basic structure


    - Set up StatefulWidget with state variables
    - Initialize with loading state, fetch data on init
    - _Requirements: 2.1_
  - [x] 3.2 Implement header with back button and title

    - Add AppBar with "Hometown Heroes" title
    - Back button navigates to previous screen
    - _Requirements: 5.2_
  - [x] 3.3 Implement scope toggle (Global / My Town)

    - Create segmented button with two options
    - On selection change, refetch leaderboard data
    - Update current user rank for selected scope
    - _Requirements: 4.1, 4.2, 4.3_
  - [x] 3.4 Implement current user rank card

    - Display highlighted card with user's rank, name, total score
    - Always visible at top regardless of ranking position
    - Style with primary color background
    - _Requirements: 3.1, 3.2_

  - [x] 3.5 Implement leaderboard list with top 3 styling

    - Create list items for top 50 users
    - Apply gold gradient for rank 1, silver for rank 2, bronze for rank 3
    - Standard styling for ranks 4-50
    - Display rank, name, hometown, points for each entry
    - _Requirements: 2.1, 2.2, 2.3, 2.4_
  - [ ]* 3.6 Write property test for hometown filter
    - **Property 4: Hometown filter correctness**
    - **Validates: Requirements 4.2**

- [x] 4. Integrate score saving with quiz completion



  - [x] 4.1 Update ResultsPage to save score on load



    - Call ScoreService.saveQuizScore when results page loads
    - Handle success/failure with appropriate feedback
    - _Requirements: 1.1, 1.2, 1.3_

  - [x] 4.2 Update "View Leaderboard" button to navigate

    - Change from TODO placeholder to actual navigation
    - Navigate to LeaderboardPage when tapped
    - _Requirements: 5.1_

- [x] 5. Add error handling and loading states





  - [x] 5.1 Add loading indicator while fetching leaderboard

    - Show CircularProgressIndicator during data fetch
    - _Requirements: 2.1_
  - [x] 5.2 Add error handling with retry option

    - Display error message if fetch fails
    - Provide retry button to refetch data
    - _Requirements: 1.3_
  - [x] 5.3 Add empty state for no scores

    - Display friendly message when leaderboard is empty
    - _Requirements: 2.1_

- [ ] 6. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [x] 7. Connect leaderboard from main page





  - [x] 7.1 Add navigation from home page leaderboard card


    - Update the Leaderboard card GestureDetector onTap to navigate to LeaderboardPage
    - Import leaderboard_page.dart in home.dart
    - _Requirements: 5.1_
  - [x] 7.2 Add navigation from bottom navigation bar


    - Update the Leaderboard button in bottom nav to navigate to LeaderboardPage
    - _Requirements: 5.1_

- [x] 8. Fix leaderboard UI issues





  - [x] 8.1 Change "Pts" to "Points" throughout leaderboard


    - Update current user rank card to show "Points" instead of "Pts"
    - Update top 3 items to show "Points" instead of "Pts"
    - Update standard items (ranks 4-50) to show "Points" instead of "Pts"
    - _Requirements: 2.2_

  - [x] 8.2 Verify and fix leaderboard ordering

    - Ensure leaderboard is sorted by total_score in descending order (highest first)
    - Test with multiple users to confirm ordering is correct
    - _Requirements: 2.1_

- [x] 9. Verify score saving and fetching





  - [x] 9.1 Test score saving flow


    - Complete a quiz and verify score is saved to quiz_scores table
    - Verify user's total_score is updated correctly in users table
    - _Requirements: 1.1, 1.2_
  - [x] 9.2 Test leaderboard data fetching


    - Verify global leaderboard shows all users ordered by score
    - Verify hometown leaderboard filters correctly by user's hometown
    - Verify current user rank is calculated correctly
    - _Requirements: 2.1, 3.1, 4.2_

- [x] 10. Final Checkpoint - Ensure all features work correctly





  - Ensure all tests pass, ask the user if questions arise.

- [x] 11. Fix SQL migration syntax errors





  - [x] 11.1 Fix dollar-quoting in SQL functions


    - Change `$` to `$$` in save_quiz_score function body delimiters
    - Change `$` to `$$` in get_user_rank function body delimiters
    - _Requirements: 1.1, 1.2_

- [x] 12. Update ScoreService to use atomic RPC function






  - [x] 12.1 Modify saveQuizScore to use save_quiz_score RPC

    - Replace separate INSERT and UPDATE with single RPC call
    - Use supabase.rpc('save_quiz_score', params: {...})
    - Handle the JSON response from the function
    - _Requirements: 1.1, 1.2_

- [x] 13. Fix time bonus calculation in quiz page





  - [x] 13.1 Review and fix totalTimeBonus tracking


    - Currently tracking count of fast answers (1 per fast answer)
    - Should track actual bonus points (1 point per fast answer is correct, but verify)
    - Ensure timeBonus passed to ResultsPage matches what's saved to database
    - _Requirements: 2.2_
