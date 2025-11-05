import 'package:flutter/material.dart';
import 'package:hometown_quiz/pages/category.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  // Simple variable to store user name
  String userName = 'User'; // Default name

  @override
  void initState() {
    super.initState();
    // Get user name when page loads
    getUserName();
  }

  // Simple function to get user name from Supabase
  Future<void> getUserName() async {
    try {
      // Get current user ID
      String? userId = Supabase.instance.client.auth.currentUser?.id;

      if (userId != null) {
        // Get user data from database
        final response = await Supabase.instance.client
            .from('users')
            .select('name')
            .eq('id', userId)
            .single();

        // Update user name
        setState(() {
          userName = response['name'] ?? 'User';
        });
      }
    } catch (e) {
      // If error, keep default name
      print('Error getting user name: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F5), // Light background color
      body: SafeArea(
        child: Column(
          children: [
            // Header with logo and avatar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F7F5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo icon
                  const Icon(
                    Icons.location_on,
                    color: Color(0xFFF47B25),
                    size: 32,
                  ),
                  // Title
                  const Text(
                    'Hometown Quiz',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF221710),
                    ),
                  ),
                  // User avatar
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0x33F47B25),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Icon(
                        Icons.person,
                        color: const Color(0xFFF47B25),
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome message
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Hi, $userName! ',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF221710),
                                ),
                              ),
                              // Waving hand emoji
                              const Text('👋', style: TextStyle(fontSize: 28)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Ready to test your town knowledge?',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0x99221710),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Play Now button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                // TODO: Navigate to quiz page later
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF47B25),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 8,
                                shadowColor: const Color(
                                  0xFFF47B25,
                                ).withOpacity(0.4),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Play Now',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward, size: 24),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '✨ 10 new questions today! ✨',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0x80221710),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Menu cards grid
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          // First row
                          Row(
                            children: [
                              // Categories card
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const CategoryPage(),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    height: 100,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 10,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Categories /\nDifficulty',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF221710),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Leaderboard card
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    // TODO: Navigate to leaderboard page later
                                  },
                                  child: Container(
                                    height: 100,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 10,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Leaderboard',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF221710),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Second row
                          Row(
                            children: [
                              // Progress card
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    // TODO: Navigate to progress page later
                                  },
                                  child: Container(
                                    height: 100,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 10,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Progress /\nScore History',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF221710),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Fun Facts card
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    // TODO: Navigate to fun facts page later
                                  },
                                  child: Container(
                                    height: 100,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 10,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Fun Facts /\nLearn',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF221710),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Bottom navigation bar
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8F7F5),
                border: const Border(
                  top: BorderSide(color: Color(0x33F47B25), width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Home button (active)
                  GestureDetector(
                    onTap: () {
                      // Already on home page
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.home, color: Color(0xFFF47B25), size: 28),
                          SizedBox(height: 4),
                          Text(
                            'Home',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFF47B25),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Leaderboard button
                  GestureDetector(
                    onTap: () {
                      // TODO: Navigate to leaderboard later
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.emoji_events_outlined,
                            color: Color(0x80221710),
                            size: 28,
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Leaderboard',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0x80221710),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Profile button
                  GestureDetector(
                    onTap: () {
                      // TODO: Navigate to profile later
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.person_outline,
                            color: Color(0x80221710),
                            size: 28,
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Profile',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0x80221710),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Settings button
                  GestureDetector(
                    onTap: () {
                      // TODO: Navigate to settings later
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.settings_outlined,
                            color: Color(0x80221710),
                            size: 28,
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Settings',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0x80221710),
                            ),
                          ),
                        ],
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
