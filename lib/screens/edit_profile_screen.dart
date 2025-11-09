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
  // Keep constructor simple (screen will load current user data from Firestore)
  const EditProfileScreen({super.key, required Map<String, dynamic> userData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  late TextEditingController _emailController;
  late TextEditingController _firstNameController; // First name
  late TextEditingController _branchController;    // Branch (course)
  late TextEditingController _yearController;
  late TextEditingController _contactController;
  late TextEditingController _linkedinController;
  late TextEditingController _githubController;
  late TextEditingController _passwordController;       // New password
  late TextEditingController _confirmPasswordController; // Confirm password

  String? _photoPath;
  String? _photoUrl;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _firstNameController = TextEditingController();
    _branchController = TextEditingController();
    _yearController = TextEditingController();
    _contactController = TextEditingController();
    _linkedinController = TextEditingController();
    _githubController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();

    _loadUserData();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _firstNameController.dispose();
    _branchController.dispose();
    _yearController.dispose();
    _contactController.dispose();
    _linkedinController.dispose();
    _githubController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() => _loading = true);
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        final data = doc.data();
        if (data != null) {
          _emailController.text = data['email'] ?? '';
          // Keep naming consistent: using 'name' field from Firestore as first name
          _firstNameController.text = data['name'] ?? '';
          _branchController.text = data['course'] ?? '';
          _yearController.text = data['year'] ?? '';
          _contactController.text = data['contact'] ?? '';
          _linkedinController.text = data['linkedin'] ?? '';
          _githubController.text = data['github'] ?? '';
          _photoUrl = data['photoUrl'];
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading user data: $e')),
        );
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (xFile != null) {
      setState(() => _photoPath = xFile.path);
    }
  }

  Future<void> _saveProfile() async {
    // Validate passwords match if provided
    if (_passwordController.text.isNotEmpty &&
        _passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception("No user logged in");

      String? uploadedPhotoUrl = _photoUrl;

      // Upload new profile photo if selected
      if (_photoPath != null) {
        final ref = _storage.ref().child('profile_photos/${user.uid}.jpg');
        await ref.putFile(File(_photoPath!));
        uploadedPhotoUrl = await ref.getDownloadURL();
      }

      // Update password if provided
      if (_passwordController.text.isNotEmpty) {
        await user.updatePassword(_passwordController.text.trim());
      }

      // Prepare updated data; 'name' stores first name to keep DB consistent
      final updatedData = {
        'name': _firstNameController.text.trim(),
        'course': _branchController.text.trim(),
        'year': _yearController.text.trim(),
        'contact': _contactController.text.trim(),
        'linkedin': _linkedinController.text.trim(),
        'github': _githubController.text.trim(),
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
    } on FirebaseException catch (e) {
      // handle firebase-specific exceptions (e.g., requires-recent-login)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving profile: ${e.message}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving profile: $e')),
        );
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  ImageProvider? _buildImageProvider() {
    if (_photoPath != null) return FileImage(File(_photoPath!));
    if (_photoUrl != null && _photoUrl!.isNotEmpty) {
      return NetworkImage(_photoUrl!);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppTheme.secondaryColor,
      appBar: AppBar(
        title: const Text('Edit Profile'),
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
          children: [
            GestureDetector(
              onTap: _pickPhoto,
              child: CircleAvatar(
                radius: 48,
                backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                backgroundImage: _buildImageProvider(),
                child: _photoUrl == null && _photoPath == null
                    ? const Icon(Icons.camera_alt, size: 32, color: Colors.white70)
                    : null,
              ),
            ),
            const SizedBox(height: 16),

            // Email (read-only)
            CustomTextField(controller: _emailController, hint: 'Email', enabled: false),
            const SizedBox(height: 12),

            // Reordered fields (exact requested order)
            CustomTextField(controller: _firstNameController, hint: 'First name'),
            const SizedBox(height: 12),
            CustomTextField(controller: _branchController, hint: 'Branch'),
            const SizedBox(height: 12),
            CustomTextField(controller: _yearController, hint: 'Year'),
            const SizedBox(height: 12),
            CustomTextField(controller: _contactController, hint: 'Contact Number'),
            const SizedBox(height: 12),
            CustomTextField(controller: _linkedinController, hint: 'LinkedIn URL'),
            const SizedBox(height: 12),
            CustomTextField(controller: _githubController, hint: 'GitHub URL'),
            const SizedBox(height: 12),

            // Passwords at the end in requested order
            CustomTextField(controller: _passwordController, hint: 'New Password (optional)', obscureText: true),
            const SizedBox(height: 12),
            CustomTextField(controller: _confirmPasswordController, hint: 'Confirm Password', obscureText: true),
            const SizedBox(height: 24),

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
}
