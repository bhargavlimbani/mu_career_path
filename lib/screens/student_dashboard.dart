import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mu_career_pat_offline/services/auth_service.dart';
import 'login_screen.dart';
import 'experiences_screen.dart';
import 'companies_screen.dart';
import 'profile_screen.dart';
import 'package:mu_career_pat_offline/theme/app_theme.dart';
import 'package:mu_career_pat_offline/widgets/bottom_navbar.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic>? userData;
  bool _loading = true;
  int _selectedIndex = 0;

  final List<String> photoAssets = [
    "assets/1.jpeg",
    "assets/7.jpeg",
    "assets/13.jpg",
  ];

  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchUserData();

    _pageController = PageController(initialPage: 0, viewportFraction: 0.9);
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) return;
      if (_pageController.hasClients) {
        _currentPage = (_currentPage + 1) % photoAssets.length;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    setState(() => _loading = true);
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          setState(() => userData = doc.data());
        } else {
          setState(() => userData = null);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error fetching data: $e")),
        );
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _openLink(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not open $url")),
      );
    }
  }

  // ---------------------------- HOME SCREEN ----------------------------
  Widget _buildHomeScreen() {
    if (userData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------------- Header ----------------
          Text(
            "👋 Hello, ${userData?['name'] ?? 'Student'}",
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Your career journey starts here 🚀",
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 20),

          // ---------------- Motivational Quote ----------------
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryColor.withOpacity(0.85), Colors.deepPurpleAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "💡 Career Tip of the Day",
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 6),
                Text(
                  "“Opportunities don’t happen. You create them.” — Chris Grosser",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // ---------------- Quick Access Tiles ----------------
          const Text(
            "Quick Actions",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _actionTile(Icons.work_outline, "My Experiences", Colors.blueAccent, () {
                setState(() => _selectedIndex = 1);
              }),
              _actionTile(Icons.business_outlined, "Companies", Colors.green, () {
                setState(() => _selectedIndex = 2);
              }),
              _actionTile(Icons.psychology_alt_outlined, "Career Tests", Colors.orangeAccent, () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Career Tests section coming soon.")),
                );
              }),
              _actionTile(Icons.assignment_outlined, "My Resume", Colors.purple, () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Resume Builder coming soon.")),
                );
              }),
            ],
          ),

          const SizedBox(height: 25),

          // ---------------- Announcements ----------------
          const Text(
            "Latest Announcements",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          _announcementCard(
            "Infosys Drive 2025 - Register before Nov 15!",
            "Don't miss your chance to participate in the upcoming campus drive.",
          ),
          _announcementCard(
            "Soft Skills Workshop Tomorrow 🎤",
            "Improve your communication and interview skills with experts.",
          ),
          const SizedBox(height: 25),

          // ---------------- Recommended Paths ----------------
          const Text(
            "Recommended for You",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          _careerCard(
            "💻 Software Development",
            "Explore roles in app, web, and cloud development.",
          ),
          _careerCard(
            "🔒 Cybersecurity",
            "Learn about ethical hacking, data protection, and digital forensics.",
          ),
          _careerCard(
            "🧠 Data Science",
            "Master analytics, AI, and data visualization tools.",
          ),
          const SizedBox(height: 20),

          // ---------------- Motivational Footer ----------------
          Center(
            child: Text(
              "Keep learning, keep growing 🌱",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  // ---------------- Helper Widgets ----------------

  Widget _actionTile(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 36),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _announcementCard(String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.campaign_outlined, color: AppTheme.primaryColor, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 13, color: Colors.black54)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _careerCard(String title, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple.shade100, Colors.deepPurple.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  // ---------------------------- MAIN BUILD ----------------------------
  @override
  Widget build(BuildContext context) {
    final screens = [
      _buildHomeScreen(),
      const ExperiencesScreen(),
      const CompaniesScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppTheme.secondaryColor,
      appBar: _selectedIndex == 0
          ? AppBar(
        title: const Text(
          'Student Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.primaryColor,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
        ),
        centerTitle: true,
        actions: [
          if (!_loading && userData != null)
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.primaryColor.withOpacity(0.3),
                backgroundImage: (userData?['photoUrl'] != null &&
                    userData!['photoUrl'].isNotEmpty)
                    ? NetworkImage(userData!['photoUrl'])
                    : null,
                child: (userData?['photoUrl'] == null ||
                    userData!['photoUrl'].isEmpty)
                    ? const Icon(Icons.person,
                    color: Colors.white, size: 22)
                    : null,
              ),
            ),
        ],
      )
          : null,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (userData == null)
          ? const Center(
        child: Text(
          'No user data found.\nPlease register or try logging in again.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.black87),
        ),
      )
          : AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: screens[_selectedIndex],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}