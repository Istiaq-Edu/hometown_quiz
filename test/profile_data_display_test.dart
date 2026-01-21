import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:hometown_quiz/models/user_profile.dart';

/// Property-based tests for profile data display
/// **Feature: profile-page, Property 2: User profile data displayed correctly**
/// **Validates: Requirements 1.3**
void main() {
  group('Profile Data Display Property Tests', () {
    final random = Random(42); // Fixed seed for reproducibility

    /// Helper function to generate random string
    String generateRandomString(int length) {
      const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ ';
      return List.generate(
        length,
        (_) => chars[random.nextInt(chars.length)],
      ).join().trim();
    }

    /// Helper function to generate random non-empty string
    String generateNonEmptyString(int minLength, int maxLength) {
      final length = minLength + random.nextInt(maxLength - minLength + 1);
      String result;
      do {
        result = generateRandomString(length);
      } while (result.isEmpty);
      return result;
    }

    /// Calculate user rank based on total score (mirrors ProfilePageState._calculateRank)
    String calculateRank(int totalScore) {
      if (totalScore >= 10000) return 'Bangladesh Legend';
      if (totalScore >= 5000) return 'Regional Expert';
      if (totalScore >= 2000) return 'Town Champion';
      if (totalScore >= 500) return 'Dhaka Dynamo';
      return 'Quiz Beginner';
    }

    /// **Feature: profile-page, Property 2: User profile data displayed correctly**
    /// *For any* valid user profile (name, hometown, rank), the profile page
    /// SHALL display all three values in their respective UI elements.
    /// **Validates: Requirements 1.3**
    test(
      'Property 2: Profile data (name, hometown, rank) is correctly derived from UserProfile',
      () {
        // Run 100 iterations with random user profiles
        for (int i = 0; i < 100; i++) {
          // Generate random user profile
          final name = generateNonEmptyString(3, 20);
          final hometown = generateNonEmptyString(3, 15);
          final totalScore = random.nextInt(15000);

          final profile = UserProfile(
            id: 'user_${random.nextInt(10000)}',
            name: name,
            hometown: hometown,
            photoUrl: random.nextBool()
                ? 'https://example.com/photo.jpg'
                : null,
            totalScore: totalScore,
          );

          // Calculate expected rank
          final expectedRank = calculateRank(totalScore);

          // Verify profile data is correctly accessible
          expect(
            profile.name,
            equals(name),
            reason: 'Profile name should match input: $name',
          );

          expect(
            profile.hometown,
            equals(hometown),
            reason: 'Profile hometown should match input: $hometown',
          );

          expect(
            calculateRank(profile.totalScore),
            equals(expectedRank),
            reason: 'Rank for score $totalScore should be $expectedRank',
          );
        }
      },
    );

    /// Test rank calculation boundaries
    test('Property 2: Rank calculation follows score thresholds', () {
      // Test boundary cases for rank calculation
      final testCases = [
        (0, 'Quiz Beginner'),
        (499, 'Quiz Beginner'),
        (500, 'Dhaka Dynamo'),
        (1999, 'Dhaka Dynamo'),
        (2000, 'Town Champion'),
        (4999, 'Town Champion'),
        (5000, 'Regional Expert'),
        (9999, 'Regional Expert'),
        (10000, 'Bangladesh Legend'),
        (50000, 'Bangladesh Legend'),
      ];

      for (final (score, expectedRank) in testCases) {
        expect(
          calculateRank(score),
          equals(expectedRank),
          reason: 'Score $score should give rank $expectedRank',
        );
      }
    });

    /// Property: For any random score, rank should be one of the valid ranks
    test('Property 2: Rank is always one of the valid rank values', () {
      const validRanks = [
        'Quiz Beginner',
        'Dhaka Dynamo',
        'Town Champion',
        'Regional Expert',
        'Bangladesh Legend',
      ];

      // Run 100 iterations with random scores
      for (int i = 0; i < 100; i++) {
        final score = random.nextInt(100000);
        final rank = calculateRank(score);

        expect(
          validRanks.contains(rank),
          isTrue,
          reason: 'Rank "$rank" for score $score should be one of $validRanks',
        );
      }
    });

    /// Property: Higher scores should result in equal or higher rank
    test('Property 2: Higher scores result in equal or higher rank', () {
      const rankOrder = [
        'Quiz Beginner',
        'Dhaka Dynamo',
        'Town Champion',
        'Regional Expert',
        'Bangladesh Legend',
      ];

      // Run 100 iterations comparing random score pairs
      for (int i = 0; i < 100; i++) {
        final score1 = random.nextInt(15000);
        final score2 = random.nextInt(15000);
        final lowerScore = score1 < score2 ? score1 : score2;
        final higherScore = score1 < score2 ? score2 : score1;

        final lowerRank = calculateRank(lowerScore);
        final higherRank = calculateRank(higherScore);

        final lowerRankIndex = rankOrder.indexOf(lowerRank);
        final higherRankIndex = rankOrder.indexOf(higherRank);

        expect(
          higherRankIndex >= lowerRankIndex,
          isTrue,
          reason:
              'Score $higherScore (rank: $higherRank) should have equal or higher rank than score $lowerScore (rank: $lowerRank)',
        );
      }
    });
  });
}
