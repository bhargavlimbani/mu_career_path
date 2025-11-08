import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/custom_button.dart';
import '../theme/app_theme.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const EditProfileScreen({super.key, required this.userData});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  late TextEditingController _nameController;
  late TextEditingController _courseController;
  late TextEditingController _yearController;
  late TextEditingController _contactController;
  late TextEditingController _linkedinController;
  late TextEditingController _githubController;

  String? _photoPath;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final data = widget.userData;

    _emailController = TextEditingController(text: data['email'] ?? '');
    _passwordController = TextEditingController(text: '');
    _confirmPasswordController = TextEditingController(text: '');
    _nameController = TextEditingController(text: data['name'] ?? '');
    _courseController = TextEditingController(text: data['course'] ?? '');
    _yearController = TextEditingController(text: data['year'] ?? '');
    _contactController = TextEditingController(text: data['contact'] ?? '');
    _linkedinController = TextEditingController(text: data['linkedin'] ?? '');
    _githubController = TextEditingController(text: data['github'] ?? '');
    _photoPath = data['photoPath'];
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _courseController.dispose();
    _yearController.dispose();
    _contactController.dispose();
    _linkedinController.dispose();
    _githubController.dispose();
    super.dispose();
  }

  ImageProvider? _buildImageProvider(String? path) {
    if (path == null || path.isEmpty) return null;
    if (kIsWeb) return null; // Web support optional
    final file = File(path);
    if (file.existsSync()) return FileImage(file);
    return null;
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (xFile != null) setState(() => _photoPath = xFile.path);
  }

  void _saveProfile() {
    if (_passwordController.text.isNotEmpty &&
        _passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    final updatedData = {
      'email': _emailController.text.trim(),
      'password': _passwordController.text.trim(), // optional
      'name': _nameController.text.trim(),
      'course': _courseController.text.trim(),
      'year': _yearController.text.trim(),
      'contact': _contactController.text.trim(),
      'linkedin': _linkedinController.text.trim(),
      'github': _githubController.text.trim(),
      'photoPath': _photoPath,
    };

    Navigator.pop(context, updatedData);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

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
                backgroundImage: _buildImageProvider(_photoPath),
                child: _photoPath == null
                    ? const Icon(Icons.camera_alt, size: 32, color: Colors.white70)
                    : null,
                backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
              ),
            ),
            const SizedBox(height: 16),

            // Form fields
            CustomTextField(controller: _emailController, hint: 'Email', enabled: false),
            const SizedBox(height: 12),
            CustomTextField(controller: _passwordController, hint: 'New Password', obscureText: true),
            const SizedBox(height: 12),
            CustomTextField(controller: _confirmPasswordController, hint: 'Confirm Password', obscureText: true),
            const SizedBox(height: 12),
            CustomTextField(controller: _nameController, hint: 'Full Name'),
            const SizedBox(height: 12),
            CustomTextField(controller: _courseController, hint: 'Course / Branch'),
            const SizedBox(height: 12),
            CustomTextField(controller: _yearController, hint: 'Year'),
            const SizedBox(height: 12),
            CustomTextField(controller: _contactController, hint: 'Contact Number'),
            const SizedBox(height: 12),
            CustomTextField(controller: _linkedinController, hint: 'LinkedIn URL'),
            const SizedBox(height: 12),
            CustomTextField(controller: _githubController, hint: 'GitHub URL'),
            const SizedBox(height: 24),

            // Save button
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
