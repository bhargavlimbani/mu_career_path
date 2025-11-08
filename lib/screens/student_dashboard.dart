import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  // Carousel variables
  final List<String> photoAssets = [
    "assets/1.jpeg",
    "assets/7.jpeg",
    "assets/13.jpeg",
  ];
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchUserData();

    _pageController = PageController(initialPage: 0, viewportFraction: 0.9);

    // Circular auto-scroll
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) return;
      if (_pageController.hasClients) {
        _currentPage = (_currentPage + 1) % photoAssets.length; // circular
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

  Widget _buildProfileAvatar() {
    final photoPath = userData?['photoPath'];
    final imageProvider =
    photoPath != null && photoPath.isNotEmpty ? NetworkImage(photoPath) : null;

    return GestureDetector(
      onTap: () async {
        if (userData != null) {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EditProfileScreen(userData: userData!),
            ),
          );
          if (result == true) _fetchUserData();
        }
      },
      child: CircleAvatar(
        radius: 20,
        backgroundColor: AppTheme.primaryColor.withOpacity(0.3),
        backgroundImage: imageProvider,
        child: imageProvider == null ? const Icon(Icons.person) : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.secondaryColor,
      appBar: AppBar(
        title: const Text('Student Dashboard'),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
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
              child: _buildProfileAvatar(),
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : userData == null
          ? const Center(
        child: Text(
          'No user data found.\nPlease register or try logging in again.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.black87),
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header
            Text(
              "Welcome, ${userData!['name'] ?? 'Student'} 👋",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 15),

            // User Info Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.secondaryColor,
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
                  Text(
                    "📧 Email: ${userData!['email'] ?? 'N/A'}",
                    style: const TextStyle(
                        fontSize: 16, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "🎓 Course: ${userData!['course'] ?? 'N/A'}",
                    style: const TextStyle(
                        fontSize: 16, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "📅 Year: ${userData!['year'] ?? 'N/A'}",
                    style: const TextStyle(
                        fontSize: 16, color: Colors.black87),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              EditProfileScreen(userData: userData!),
                        ),
                      );
                      if (result == true) _fetchUserData();
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text("Edit Profile"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding:
                      const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ViewCompaniesScreen()),
                      );
                    },
                    icon: const Icon(Icons.business),
                    label: const Text("View Companies"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding:
                      const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Horizontal Photo Carousel (circular)
            SizedBox(
              height: 200,
              child: PageView.builder(
                controller: _pageController,
                itemCount: photoAssets.length,
                itemBuilder: (context, index) {
                  final circularIndex = index % photoAssets.length;
                  return Container(
                    margin:
                    const EdgeInsets.symmetric(horizontal: 6),
                    width: double.infinity,
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
      ),
    );
  }
}
