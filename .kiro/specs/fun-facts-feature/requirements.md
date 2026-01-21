# Requirements Document

## Introduction

This feature adds a Fun Facts system to the Hometown Quiz gameplay. A fun facts button appears on every 5th question (5, 10, 15), allowing users to view a random fun fact about Bangladesh. When viewed, the current question is skipped (neutral - no points lost) and replaced with a new question, ensuring users always answer 15 questions total. The quiz length is increased from 10 to 15 questions.

## Glossary

- **Fun Facts Button**: A lightbulb icon button that appears on every 5th question during gameplay
- **Fun Fact Modal**: A popup overlay displaying a random fun fact with a "Continue Quiz" button
- **Soft Pause**: When the modal is open, the current question is skipped and replaced with a new one
- **Active State**: The fun facts button is visible and tappable
- **Inactive State**: The fun facts button is hidden from the UI

## Requirements

### Requirement 1

**User Story:** As a user, I want to see a fun facts button on every 5th question, so that I can take a break and learn something interesting.

#### Acceptance Criteria

1. WHEN the user is on question 5, 10, or 15 THEN the Quiz_Page SHALL display the fun facts button (lightbulb icon)
2. WHEN the user is on any other question number THEN the Quiz_Page SHALL hide the fun facts button
3. WHEN the user advances from question 5 to 6 without tapping the button THEN the Quiz_Page SHALL hide the fun facts button

### Requirement 2

**User Story:** As a user, I want to view a fun fact when I tap the button, so that I can learn interesting information about Bangladesh.

#### Acceptance Criteria

1. WHEN a user taps the fun facts button THEN the Quiz_Page SHALL display the fun fact modal overlay
2. WHEN the modal is displayed THEN the Quiz_Page SHALL show a random fun fact fetched from Supabase
3. WHEN the modal is displayed THEN the Quiz_Page SHALL show a lightbulb icon, "Fun Fact!" title, fact content, and category label
4. WHEN the modal is displayed THEN the Quiz_Page SHALL show a "Continue Quiz" button

### Requirement 3

**User Story:** As a user, I want the current question to be skipped when I view a fun fact, so that I get a fresh question after the break.

#### Acceptance Criteria

1. WHEN a user closes the fun fact modal THEN the Quiz_Page SHALL replace the current question with a new question
2. WHEN a question is skipped via fun fact THEN the Quiz_Page SHALL NOT count it as correct or incorrect (neutral)
3. WHEN a question is skipped via fun fact THEN the Quiz_Page SHALL NOT award or deduct any points
4. WHEN a question is skipped via fun fact THEN the Quiz_Page SHALL fetch an additional question to maintain 15 total answered questions

### Requirement 4

**User Story:** As a user, I want to answer 15 questions per quiz, so that I have a longer and more engaging experience.

#### Acceptance Criteria

1. WHEN a quiz starts THEN the Quiz_Page SHALL load 15 questions from Supabase
2. WHEN displaying progress THEN the Quiz_Page SHALL show "Q X of 15" format
3. WHEN all 15 questions are answered THEN the Quiz_Page SHALL navigate to the results page

### Requirement 5

**User Story:** As a developer, I want fun facts stored in Supabase, so that they can be easily managed and updated.

#### Acceptance Criteria

1. WHEN the app needs a fun fact THEN the System SHALL fetch a random fun fact from the fun_facts table in Supabase
2. WHEN storing fun facts THEN the System SHALL store fact content and category for each fun fact
