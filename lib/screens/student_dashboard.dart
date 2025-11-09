import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mu_career_pat_offline/services/auth_service.dart';
import 'login_screen.dart';
import 'experiences_screen.dart';
import 'companies_screen.dart';
import 'profile_screen.dart';
import 'package:mu_career_pat_offline/theme/app_theme.dart';
import 'package:mu_career_pat_offline/widgets/bottom_navbar.dart';

// Explore Screens
import 'software_development_explore_screen.dart';
import 'cybersecurity_explore_screen.dart';
import 'data_science_ai_explore_screen.dart';
import 'hardware_iot_explore_screen.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  Map<String, dynamic>? userData;
  bool _loading = true;
  int _selectedIndex = 0;

  // Carousel
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  final List<String> carouselImages = [
    'assets/1.jpeg',
    'assets/7.jpeg',
    'assets/13.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserData();

    _pageController = PageController(initialPage: 0, viewportFraction: 0.9);
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) return;
      if (_pageController.hasClients) {
        _currentPage = (_currentPage + 1) % carouselImages.length;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 600),
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
        if (doc.exists) setState(() => userData = doc.data());
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error fetching data: $e")));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
      );
    }
  }

  // ---------------- HOME SCREEN ----------------
  Widget _buildHomeScreen() {
    if (userData == null) return const Center(child: CircularProgressIndicator());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // 👋 Greeting
        Row(children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
            backgroundImage: (userData?['photoUrl'] != null &&
                userData!['photoUrl'].isNotEmpty)
                ? NetworkImage(userData!['photoUrl'])
                : null,
            child: (userData?['photoUrl'] == null ||
                userData!['photoUrl'].isEmpty)
                ? const Icon(Icons.person, color: AppTheme.primaryColor)
                : null,
          ),
          const SizedBox(width: 14),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text("Hello, ${userData?['name'] ?? 'Student'} 👋",
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            const Text("Your career journey starts here 🚀",
                style: TextStyle(color: Colors.black54, fontSize: 14)),
          ]),
        ]),
        const SizedBox(height: 22),

        // 🌟 Carousel
        SizedBox(
          height: 220,
          width: double.infinity,
          child: PageView.builder(
            controller: _pageController,
            itemCount: carouselImages.length,
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double value = 1.0;
                  if (_pageController.position.haveDimensions) {
                    value = _pageController.page! - index;
                    value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
                  }
                  return Center(
                    child: SizedBox(
                      height: Curves.easeOut.transform(value) * 220,
                      width: MediaQuery.of(context).size.width * 0.95,
                      child: child,
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppTheme.primaryColor.withOpacity(0.4),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                    image: DecorationImage(
                      image: AssetImage(carouselImages[index]),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 25),

        // 📢 Announcements
        const Text("📢 Latest Announcements",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 14),
        _announcementCard("Infosys Drive 2025 - Register before Nov 15!",
            "Don’t miss your chance to participate in the upcoming campus drive."),
        _announcementCard("Soft Skills Workshop 🎤",
            "Improve your communication and interview skills with experts."),
        _announcementCard("Resume Review Week ✍️",
            "Get your resume reviewed by placement experts this weekend!"),

        const SizedBox(height: 28),

        // 🎯 Career Paths
        const Text("🎯 Recommended Career Paths",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),
        _careerCard(
          title: "💻 Software Development",
          desc:
          "Explore app, web, and backend development with top IT firms. Ideal for problem solvers and builders.",
          onExplore: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const SoftwareDevelopmentExploreScreen()),
            );
          },
        ),
        _careerCard(
          title: "🔒 Cybersecurity",
          desc:
          "Learn ethical hacking, digital forensics, and network protection. Become a data guardian!",
          onExplore: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const CyberSecurityExploreScreen()),
            );
          },
        ),
        _careerCard(
          title: "🧠 Data Science & AI",
          desc:
          "Master ML, data analytics, and visualization. Unlock the power of intelligent systems.",
          onExplore: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const DataScienceAIExploreScreen()),
            );
          },
        ),
        _careerCard(
          title: "⚙️ Hardware & IoT",
          desc:
          "Design and develop embedded, automation, and smart IoT-based solutions for the future.",
          onExplore: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const HardwareIoTExploreScreen()),
            );
          },
        ),

        const SizedBox(height: 40),
        Center(
          child: Text(
            "Keep exploring, keep growing 🌱",
            style: TextStyle(
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: 30),
      ]),
    );
  }

  // 📢 Announcement Card
  Widget _announcementCard(String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.6)),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(children: [
        const Icon(Icons.campaign_outlined,
            color: AppTheme.primaryColor, size: 28),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style:
                const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            const SizedBox(height: 4),
            Text(subtitle,
                style:
                const TextStyle(fontSize: 13, color: Colors.black54, height: 1.3)),
          ]),
        ),
      ]),
    );
  }

  // 🎯 Career Card with Centered Explore Button
  Widget _careerCard({
    required String title,
    required String desc,
    required VoidCallback onExplore,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.4), width: 1.2),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Text(
          desc,
          style: const TextStyle(fontSize: 14.5, color: Colors.black87, height: 1.5),
        ),
        const SizedBox(height: 22),
        Center( // ⬅️ Center-aligned Explore Now button
          child: ElevatedButton(
            onPressed: onExplore,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text(
              "Explore Now",
              style: TextStyle(color: Colors.white, fontSize: 15),
            ),
          ),
        ),
      ]),
    );
  }

  // ---------------- Main Scaffold ----------------
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
        backgroundColor: AppTheme.primaryColor,
        elevation: 4,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ProfileScreen())),
              child: CircleAvatar(
                radius: 20,
                backgroundColor:
                AppTheme.primaryColor.withOpacity(0.3),
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
            const Text("Student Dashboard",
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 22)),
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: _logout,
            ),
          ],
        ),
      )
          : null,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : screens[_selectedIndex],
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}