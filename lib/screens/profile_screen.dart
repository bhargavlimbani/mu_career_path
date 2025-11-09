import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_profile_screen.dart';
import 'login_screen.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic>? _userData;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    setState(() => _loading = true);
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          setState(() => _userData = doc.data());
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error loading profile: $e')));
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _logout() async {
    await AuthService().logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.secondaryColor,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
        ),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _userData == null
          ? const Center(child: Text("No user data found."))
          : RefreshIndicator(
        onRefresh: _fetchUserData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // ======= Profile Avatar =======
              CircleAvatar(
                radius: 55,
                backgroundColor:
                AppTheme.primaryColor.withOpacity(0.2),
                backgroundImage: _userData!['photoUrl'] != null &&
                    _userData!['photoUrl']!.isNotEmpty
                    ? NetworkImage(_userData!['photoUrl']!)
                    : null,
                child: _userData!['photoUrl'] == null ||
                    _userData!['photoUrl']!.isEmpty
                    ? const Icon(Icons.person,
                    size: 60, color: AppTheme.primaryColor)
                    : null,
              ),

              const SizedBox(height: 20),

              // ======= Name =======
              Text(
                _userData!['name'] ?? 'Student',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),

              // ======= Email =======
              Text(
                _userData!['email'] ?? 'No Email',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 20),

              // ======= Info Sections =======
              _buildSection(
                  "👤 Personal Information",
                  [
                    _infoTile("📞 Contact",
                        _userData!['contact'] ?? "N/A"),
                  ]),
              const SizedBox(height: 16),

              _buildSection(
                  "🎓 Academic Information",
                  [
                    _infoTile("🏫 Course",
                        _userData!['course'] ?? "N/A"),
                    _infoTile("📅 Year", _userData!['year'] ?? "N/A"),
                    _infoTile("📊 CGPA", _userData!['cgpa'] ?? "N/A"),
                  ]),
              const SizedBox(height: 16),

              _buildSection(
                  "💼 Professional Information",
                  [
                    _infoTile("🎯 Career Goal",
                        _userData!['careerGoal'] ?? "N/A"),
                    _infoTile(
                        "🧠 Skills",
                        _listToString(
                            _userData!['skills'] ?? "N/A")),
                    _infoTile("🔗 LinkedIn",
                        _userData!['linkedin'] ?? "N/A"),
                    _infoTile("💻 GitHub",
                        _userData!['github'] ?? "N/A"),
                    _infoTile("📄 Resume Link",
                        _userData!['resumeLink'] ?? "N/A"),
                    _infoTile("🌐 Portfolio",
                        _userData!['portfolioLink'] ?? "N/A"),
                  ]),
              const SizedBox(height: 16),

              _buildSection(
                  "🏆 Achievements & Languages",
                  [
                    _infoTile("🏅 Achievements",
                        _listToString(_userData!['achievements'])),
                    _infoTile("🗣️ Languages Known",
                        _listToString(_userData!['languagesKnown'])),
                  ]),

              const SizedBox(height: 25),

              // ======= Buttons =======
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              EditProfileScreen(userData: _userData!),
                        ),
                      );
                      if (result == true) _fetchUserData();
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text("Edit Profile"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout),
                    label: const Text("Logout"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ======= Section Builder =======
  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppTheme.primaryColor,
              )),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  // ======= Info Tile Widget =======
  Widget _infoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: Colors.black87),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value.isNotEmpty ? value : "N/A",
              style: const TextStyle(color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ======= Convert List to Comma-Separated String =======
  String _listToString(dynamic listData) {
    if (listData == null) return "N/A";
    if (listData is List) {
      return listData.isEmpty ? "N/A" : listData.join(", ");
    }
    return listData.toString();
  }
}