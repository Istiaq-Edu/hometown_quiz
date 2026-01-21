import 'package:flutter/material.dart';
import 'package:hometown_quiz/pages/login.dart';
import 'package:hometown_quiz/pages/home.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  // Initialize Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase with credentials
  // Note: The anon key is safe to include in code - it's designed for client-side use
  // Your data is protected by Row Level Security (RLS) policies in Supabase
  await Supabase.initialize(
    url: 'https://uurccpzssdfnplxllbvi.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InV1cmNjcHpzc2RmbnBseGxsYnZpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA1MDkwMjQsImV4cCI6MjA3NjA4NTAyNH0.t4_gavQ3QtdpkVD6Ch2g4izBATti0U9x3nptdTBF3z0',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hometown Quiz',
      debugShowCheckedModeBanner: false, // Remove debug banner
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFF47B25)),
      ),
      home: const AuthChecker(), // Check if user is logged in
    );
  }
}

// Simple widget to check if user is logged in
class AuthChecker extends StatelessWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if user is already logged in
    final session = Supabase.instance.client.auth.currentSession;

    // If logged in, go to home page, otherwise go to login page
    if (session != null) {
      return const HomePage();
    } else {
      return const LoginPage();
    }
  }
}
