import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/fun_fact.dart';

/// Supabase client reference
final _supabase = Supabase.instance.client;

/// Service class for fun fact operations
/// (Requirements: 5.1)
class FunFactService {
  /// Fetches a random fun fact from Supabase
  /// Fetches all facts and selects one randomly
  /// Returns FunFact object or null on error
  /// (Requirements: 5.1)
  static Future<FunFact?> getRandomFunFact() async {
    try {
      // Fetch all facts and select randomly
      // Note: Database uses 'fact_text' column, we map it to 'content' for the model
      final response = await _supabase
          .from('fun_facts')
          .select('id, fact_text, category');

      final List<dynamic> factsList = response as List<dynamic>;
      if (factsList.isEmpty) return null;

      factsList.shuffle();

      // Map database column 'fact_text' to model field 'content'
      final data = factsList.first as Map<String, dynamic>;
      return FunFact(
        id: data['id'] as String,
        content: data['fact_text'] as String,
        category: data['category'] as String? ?? 'General',
      );
    } catch (e) {
      print('Error fetching fun fact: $e');
      return null;
    }
  }
}
