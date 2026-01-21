# Design Document: Profile Page

## Overview

This design document outlines the implementation of a Profile Page for the Hometown Quiz app. The page allows users to view their quiz statistics, manage their profile information (name, hometown, photo), and handle account actions (logout, delete). The implementation integrates with Supabase for data storage, authentication, and file storage.

## Architecture

The profile page follows the existing Flutter architecture pattern with a service layer for Supabase operations.

```
┌─────────────────────────────────────────┐
│            ProfilePage                   │
│  ┌─────────────────────────────────┐    │
│  │ Header (Back, Title)            │    │
│  ├─────────────────────────────────┤    │
│  │ Profile Info Section            │    │
│  │  - Photo with edit button       │    │
│  │  - Name, Rank, Hometown         │    │
│  ├─────────────────────────────────┤    │
│  │ Stats Section (4 cards)         │    │
│  │  - Quizzes Played               │    │
│  │  - Highest Score                │    │
│  │  - Accuracy                     │    │
│  │  - Time Bonuses                 │    │
│  ├─────────────────────────────────┤    │
│  │ Update Details Section          │    │
│  │  - Edit Name                    │    │
│  │  - Change Hometown              │    │
│  │  - View Achievements            │    │
│  ├─────────────────────────────────┤    │
│  │ Footer Actions                  │    │
│  │  - Logout                       │    │
│  │  - Delete Account               │    │
│  └─────────────────────────────────┘    │
└─────────────────────────────────────────┘
           │
           ▼
┌─────────────────────────────────────────┐
│          ProfileService                  │
│  - getUserProfile()                      │
│  - getUserStats()                        │
│  - updateName()                          │
│  - updateHometown()                      │
│  - uploadProfilePhoto()                  │
│  - deleteAccount()                       │
└─────────────────────────────────────────┘
           │
           ▼
┌─────────────────────────────────────────┐
│          Supabase                        │
│  - Auth (logout, delete)                 │
│  - Database (users, quiz_scores)         │
│  - Storage (profile photos)              │
└─────────────────────────────────────────┘
```

## Components and Interfaces

### ProfilePage Widget

**State Variables:**
- `isLoading: bool` - Loading state for initial data fetch
- `userName: String` - User's display name
- `userHometown: String` - User's hometown
- `userRank: String` - User's rank title (e.g., "Dhaka Dynamo")
- `profilePhotoUrl: String?` - URL to profile photo in Supabase Storage
- `stats: UserStats` - Aggregated quiz statistics

**Methods:**
- `_loadUserData()` - Fetches user profile and stats from Supabase
- `_showEditNameDialog()` - Shows dialog to edit name
- `_showChangeHometownDialog()` - Shows dialog to change hometown
- `_showPhotoOptions()` - Shows bottom sheet with gallery/camera options
- `_uploadPhoto(File image)` - Uploads photo to Supabase Storage
- `_logout()` - Signs out user and navigates to login
- `_showDeleteConfirmation()` - Shows confirmation dialog for account deletion
- `_deleteAccount()` - Deletes user account and all data

### ProfileService

A new service class for profile-related database operations.

**Methods:**
```dart
class ProfileService {
  /// Gets user profile data (name, hometown, photo_url)
  static Future<UserProfile?> getUserProfile();
  
  /// Gets aggregated user stats from quiz_scores
  static Future<UserStats?> getUserStats();
  
  /// Updates user's name
  static Future<bool> updateName(String name);
  
  /// Updates user's hometown
  static Future<bool> updateHometown(String hometown);
  
  /// Uploads profile photo and returns URL
  static Future<String?> uploadProfilePhoto(File image);
  
  /// Deletes user account and all related data
  static Future<bool> deleteAccount();
}
```

### Data Models

```dart
/// User profile data
class UserProfile {
  final String id;
  final String name;
  final String hometown;
  final String? photoUrl;
  final int totalScore;
  
  const UserProfile({
    required this.id,
    required this.name,
    required this.hometown,
    this.photoUrl,
    required this.totalScore,
  });
}

/// Aggregated user statistics
class UserStats {
  final int quizzesPlayed;
  final int highestScore;
  final double accuracy;
  final int timeBonuses;
  
  const UserStats({
    required this.quizzesPlayed,
    required this.highestScore,
    required this.accuracy,
    required this.timeBonuses,
  });
}
```

### Supabase Schema Updates

**Users table update:**
- Add `photo_url` column (text, nullable)

**Storage bucket:**
- Create `profile-photos` bucket with public access

