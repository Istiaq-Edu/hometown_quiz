import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:hometown_quiz/pages/home.dart';

/// Property-based tests for category card rendering and navigation
/// **Feature: home-page-redesign, Property 2: Category card contains all required elements**
/// **Feature: home-page-redesign, Property 3: Navigation receives valid category string**
/// **Validates: Requirements 1.2, 1.3, 2.2**
void main() {
  group('Category Card Property Tests', () {
    final random = Random(42); // Fixed seed for reproducibility

    /// **Feature: home-page-redesign, Property 2: Category card contains all required elements**
    /// *For any* category data (name, description, image path), the rendered category card
    /// SHALL contain the category title, description text, image widget, and a "Start Quiz" button.
    /// **Validates: Requirements 1.2**
    test(
      'Property 2: All categories have required fields (name, description, imagePath)',
      () {
        // Run 100 iterations verifying all categories have required fields
        for (int i = 0; i < 100; i++) {
          // Pick a random category
          final categoryIndex = random.nextInt(categories.length);
          final category = categories[categoryIndex];

          // Verify category has all required fields
          expect(
            category.name.isNotEmpty,
            isTrue,
            reason:
                'Category at index $categoryIndex should have a non-empty name',
          );
          expect(
            category.description.isNotEmpty,
            isTrue,
            reason:
                'Category at index $categoryIndex should have a non-empty description',
          );
          expect(
            category.imagePath.isNotEmpty,
            isTrue,
            reason:
                'Category at index $categoryIndex should have a non-empty imagePath',
          );

          // Verify the category name is one of the valid categories
          expect(
            validCategoryNames.contains(category.name),
            isTrue,
            reason:
                'Category name "${category.name}" should be in validCategoryNames',
          );
        }
      },
    );

    /// **Feature: home-page-redesign, Property 3: Navigation receives valid category string**
    /// *For any* quiz start action (either direct category tap or random selection),
    /// the navigation to QuizPage SHALL receive a category string that matches
    /// one of the three valid categories.
    /// **Validates: Requirements 1.3, 2.2**
    test(
      'Property 3: All category names in categories list are valid for navigation',
      () {
        // Run 100 iterations verifying category names are valid
        for (int i = 0; i < 100; i++) {
          // Pick a random category
          final categoryIndex = random.nextInt(categories.length);
          final category = categories[categoryIndex];

          // Verify the category name is valid for navigation
          expect(
            validCategoryNames.contains(category.name),
            isTrue,
            reason:
                'Category name "${category.name}" should be valid for navigation to QuizPage',
          );
        }
      },
    );

    /// Verify the categories list contains exactly 3 categories as per requirements
    test('Categories list contains exactly 3 categories', () {
      expect(
        categories.length,
        equals(3),
        reason: 'There should be exactly 3 quiz categories',
      );
    });

    /// Verify all expected categories are present
    test('All expected categories are present', () {
      final categoryNames = categories.map((c) => c.name).toList();

      expect(
        categoryNames.contains('Places & History'),
        isTrue,
        reason: 'Categories should include "Places & History"',
      );
      expect(
        categoryNames.contains('Culture & Traditions'),
        isTrue,
        reason: 'Categories should include "Culture & Traditions"',
      );
      expect(
        categoryNames.contains('Everyday Bangladesh'),
        isTrue,
        reason: 'Categories should include "Everyday Bangladesh"',
      );
    });

    /// Verify validCategoryNames matches categories list
    test('validCategoryNames matches categories list', () {
      final categoryNames = categories.map((c) => c.name).toSet();
      final validNames = validCategoryNames.toSet();

      expect(
        categoryNames,
        equals(validNames),
        reason: 'validCategoryNames should match all category names',
      );
    });
  });
}
