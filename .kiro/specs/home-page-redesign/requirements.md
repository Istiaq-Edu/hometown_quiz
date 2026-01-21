# Requirements Document

## Introduction

This feature redesigns the Hometown Quiz app's home page to improve UX by bringing quiz categories directly to the main page, eliminating the need for a separate category selection screen. The redesign includes a new progress section placeholder, streamlined navigation, and a "Play Now" button that starts a random category quiz.

## Glossary

- **Home Page**: The main landing screen of the Hometown Quiz app after user login
- **Category Card**: A horizontal card displaying a quiz category with image, title, description, and start button
- **Progress Section**: A UI component showing user's rank and progress (placeholder for now)
- **Random Quiz**: A quiz that randomly selects one of the three available categories
- **Bottom Navigation**: The fixed navigation bar at the bottom of the screen

## Requirements

### Requirement 1

**User Story:** As a user, I want to see quiz categories directly on the home page, so that I can quickly start a quiz without navigating to a separate screen.

#### Acceptance Criteria

1. WHEN the home page loads THEN the Home_Page SHALL display three category cards in a vertical list: "Places & History", "Culture & Traditions", and "Everyday Bangladesh"
2. WHEN a category card is displayed THEN the Home_Page SHALL show the category image, title, description, and a "Start Quiz" button for each card
3. WHEN a user taps a category's "Start Quiz" button THEN the Home_Page SHALL navigate to the Quiz_Page with the selected category
4. WHEN the home page loads THEN the Home_Page SHALL display an "Events" placeholder card with "Coming Soon" overlay

### Requirement 2

**User Story:** As a user, I want to quickly start a random quiz, so that I can play without choosing a specific category.

#### Acceptance Criteria

1. WHEN a user taps the "Play Now" button THEN the Home_Page SHALL randomly select one category from the three available categories
2. WHEN a random category is selected THEN the Home_Page SHALL navigate to the Quiz_Page with that randomly selected category
3. WHEN the "Play Now" button is displayed THEN the Home_Page SHALL show helper text "✨ Play a random quiz! ✨" below the button

### Requirement 3

**User Story:** As a user, I want to see my progress summary on the home page, so that I can track my learning journey at a glance.

#### Acceptance Criteria

1. WHEN the home page loads THEN the Home_Page SHALL display a "Your Hometown Journey" section with placeholder data
2. WHEN the progress section is displayed THEN the Home_Page SHALL show a rank title "Dhaka Dynamo", a circular progress indicator at 75%, and a linear progress bar at 75%
3. WHEN a user taps "View Full Progress →" link THEN the Home_Page SHALL display a "Coming Soon" message

### Requirement 4

**User Story:** As a user, I want a cleaner home page layout, so that I can focus on starting quizzes without unnecessary navigation options.

#### Acceptance Criteria

1. WHEN the home page loads THEN the Home_Page SHALL NOT display the old 4-card menu grid (Categories, Leaderboard, Progress, Fun Facts)
2. WHEN the home page loads THEN the Home_Page SHALL display the header with logo, title "Hometown Quiz", and user avatar
3. WHEN the home page loads THEN the Home_Page SHALL display the welcome message with user's name and waving hand emoji

### Requirement 5

**User Story:** As a developer, I want to remove the unused CategoryPage, so that the codebase remains clean and maintainable.

#### Acceptance Criteria

1. WHEN the redesign is complete THEN the System SHALL delete the category.dart file from lib/pages/
2. WHEN the redesign is complete THEN the System SHALL remove all imports and references to CategoryPage from the codebase
