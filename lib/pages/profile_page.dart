import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:random_avatar/random_avatar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hometown_quiz/pages/achievements_page.dart';
import 'package:hometown_quiz/pages/login.dart';
import 'package:hometown_quiz/profile_service.dart';
import 'package:hometown_quiz/score_service.dart';
import 'package:hometown_quiz/models/user_profile.dart';
import 'package:hometown_quiz/models/user_stats.dart';
import 'dart:io';
import 'package:hometown_quiz/pages/home.dart';
import 'package:hometown_quiz/pages/leaderboard_page.dart';
import 'package:hometown_quiz/achievement_service.dart';
import 'package:hometown_quiz/models/achievement.dart';
import 'package:hometown_quiz/pages/settings_page.dart';

/// Profile Page for viewing and managing user profile
/// (Requirements: 1.1, 1.2, 1.3, 1.4)
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => ProfilePageState();
}

/// State class for ProfilePage - made public for testing
class ProfilePageState extends State<ProfilePage> {
  // Loading state for initial data fetch
  bool isLoading = true;

  // Loading state for photo upload
  bool isUploadingPhoto = false;

  // User profile data
  UserProfile? userProfile;
  UserStats? userStats;
  
  // Achievement data
  int unlockedAchievementsCount = 0;
  int totalAchievementsCount = 0;

  // Image picker instance
  final ImagePicker _imagePicker = ImagePicker();

