# Implementation Plan

- [x] 1. Set up Supabase infrastructure





  - [x] 1.1 Add photo_url column to users table


    - Create migration SQL to add nullable text column `photo_url` to users table
    - _Requirements: 2.2, 2.3_
  - [x] 1.2 Create Supabase Storage bucket for profile photos


    - Create `profile-photos` bucket with public access policy
    - Add RLS policy to allow authenticated users to upload/delete their own photos
    - _Requirements: 2.2_
  - [x] 1.3 Create get_user_stats RPC function


    - Create SQL function to aggregate quiz_scores (count, max score, sum correct/total, sum time_bonus)
    - _Requirements: 3.2, 3.3, 3.4, 3.5_
  - [x] 1.4 Create delete_user_account RPC function


    - Create SQL function to delete quiz_scores and user record
    - Delete profile photo from storage if exists
    - _Requirements: 8.2_


- [x] 2. Add Flutter dependencies





  - [x] 2.1 Add image_picker package to pubspec.yaml

    - Add `image_picker: ^1.0.0` dependency
    - Run flutter pub get
    - _Requirements: 2.1_


  - [ ] 2.2 Add avatar package to pubspec.yaml
    - Add `flutter_avataaar` or `random_avatar` package for default avatars
    - Run flutter pub get
    - _Requirements: 1.2_

- [x] 3. Create data models






  - [x] 3.1 Create UserProfile model

    - Define class with id, name, hometown, photoUrl, totalScore fields
    - Add fromJson factory constructor
    - _Requirements: 1.3_

  - [x] 3.2 Create UserStats model

    - Define class with quizzesPlayed, highestScore, accuracy, timeBonuses fields
    - Add fromJson factory constructor with accuracy calculation
    - _Requirements: 3.2, 3.3, 3.4, 3.5_

  - [x] 3.3 Write property test for accuracy calculation


    - **Property 4: Accuracy calculation correctness**
    - **Validates: Requirements 3.4**


- [x] 4. Create ProfileService




  - [x] 4.1 Implement getUserProfile method


    - Fetch user data from users table (name, hometown, photo_url, total_score)
    - Return UserProfile object
    - _Requirements: 1.3_
  - [x] 4.2 Implement getUserStats method


    - Call get_user_stats RPC function
    - Calculate accuracy from total_correct / total_questions
    - Return UserStats object
    - _Requirements: 3.2, 3.3, 3.4, 3.5_
  - [x] 4.3 Implement updateName method

    - Update name in users table
    - Return success/failure boolean
    - _Requirements: 4.2_
  - [x] 4.4 Implement updateHometown method

    - Update hometown in users table
    - Return success/failure boolean
    - _Requirements: 5.2_
  - [x] 4.5 Implement uploadProfilePhoto method

    - Upload image to Supabase Storage profile-photos bucket
    - Update photo_url in users table
    - Return new photo URL or null on failure
    - _Requirements: 2.2, 2.3_

  - [x] 4.6 Implement deleteAccount method
    - Delete profile photo from storage if exists
    - Call delete_user_account RPC function
    - Sign out user from Supabase Auth
    - Return success/failure boolean
    - _Requirements: 8.2_

- [x] 5. Checkpoint - Ensure all tests pass





  - Ensure all tests pass, ask the user if questions arise.

- [x] 6. Create ProfilePage UI structure





  - [x] 6.1 Create profile_page.dart file with basic scaffold


    - Create StatefulWidget with loading state
    - Add header with back button and "Your Hometown Profile" title
    - _Requirements: 1.4_
  - [x] 6.2 Implement profile info section

    - Add profile photo with edit button overlay
    - Display default avatar when no photo URL exists
    - Display user name, rank, and hometown
    - _Requirements: 1.1, 1.2, 1.3_
  - [x] 6.3 Write property test for default avatar display



    - **Property 1: Default avatar displayed when no photo URL exists**
    - **Validates: Requirements 1.2**
  - [x] 6.4 Write property test for profile data display



    - **Property 2: User profile data displayed correctly**
    - **Validates: Requirements 1.3**

- [x] 7. Implement stats section





  - [x] 7.1 Create "Your Journey So Far" section with 4 stat cards


    - Add section header
    - Create 2x2 grid of stat cards
    - Display Quizzes Played, Highest Score, Accuracy, Time Bonuses
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_
  - [x] 7.2 Write property test for stats display



    - **Property 3: Stats values displayed in cards**
    - **Validates: Requirements 3.2, 3.3, 3.5**


- [x] 8. Implement update details section




  - [x] 8.1 Create "Update Your Details" section with list items


    - Add Edit Name row with current name and chevron
    - Add Change Hometown row with current hometown and chevron
    - Add View Achievements row with chevron
    - _Requirements: 4.1, 5.1, 6.1_

  - [x] 8.2 Implement Edit Name dialog

    - Show dialog with text field pre-filled with current name
    - Validate name is not empty
    - Call ProfileService.updateName on submit
    - Refresh displayed name on success
    - _Requirements: 4.1, 4.2, 4.3, 4.4_

  - [x] 8.3 Write property test for name validation


    - **Property 5: Name validation rejects empty input**
    - **Validates: Requirements 4.4**
  - [x] 8.4 Implement Change Hometown dialog


    - Show dialog with dropdown of Bangladesh cities (reuse from signup)
    - Call ProfileService.updateHometown on selection
    - Refresh displayed hometown on success
    - _Requirements: 5.1, 5.2, 5.3_

  - [x] 8.5 Implement View Achievements tap handler

    - Show "Coming Soon" snackbar message
    - _Requirements: 6.1_

- [x] 9. Implement photo upload functionality






  - [x] 9.1 Implement photo options bottom sheet

    - Show options for Gallery and Camera
    - Use image_picker to select image
    - _Requirements: 2.1_

  - [x] 9.2 Implement photo upload flow

    - Call ProfileService.uploadProfilePhoto with selected image
    - Show loading indicator during upload
    - Update displayed photo on success
    - Show error snackbar on failure
    - _Requirements: 2.2, 2.3, 2.4_


- [x] 10. Implement footer actions




  - [x] 10.1 Create footer section with Logout and Delete Account buttons


    - Add Logout button with orange background
    - Add Delete Account button with red border
    - _Requirements: 7.1, 8.1_

  - [x] 10.2 Implement Logout functionality

    - Call Supabase auth signOut
    - Navigate to login page and clear navigation stack
    - Show error snackbar on failure
    - _Requirements: 7.1, 7.2, 7.3_

  - [x] 10.3 Implement Delete Account functionality


    - Show confirmation dialog with warning message
    - Call ProfileService.deleteAccount on confirm
    - Navigate to login page and clear navigation stack
    - Show error snackbar on failure
    - _Requirements: 8.1, 8.2, 8.3, 8.4_

- [ ] 11. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.


- [x] 12. Add navigation to ProfilePage







  - [x] 12.1 Update bottom navigation Profile button in HomePage


    - Add navigation to ProfilePage on Profile button tap
    - _Requirements: 9.1_

  - [x] 12.2 Update profile avatar tap in HomePage header

    - Add GestureDetector to avatar
    - Navigate to ProfilePage on tap
    - _Requirements: 9.2_


- [x] 13. Final Checkpoint - Ensure all tests pass







  - Ensure all tests pass, ask the user if questions arise.
