// Basic widget test for Hometown Quiz app
//
// Note: Full widget tests requiring Supabase are not included here
// as they require environment setup. The property-based tests in
// other test files cover the core functionality.

import 'package:flutter_test/flutter_test.dart';
import 'package:hometown_quiz/pages/home.dart';

void main() {
  group('Hometown Quiz App Tests', () {
    test('App constants are properly defined', () {
      // Verify that the categories list is properly defined
      expect(categories.length, equals(3));
      expect(validCategoryNames.length, equals(3));
    });

    test('Category data structure is valid', () {
      for (final category in categories) {
        expect(category.name.isNotEmpty, isTrue);
        expect(category.description.isNotEmpty, isTrue);
        expect(category.imagePath.isNotEmpty, isTrue);
      }
    });
  });
}
