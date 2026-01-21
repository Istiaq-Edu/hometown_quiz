import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hometown_quiz/pages/achievements_page.dart';
import 'package:hometown_quiz/pages/leaderboard_page.dart';
import 'package:hometown_quiz/pages/profile_page.dart';
import 'package:hometown_quiz/pages/quiz.dart';
import 'package:hometown_quiz/achievement_service.dart';
import 'package:hometown_quiz/score_service.dart';
import 'package:hometown_quiz/profile_service.dart';
import 'package:hometown_quiz/pages/settings_page.dart';
import 'package:hometown_quiz/models/user_stats.dart';
import 'package:random_avatar/random_avatar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Category data structure for quiz categories
/// Requirements: 1.1
class CategoryData {
  final String name;
  final String description;
  final String imagePath;

  const CategoryData({
    required this.name,
    required this.description,
    required this.imagePath,
  });
}

/// List of available quiz categories
/// Requirements: 1.1
const List<CategoryData> categories = [
  CategoryData(
    name: 'Places & History',
    description:
        "Explore landmarks and Bangladesh's rich past. Difficulty adapts to you.",
    imagePath: 'lib/images/Place and History.png',
  ),
  CategoryData(
    name: 'Culture & Traditions',
    description:
        'Quizzes on festivals, customs, and local life. Your skills determine the challenge.',
    imagePath: 'lib/images/Culture and Traditions.png',
  ),
  CategoryData(
    name: 'Everyday Bangladesh',
    description:
        'Fun facts about daily life in our towns. Test your knowledge, watch it grow!',
    imagePath: 'lib/images/Everyday Bangladesh.png',
  ),
];

/// Valid category names for validation
/// Used by property tests to verify navigation receives valid categories
const List<String> validCategoryNames = [
  'Places & History',
  'Culture & Traditions',
  'Everyday Bangladesh',
];

