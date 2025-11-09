import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mu_career_pat_offline/services/auth_service.dart';
import 'login_screen.dart';
import 'edit_profile_screen.dart';
import 'view_companies_screen.dart';
import 'package:mu_career_pat_offline/theme/app_theme.dart';

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
          setState(() {
            userData = doc.data();
          });
        } else {
          setState(() => userData = null);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error fetching data: $e")));
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _logout(BuildContext context) async {
    await AuthService().logout();
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  Widget _buildProfileAvatar({double radius = 45}) {
    final photoUrl = userData?['photoUrl'];
    final imageProvider =
        (photoUrl != null && photoUrl.isNotEmpty) ? NetworkImage(photoUrl) : null;

    return CircleAvatar(
      radius: radius,
      backgroundColor: AppTheme.primaryColor.withOpacity(0.3),
      backgroundImage: imageProvider,
      child: imageProvider == null
          ? const Icon(Icons.person, color: Colors.white, size: 40)
          : null,
    );
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

  // ---------------------------- SCREENS ----------------------------

  Widget _buildHomeScreen() {
    if (userData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          _buildProfileAvatar(radius: 50),
          const SizedBox(height: 15),
          Text(
            "Welcome, ${userData?['name'] ?? 'Student'} 👋",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoTile("📧 Email", userData?['email']),
                _infoTile("🎓 Course", userData?['course']),
                _infoTile("📅 Year", userData?['year']),
                _infoTile("🔎 Contact", userData?['contact']),
                _linkTile("🔗 LinkedIn", userData?['linkedin']),
                _linkTile("💻 GitHub", userData?['github']),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: PageView.builder(
              controller: _pageController,
              itemCount: photoAssets.length,
              itemBuilder: (context, index) {
                final circularIndex = index % photoAssets.length;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(
                      image: AssetImage(photoAssets[circularIndex]),
                      fit: BoxFit.cover,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        "$label: ${value ?? 'N/A'}",
        style: const TextStyle(fontSize: 16, color: Colors.black87),
      ),
    );
  }

  Widget _linkTile(String label, String? url) {
    if (url == null || url.isEmpty) {
      return _infoTile(label, "N/A");
    }
    return InkWell(
      onTap: () => _openLink(url),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text(
          "$label: $url",
          style: const TextStyle(
            fontSize: 16,
            color: Colors.blueAccent,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }

  Widget _buildCompanyScreen() => ViewCompaniesScreen();

  Widget _buildAcademyScreen() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            "Academy Details Coming Soon",
            style: TextStyle(fontSize: 18, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileScreen() {
    if (userData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: () async {
              if (userData != null) {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditProfileScreen(userData: userData!),
                  ),
                );
                _fetchUserData();
              }
            },
            icon: const Icon(Icons.edit),
            label: const Text("Edit Profile"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 28),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
            label: const Text("Logout"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 28),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
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
      _buildCompanyScreen(),
      _buildAcademyScreen(),
      _buildProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppTheme.secondaryColor,
      appBar: AppBar(
        title: const Text('Student Dashboard'),
        backgroundColor: AppTheme.primaryColor,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.school, size: 28),
          ),
        ),
        actions: [
          if (!_loading && userData != null)
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: _buildProfileAvatar(radius: 20),
            ),
        ],
      ),
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
              : screens[_selectedIndex],

      // 🔥 Floating Navigation Bar
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primaryColor, Colors.deepPurpleAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            backgroundColor: Colors.transparent,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white70,
            showSelectedLabels: true,
            showUnselectedLabels: false,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            onTap: (index) => setState(() => _selectedIndex = index),
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined), label: 'Home'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.business_outlined), label: 'Company'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.school_outlined), label: 'Academy'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline), label: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }
}
