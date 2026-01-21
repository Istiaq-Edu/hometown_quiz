# Requirements Document

## Introduction

This feature implements a Profile Page for the Hometown Quiz app where users can view their quiz statistics, update their personal information (name, hometown, profile photo), and manage their account (logout, delete account). The profile page is accessible from the bottom navigation bar and by tapping the profile avatar on the home page.

## Glossary

- **Profile Page**: A screen displaying user information, quiz statistics, and account management options
- **Profile Photo**: User's avatar image stored in Supabase Storage, with a default random avatar
- **User Stats**: Aggregated quiz statistics including quizzes played, highest score, accuracy, and time bonuses
- **Hometown**: The user's selected town from a predefined list of Bangladesh cities
- **Account Deletion**: Permanent removal of user account and all associated data from the system

## Requirements

### Requirement 1

**User Story:** As a user, I want to see my profile information at a glance, so that I can verify my account details.

#### Acceptance Criteria

1. WHEN the profile page loads THEN the Profile_Page SHALL display the user's profile photo with an edit button overlay
2. WHEN no profile photo exists THEN the Profile_Page SHALL display a default random avatar using a Flutter avatar package
3. WHEN the profile page loads THEN the Profile_Page SHALL display the user's name, rank title, and hometown
4. WHEN the profile page loads THEN the Profile_Page SHALL display a header with back button and "Your Hometown Profile" title

### Requirement 2

**User Story:** As a user, I want to upload or change my profile photo, so that I can personalize my account.

#### Acceptance Criteria

1. WHEN a user taps the edit button on the profile photo THEN the Profile_Page SHALL present options to choose from gallery or camera
2. WHEN a user selects an image THEN the Profile_Page SHALL upload the image to Supabase Storage
3. WHEN the upload completes THEN the Profile_Page SHALL update the displayed profile photo immediately
4. IF the image upload fails THEN the Profile_Page SHALL display an error message and retain the previous photo

### Requirement 3

**User Story:** As a user, I want to see my quiz statistics, so that I can track my learning progress.

#### Acceptance Criteria

1. WHEN the profile page loads THEN the Profile_Page SHALL display a "Your Journey So Far" section with four stat cards
2. WHEN displaying stats THEN the Profile_Page SHALL show "Quizzes Played" count fetched from Supabase
3. WHEN displaying stats THEN the Profile_Page SHALL show "Highest Score" value fetched from Supabase
4. WHEN displaying stats THEN the Profile_Page SHALL show "Accuracy" percentage calculated from total correct answers and total questions
5. WHEN displaying stats THEN the Profile_Page SHALL show "Time Bonuses" count fetched from Supabase

### Requirement 4

**User Story:** As a user, I want to update my name, so that I can correct or change my display name.

#### Acceptance Criteria

1. WHEN a user taps "Edit Name" THEN the Profile_Page SHALL display an input dialog with the current name pre-filled
2. WHEN a user submits a non-empty name THEN the Profile_Page SHALL update the name in Supabase
3. WHEN the name update succeeds THEN the Profile_Page SHALL refresh the displayed name immediately
4. IF a user submits an empty name THEN the Profile_Page SHALL display a validation error and prevent submission

### Requirement 5

**User Story:** As a user, I want to change my hometown, so that I can update my location if I move.

#### Acceptance Criteria

1. WHEN a user taps "Change Hometown" THEN the Profile_Page SHALL display a dropdown dialog with Bangladesh cities
2. WHEN a user selects a new hometown THEN the Profile_Page SHALL update the hometown in Supabase
3. WHEN the hometown update succeeds THEN the Profile_Page SHALL refresh the displayed hometown immediately

### Requirement 6

**User Story:** As a user, I want to view my achievements, so that I can see my accomplishments.

#### Acceptance Criteria

1. WHEN a user taps "View Achievements" THEN the Profile_Page SHALL display a "Coming Soon" message

### Requirement 7

**User Story:** As a user, I want to log out of my account, so that I can secure my session or switch accounts.

#### Acceptance Criteria

1. WHEN a user taps "Logout" THEN the Profile_Page SHALL sign out the user from Supabase
2. WHEN logout succeeds THEN the Profile_Page SHALL navigate to the login page and clear the navigation stack
3. IF logout fails THEN the Profile_Page SHALL display an error message

### Requirement 8

**User Story:** As a user, I want to delete my account, so that I can remove all my data from the system.

#### Acceptance Criteria

1. WHEN a user taps "Delete Account" THEN the Profile_Page SHALL display a confirmation dialog
2. WHEN a user confirms deletion THEN the Profile_Page SHALL delete all user data from Supabase including quiz scores
3. WHEN deletion succeeds THEN the Profile_Page SHALL navigate to the login page and clear the navigation stack
4. IF deletion fails THEN the Profile_Page SHALL display an error message

### Requirement 9

**User Story:** As a user, I want to access my profile from multiple places, so that I can easily view my information.

#### Acceptance Criteria

1. WHEN a user taps the "Profile" button in the bottom navigation THEN the App SHALL navigate to the Profile_Page
2. WHEN a user taps the profile avatar in the home page header THEN the App SHALL navigate to the Profile_Page
