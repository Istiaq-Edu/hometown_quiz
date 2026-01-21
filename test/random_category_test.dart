import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:hometown_quiz/pages/home.dart';

/// Property-based tests for random category selection
/// **Feature: home-page-redesign, Property 1: Random category selection produces valid category**
/// **Validates: Requirements 2.1**
void main() {
  group('Random Category Selection Property Tests', () {
    /// **Feature: home-page-redesign, Property 1: Random category selection produces valid category**
    /// *For any* invocation of the random category selection function, the result SHALL be
    /// one of the three valid category strings: "Places & History", "Culture & Traditions",
    /// or "Everyday Bangladesh".
    /// **Validates: Requirements 2.1**
    test(
      'Property 1: Random category selection always produces valid category',
      () {
        // Run 100 iterations with different random seeds to verify property holds
        for (int seed = 0; seed < 100; seed++) {
          final random = Random(seed);

          // Call the random category selection function multiple times per seed
          for (int i = 0; i < 10; i++) {
            final selectedCategory = getRandomCategory(random);

            // Verify the selected category is one of the valid categories
            expect(
              validCategoryNames.contains(selectedCategory),
              isTrue,
              reason:
                  'Selected category "$selectedCategory" (seed: $seed, iteration: $i) '
                  'should be one of: ${validCategoryNames.join(", ")}',
            );
          }
        }
      },
    );

    /// Additional property: Random selection covers all categories over many iterations
    test(
      'Property 1 (coverage): Random selection can produce all valid categories',
      () {
        final selectedCategories = <String>{};
        final random = Random(42);

        // Run enough iterations to statistically cover all categories
        for (int i = 0; i < 1000; i++) {
          final selectedCategory = getRandomCategory(random);
          selectedCategories.add(selectedCategory);

          // Early exit if we've seen all categories
          if (selectedCategories.length == validCategoryNames.length) {
            break;
          }
        }

        // Verify all categories were selected at least once
        expect(
          selectedCategories.length,
          equals(validCategoryNames.length),
          reason:
              'Random selection should be able to produce all ${validCategoryNames.length} categories. '
              'Only produced: ${selectedCategories.join(", ")}',
        );
      },
    );

    /// Verify the function returns a string type
    test('Random category selection returns a non-empty string', () {
      for (int seed = 0; seed < 100; seed++) {
        final random = Random(seed);
        final selectedCategory = getRandomCategory(random);

        expect(
          selectedCategory.isNotEmpty,
          isTrue,
          reason: 'Selected category should be a non-empty string',
        );
      }
    });
  });
}
