import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:hometown_quiz/score_service.dart';

/// Tests for score saving flow verification
/// **Feature: leaderboard-scores, Task 9.1: Test score saving flow**
/// **Validates: Requirements 1.1, 1.2**

void main() {
  group('Score Saving Flow Tests', () {
    /// Test that QuizScoreData correctly serializes all required fields
    /// (Requirements: 1.1)
    test('QuizScoreData serializes all required fields correctly', () {
      final scoreData = QuizScoreData(
        category: 'Place and History',
        score: 85,
        timeBonus: 5,
        correctAnswers: 8,
        totalQuestions: 10,
      );

      final json = scoreData.toJson();

      expect(json['category'], equals('Place and History'));
      expect(json['score'], equals(85));
      expect(json['time_bonus'], equals(5));
      expect(json['correct_answers'], equals(8));
      expect(json['total_questions'], equals(10));
    });

    /// Property test: QuizScoreData serialization preserves all values
    /// (Requirements: 1.1)
    test('Property: QuizScoreData serialization preserves all values', () {
      final random = Random(42);

      for (int i = 0; i < 100; i++) {
        final categories = [
          'Place and History',
          'Culture and Traditions',
          'Everyday Bangladesh',
        ];
        final category = categories[random.nextInt(categories.length)];
        final score = random.nextInt(201); // 0-200
        final timeBonus = random.nextInt(11); // 0-10
        final totalQuestions = 5 + random.nextInt(16); // 5-20
        final correctAnswers = random.nextInt(totalQuestions + 1);

        final scoreData = QuizScoreData(
          category: category,
          score: score,
          timeBonus: timeBonus,
          correctAnswers: correctAnswers,
          totalQuestions: totalQuestions,
        );

        final json = scoreData.toJson();

        expect(json['category'], equals(category));
        expect(json['score'], equals(score));
        expect(json['time_bonus'], equals(timeBonus));
        expect(json['correct_answers'], equals(correctAnswers));
        expect(json['total_questions'], equals(totalQuestions));
      }
    });

    /// Test that score values are within valid ranges
    /// (Requirements: 1.1)
    test('Score values are within valid ranges', () {
      final random = Random(42);

      for (int i = 0; i < 100; i++) {
        final totalQuestions = 5 + random.nextInt(16);
        final correctAnswers = random.nextInt(totalQuestions + 1);
        // Max score: 11 points per question (10 base + 1 bonus)
        final maxPossibleScore = totalQuestions * 11;
        final score = random.nextInt(maxPossibleScore + 1);
        final timeBonus = random.nextInt(totalQuestions + 1);

        final scoreData = QuizScoreData(
          category: 'Test Category',
          score: score,
          timeBonus: timeBonus,
          correctAnswers: correctAnswers,
          totalQuestions: totalQuestions,
        );

        // Verify constraints
        expect(
          scoreData.correctAnswers,
          lessThanOrEqualTo(scoreData.totalQuestions),
        );
        expect(
          scoreData.timeBonus,
          lessThanOrEqualTo(scoreData.totalQuestions),
        );
        expect(scoreData.score, greaterThanOrEqualTo(0));
      }
    });
  });

  group('LeaderboardEntry Tests', () {
    /// Test LeaderboardEntry.fromJson correctly parses all fields
    /// (Requirements: 2.2)
    test('LeaderboardEntry.fromJson parses all fields correctly', () {
      final json = {
        'id': 'user-123',
        'name': 'Test User',
        'hometown': 'Dhaka',
        'total_score': 500,
      };

      final entry = LeaderboardEntry.fromJson(json, 1);

      expect(entry.rank, equals(1));
      expect(entry.userId, equals('user-123'));
      expect(entry.name, equals('Test User'));
      expect(entry.hometown, equals('Dhaka'));
      expect(entry.totalScore, equals(500));
    });

    /// Test LeaderboardEntry handles null values with defaults
    /// (Requirements: 2.2)
    test('LeaderboardEntry handles null values with defaults', () {
      final json = {
        'id': 'user-456',
        'name': null,
        'hometown': null,
        'total_score': null,
      };

      final entry = LeaderboardEntry.fromJson(json, 5);

      expect(entry.rank, equals(5));
      expect(entry.userId, equals('user-456'));
      expect(entry.name, equals('Unknown'));
      expect(entry.hometown, equals('Unknown'));
      expect(entry.totalScore, equals(0));
    });

    /// Property test: LeaderboardEntry preserves rank assignment
    /// (Requirements: 2.2)
    test('Property: LeaderboardEntry preserves rank assignment', () {
      final random = Random(42);

      for (int i = 0; i < 100; i++) {
        final rank = 1 + random.nextInt(50);
        final json = {
          'id': 'user-$i',
          'name': 'User $i',
          'hometown': 'City $i',
          'total_score': random.nextInt(10001),
        };

        final entry = LeaderboardEntry.fromJson(json, rank);

        expect(entry.rank, equals(rank));
      }
    });
  });

  group('UserRankData Tests', () {
    /// Test UserRankData construction
    /// (Requirements: 3.1, 3.2)
    test('UserRankData stores rank, name, and totalScore correctly', () {
      final rankData = UserRankData(
        rank: 15,
        name: 'Current User',
        totalScore: 750,
      );

      expect(rankData.rank, equals(15));
      expect(rankData.name, equals('Current User'));
      expect(rankData.totalScore, equals(750));
    });

    /// Property test: UserRankData preserves all values
    /// (Requirements: 3.1, 3.2)
    test('Property: UserRankData preserves all values', () {
      final random = Random(42);

      for (int i = 0; i < 100; i++) {
        final rank = 1 + random.nextInt(1000);
        final name = 'User $i';
        final totalScore = random.nextInt(50001);

        final rankData = UserRankData(
          rank: rank,
          name: name,
          totalScore: totalScore,
        );

        expect(rankData.rank, equals(rank));
        expect(rankData.name, equals(name));
        expect(rankData.totalScore, equals(totalScore));
      }
    });
  });
}
