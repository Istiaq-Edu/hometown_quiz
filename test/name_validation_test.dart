import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:hometown_quiz/pages/profile_page.dart';

/// Property-based tests for name validation
/// **Feature: profile-page, Property 5: Name validation rejects empty input**
/// **Validates: Requirements 4.4**
void main() {
  group('Name Validation Property Tests', () {
    final random = Random(42); // Fixed seed for reproducibility

    /// **Feature: profile-page, Property 5: Name validation rejects empty input**
    /// *For any* string that is empty or contains only whitespace characters,
    /// the name validation SHALL return false and prevent submission.
    /// **Validates: Requirements 4.4**
    test('Property 5: Empty or whitespace-only strings are rejected', () {
      // Run 100 iterations with various whitespace-only strings
      for (int i = 0; i < 100; i++) {
        // Generate random whitespace-only string
        final whitespaceString = _generateWhitespaceString(random);

        final isValid = ProfilePageState.validateName(whitespaceString);

        expect(
          isValid,
          isFalse,
          reason:
              'Whitespace-only string "${_escapeString(whitespaceString)}" should be rejected',
        );
      }
    });

    /// Property: Valid names (non-empty, non-whitespace-only) are accepted
    test('Property 5 inverse: Non-empty strings with content are accepted', () {
      // Run 100 iterations with valid names
      for (int i = 0; i < 100; i++) {
        // Generate random valid name
        final validName = _generateValidName(random);

        final isValid = ProfilePageState.validateName(validName);

        expect(
          isValid,
          isTrue,
          reason: 'Valid name "$validName" should be accepted',
        );
      }
    });

    /// Edge case: Empty string should be rejected
    test('Edge case: Empty string is rejected', () {
      final isValid = ProfilePageState.validateName('');
      expect(isValid, isFalse);
    });

    /// Edge case: Single space should be rejected
    test('Edge case: Single space is rejected', () {
      final isValid = ProfilePageState.validateName(' ');
      expect(isValid, isFalse);
    });

    /// Edge case: Multiple spaces should be rejected
    test('Edge case: Multiple spaces are rejected', () {
      final isValid = ProfilePageState.validateName('     ');
      expect(isValid, isFalse);
    });

    /// Edge case: Tab characters should be rejected
    test('Edge case: Tab characters are rejected', () {
      final isValid = ProfilePageState.validateName('\t\t');
      expect(isValid, isFalse);
    });

    /// Edge case: Newline characters should be rejected
    test('Edge case: Newline characters are rejected', () {
      final isValid = ProfilePageState.validateName('\n\n');
      expect(isValid, isFalse);
    });

    /// Edge case: Mixed whitespace should be rejected
    test('Edge case: Mixed whitespace is rejected', () {
      final isValid = ProfilePageState.validateName(' \t\n ');
      expect(isValid, isFalse);
    });

    /// Edge case: Name with leading/trailing whitespace but content is valid
    test('Edge case: Name with leading/trailing whitespace is valid', () {
      final isValid = ProfilePageState.validateName('  John  ');
      expect(isValid, isTrue);
    });
  });
}

/// Generate a random whitespace-only string
String _generateWhitespaceString(Random random) {
  final whitespaceChars = [' ', '\t', '\n', '\r'];
  final length = random.nextInt(10); // 0 to 9 characters

  if (length == 0) return '';

  final buffer = StringBuffer();
  for (int i = 0; i < length; i++) {
    buffer.write(whitespaceChars[random.nextInt(whitespaceChars.length)]);
  }
  return buffer.toString();
}

/// Generate a random valid name (contains at least one non-whitespace character)
String _generateValidName(Random random) {
  const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
  final length = 1 + random.nextInt(20); // 1 to 20 characters

  final buffer = StringBuffer();

  // Optionally add leading whitespace
  if (random.nextBool()) {
    buffer.write(' ' * random.nextInt(3));
  }

  // Add actual name content
  for (int i = 0; i < length; i++) {
    buffer.write(chars[random.nextInt(chars.length)]);
  }

  // Optionally add trailing whitespace
  if (random.nextBool()) {
    buffer.write(' ' * random.nextInt(3));
  }

  return buffer.toString();
}

/// Escape string for readable output
String _escapeString(String s) {
  return s
      .replaceAll('\n', '\\n')
      .replaceAll('\t', '\\t')
      .replaceAll('\r', '\\r');
}
