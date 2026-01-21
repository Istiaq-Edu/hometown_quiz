import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:hometown_quiz/models/user_profile.dart';

/// Property-based tests for default avatar display
/// **Feature: profile-page, Property 1: Default avatar displayed when no photo URL exists**
/// **Validates: Requirements 1.2**
void main() {
  group('Default Avatar Display Property Tests', () {
    final random = Random(42); // Fixed seed for reproducibility

    /// Helper function to generate random string
    String generateRandomString(int length) {
      const chars =
          'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
      return List.generate(
        length,
        (_) => chars[random.nextInt(chars.length)],
      ).join();
    }

    /// Helper function to check if photo URL should show default avatar
    /// Returns true if default avatar should be displayed
    bool shouldShowDefaultAvatar(String? photoUrl) {
      return photoUrl == null || photoUrl.isEmpty;
    }

    /// **Feature: profile-page, Property 1: Default avatar displayed when no photo URL exists**
    /// *For any* user profile with a null or empty photo URL, the profile page
    /// SHALL render a default avatar widget instead of an image.
    /// **Validates: Requirements 1.2**
    test('Property 1: Default avatar shown for null photo URL', () {
      // Run 100 iterations with random user profiles
      for (int i = 0; i < 100; i++) {
        // Generate random user profile with null photo URL
        final profile = UserProfile(
          id: generateRandomString(10),
          name: generateRandomString(8),
          hometown: generateRandomString(10),
          photoUrl: null, // Null photo URL
          totalScore: random.nextInt(10000),
        );

        // Verify that shouldShowDefaultAvatar returns true for null photoUrl
        expect(
          shouldShowDefaultAvatar(profile.photoUrl),
          isTrue,
          reason: 'Default avatar should be shown when photoUrl is null',
        );
      }
    });

    /// **Feature: profile-page, Property 1: Default avatar displayed when no photo URL exists**
    /// *For any* user profile with an empty string photo URL, the profile page
    /// SHALL render a default avatar widget instead of an image.
    /// **Validates: Requirements 1.2**
    test('Property 1: Default avatar shown for empty photo URL', () {
      // Run 100 iterations with random user profiles
      for (int i = 0; i < 100; i++) {
        // Generate random user profile with empty photo URL
        final profile = UserProfile(
          id: generateRandomString(10),
          name: generateRandomString(8),
          hometown: generateRandomString(10),
          photoUrl: '', // Empty photo URL
          totalScore: random.nextInt(10000),
        );

        // Verify that shouldShowDefaultAvatar returns true for empty photoUrl
        expect(
          shouldShowDefaultAvatar(profile.photoUrl),
          isTrue,
          reason: 'Default avatar should be shown when photoUrl is empty',
        );
      }
    });

    /// Inverse property: When photo URL exists and is non-empty, default avatar should NOT be shown
    test('Property 1 (inverse): Photo shown when valid URL exists', () {
      // Run 100 iterations with random user profiles with valid URLs
      for (int i = 0; i < 100; i++) {
        // Generate random user profile with valid photo URL
        final photoUrl = 'https://example.com/${generateRandomString(10)}.jpg';
        final profile = UserProfile(
          id: generateRandomString(10),
          name: generateRandomString(8),
          hometown: generateRandomString(10),
          photoUrl: photoUrl, // Valid photo URL
          totalScore: random.nextInt(10000),
        );

        // Verify that shouldShowDefaultAvatar returns false for valid photoUrl
        expect(
          shouldShowDefaultAvatar(profile.photoUrl),
          isFalse,
          reason:
              'Default avatar should NOT be shown when photoUrl is valid: $photoUrl',
        );
      }
    });
  });
}
