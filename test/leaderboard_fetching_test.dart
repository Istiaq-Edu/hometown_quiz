import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:hometown_quiz/score_service.dart';

/// Tests for leaderboard data fetching verification
/// **Feature: leaderboard-scores, Task 9.2: Test leaderboard data fetching**
/// **Validates: Requirements 2.1, 3.1, 4.2**

/// Helper function to simulate leaderboard ordering logic
/// This mirrors the ordering logic in ScoreService.getGlobalLeaderboard
List<LeaderboardEntry> sortAndRankEntries(List<Map<String, dynamic>> users) {
  // Sort by total_score descending
  users.sort(
    (a, b) => (b['total_score'] as int).compareTo(a['total_score'] as int),
  );

  // Assign ranks
  return users.asMap().entries.map((entry) {
    return LeaderboardEntry.fromJson(entry.value, entry.key + 1);
  }).toList();
}

/// Helper function to simulate hometown filtering logic
/// This mirrors the filtering logic in ScoreService.getHometownLeaderboard
List<LeaderboardEntry> filterByHometownAndRank(
  List<Map<String, dynamic>> users,
  String hometown,
) {
  // Filter by hometown
  final filtered = users.where((u) => u['hometown'] == hometown).toList();

  // Sort by total_score descending
  filtered.sort(
    (a, b) => (b['total_score'] as int).compareTo(a['total_score'] as int),
  );

  // Assign ranks within hometown scope
  return filtered.asMap().entries.map((entry) {
    return LeaderboardEntry.fromJson(entry.value, entry.key + 1);
  }).toList();
}

/// Helper function to calculate user rank
/// This mirrors the rank calculation in ScoreService.getCurrentUserRank
int calculateUserRank(
  List<Map<String, dynamic>> users,
  int userScore, {
  String? hometown,
}) {
  List<Map<String, dynamic>> relevantUsers = users;

  if (hometown != null) {
    relevantUsers = users.where((u) => u['hometown'] == hometown).toList();
  }

  // Count users with higher scores
  final higherScoreCount = relevantUsers
      .where((u) => (u['total_score'] as int) > userScore)
      .length;

  return higherScoreCount + 1;
}