  // Derived display values
  String get userName => userProfile?.name ?? 'User';
  String get userHometown => userProfile?.hometown ?? 'Unknown';
  String? get profilePhotoUrl => userProfile?.photoUrl;
  String get userRank => AchievementService.getRankTitle(
        userProfile?.totalScore ?? 0,
        hometown: userProfile?.hometown,
      );

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }




  /// Fetches user profile and stats from Supabase
  Future<void> _loadUserData() async {
    setState(() => isLoading = true);

    final profile = await ProfileService.getUserProfile();
    final stats = await ProfileService.getUserStats();
    final achievements = await AchievementService.getAchievements();

    if (mounted) {
      setState(() {
        userProfile = profile;
        userStats = stats;
        unlockedAchievementsCount = achievements.where((a) => a.isUnlocked).length;
        totalAchievementsCount = achievements.length;
        isLoading = false;
      });
    }
  }

  /// Show photo options bottom sheet with Gallery and Camera options
  /// (Requirements: 2.1)
  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFF8F7F5),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                const Text(
                  'Change Profile Photo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF221710),
                  ),
                ),
                const SizedBox(height: 20),
                // Gallery option
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0x1AF47B25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.photo_library,
                      color: Color(0xFFF47B25),
                    ),
                  ),
                  title: const Text(
                    'Choose from Gallery',
                    style: TextStyle(fontSize: 16, color: Color(0xFF221710)),
                  ),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                // Camera option
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0x1AF47B25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Color(0xFFF47B25),
                    ),
                  ),
                  title: const Text(
                    'Take a Photo',
                    style: TextStyle(fontSize: 16, color: Color(0xFF221710)),
                  ),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    _pickImage(ImageSource.camera);
                  },
                ),
                const SizedBox(height: 10),
                // Cancel button
                TextButton(
                  onPressed: () => Navigator.pop(bottomSheetContext),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontSize: 16, color: Color(0x99221710)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Pick image from gallery or camera using image_picker
  /// (Requirements: 2.1)
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        await _uploadPhoto(File(pickedFile.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to pick image'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Upload photo to Supabase Storage
  /// (Requirements: 2.2, 2.3, 2.4)
  Future<void> _uploadPhoto(File image) async {
    // Show loading indicator during upload
    setState(() => isUploadingPhoto = true);

    try {
      // Call ProfileService.uploadProfilePhoto with selected image
      final newPhotoUrl = await ProfileService.uploadProfilePhoto(image);

      if (mounted) {
        if (newPhotoUrl != null) {
          // Update displayed photo on success (Requirements: 2.3)
          await _loadUserData();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile photo updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          // Show error snackbar on failure (Requirements: 2.4)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to upload photo. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Show error snackbar on failure (Requirements: 2.4)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to upload photo. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isUploadingPhoto = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F5),
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button and title
            // (Requirements: 1.4)
            _buildHeader(),

            // Main content
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFF47B25),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          const SizedBox(height: 24),
                          // Profile info section
                          // (Requirements: 1.1, 1.2, 1.3)
                          _buildProfileInfoSection(),
                          const SizedBox(height: 32),
                          const SizedBox(height: 32),
                          // Achievements Section (New)
                          _buildAchievementsSection(),
                          const SizedBox(height: 32),
                          // Stats section - "Your Journey So Far"
                          // (Requirements: 3.1, 3.2, 3.3, 3.4, 3.5)
                          _buildStatsSection(),
                          const SizedBox(height: 32),
                          // Update Details moved to Settings Page
                          // Footer actions moved to Settings Page
                          const SizedBox(height: 32),

                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
            ),

            // Bottom navigation bar
            _buildBottomNavBar(),
          ],
        ),
      ),
    );
  }

  /// Build individual detail row with label, value, and chevron
  Widget _buildDetailRow({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            // Label
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 16, color: Color(0xFF221710)),
              ),
            ),
            // Current value (if any)
            if (value.isNotEmpty)
              Text(
                value,
                style: const TextStyle(fontSize: 14, color: Color(0x99221710)),
              ),
            const SizedBox(width: 8),
            // Chevron icon
            const Icon(Icons.chevron_right, color: Color(0x99221710)),
          ],
        ),
      ),
    );
  }



  /// List of Bangladesh towns (reused from signup.dart)
  static const List<String> bangladeshTowns = [
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

  /// Show "Coming Soon" snackbar for achievements
  /// (Requirements: 6.1)
  void _showAchievementsComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Coming Soon'),
        backgroundColor: Color(0xFFF47B25),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Build header with back button and title
  /// (Requirements: 1.4)
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F7F5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back button
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            color: const Color(0xFF221710),
          ),
          // Title
          const Expanded(
            child: Text(
              'Your Hometown Profile',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF221710),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // Placeholder for balance
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  /// Build Achievements Dashboard Section
  Widget _buildAchievementsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Achievements',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF221710),
          ),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AchievementsPage()),
            );
            if (mounted) {
              _loadUserData();
            }
          },
          child: Container(
            padding: const EdgeInsets.all(20),
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
            child: Row(
              children: [
                // Trophy Icon Container
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF4E5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.emoji_events_rounded,
                    color: Color(0xFFF47B25),
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                // Text Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$unlockedAchievementsCount / $totalAchievementsCount Unlocked',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF221710),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Tap to view your collection',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0x99221710),
                        ),
                      ),
                    ],
                  ),
                ),
                // Arrow Icon
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Color(0x66221710),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build profile info section with photo, name, rank, and hometown
  /// (Requirements: 1.1, 1.2, 1.3)
  Widget _buildProfileInfoSection() {
    return Column(
      children: [
        // Profile photo with edit button
        // (Requirements: 1.1, 1.2)
        Stack(
          children: [
            // Profile photo or default avatar
            Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFF47B25), width: 4),
              ),
              child: ClipOval(
                child: isUploadingPhoto
                    ? Container(
                        color: const Color(0xFFF8F7F5),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFF47B25),
                          ),
                        ),
                      )
                    : _buildProfileImage(),
              ),
            ),
            // Edit button overlay
            // (Requirements: 1.1, 2.1)
            Positioned(
              bottom: 4,
              right: 4,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF47B25),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: isUploadingPhoto ? null : _showPhotoOptions,
                  icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // User name
        // (Requirements: 1.3)
        Text(
          userName,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF221710),
          ),
        ),
        const SizedBox(height: 4),
        // User rank
        // (Requirements: 1.3)
        Text(
          userRank,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFFF47B25),
          ),
        ),
        const SizedBox(height: 4),
        // User hometown
        // (Requirements: 1.3)
        Text(
          'From $userHometown',
          style: const TextStyle(fontSize: 14, color: Color(0x99221710)),
        ),
      ],
    );
  }

  /// Build profile image - shows photo URL if available, otherwise default avatar
  /// (Requirements: 1.2)
  Widget _buildProfileImage() {
    if (profilePhotoUrl != null && profilePhotoUrl!.isNotEmpty) {
      return Image.network(
        profilePhotoUrl!,
        fit: BoxFit.cover,
        width: 120,
        height: 120,
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultAvatar();
        },
      );
    }
    return _buildDefaultAvatar();
  }

  /// Build default random avatar when no photo URL exists
  /// (Requirements: 1.2)
  Widget _buildDefaultAvatar() {
    // Use user ID or name as seed for consistent avatar
    final seed = userProfile?.id ?? userName;
    return RandomAvatar(seed, height: 120, width: 120);
  }

  /// Build stats section - "Your Journey So Far" with 4 stat cards
  /// (Requirements: 3.1, 3.2, 3.3, 3.4, 3.5)
  Widget _buildStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        // (Requirements: 3.1)
        const Text(
          'Your Journey So Far',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF221710),
          ),
        ),
        const SizedBox(height: 16),
        // 2x2 grid of stat cards
        // (Requirements: 3.2, 3.3, 3.4, 3.5)
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            // Quizzes Played card (Requirements: 3.2)
            _buildStatCard(
              label: 'Quizzes Played',
              value: '${userStats?.quizzesPlayed ?? 0}',
            ),
            // Highest Score card (Requirements: 3.3)
            _buildStatCard(
              label: 'Highest Score',
              value: '${userStats?.highestScore ?? 0}',
            ),
            // Accuracy card (Requirements: 3.4)
            _buildStatCard(
              label: 'Accuracy',
              value: '${(userStats?.accuracy ?? 0).toStringAsFixed(0)}%',
            ),
            // Time Bonuses card (Requirements: 3.5)
            _buildStatCard(
              label: 'Time Bonuses',
              value: '${userStats?.timeBonuses ?? 0}',
            ),
          ],
        ),
      ],
    );
  }

  /// Build individual stat card widget
  Widget _buildStatCard({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F7F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E5E5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Stat label
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Color(0x99221710)),
          ),
          const SizedBox(height: 4),
          // Stat value
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF221710),
            ),
          ),
        ],
      ),
    );
  }



  /// Build bottom navigation bar
  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F7F5),
        border: const Border(
          top: BorderSide(color: Color(0x33F47B25), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Home button
          GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.home_outlined, color: Color(0x80221710), size: 28),
                  SizedBox(height: 4),
                  Text(
                    'Home',
                    style: TextStyle(fontSize: 12, color: Color(0x80221710)),
                  ),
                ],
              ),
            ),
          ),

          // Leaderboard button
          GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
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
                    style: TextStyle(fontSize: 12, color: Color(0x80221710)),
                  ),
                ],
              ),
            ),
          ),

          // Profile button (active)
          GestureDetector(
            onTap: () {
              // Already on profile page
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person, color: Color(0xFFF47B25), size: 28),
                  SizedBox(height: 4),
                  Text(
                    'Profile',
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
                    style: TextStyle(fontSize: 12, color: Color(0x80221710)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
