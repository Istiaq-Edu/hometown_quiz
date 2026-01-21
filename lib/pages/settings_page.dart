import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hometown_quiz/pages/home.dart';
import 'package:hometown_quiz/pages/login.dart';
import 'package:hometown_quiz/pages/profile_page.dart';
import 'package:hometown_quiz/pages/leaderboard_page.dart';
import 'package:hometown_quiz/profile_service.dart';
import 'package:hometown_quiz/models/user_profile.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  UserProfile? userProfile;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => isLoading = true);
    final profile = await ProfileService.getUserProfile();
    if (mounted) {
      setState(() {
        userProfile = profile;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F5),
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFF8F7F5),
        elevation: 0,
        foregroundColor: const Color(0xFF221710),
        automaticallyImplyLeading: false,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFF47B25)))
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Account Section
                      _buildSectionHeader('Account'),
                      _buildSettingsTile(
                        icon: Icons.edit,
                        title: 'Edit Name',
                        subtitle: userProfile?.name ?? 'Set your name',
                        onTap: _showEditNameDialog,
                      ),
                      _buildSettingsTile(
                        icon: Icons.location_on,
                        title: 'Change Hometown',
                        subtitle: userProfile?.hometown ?? 'Set your hometown',
                        onTap: _showChangeHometownDialog,
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Support Section
                      _buildSectionHeader('Support'),
                      _buildSettingsTile(
                        icon: Icons.info_outline,
                        title: 'About App',
                        onTap: () {
                          showAboutDialog(
                            context: context,
                            applicationName: 'Hometown Quiz',
                            applicationVersion: '1.0.0',
                            applicationIcon: const Icon(Icons.quiz, color: Color(0xFFF47B25), size: 48),
                            children: [
                              const Text('The ultimate quiz app for Bangladesh! Test your knowledge about your hometown and compete with others.'),
                            ],
                          );
                        },
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Danger Zone
                      _buildSectionHeader('Actions', color: Colors.red),
                      _buildSettingsTile(
                        icon: Icons.logout,
                        title: 'Log Out',
                        color: const Color(0xFFF47B25),
                        onTap: _logout,
                      ),
                      _buildSettingsTile(
                        icon: Icons.delete_forever,
                        title: 'Delete Account',
                        color: Colors.red,
                        onTap: _showDeleteConfirmation,
                      ),
                    ],
                  ),
                ),
                _buildBottomNavBar(),
              ],
            ),
    );
  }

  Widget _buildSectionHeader(String title, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: color ?? const Color(0xFF221710).withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (color ?? const Color(0xFFF47B25)).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color ?? const Color(0xFFF47B25)),
        ),
        title: Text(
          title, 
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color ?? const Color(0xFF221710),
          )
        ),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  // --- Logic copied and adapted from ProfilePage ---

  void _showEditNameDialog() {
    final TextEditingController nameController = TextEditingController(text: userProfile?.name);
    String? errorText;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Name'),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: 'Name',
              errorText: errorText,
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) {
                  setState(() => errorText = 'Name cannot be empty');
                  return;
                }
                Navigator.pop(context);
                final success = await ProfileService.updateName(nameController.text.trim());
                if (mounted) {
                  _loadUserData();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(success ? 'Name updated' : 'Failed to update name'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ));
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangeHometownDialog() {
    String? selectedTown = userProfile?.hometown;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
              title: const Text('Change Hometown'),
              content: SizedBox(
                width: double.maxFinite,
                child: DropdownButton<String>(
                  value: selectedTown,
                  isExpanded: true,
                  items: ProfilePageState.bangladeshTowns.map((town) => DropdownMenuItem(
                    value: town,
                    child: Text(town),
                  )).toList(),
                  onChanged: (val) => setState(() => selectedTown = val),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (selectedTown == null) return;
                    Navigator.pop(context);
                    final success = await ProfileService.updateHometown(selectedTown!);
                    if (mounted) {
                      _loadUserData();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(success ? 'Hometown updated' : 'Failed to update'),
                        backgroundColor: success ? Colors.green : Colors.red,
                      ));
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
      ),
    );
  }

  Future<void> _logout() async {
    await Supabase.instance.client.auth.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account', style: TextStyle(color: Colors.red)),
        content: const Text('Are you sure? This action is permanent and cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              _deleteAccount();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    final success = await ProfileService.deleteAccount();
    if (mounted) {
      if (success) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete account'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F7F5),
        border: const Border(top: BorderSide(color: Color(0x33F47B25), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavBarItem(Icons.home_outlined, 'Home', () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()))),
          _buildNavBarItem(Icons.emoji_events_outlined, 'Leaderboard', () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LeaderboardPage()))),
          _buildNavBarItem(Icons.person_outline, 'Profile', () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ProfilePage()))),
          _buildNavBarItem(Icons.settings, 'Settings', () {}, isActive: true),
        ],
      ),
    );
  }

  Widget _buildNavBarItem(IconData icon, String label, VoidCallback onTap, {bool isActive = false}) {
    final color = isActive ? const Color(0xFFF47B25) : const Color(0x80221710);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}