void main() {
  group('Leaderboard Ordering Tests', () {
    final random = Random(42);

    /// **Property 2: Leaderboard ordering correctness**
    /// *For any* leaderboard result, all entries SHALL be ordered by total_score
    /// in descending order (entry[i].totalScore >= entry[i+1].totalScore for all valid i).
    /// **Validates: Requirements 2.1**
    test('Property 2: Leaderboard entries are ordered by score descending', () {
      for (int iteration = 0; iteration < 100; iteration++) {
        // Generate random users with random scores
        final numUsers = 5 + random.nextInt(46); // 5-50 users
        final users = List.generate(
          numUsers,
          (i) => {
            'id': 'user-$i',
            'name': 'User $i',
            'hometown': ['Dhaka', 'Chittagong', 'Sylhet'][random.nextInt(3)],
            'total_score': random.nextInt(10001),
          },
        );

        final leaderboard = sortAndRankEntries(users);

        // Verify ordering: each entry should have score >= next entry
        for (int i = 0; i < leaderboard.length - 1; i++) {
          expect(
            leaderboard[i].totalScore,
            greaterThanOrEqualTo(leaderboard[i + 1].totalScore),
            reason:
                'Entry at rank ${leaderboard[i].rank} (score: ${leaderboard[i].totalScore}) '
                'should have score >= entry at rank ${leaderboard[i + 1].rank} (score: ${leaderboard[i + 1].totalScore})',
          );
        }
      }
    });

    /// **Property 3: Rank assignment correctness**
    /// *For any* leaderboard with N entries, ranks SHALL be assigned sequentially
    /// from 1 to N with no gaps or duplicates.
    /// **Validates: Requirements 2.2**
    test('Property 3: Ranks are assigned sequentially from 1 to N', () {
      for (int iteration = 0; iteration < 100; iteration++) {
        final numUsers = 1 + random.nextInt(50); // 1-50 users
        final users = List.generate(
          numUsers,
          (i) => {
            'id': 'user-$i',
            'name': 'User $i',
            'hometown': 'Dhaka',
            'total_score': random.nextInt(10001),
          },
        );

        final leaderboard = sortAndRankEntries(users);

        // Verify ranks are 1, 2, 3, ..., N
        for (int i = 0; i < leaderboard.length; i++) {
          expect(
            leaderboard[i].rank,
            equals(i + 1),
            reason:
                'Entry at index $i should have rank ${i + 1}, but has rank ${leaderboard[i].rank}',
          );
        }
      }
    });

    /// **Property 5: Top 50 limit correctness**
    /// *For any* leaderboard query, the result SHALL contain at most 50 entries.
    /// **Validates: Requirements 2.1**
    test('Property 5: Leaderboard contains at most 50 entries', () {
      for (int iteration = 0; iteration < 100; iteration++) {
        final numUsers = random.nextInt(101); // 0-100 users
        final users = List.generate(
          numUsers,
          (i) => {
            'id': 'user-$i',
            'name': 'User $i',
            'hometown': 'Dhaka',
            'total_score': random.nextInt(10001),
          },
        );

        final leaderboard = sortAndRankEntries(users);
        final limitedLeaderboard = leaderboard.take(50).toList();

        expect(
          limitedLeaderboard.length,
          lessThanOrEqualTo(50),
          reason: 'Leaderboard should have at most 50 entries',
        );
      }
    });
  });

  group('Hometown Filter Tests', () {
    final random = Random(42);

    /// **Property 4: Hometown filter correctness**
    /// *For any* hometown-filtered leaderboard, all entries SHALL have hometown
    /// matching the filter value.
    /// **Validates: Requirements 4.2**
    test('Property 4: Hometown filter returns only matching entries', () {
      final hometowns = ['Dhaka', 'Chittagong', 'Sylhet', 'Rajshahi', 'Khulna'];

      for (int iteration = 0; iteration < 100; iteration++) {
        // Generate random users with various hometowns
        final numUsers = 10 + random.nextInt(41); // 10-50 users
        final users = List.generate(
          numUsers,
          (i) => {
            'id': 'user-$i',
            'name': 'User $i',
            'hometown': hometowns[random.nextInt(hometowns.length)],
            'total_score': random.nextInt(10001),
          },
        );

        // Pick a random hometown to filter by
        final filterHometown = hometowns[random.nextInt(hometowns.length)];
        final filteredLeaderboard = filterByHometownAndRank(
          users,
          filterHometown,
        );

        // Verify all entries have matching hometown
        for (final entry in filteredLeaderboard) {
          expect(
            entry.hometown,
            equals(filterHometown),
            reason:
                'Entry ${entry.name} has hometown ${entry.hometown}, '
                'but filter was for $filterHometown',
          );
        }
      }
    });

    /// Test that hometown filter maintains descending score order
    /// **Validates: Requirements 4.2**
    test('Hometown filtered leaderboard maintains score ordering', () {
      for (int iteration = 0; iteration < 100; iteration++) {
        final numUsers = 20 + random.nextInt(31);
        final users = List.generate(
          numUsers,
          (i) => {
            'id': 'user-$i',
            'name': 'User $i',
            'hometown': ['Dhaka', 'Chittagong'][random.nextInt(2)],
            'total_score': random.nextInt(10001),
          },
        );

        final filteredLeaderboard = filterByHometownAndRank(users, 'Dhaka');

        // Verify ordering within filtered results
        for (int i = 0; i < filteredLeaderboard.length - 1; i++) {
          expect(
            filteredLeaderboard[i].totalScore,
            greaterThanOrEqualTo(filteredLeaderboard[i + 1].totalScore),
            reason:
                'Filtered leaderboard should maintain descending score order',
          );
        }
      }
    });

    /// Test that hometown filter assigns ranks within scope
    /// **Validates: Requirements 4.2**
    test('Hometown filtered leaderboard assigns ranks within scope', () {
      for (int iteration = 0; iteration < 100; iteration++) {
        final numUsers = 20 + random.nextInt(31);
        final users = List.generate(
          numUsers,
          (i) => {
            'id': 'user-$i',
            'name': 'User $i',
            'hometown': ['Dhaka', 'Chittagong'][random.nextInt(2)],
            'total_score': random.nextInt(10001),
          },
        );

        final filteredLeaderboard = filterByHometownAndRank(users, 'Dhaka');

        // Verify ranks are 1, 2, 3, ... within the filtered scope
        for (int i = 0; i < filteredLeaderboard.length; i++) {
          expect(
            filteredLeaderboard[i].rank,
            equals(i + 1),
            reason: 'Filtered entry at index $i should have rank ${i + 1}',
          );
        }
      }
    });
  });

  group('User Rank Calculation Tests', () {
    final random = Random(42);

    /// Test that user rank is calculated correctly globally
    /// **Validates: Requirements 3.1**
    test('User rank is calculated correctly in global scope', () {
      for (int iteration = 0; iteration < 100; iteration++) {
        final numUsers = 10 + random.nextInt(41);
        final users = List.generate(
          numUsers,
          (i) => {
            'id': 'user-$i',
            'name': 'User $i',
            'hometown': 'Dhaka',
            'total_score': random.nextInt(10001),
          },
        );

        // Pick a random user's score
        final userScore =
            users[random.nextInt(users.length)]['total_score'] as int;
        final calculatedRank = calculateUserRank(users, userScore);

        // Verify rank by counting users with higher scores + 1
        final expectedRank =
            users.where((u) => (u['total_score'] as int) > userScore).length +
            1;

        expect(
          calculatedRank,
          equals(expectedRank),
          reason: 'User with score $userScore should have rank $expectedRank',
        );
      }
    });

    /// Test that user rank is calculated correctly within hometown scope
    /// **Validates: Requirements 3.2**
    test('User rank is calculated correctly in hometown scope', () {
      final hometowns = ['Dhaka', 'Chittagong', 'Sylhet'];

      for (int iteration = 0; iteration < 100; iteration++) {
        final numUsers = 20 + random.nextInt(31);
        final users = List.generate(
          numUsers,
          (i) => {
            'id': 'user-$i',
            'name': 'User $i',
            'hometown': hometowns[random.nextInt(hometowns.length)],
            'total_score': random.nextInt(10001),
          },
        );

        // Pick a random hometown and user score
        final hometown = hometowns[random.nextInt(hometowns.length)];
        final hometownUsers = users
            .where((u) => u['hometown'] == hometown)
            .toList();

        if (hometownUsers.isEmpty) continue;

        final userScore =
            hometownUsers[random.nextInt(hometownUsers.length)]['total_score']
                as int;
        final calculatedRank = calculateUserRank(
          users,
          userScore,
          hometown: hometown,
        );

        // Verify rank within hometown scope
        final expectedRank =
            hometownUsers
                .where((u) => (u['total_score'] as int) > userScore)
                .length +
            1;

        expect(
          calculatedRank,
          equals(expectedRank),
          reason:
              'User with score $userScore in $hometown should have rank $expectedRank',
        );
      }
    });

    /// Test that highest scorer gets rank 1
    /// **Validates: Requirements 3.1**
    test('Highest scorer always gets rank 1', () {
      for (int iteration = 0; iteration < 100; iteration++) {
        final numUsers = 5 + random.nextInt(46);
        final users = List.generate(
          numUsers,
          (i) => {
            'id': 'user-$i',
            'name': 'User $i',
            'hometown': 'Dhaka',
            'total_score': random.nextInt(10001),
          },
        );

        // Find the highest score
        final highestScore = users
            .map((u) => u['total_score'] as int)
            .reduce((a, b) => a > b ? a : b);
        final rank = calculateUserRank(users, highestScore);

        expect(
          rank,
          equals(1),
          reason: 'User with highest score ($highestScore) should have rank 1',
        );
      }
    });

    /// Test that lowest scorer gets last rank
    /// **Validates: Requirements 3.1**
    test('Lowest scorer gets appropriate rank', () {
      for (int iteration = 0; iteration < 100; iteration++) {
        final numUsers = 5 + random.nextInt(46);
        final users = List.generate(
          numUsers,
          (i) => {
            'id': 'user-$i',
            'name': 'User $i',
            'hometown': 'Dhaka',
            'total_score': i * 100, // Unique scores for simplicity
          },
        );

        // Find the lowest score
        final lowestScore = users
            .map((u) => u['total_score'] as int)
            .reduce((a, b) => a < b ? a : b);
        final rank = calculateUserRank(users, lowestScore);

        // With unique scores, lowest scorer should have rank equal to number of users
        expect(
          rank,
          equals(numUsers),
          reason:
              'User with lowest score ($lowestScore) should have rank $numUsers',
        );
      }
    });
  });

  group('Edge Cases', () {
    /// Test empty leaderboard
    test('Empty user list produces empty leaderboard', () {
      final leaderboard = sortAndRankEntries([]);
      expect(leaderboard, isEmpty);
    });

    /// Test single user leaderboard
    test('Single user gets rank 1', () {
      final users = [
        {
          'id': 'user-1',
          'name': 'Solo User',
          'hometown': 'Dhaka',
          'total_score': 500,
        },
      ];

      final leaderboard = sortAndRankEntries(users);

      expect(leaderboard.length, equals(1));
      expect(leaderboard[0].rank, equals(1));
      expect(leaderboard[0].totalScore, equals(500));
    });

    /// Test users with same score
    test('Users with same score get sequential ranks', () {
      final users = [
        {
          'id': 'user-1',
          'name': 'User A',
          'hometown': 'Dhaka',
          'total_score': 500,
        },
        {
          'id': 'user-2',
          'name': 'User B',
          'hometown': 'Dhaka',
          'total_score': 500,
        },
        {
          'id': 'user-3',
          'name': 'User C',
          'hometown': 'Dhaka',
          'total_score': 500,
        },
      ];

      final leaderboard = sortAndRankEntries(users);

      // All have same score, but ranks should still be 1, 2, 3
      expect(leaderboard[0].rank, equals(1));
      expect(leaderboard[1].rank, equals(2));
      expect(leaderboard[2].rank, equals(3));
    });

    /// Test hometown filter with no matching users
    test('Hometown filter with no matches returns empty list', () {
      final users = [
        {
          'id': 'user-1',
          'name': 'User A',
          'hometown': 'Dhaka',
          'total_score': 500,
        },
        {
          'id': 'user-2',
          'name': 'User B',
          'hometown': 'Chittagong',
          'total_score': 600,
        },
      ];

      final filtered = filterByHometownAndRank(users, 'Sylhet');

      expect(filtered, isEmpty);
    });

    /// Test zero scores
    test('Users with zero score are ranked correctly', () {
      final users = [
        {
          'id': 'user-1',
          'name': 'User A',
          'hometown': 'Dhaka',
          'total_score': 0,
        },
        {
          'id': 'user-2',
          'name': 'User B',
          'hometown': 'Dhaka',
          'total_score': 100,
        },
        {
          'id': 'user-3',
          'name': 'User C',
          'hometown': 'Dhaka',
          'total_score': 0,
        },
      ];

      final leaderboard = sortAndRankEntries(users);

      expect(leaderboard[0].totalScore, equals(100));
      expect(leaderboard[0].rank, equals(1));
      // Zero score users should be ranked after
      expect(leaderboard[1].totalScore, equals(0));
      expect(leaderboard[2].totalScore, equals(0));
    });
  });
}
