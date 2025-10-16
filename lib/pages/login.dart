import 'package:flutter/material.dart';
import 'package:hometown_quiz/pages/signup.dart';
import 'package:hometown_quiz/supabase_helper.dart';
import 'package:hometown_quiz/pages/home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controllers to get text from input fields
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  // Variable to show/hide password
  bool hidePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F5), // Light background color
      body: SafeArea(
        child: Column(
          children: [
            // Main content area
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Title
                      const Text(
                        'Welcome Back!',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF221710),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),

                      // Subtitle
                      const Text(
                        'Sign in to continue your hometown challenge.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0x99221710),
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 48),

                      // Email input field
                      SizedBox(
                        height: 56,
                        child: TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(color: Color(0xFF221710)),
                          decoration: InputDecoration(
                            hintText: 'Enter email',
                            hintStyle: const TextStyle(
                              color: Color(0x80221710),
                            ),
                            prefixIcon: const Icon(
                              Icons.email_outlined,
                              color: Color(0x66221710),
                            ),
                            filled: true,
                            fillColor: const Color(0x0D221710),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(100),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Password input field
                      Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: const Color(
                            0x0D221710,
                          ), // Light gray background
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: TextField(
                          controller: passwordController,
                          obscureText: hidePassword, // Hide password text
                          style: const TextStyle(color: Color(0xFF221710)),
                          decoration: InputDecoration(
                            hintText: 'Enter password',
                            hintStyle: const TextStyle(
                              color: Color(0x80221710),
                            ),
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: Color(0x66221710),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                hidePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: const Color(0x66221710),
                              ),
                              onPressed: () {
                                // Toggle password visibility
                                setState(() {
                                  hidePassword = !hidePassword;
                                });
                              },
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Forgot Password button
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // TODO: Add forgot password functionality later
                          },
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFF47B25),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Login button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () async {
                            // Get the entered values
                            String email = emailController.text;
                            String password = passwordController.text;

                            // Simple validation
                            if (email.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please enter your email'),
                                  backgroundColor: Color(0xFFF47B25),
                                ),
                              );
                              return;
                            }

                            if (password.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please enter your password'),
                                  backgroundColor: Color(0xFFF47B25),
                                ),
                              );
                              return;
                            }

                            // Call login function
                            String? error = await loginUser(email, password);

                            // Check if login was successful
                            if (error == null) {
                              // Show success message
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Login successful!'),
                                  backgroundColor: Colors.green,
                                ),
                              );

                              // Go to home page
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const HomePage(),
                                ),
                              );
                            } else {
                              // Show error message
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: $error'),
                                  backgroundColor: Color(0xFFF47B25),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(
                              0xFFF47B25,
                            ), // Orange button
                            foregroundColor: Colors.white, // White text
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100),
                            ),
                            elevation: 0,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Sign up link at bottom
            Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'New here? ',
                    style: TextStyle(fontSize: 14, color: Color(0x99221710)),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to signup page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignupPage(),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                    ),
                    child: const Text(
                      'Create an account.',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF47B25),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