**RPC function for stats aggregation:**
```sql
CREATE OR REPLACE FUNCTION get_user_stats(p_user_id UUID)
RETURNS JSON AS $$
DECLARE
  result JSON;
BEGIN
  SELECT json_build_object(
    'quizzes_played', COUNT(*),
    'highest_score', COALESCE(MAX(score), 0),
    'total_correct', COALESCE(SUM(correct_answers), 0),
    'total_questions', COALESCE(SUM(total_questions), 0),
    'time_bonuses', COALESCE(SUM(time_bonus), 0)
  ) INTO result
  FROM quiz_scores
  WHERE user_id = p_user_id;
  
  RETURN result;
END;
$$ LANGUAGE plpgsql;
```

**RPC function for account deletion:**
```sql
CREATE OR REPLACE FUNCTION delete_user_account(p_user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
  -- Delete quiz scores
  DELETE FROM quiz_scores WHERE user_id = p_user_id;
  
  -- Delete user record
  DELETE FROM users WHERE id = p_user_id;
  
  RETURN TRUE;
EXCEPTION
  WHEN OTHERS THEN
    RETURN FALSE;
END;
$$ LANGUAGE plpgsql;
```

## Data Models

### Bangladesh Towns List

Reuse the existing list from `signup.dart`:
```dart
final List<String> bangladeshTowns = [
  'Dhaka', 'Chittagong', 'Sylhet', 'Rajshahi', 'Khulna',
  'Barisal', 'Rangpur', 'Mymensingh', 'Comilla', 'Narayanganj',
  // ... (63 total towns)
];
```

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*



### Property 1: Default avatar displayed when no photo URL exists

*For any* user profile with a null or empty photo URL, the profile page SHALL render a default avatar widget instead of an image.

**Validates: Requirements 1.2**

### Property 2: User profile data displayed correctly

*For any* valid user profile (name, hometown, rank), the profile page SHALL display all three values in their respective UI elements.

**Validates: Requirements 1.3**

### Property 3: Stats values displayed in cards

*For any* UserStats object (quizzes played, highest score, time bonuses), all stat values SHALL be displayed in their respective stat cards.

**Validates: Requirements 3.2, 3.3, 3.5**

### Property 4: Accuracy calculation correctness

*For any* pair of (correct answers, total questions) where total questions > 0, the accuracy SHALL equal (correct answers / total questions) * 100.

**Validates: Requirements 3.4**

### Property 5: Name validation rejects empty input

*For any* string that is empty or contains only whitespace characters, the name validation SHALL return false and prevent submission.

**Validates: Requirements 4.4**

## Error Handling

| Scenario | Handling |
|----------|----------|
| Profile data fetch fails | Display error message, show retry option |
| Stats fetch fails | Display "N/A" or 0 values with error indicator |
| Photo upload fails | Show error snackbar, retain previous photo |
| Name update fails | Show error snackbar, revert to previous name |
| Hometown update fails | Show error snackbar, revert to previous hometown |
| Logout fails | Show error snackbar |
| Account deletion fails | Show error snackbar |

## Testing Strategy

### Property-Based Testing

The project will use the `dart_quickcheck` package for property-based testing. Each property test will run a minimum of 100 iterations.

**Property Tests:**
1. **Default Avatar Test** - Generate profiles with null/empty photo URLs, verify default avatar rendered
2. **Profile Display Test** - Generate various user profiles, verify all fields displayed
3. **Stats Display Test** - Generate various UserStats, verify all values shown
4. **Accuracy Calculation Test** - Generate random correct/total pairs, verify calculation
5. **Name Validation Test** - Generate empty/whitespace strings, verify rejection

### Unit Tests

1. **ProfileService Tests**
   - Test getUserProfile returns correct data structure
   - Test getUserStats aggregation logic
   - Test updateName with valid/invalid inputs
   - Test updateHometown with valid inputs

2. **ProfilePage Widget Tests**
   - Verify profile info section renders
   - Verify stats section renders with 4 cards
   - Verify update details section renders
   - Verify footer actions render

### Integration Tests

1. **Photo upload flow**: Select image → Upload → Verify URL updated
2. **Edit name flow**: Tap edit → Enter name → Save → Verify update
3. **Logout flow**: Tap logout → Verify navigation to login
4. **Delete account flow**: Tap delete → Confirm → Verify navigation to login

## Dependencies

### Flutter Packages

- `image_picker` - For selecting photos from gallery/camera
- `flutter_avatar` or `random_avatar` - For generating default avatars
- `supabase_flutter` - Already installed, for storage operations
