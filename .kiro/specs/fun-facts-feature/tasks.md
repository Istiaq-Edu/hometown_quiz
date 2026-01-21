# Implementation Plan

- [x] 1. Set up Supabase infrastructure for fun facts





  - [x] 1.1 Create fun_facts table in Supabase


    - Create table with id (UUID), content (TEXT), category (TEXT), created_at columns
    - Enable RLS with read policy for authenticated users
    - _Requirements: 5.1, 5.2_
  - [x] 1.2 Add sample fun facts data



    - Insert 10-15 fun facts about Bangladesh covering all categories
    - Include facts about tea gardens, rivers, landmarks, culture, etc.
    - _Requirements: 5.2_

- [x] 2. Create FunFact data model and service





  - [x] 2.1 Create FunFact model class


    - Define class with id, content, category fields
    - Add fromJson factory constructor
    - _Requirements: 2.3_
  - [x] 2.2 Create FunFactService with getRandomFunFact method


    - Fetch random fun fact from Supabase using order by random()
    - Return FunFact object or null on error
    - _Requirements: 5.1_

- [x] 3. Update QuizPage to load 15 questions





  - [x] 3.1 Update loadQuestions to fetch 15+ questions


    - Change limit from 10 to 18 (buffer for potential skips)
    - _Requirements: 4.1_
  - [x] 3.2 Update progress display to show "Q X of 15"


    - Update header text to use answeredQuestions + 1
    - Update progress bar calculation for 15 questions
    - _Requirements: 4.2_
  - [x] 3.3 Write property test for progress display format



    - **Property 5: Progress display format correctness**
    - **Validates: Requirements 4.2**


- [x] 4. Implement fun facts button visibility logic




  - [x] 4.1 Add answeredQuestions state variable


    - Track number of questions actually answered (not skipped)
    - Initialize to 0, increment on each answer submission
    - _Requirements: 3.4_
  - [x] 4.2 Create _isFunFactButtonVisible method


    - Return true when (answeredQuestions + 1) equals 5, 10, or 15
    - Return false for all other question numbers
    - _Requirements: 1.1, 1.2_
  - [x] 4.3 Write property test for button visibility logic



    - **Property 1: Fun facts button visibility based on question number**
    - **Validates: Requirements 1.1, 1.2**
  - [x] 4.4 Add fun facts button to QuizPage header


    - Add lightbulb icon button next to timer
    - Conditionally render based on _isFunFactButtonVisible()
    - Style with primary color when visible
    - _Requirements: 1.1, 1.2, 1.3_

- [ ] 5. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.


- [x] 6. Implement fun fact modal




  - [x] 6.1 Add modal state variables


    - Add showFunFactModal boolean
    - Add currentFunFact FunFact? variable
    - _Requirements: 2.1_
  - [x] 6.2 Create fun fact modal widget


    - Create modal overlay with blur backdrop
    - Add lightbulb icon header
    - Add "Fun Fact!" title
    - Add fact content text
    - Add category label chip
    - Add "Continue Quiz" button
    - _Requirements: 2.3, 2.4_
  - [x] 6.3 Write property test for modal content display



    - **Property 2: Fun fact modal displays all required fields**
    - **Validates: Requirements 2.3**
  - [x] 6.4 Implement _showFunFactModal method


    - Pause timer
    - Fetch random fun fact from FunFactService
    - Set currentFunFact and showFunFactModal = true
    - Handle fetch errors with snackbar
    - _Requirements: 2.1, 2.2_

- [-] 7. Implement question skip logic



  - [x] 7.1 Implement _closeFunFactModal method


    - Set showFunFactModal = false
    - Remove current question from list
    - Fetch one extra question and add to list
    - Reset timer and start for new question
    - _Requirements: 3.1_
  - [x] 7.2 Ensure score remains unchanged during skip


    - Do not modify totalScore or correctAnswers when skipping
    - Do not increment answeredQuestions when skipping
    - _Requirements: 3.2, 3.3_

  - [x] 7.3 Write property test for score invariance


    - **Property 3: Score invariance during question skip**
    - **Validates: Requirements 3.2, 3.3**
  - [ ] 7.4 Implement _fetchExtraQuestion method
    - Fetch one additional question from Supabase for same category/hometown
    - Add to questions list
    - Handle fetch errors gracefully
    - _Requirements: 3.4_


- [x] 8. Update quiz completion logic








  - [x] 8.1 Update goToNextQuestion to check answeredQuestions


    - Navigate to results when answeredQuestions reaches 15
    - Increment answeredQuestions on each actual answer
    - _Requirements: 4.3_
  - [x] 8.2 Write property test for total questions count



    - **Property 4: Total answered questions equals 15**
    - **Validates: Requirements 3.4, 4.3**

- [ ] 9. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.


- [x] 10. Wire up button tap handler







  - [x] 10.1 Connect fun facts button to _showFunFactModal

    - Add onTap handler to lightbulb button
    - Call _showFunFactModal when tapped
    - _Requirements: 2.1_

  - [x] 10.2 Connect "Continue Quiz" button to _closeFunFactModal

    - Add onTap handler to continue button
    - Call _closeFunFactModal when tapped
    - _Requirements: 3.1_



- [x] 11. Final Checkpoint - Ensure all tests pass






  - Ensure all tests pass, ask the user if questions arise.
