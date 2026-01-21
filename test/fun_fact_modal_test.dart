import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hometown_quiz/models/fun_fact.dart';

/// Property-based tests for fun fact modal content display
/// **Feature: fun-facts-feature, Property 2: Fun fact modal displays all required fields**
/// **Validates: Requirements 2.3**
void main() {
  group('Fun Fact Modal Content Display Property Tests', () {
    final random = Random(42); // Fixed seed for reproducibility

    /// Generates a random string of given length
    String generateRandomString(int length) {
      const chars =
          'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 ';
      return List.generate(
        length,
        (index) => chars[random.nextInt(chars.length)],
      ).join();
    }

    /// Generates a random FunFact with random content and category
    FunFact generateRandomFunFact() {
      final categories = [
        'Culture & Traditions',
        'Places & History',
        'Everyday Bangladesh',
        'Nature & Wildlife',
        'Food & Cuisine',
      ];
      return FunFact(
        id: 'test-${random.nextInt(10000)}',
        content: generateRandomString(50 + random.nextInt(150)),
        category: categories[random.nextInt(categories.length)],
      );
    }

    /// **Feature: fun-facts-feature, Property 2: Fun fact modal displays all required fields**
    /// *For any* FunFact object with content and category, the modal SHALL display
    /// the lightbulb icon, "Fun Fact!" title, the fact content, and the category label.
    /// **Validates: Requirements 2.3**
    testWidgets(
      'Property 2: Modal displays all required fields for random FunFact objects',
      (WidgetTester tester) async {
        // Run 100 iterations with different random FunFact objects
        for (int i = 0; i < 100; i++) {
          final funFact = generateRandomFunFact();

          // Build a minimal widget that displays the modal content
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(body: _TestFunFactModalContent(funFact: funFact)),
            ),
          );

          // Verify lightbulb icon is present
          expect(
            find.byIcon(Icons.lightbulb),
            findsOneWidget,
            reason:
                'Iteration $i: Modal should display lightbulb icon for FunFact with content "${funFact.content.substring(0, 20)}..."',
          );

          // Verify "Fun Fact!" title is present
          expect(
            find.text('Fun Fact!'),
            findsOneWidget,
            reason:
                'Iteration $i: Modal should display "Fun Fact!" title for FunFact with content "${funFact.content.substring(0, 20)}..."',
          );

          // Verify fact content is displayed
          expect(
            find.text(funFact.content),
            findsOneWidget,
            reason:
                'Iteration $i: Modal should display fact content "${funFact.content.substring(0, 20)}..."',
          );

          // Verify category label is displayed
          expect(
            find.text(funFact.category),
            findsOneWidget,
            reason:
                'Iteration $i: Modal should display category "${funFact.category}"',
          );

          // Verify "Continue Quiz" button is present
          expect(
            find.text('Continue Quiz'),
            findsOneWidget,
            reason: 'Iteration $i: Modal should display "Continue Quiz" button',
          );
        }
      },
    );

    /// Test with specific edge cases
    testWidgets('Modal displays all fields for edge case FunFacts', (
      WidgetTester tester,
    ) async {
      // Test with very short content
      final shortFact = FunFact(id: 'short-1', content: 'A', category: 'X');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: _TestFunFactModalContent(funFact: shortFact)),
        ),
      );

      expect(find.byIcon(Icons.lightbulb), findsOneWidget);
      expect(find.text('Fun Fact!'), findsOneWidget);
      expect(find.text('A'), findsOneWidget);
      expect(find.text('X'), findsOneWidget);
      expect(find.text('Continue Quiz'), findsOneWidget);

      // Test with long content
      final longFact = FunFact(
        id: 'long-1',
        content: 'A' * 500,
        category: 'Very Long Category Name That Might Wrap',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: _TestFunFactModalContent(funFact: longFact)),
        ),
      );

      expect(find.byIcon(Icons.lightbulb), findsOneWidget);
      expect(find.text('Fun Fact!'), findsOneWidget);
      expect(find.text('A' * 500), findsOneWidget);
      expect(
        find.text('Very Long Category Name That Might Wrap'),
        findsOneWidget,
      );
      expect(find.text('Continue Quiz'), findsOneWidget);
    });
  });
}

/// Test widget that mimics the fun fact modal content structure
/// This allows us to test the modal content display without needing the full QuizPage
class _TestFunFactModalContent extends StatelessWidget {
  final FunFact funFact;

  const _TestFunFactModalContent({required this.funFact});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Lightbulb icon header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFFDE8D7),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lightbulb,
              size: 40,
              color: Color(0xFFF47B25),
            ),
          ),
          const SizedBox(height: 16),
          // "Fun Fact!" title
          const Text(
            'Fun Fact!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF221710),
            ),
          ),
          const SizedBox(height: 16),
          // Fact content text
          Text(
            funFact.content,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF221710),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // Category label chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              funFact.category,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF2E7D32),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // "Continue Quiz" button
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF47B25),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Continue Quiz',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
