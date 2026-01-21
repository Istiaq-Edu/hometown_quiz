# Implementation Plan

- [x] 1. Refactor HomePage layout structure





  - [x] 1.1 Remove the old 4-card menu grid from HomePage


    - Delete the Categories, Leaderboard, Progress, and Fun Facts card widgets
    - Remove associated GestureDetector wrappers and navigation code
    - _Requirements: 4.1_
  - [x] 1.2 Update imports and remove CategoryPage reference

    - Remove `import 'package:hometown_quiz/pages/category.dart';`
    - _Requirements: 5.2_


- [x] 2. Implement Progress Section placeholder




  - [x] 2.1 Create the "Your Hometown Journey" section widget


    - Add section header with "Your Hometown Journey" title
    - Add "View Full Progress →" link that shows "Coming Soon" snackbar
    - Create white card container with rounded corners and shadow
    - _Requirements: 3.1, 3.3_
  - [x] 2.2 Add progress display elements

    - Add "Current Rank" label and "Dhaka Dynamo" rank title with verified icon
    - Add circular progress indicator showing 75%
    - Add linear progress bar showing 75%
    - _Requirements: 3.2_


- [x] 3. Implement Category Cards section




  - [x] 3.1 Create category data structure


    - Define list of category maps with name, description, and image path
    - _Requirements: 1.1_
  - [x] 3.2 Build horizontal category card widget

    - Create card with image on left (1/3 width), content on right
    - Display category title, description, and "Start Quiz" button
    - Use existing images from lib/images/
    - _Requirements: 1.2_

  - [x] 3.3 Implement category card navigation
    - Add onTap handler to "Start Quiz" button
    - Navigate to QuizPage with selected category name
    - _Requirements: 1.3_
  - [x] 3.4 Write property test for category card rendering



    - **Property 2: Category card contains all required elements**
    - **Validates: Requirements 1.2**
  - [x] 3.5 Write property test for navigation category validation


    - **Property 3: Navigation receives valid category string**
    - **Validates: Requirements 1.3, 2.2**

- [x] 4. Implement Events placeholder card

  - [x] 4.1 Create "Events" card with "Coming Soon" overlay

    - Add dashed border card with gray background
    - Add celebration icon and "COMING SOON" badge overlay
    - Add "Events" title and placeholder description
    - _Requirements: 1.4_


- [x] 5. Implement Random Quiz functionality




  - [x] 5.1 Create random category selection function


    - Import dart:math for Random class
    - Create function that randomly selects from 3 categories
    - _Requirements: 2.1_

  - [x] 5.2 Update "Play Now" button behavior

    - Call random selection function on tap
    - Navigate to QuizPage with randomly selected category
    - Update helper text to "✨ Play a random quiz! ✨"
    - _Requirements: 2.2, 2.3_

  - [x] 5.3 Write property test for random category selection


    - **Property 1: Random category selection produces valid category**
    - **Validates: Requirements 2.1**

- [ ] 6. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.


- [x] 7. Update Bottom Navigation





  - [x] 7.1 Keep "Leaderboard" label as is

    - Verify bottom nav still shows Home, Leaderboard, Profile, Settings
    - _Requirements: 4.2_


- [x] 8. Clean up and delete CategoryPage





  - [x] 8.1 Delete lib/pages/category.dart file

    - Remove the file from the codebase
    - _Requirements: 5.1_

  - [x] 8.2 Verify no remaining references to CategoryPage

    - Search codebase for any remaining imports or usages
    - _Requirements: 5.2_

- [ ]* 9. Write property test for welcome message
  - **Property 4: Welcome message contains user name**
  - **Validates: Requirements 4.3**


- [x] 10. Final Checkpoint - Ensure all tests pass




  - Ensure all tests pass, ask the user if questions arise.
