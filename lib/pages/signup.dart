import 'package:flutter/material.dart';
import 'package:hometown_quiz/supabase_helper.dart';
import 'package:hometown_quiz/pages/home.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  // Controllers to get text from input fields
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  // Variables to show/hide passwords
  bool hidePassword = true;
  bool hideConfirmPassword = true;

  // Variable for selected town
  String? selectedTown;

  // List of all Bangladesh towns
  List<String> bangladeshTowns = [
    'Dhaka',
    'Chittagong',
    'Sylhet',
    'Rajshahi',
    'Khulna',
    'Barisal',
    'Rangpur',
    'Mymensingh',
    'Comilla',
    'Narayanganj',
    'Gazipur',
    'Bogra',
    'Jessore',
    'Dinajpur',
    'Pabna',
    'Tangail',
    'Jamalpur',
    'Kushtia',
    'Faridpur',
    'Brahmanbaria',
    'Narsingdi',
    'Sirajganj',
    'Rangamati',
    'Cox\'s Bazar',
    'Noakhali',
    'Feni',
    'Lakshmipur',
    'Chandpur',
    'Munshiganj',
    'Manikganj',
    'Kishoreganj',
    'Netrokona',
    'Sherpur',
    'Madaripur',
    'Gopalganj',
    'Shariatpur',
    'Rajbari',
    'Magura',
    'Jhenaidah',
    'Chuadanga',
    'Meherpur',
    'Narail',
    'Satkhira',
    'Bagerhat',
    'Pirojpur',
    'Jhalokati',
    'Patuakhali',
    'Barguna',
    'Panchagarh',
    'Thakurgaon',
    'Nilphamari',
    'Lalmonirhat',
    'Kurigram',
    'Gaibandha',
    'Joypurhat',
    'Naogaon',
    'Natore',
    'Chapainawabganj',
    'Habiganj',
    'Moulvibazar',
    'Sunamganj',
    'Bandarban',
    'Khagrachari',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F5), // Light background color
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button and title
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      // Go back to login page
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back),
                    color: const Color(0xFF221710),
                  ),
                  const Expanded(
                    child: Text(
                      'Create Your Account',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF221710),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48), // Balance the back button
                ],
              ),
            ),

            // Scrollable form content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 16),

                    // Main title
                    const Text(
                      'Join thousands of players exploring Bangladesh, one quiz at a time.',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF221710),
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 32),

                    // Name input field
                    TextField(
                      controller: nameController,
                      style: const TextStyle(color: Color(0xFF221710)),
                      decoration: InputDecoration(
                        hintText: 'Enter your name',
                        hintStyle: const TextStyle(color: Color(0x80221710)),
                        filled: true,
                        fillColor: const Color(0x1AF47B25),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Email input field
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: Color(0xFF221710)),
                      decoration: InputDecoration(
                        hintText: 'Enter email',
                        hintStyle: const TextStyle(color: Color(0x80221710)),
                        filled: true,
                        fillColor: const Color(0x1AF47B25),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Password input field
                    TextField(
                      controller: passwordController,
                      obscureText: hidePassword, // Hide password text
                      style: const TextStyle(color: Color(0xFF221710)),
                      decoration: InputDecoration(
                        hintText: 'Password',
                        hintStyle: const TextStyle(color: Color(0x80221710)),
                        filled: true,
                        fillColor: const Color(0x1AF47B25),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            hidePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: const Color(0x80221710),
                          ),
                          onPressed: () {
                            // Toggle password visibility
                            setState(() {
                              hidePassword = !hidePassword;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Confirm Password input field
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(
                          0x1AF47B25,
                        ), // Light orange background
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextField(
                        controller: confirmPasswordController,
                        obscureText: hideConfirmPassword, // Hide password text
                        style: const TextStyle(color: Color(0xFF221710)),
                        decoration: InputDecoration(
                          hintText: 'Confirm Password',
                          hintStyle: const TextStyle(color: Color(0x80221710)),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              hideConfirmPassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: const Color(0x80221710),
                            ),
                            onPressed: () {
                              // Toggle confirm password visibility
                              setState(() {
                                hideConfirmPassword = !hideConfirmPassword;
                              });
                            },
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Town dropdown
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(
                          0x1AF47B25,
                        ), // Light orange background
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: DropdownButton<String>(
                        value: selectedTown,
                        hint: const Text(
                          'Select your town',
                          style: TextStyle(color: Color(0x80221710)),
                        ),
                        isExpanded: true,
                        underline: const SizedBox(), // Remove default underline
                        icon: const Icon(
                          Icons.keyboard_arrow_down,
                          color: Color(0xFFF47B25),
                        ),
                        dropdownColor: const Color(0xFFF8F7F5),
                        items: bangladeshTowns.map((String town) {
                          return DropdownMenuItem<String>(
                            value: town,
                            child: Text(
                              town,
                              style: const TextStyle(color: Color(0xFF221710)),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          // Update selected town
                          setState(() {
                            selectedTown = newValue;
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Bottom section with Sign Up button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Sign Up button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        // Get all the entered values
                        String name = nameController.text;
                        String email = emailController.text;
                        String password = passwordController.text;
                        String confirmPassword = confirmPasswordController.text;

                        // Simple validation
                        if (name.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter your name'),
                              backgroundColor: Color(0xFFF47B25),
                            ),
                          );
                          return;
                        }

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
                              content: Text('Please enter a password'),
                              backgroundColor: Color(0xFFF47B25),
                            ),
                          );
                          return;
                        }

                        if (password.length < 6) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Password must be at least 6 characters',
                              ),
                              backgroundColor: Color(0xFFF47B25),
                            ),
                          );
                          return;
                        }

                        if (password != confirmPassword) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Passwords do not match'),
                              backgroundColor: Color(0xFFF47B25),
                            ),
                          );
                          return;
                        }

                        if (selectedTown == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please select your town'),
                              backgroundColor: Color(0xFFF47B25),
                            ),
                          );
                          return;
                        }

                        // Call signup function
                        String? error = await signUpUser(
                          email,
                          password,
                          name,
                          selectedTown!,
                        );

                        // Check if signup was successful
                        if (error == null) {
                          // Show success message
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Account created successfully!'),
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
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Sign Up',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Login link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already have an account? ',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0x99221710),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Go back to login page
                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                        ),
                        child: const Text(
                          'Log in.',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFF47B25),
                          ),
                        ),
                      ),
                    ],
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
