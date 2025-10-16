import 'package:supabase_flutter/supabase_flutter.dart';

// Supabase client - easy access anywhere in the app
final supabase = Supabase.instance.client;

// Simple signup function
Future<String?> signUpUser(
  String email,
  String password,
  String name,
  String hometown,
) async {
  try {
    // Create user account in Supabase Auth
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
      emailRedirectTo: null,
    );

    // If signup successful, save user info to database
    if (response.user != null) {
      await supabase.from('users').insert({
        'id': response.user!.id,
        'email': email,
        'name': name,
        'hometown': hometown,
      });

      return null; // No error
    }

    return 'Signup failed. Please try again.';
  } catch (e) {
    // Show simple error message
    String errorMessage = e.toString();
    if (errorMessage.contains('already registered')) {
      return 'This email is already registered. Please login instead.';
    } else if (errorMessage.contains('Invalid email')) {
      return 'Please enter a valid email address.';
    } else if (errorMessage.contains('weak password')) {
      return 'Password is too weak. Use at least 6 characters.';
    } else {
      return 'Signup failed. Try using a different email.';
    }
  }
}

// Simple login function
Future<String?> loginUser(String email, String password) async {
  try {
    await supabase.auth.signInWithPassword(email: email, password: password);
    return null; // No error
  } catch (e) {
    return e.toString();
  }
}

// Simple logout function
Future<void> logoutUser() async {
  await supabase.auth.signOut();
}

// Check if user is logged in
bool isUserLoggedIn() {
  return supabase.auth.currentUser != null;
}

// Get current user email
String? getCurrentUserEmail() {
  return supabase.auth.currentUser?.email;
}