/// Randomly select a category from the available categories
/// Requirements: 2.1
/// Returns one of: "Places & History", "Culture & Traditions", or "Everyday Bangladesh"
/// This is a standalone function for testability
String getRandomCategory([Random? random]) {
  final rng = random ?? Random();
  final randomIndex = rng.nextInt(categories.length);
  return categories[randomIndex].name;
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  // Simple variable to store user name
  String userName = 'User'; // Default name
  String? userPhotoUrl; // User's profile photo URL
  String? userId; // User ID for default avatar seed
  String? userHometown; // User's hometown
  UserRankData? userRank; // Current user's rank info
  UserStats? userStats; // Current user's stats
  bool isStatsLoading = true;

  @override
  void initState() {
    super.initState();
    // Get user data when page loads
    getUserData();
  }

  // Simple function to get user data from Supabase
  Future<void> getUserData() async {
    try {
      setState(() => isStatsLoading = true);
      
      // Get current user ID
      String? currentUserId = Supabase.instance.client.auth.currentUser?.id;

      if (currentUserId != null) {
        // Get user data from database
        final response = await Supabase.instance.client
            .from('users')
            .select('name, photo_url, hometown')
            .eq('id', currentUserId)
            .single();

        // Get rank and stats
        final rankData = await ScoreService.getCurrentUserRank();
        final statsData = await ProfileService.getUserStats();

        // Update user data
        setState(() {
          userName = response['name'] ?? 'User';
          userPhotoUrl = response['photo_url'];
          userHometown = response['hometown'];
          userId = currentUserId;
          userRank = rankData;
          userStats = statsData;
          isStatsLoading = false;
        });
      }
    } catch (e) {
      // If error, keep default values
      debugPrint('Error getting user data: $e');
      setState(() => isStatsLoading = false);
    }
  }

  // Show "Coming Soon" snackbar for placeholder features
  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Coming Soon!'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show Rank System Info Dialog
  void _showRankSystemDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rank System'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Earn points to level up your hometown rank!'),
            const SizedBox(height: 16),
            _buildRankTier('Novice', '0 - 99 pts'),
            _buildRankTier('Scout', '100 - 499 pts'),
            _buildRankTier('Explorer', '500 - 999 pts'),
            _buildRankTier('Captain', '1000 - 1999 pts'),
            _buildRankTier('Master', '2000 - 4999 pts'),
            _buildRankTier('Hero', '5000+ pts'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  Widget _buildRankTier(String title, String range) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(range, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  /// Build profile avatar - shows photo URL if available, otherwise default avatar
  Widget _buildProfileAvatar() {
    if (userPhotoUrl != null && userPhotoUrl!.isNotEmpty) {
      return Image.network(
        userPhotoUrl!,
        fit: BoxFit.cover,
        width: 44,
        height: 44,
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultAvatar();
        },
      );
    }
    return _buildDefaultAvatar();
  }

  /// Build default random avatar when no photo URL exists
  Widget _buildDefaultAvatar() {
    final seed = userId ?? userName;
    return RandomAvatar(seed, height: 44, width: 44);
  }

  /// Navigate to QuizPage with the selected category
  /// Requirements: 1.3
  void _startCategoryQuiz(String category) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => QuizPage(category: category)),
    );
  }

  /// Start a random quiz by selecting a random category and navigating to QuizPage
  /// Requirements: 2.1, 2.2
  void _startRandomQuiz() {
    final randomCategory = getRandomCategory();
    _startCategoryQuiz(randomCategory);
  }

  /// Build a horizontal category card widget
  /// Requirements: 1.2
  Widget _buildCategoryCard(CategoryData category) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Image on left (1/3 width)
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
            child: SizedBox(
              width: 100,
              height: 120,
              child: Image.asset(
                category.imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFFF47B25).withValues(alpha: 0.2),
                    child: const Icon(
                      Icons.image,
                      color: Color(0xFFF47B25),
                      size: 40,
                    ),
                  );
                },
              ),
            ),
          ),
          // Content on right
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF221710),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category.description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0x99221710),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Start Quiz button
                  // Requirements: 1.3
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _startCategoryQuiz(category.name),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF47B25),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Start Quiz',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build the Events placeholder card with "Coming Soon" overlay
  /// Requirements: 1.4
  Widget _buildEventsPlaceholderCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
      ),
      child: Stack(
        children: [
          // Card content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF47B25).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.celebration,
                    color: Color(0xFFF47B25),
                    size: 32,
                  ),
                ),
                const SizedBox(width: 12),
                // Text content
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Events',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF221710),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Special quizzes for holidays and local events',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0x99221710),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Coming Soon overlay badge
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF47B25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'COMING SOON',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
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
                  // Placeholder for balance (removed location icon)
                  const SizedBox(width: 48),
                  // Title
                  const Text(
                    'Hometown Quiz',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF221710),
                    ),
                  ),
                  // User avatar with profile photo
                  // Requirements: 9.2
                  GestureDetector(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfilePage(),
                        ),
                      );
                      // Refresh user data when returning from profile page
                      getUserData();
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0x33F47B25),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: const Color(0xFFF47B25),
                          width: 2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: _buildProfileAvatar(),
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
                    // Requirements: 2.2, 2.3
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _startRandomQuiz,
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
                            '✨ Play a random quiz! ✨',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0x80221710),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Your Hometown Journey section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          // Section header row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Your Hometown Journey',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF221710),
                                ),
                              ),
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const AchievementsPage(),
                                        ),
                                      );
                                    },
                                    child: const Icon(
                                      Icons.emoji_events,
                                      color: Color(0xFFF47B25),
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: _showRankSystemDialog,
                                    child: const Icon(
                                      Icons.info_outline,
                                      color: Color(0xFF221710),
                                      size: 22,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Progress card
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LeaderboardPage(),
                                ),
                              );
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: isStatsLoading
                                  ? const Center(
                                      child: CircularProgressIndicator(
                                        color: Color(0xFFF47B25),
                                      ),
                                    )
                                  : Row(
                                      children: [
                                        // Left side - Rank info
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Current Rank',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0x99221710),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Text(
                                                    AchievementService.getRankTitle(
                                                      userRank?.totalScore ?? 0,
                                                      hometown: userHometown,
                                                    ),
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold,
                                                      color: Color(0xFF221710),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  const Icon(
                                                    Icons.verified,
                                                    color: Color(0xFFF47B25),
                                                    size: 18,
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 12),
                                              // Linear progress bar
                                              Builder(
                                                builder: (context) {
                                                  final progress = AchievementService.getRankProgress(userRank?.totalScore ?? 0);
                                                  final progressPct = (progress * 100).toInt();
                                                  
                                                  return Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    children: [
                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius.circular(4),
                                                        child: LinearProgressIndicator(
                                                          value: progress,
                                                          backgroundColor:
                                                              const Color(0xFFE8E8E8),
                                                          valueColor:
                                                              const AlwaysStoppedAnimation<
                                                                Color
                                                              >(Color(0xFFF47B25)),
                                                          minHeight: 8,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        '$progressPct% to next rank',
                                                        style: const TextStyle(
                                                          fontSize: 11,
                                                          color: Color(0x99221710),
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                }
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        // Right side - Circular progress
                                        SizedBox(
                                          width: 70,
                                          height: 70,
                                          child: Builder(
                                            builder: (context) {
                                              final progress = AchievementService.getRankProgress(userRank?.totalScore ?? 0);
                                              final progressPct = (progress * 100).toInt();
                                              
                                              return Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  SizedBox(
                                                    width: 70,
                                                    height: 70,
                                                    child: CircularProgressIndicator(
                                                      value: progress,
                                                      strokeWidth: 6,
                                                      backgroundColor:
                                                          const Color(0xFFE8E8E8),
                                                      valueColor:
                                                          const AlwaysStoppedAnimation<
                                                            Color
                                                          >(Color(0xFFF47B25)),
                                                    ),
                                                  ),
                                                  Text(
                                                    '$progressPct%',
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                      color: Color(0xFF221710),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Category Cards Section
                    // Requirements: 1.1, 1.2, 1.3
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Choose a Category',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF221710),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Category cards
                          ...categories.map(
                            (category) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildCategoryCard(category),
                            ),
                          ),
                          // Events placeholder card
                          // Requirements: 1.4
                          _buildEventsPlaceholderCard(),
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LeaderboardPage(),
                        ),
                      );
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
                  // Requirements: 9.1
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfilePage(),
                        ),
                      );
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
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const SettingsPage()),
                      );
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
