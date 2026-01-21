import 'package:flutter/material.dart';
import 'package:hometown_quiz/score_service.dart';
import 'package:hometown_quiz/pages/home.dart';
import 'package:hometown_quiz/pages/profile_page.dart';
import 'package:hometown_quiz/achievement_service.dart';
import 'package:hometown_quiz/pages/settings_page.dart';

/// Leaderboard page displaying ranked users by their total scores.
/// Shows global and hometown rankings with the current user's rank highlighted.
/// (Requirements: 2.1, 2.2, 2.3, 2.4, 3.1, 3.2, 4.1, 4.2, 4.3, 5.2)
class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  /// List of ranked users for the leaderboard
  List<LeaderboardEntry> leaderboardEntries = [];

  /// Current user's rank information
  UserRankData? currentUserRank;

  /// Selected scope: "Global" or "My Town"
  String selectedScope = 'Global';

  /// Loading state indicator
  bool isLoading = true;

  /// Error state
  String? errorMessage;

  /// Current user's hometown
  String? userHometown;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// Loads leaderboard data and current user rank
  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Get user's hometown first
      userHometown ??= await ScoreService.getCurrentUserHometown();

      // Fetch leaderboard based on selected scope
      List<LeaderboardEntry> entries;
      UserRankData? rankData;

      if (selectedScope == 'Global') {
        entries = await ScoreService.getGlobalLeaderboard();
        rankData = await ScoreService.getCurrentUserRank();
      } else {
        // My Town scope
        if (userHometown != null) {
          entries = await ScoreService.getHometownLeaderboard(userHometown!);
          rankData = await ScoreService.getCurrentUserRank(
            hometown: userHometown,
          );
        } else {
          entries = [];
          rankData = null;
        }
      }

      setState(() {
        leaderboardEntries = entries;
        currentUserRank = rankData;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load leaderboard. Please try again.';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F5),
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            // Scope toggle (Requirements: 4.1, 4.2, 4.3)
            _buildScopeToggle(),

            // Current user rank card (Requirements: 3.1, 3.2)
            if (currentUserRank != null) _buildCurrentUserRankCard(),

            // Main content
            Expanded(child: _buildContent()),

            // Bottom navigation bar
            _buildBottomNavBar(),
          ],
        ),
      ),
    );
  }

  /// Builds the app bar with back button and title.
  /// (Requirement 5.2)
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFF8F7F5),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF221710)),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text(
        'Hometown Heroes',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF221710),
        ),
      ),
      centerTitle: true,
    );
  }

  /// Builds the scope toggle (Global / My Town).
  /// (Requirements: 4.1, 4.2, 4.3)
  Widget _buildScopeToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFFF47B25).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            _buildScopeButton('Global', '🇧🇩'),
            _buildScopeButton(
              'My Town',
              userHometown != null ? '($userHometown)' : '',
            ),
          ],
        ),
      ),
    );
  }

  /// Builds an individual scope toggle button.
  Widget _buildScopeButton(String scope, String suffix) {
    final isSelected = selectedScope == scope;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (selectedScope != scope) {
            setState(() {
              selectedScope = scope;
            });
            _loadData();
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFF8F7F5) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              suffix.isNotEmpty ? '$scope $suffix' : scope,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? const Color(0xFF221710)
                    : const Color(0xFF221710).withOpacity(0.5),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the current user rank card.
  /// (Requirements: 3.1, 3.2)
  Widget _buildCurrentUserRankCard() {
    final rank = currentUserRank!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF47B25).withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF47B25).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Rank badge
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  '#${rank.rank}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Name and label
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rank.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AchievementService.getRankTitle(
                      rank.totalScore,
                      hometown: userHometown,
                    ),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            // Score
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatScore(rank.totalScore),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Points',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the main content area (loading, error, empty, or list).
  Widget _buildContent() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFF47B25)),
      );
    }

    if (errorMessage != null) {
      return _buildErrorState();
    }

    if (leaderboardEntries.isEmpty) {
      return _buildEmptyState();
    }

    return _buildLeaderboardList();
  }

  /// Builds the error state with retry button.
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Color(0xFFF47B25)),
            const SizedBox(height: 16),
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Color(0xFF221710)),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadData,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF47B25),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the empty state when no scores exist.
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.emoji_events_outlined,
              size: 64,
              color: Color(0xFFF47B25),
            ),
            const SizedBox(height: 16),
            const Text(
              'No scores yet!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF221710),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to complete a quiz and claim the top spot!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: const Color(0xFF221710).withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the leaderboard list with top 3 styling.
  /// (Requirements: 2.1, 2.2, 2.3, 2.4)
  Widget _buildLeaderboardList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: leaderboardEntries.length,
      itemBuilder: (context, index) {
        final entry = leaderboardEntries[index];
        return _buildLeaderboardItem(entry);
      },
    );
  }

  /// Builds an individual leaderboard item.
  /// Top 3 get special gradient styling.
  /// (Requirements: 2.3, 2.4)
  Widget _buildLeaderboardItem(LeaderboardEntry entry) {
    final isTop3 = entry.rank <= 3;

    if (isTop3) {
      return _buildTop3Item(entry);
    } else {
      return _buildStandardItem(entry);
    }
  }

  /// Builds a top 3 leaderboard item with gradient styling.
  /// (Requirement 2.3)
  Widget _buildTop3Item(LeaderboardEntry entry) {
    final gradient = _getGradientForRank(entry.rank);
    final textColor = const Color(0xFF221710);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 40,
            child: Text(
              '#${entry.rank}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Name and hometown
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  entry.hometown,
                  style: TextStyle(
                    fontSize: 13,
                    color: textColor.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          // Score
          Text(
            '${_formatScore(entry.totalScore)} Points',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a standard leaderboard item (ranks 4-50).
  /// (Requirement 2.4)
  Widget _buildStandardItem(LeaderboardEntry entry) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFF47B25).withOpacity(0.2),
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 40,
            child: Text(
              '#${entry.rank}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF221710).withOpacity(0.5),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Name and hometown
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF221710),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  entry.hometown,
                  style: TextStyle(
                    fontSize: 13,
                    color: const Color(0xFF221710).withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          // Score
          Text(
            '${_formatScore(entry.totalScore)} Points',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF221710),
            ),
          ),
        ],
      ),
    );
  }

  /// Returns the gradient for top 3 ranks.
  /// Gold for rank 1, silver for rank 2, bronze for rank 3.
  LinearGradient _getGradientForRank(int rank) {
    switch (rank) {
      case 1:
        // Gold gradient
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFCEABB), Color(0xFFF8B500)],
        );
      case 2:
        // Silver gradient
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE6E9F0), Color(0xFFEEF1F5)],
        );
      case 3:
        // Bronze gradient
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFD8C1A0), Color(0xFFB88A53)],
        );
      default:
        return const LinearGradient(colors: [Colors.white, Colors.white]);
    }
  }

  /// Formats score with comma separators for thousands.
  String _formatScore(int score) {
    if (score < 1000) return score.toString();
    return score.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
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

          // Leaderboard button (active)
          GestureDetector(
            onTap: () {
              // Already on leaderboard page
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.emoji_events, color: Color(0xFFF47B25), size: 28),
                  SizedBox(height: 4),
                  Text(
                    'Leaderboard',
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

          // Profile button
          GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
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
                    style: TextStyle(fontSize: 12, color: Color(0x80221710)),
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
