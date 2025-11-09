import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';

class ExperiencesScreen extends StatefulWidget {
  const ExperiencesScreen({super.key});

  @override
  State<ExperiencesScreen> createState() => _ExperiencesScreenState();
}

class _ExperiencesScreenState extends State<ExperiencesScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isPosting = false;

  Future<void> _shareExperience() async {
    final title = _titleController.text.trim();
    final desc = _descController.text.trim();

    if (title.isEmpty || desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in both title and description.")),
      );
      return;
    }

    setState(() => _isPosting = true);

    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception("User not logged in");

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userData = userDoc.data() ?? {};
      final name = userData['name'] ?? 'Student';
      final photoUrl = userData['photoUrl'] ?? '';

      await _firestore.collection('experiences').add({
        'uid': user.uid,
        'name': name,
        'photoUrl': photoUrl,
        'title': title,
        'desc': desc,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _titleController.clear();
      _descController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Experience shared successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error sharing experience: $e")),
      );
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  // 🟢 Show full student details in a scrollable bottom sheet
  Future<void> _showStudentDetails(String uid, Map<String, dynamic> expData) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      final userData = userDoc.data();

      if (userData == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User details not found.")),
        );
        return;
      }

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        builder: (context) {
          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.9,
            maxChildSize: 0.95,
            minChildSize: 0.5,
            builder: (_, controller) {
              return SingleChildScrollView(
                controller: controller,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 45,
                        backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                        backgroundImage: (userData['photoUrl'] != null &&
                            userData['photoUrl'].toString().isNotEmpty)
                            ? NetworkImage(userData['photoUrl'])
                            : null,
                        child: (userData['photoUrl'] == null ||
                            userData['photoUrl'].toString().isEmpty)
                            ? Text(
                          userData['name'][0].toUpperCase(),
                          style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor),
                        )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: Text(
                        userData['name'] ?? 'Unknown Student',
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Divider(thickness: 1.2, height: 25),
                    _section("📧 Email", userData['email']),
                    _section("📞 Contact", userData['contact']),
                    _section("🎓 Course", userData['course']),
                    _section("📅 Year", userData['year']),
                    _section("📊 CGPA", userData['cgpa']),
                    _section("🎯 Career Goal", userData['careerGoal']),
                    _section("🧠 Skills", _listToString(userData['skills'])),
                    _section("🔗 LinkedIn", userData['linkedin']),
                    _section("💻 GitHub", userData['github']),
                    _section("📄 Resume", userData['resumeLink']),
                    _section("🌐 Portfolio", userData['portfolioLink']),
                    _section("🏆 Achievements", _listToString(userData['achievements'])),
                    _section("🗣️ Languages Known", _listToString(userData['languagesKnown'])),
                    const SizedBox(height: 20),
                    const Divider(thickness: 1.3),
                    const Text(
                      "📝 Shared Experience",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      expData['title'] ?? "",
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      expData['desc'] ?? "",
                      style:
                      const TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                    const SizedBox(height: 25),
                  ],
                ),
              );
            },
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading student details: $e")),
      );
    }
  }

  String _listToString(dynamic list) {
    if (list == null) return "N/A";
    if (list is List) return list.join(", ");
    return list.toString();
  }

  Widget _section(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        "$label: ${value ?? 'N/A'}",
        style: const TextStyle(fontSize: 15, color: Colors.black87),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF01A6BA);

    return Scaffold(
      backgroundColor: AppTheme.secondaryColor,
      appBar: AppBar(
        title: const Text(
          'Experiences',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text(
            "💬 Share My Experience",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // Experience form
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: primaryColor, width: 1.8),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: "Enter experience title (e.g. Internship at Wipro)",
                  prefixIcon: const Icon(Icons.title, color: primaryColor),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                    const BorderSide(color: primaryColor, width: 1.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                    const BorderSide(color: primaryColor, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: "Describe your experience in detail...",
                  prefixIcon: const Icon(Icons.description_outlined,
                      color: primaryColor),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                    const BorderSide(color: primaryColor, width: 1.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                    const BorderSide(color: primaryColor, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _isPosting ? null : _shareExperience,
                icon: _isPosting
                    ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Icon(Icons.send),
                label: Text(_isPosting ? "Sharing..." : "Share Experience"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 22, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 20),
          const Text(
            "🌟 Students' Experiences",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('experiences')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator()));
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                    child: Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Text(
                            "No experiences shared yet. Be the first to share!",
                            style: TextStyle(
                                fontSize: 16, color: Colors.black54))));
              }

              final experiences = snapshot.data!.docs;
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: experiences.length,
                itemBuilder: (context, index) {
                  final exp =
                      experiences[index].data() as Map<String, dynamic>? ?? {};
                  final name = exp['name'] ?? 'Unknown';
                  final title = exp['title'] ?? '';
                  final desc = exp['desc'] ?? '';
                  final uid = exp['uid'] ?? '';
                  final photoUrl = exp['photoUrl'] ?? '';
                  final timestamp = exp['timestamp'] as Timestamp?;
                  final date = timestamp != null
                      ? "${timestamp.toDate().day}/${timestamp.toDate().month}/${timestamp.toDate().year}"
                      : '';

                  return GestureDetector(
                    onTap: () => _showStudentDetails(uid, exp),
                    child: _experienceCard(
                      name: name,
                      title: title,
                      desc: desc,
                      date: date,
                      photoUrl: photoUrl,
                      primaryColor: primaryColor,
                    ),
                  );
                },
              );
            },
          ),
        ]),
      ),
    );
  }

  Widget _experienceCard({
    required String name,
    required String title,
    required String desc,
    required String date,
    required String photoUrl,
    required Color primaryColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: primaryColor.withOpacity(0.5), width: 1.2),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: primaryColor.withOpacity(0.15),
              backgroundImage:
              (photoUrl.isNotEmpty) ? NetworkImage(photoUrl) : null,
              child: (photoUrl.isEmpty)
                  ? Text(
                name.characters.first.toUpperCase(),
                style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              )
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ),
            Text(date,
                style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ),
        const SizedBox(height: 10),
        Text(title,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87)),
        const SizedBox(height: 6),
        Text(desc,
            style: const TextStyle(
                fontSize: 14, color: Colors.black87, height: 1.4)),
      ]),
    );
  }
}