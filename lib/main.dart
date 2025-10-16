import 'package:flutter/material.dart';
import 'package:hometown_quiz/pages/login.dart';
import 'package:hometown_quiz/pages/home.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  // Initialize Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file
  await dotenv.load(fileName: ".env");

  // Initialize Supabase using environment variables
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
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
