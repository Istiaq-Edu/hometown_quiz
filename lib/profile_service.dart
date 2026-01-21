import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/user_profile.dart';
import 'models/user_stats.dart';

/// Supabase client reference
final _supabase = Supabase.instance.client;

/// Service class for profile-related database operations
/// (Requirements: 1.3, 2.2, 2.3, 3.2, 3.3, 3.4, 3.5, 4.2, 5.2, 8.2)
class ProfileService {
  /// Gets user profile data (name, hometown, photo_url, total_score)
  /// Returns UserProfile object or null on failure
  /// (Requirements: 1.3)
  static Future<UserProfile?> getUserProfile() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      final response = await _supabase
          .from('users')
          .select('id, name, hometown, photo_url, total_score')
          .eq('id', user.id)
          .single();

      return UserProfile.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  /// Gets aggregated user stats from quiz_scores using RPC function
  /// Calculates accuracy from total_correct / total_questions
  /// Returns UserStats object or null on failure
  /// (Requirements: 3.2, 3.3, 3.4, 3.5)
  static Future<UserStats?> getUserStats() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      final response = await _supabase.rpc(
        'get_user_stats',
        params: {'p_user_id': user.id},
      );

      if (response == null) {
        // Return default stats if no data
        return const UserStats(
          quizzesPlayed: 0,
          highestScore: 0,
          accuracy: 0.0,
          timeBonuses: 0,
          distinctCategories: 0,
        );
      }

      return UserStats.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  /// Updates user's name in the database
  /// Returns true on success, false on failure
  /// (Requirements: 4.2)
  static Future<bool> updateName(String name) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      await _supabase.from('users').update({'name': name}).eq('id', user.id);

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Updates user's hometown in the database
  /// Returns true on success, false on failure
  /// (Requirements: 5.2)
  static Future<bool> updateHometown(String hometown) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      await _supabase
          .from('users')
          .update({'hometown': hometown})
          .eq('id', user.id);

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Uploads profile photo to Supabase Storage and updates photo_url in users table
  /// Returns new photo URL on success, null on failure
  /// (Requirements: 2.2, 2.3)
  static Future<String?> uploadProfilePhoto(File image) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      // Generate unique filename using user ID and timestamp
      final fileExt = image.path.split('.').last;
      final fileName =
          '${user.id}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = fileName;

      // Upload image to profile-photos bucket
      await _supabase.storage
          .from('profile-photos')
          .upload(
            filePath,
            image,
            fileOptions: const FileOptions(upsert: true),
          );

      // Get public URL for the uploaded image
      final photoUrl = _supabase.storage
          .from('profile-photos')
          .getPublicUrl(filePath);

      // Update photo_url in users table
      await _supabase
          .from('users')
          .update({'photo_url': photoUrl})
          .eq('id', user.id);

      return photoUrl;
    } catch (e) {
      return null;
    }
  }

  /// Deletes user account and all related data
  /// - Deletes profile photo from storage if exists
  /// - Calls delete_user_account RPC function
  /// - Signs out user from Supabase Auth
  /// Returns true on success, false on failure
  /// (Requirements: 8.2)
  static Future<bool> deleteAccount() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      // Get current photo URL to delete from storage
      final profileResponse = await _supabase
          .from('users')
          .select('photo_url')
          .eq('id', user.id)
          .single();

      final photoUrl = profileResponse['photo_url'] as String?;

      // Delete profile photo from storage if exists
      if (photoUrl != null && photoUrl.isNotEmpty) {
        try {
          // Extract filename from URL
          final uri = Uri.parse(photoUrl);
          final pathSegments = uri.pathSegments;
          if (pathSegments.isNotEmpty) {
            final fileName = pathSegments.last;
            await _supabase.storage.from('profile-photos').remove([fileName]);
          }
        } catch (e) {
          // Continue even if photo deletion fails
        }
      }

      // Call RPC function to delete user data
      final response = await _supabase.rpc(
        'delete_user_account',
        params: {'p_user_id': user.id},
      );

      // Check if deletion was successful
      if (response == false) {
        return false;
      }

      // Sign out user
      await _supabase.auth.signOut();

      return true;
    } catch (e) {
      return false;
    }
  }
}
