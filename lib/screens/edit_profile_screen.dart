import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/custom_button.dart';
import '../theme/app_theme.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const EditProfileScreen({super.key, this.userData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

 
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _courseController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _cgpaController = TextEditingController();
  final TextEditingController _careerGoalController = TextEditingController();
  final TextEditingController _skillsController = TextEditingController();
  final TextEditingController _linkedinController = TextEditingController();
  final TextEditingController _githubController = TextEditingController();
  final TextEditingController _resumeLinkController = TextEditingController();
  final TextEditingController _portfolioLinkController = TextEditingController();
  final TextEditingController _achievementsController = TextEditingController();
  final TextEditingController _languagesController = TextEditingController();

  String? _photoPath;
  String? _photoUrl;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    final data = widget.userData;
    if (data != null) {
      _nameController.text = data['name'] ?? '';
      _emailController.text = data['email'] ?? '';
      _contactController.text = data['contact'] ?? '';
      _courseController.text = data['course'] ?? '';
      _yearController.text = data['year'] ?? '';
      _cgpaController.text = data['cgpa'] ?? '';
      _careerGoalController.text = data['careerGoal'] ?? '';
      _skillsController.text = (data['skills'] is List)
          ? (data['skills'] as List).join(', ')
          : (data['skills'] ?? '');
      _linkedinController.text = data['linkedin'] ?? '';
      _githubController.text = data['github'] ?? '';
      _resumeLinkController.text = data['resumeLink'] ?? '';
      _portfolioLinkController.text = data['portfolioLink'] ?? '';
      _achievementsController.text = (data['achievements'] is List)
          ? (data['achievements'] as List).join(', ')
          : (data['achievements'] ?? '');
      _languagesController.text = (data['languagesKnown'] is List)
          ? (data['languagesKnown'] as List).join(', ')
          : (data['languagesKnown'] ?? '');
      _photoUrl = data['photoUrl'];
    }
    setState(() => _loading = false);
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (xFile != null) setState(() => _photoPath = xFile.path);
  }

  Future<void> _saveProfile() async {
    setState(() => _loading = true);
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception("User not logged in.");

      String? uploadedPhotoUrl = _photoUrl;


      if (_photoPath != null) {
        final ref = _storage.ref().child('profile_photos/${user.uid}.jpg');
        await ref.putFile(File(_photoPath!));
        uploadedPhotoUrl = await ref.getDownloadURL();
      }

      final updatedData = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'contact': _contactController.text.trim(),
        'course': _courseController.text.trim(),
        'year': _yearController.text.trim(),
        'cgpa': _cgpaController.text.trim(),
        'careerGoal': _careerGoalController.text.trim(),
        'skills': _skillsController.text.trim().split(',').map((e) => e.trim()).toList(),
        'linkedin': _linkedinController.text.trim(),
        'github': _githubController.text.trim(),
        'resumeLink': _resumeLinkController.text.trim(),
        'portfolioLink': _portfolioLinkController.text.trim(),
        'achievements': _achievementsController.text.trim().split(',').map((e) => e.trim()).toList(),
        'languagesKnown': _languagesController.text.trim().split(',').map((e) => e.trim()).toList(),
        'photoUrl': uploadedPhotoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('users').doc(user.uid).update(updatedData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving profile: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  ImageProvider? _buildImageProvider() {
    if (_photoPath != null) return FileImage(File(_photoPath!));
    if (_photoUrl != null && _photoUrl!.isNotEmpty) return NetworkImage(_photoUrl!);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: AppTheme.secondaryColor,
      appBar: AppBar(
        title: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Photo
            Center(
              child: GestureDetector(
                onTap: _pickPhoto,
                child: CircleAvatar(
                  radius: 55,
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.3),
                  backgroundImage: _buildImageProvider(),
                  child: _buildImageProvider() == null
                      ? const Icon(Icons.camera_alt, size: 40, color: Colors.white70)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 25),

            _sectionContainer("👤 Personal Information", [
              CustomTextField(controller: _nameController, hint: 'Full Name'),
              const SizedBox(height: 12),
              CustomTextField(controller: _emailController, hint: 'Email', enabled: false),
              const SizedBox(height: 12),
              CustomTextField(controller: _contactController, hint: 'Contact Number'),
            ]),
            const SizedBox(height: 24),

            _sectionContainer("🎓 Academic Information", [
              CustomTextField(controller: _courseController, hint: 'Course / Branch'),
              const SizedBox(height: 12),
              CustomTextField(controller: _yearController, hint: 'Year'),
              const SizedBox(height: 12),
              CustomTextField(controller: _cgpaController, hint: 'CGPA'),
            ]),
            const SizedBox(height: 24),

            _sectionContainer("💼 Professional Information", [
              CustomTextField(controller: _careerGoalController, hint: 'Career Goal'),
              const SizedBox(height: 12),
              CustomTextField(controller: _skillsController, hint: 'Skills (comma separated)'),
              const SizedBox(height: 12),
              CustomTextField(controller: _linkedinController, hint: 'LinkedIn URL'),
              const SizedBox(height: 12),
              CustomTextField(controller: _githubController, hint: 'GitHub URL'),
              const SizedBox(height: 12),
              CustomTextField(controller: _resumeLinkController, hint: 'Resume Link'),
              const SizedBox(height: 12),
              CustomTextField(controller: _portfolioLinkController, hint: 'Portfolio Link'),
            ]),
            const SizedBox(height: 24),

            _sectionContainer("🏆 Achievements & Languages", [
              CustomTextField(controller: _achievementsController, hint: 'Achievements (comma separated)'),
              const SizedBox(height: 12),
              CustomTextField(controller: _languagesController, hint: 'Languages Known (comma separated)'),
            ]),
            const SizedBox(height: 30),

            CustomButton(
              text: 'Save Profile',
              onPressed: _saveProfile,
              color: AppTheme.primaryColor,
              textColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionContainer(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppTheme.primaryColor, width: 1.4),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
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
                  color: AppTheme.primaryColor)),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}