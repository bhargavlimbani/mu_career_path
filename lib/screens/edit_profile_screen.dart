import 'dart:convert';
import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/local_data.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/custom_button.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ld = LocalData();

  // ✅ Always initialize controllers to avoid LateInitializationError
  final _name = TextEditingController();
  final _branch = TextEditingController();
  final _year = TextEditingController();
  final _contact = TextEditingController();
  final _linkedin = TextEditingController();
  final _github = TextEditingController();

  String? _photoPath;
  List<String> _resumes = [];
  bool _loading = true; // ⏳ loading flag

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    await ld.init();
    var u = ld.currentUser!;
    setState(() {
      _name.text = u.name;
      _branch.text = u.branch;
      _year.text = u.year;
      _contact.text = u.contact ?? '';
      _linkedin.text = u.linkedin ?? '';
      _github.text = u.github ?? '';
      _photoPath = u.photoPath;
      _resumes = List.from(u.resumePaths);
      _loading = false;
    });
  }

  // ✅ Build image provider for profile photo
  ImageProvider? _buildImageProvider(String? path) {
    if (path == null || path.isEmpty) return null;

    if (kIsWeb) {
      try {
        return MemoryImage(base64Decode(path));
      } catch (_) {
        return null;
      }
    } else {
      final file = File(path);
      if (file.existsSync()) return FileImage(file);
      return null;
    }
  }

  // ✅ Pick profile photo
  Future<void> _pickPhoto() async {
    final ImagePicker ip = ImagePicker();
    final XFile? x =
        await ip.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (x == null) return;

    String? savedPath;
    if (kIsWeb) {
      final bytes = await x.readAsBytes();
      savedPath = base64Encode(bytes);
    } else {
      final copied = await ld.copyFileToAppDir(File(x.path));
      savedPath = copied;
    }

    setState(() {
      _photoPath = savedPath;
    });
  }

  // ✅ Pick resume (PDF or DOCX)
  Future<void> _pickResume() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx'],
    );
    if (res == null || res.files.isEmpty) return;

    if (kIsWeb) {
      setState(() {
        _resumes.add(res.files.single.name);
      });
    } else {
      final file = File(res.files.single.path!);
      final copied = await ld.copyFileToAppDir(file);
      setState(() {
        _resumes.add(copied);
      });
    }
  }

  // ✅ URL launcher
  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Could not open link')));
      }
    } catch (_) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Invalid URL')));
    }
  }

  // ✅ Save user profile
  Future<void> _save() async {
    // ✅ Validate contact number
    if (_contact.text.trim().isNotEmpty &&
        !RegExp(r'^\d{10}$').hasMatch(_contact.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid mobile number (must be 10 digits)')),
      );
      return;
    }

    var u = ld.currentUser!;
    u.name = _name.text.trim();
    u.branch = _branch.text.trim();
    u.year = _year.text.trim();
    u.photoPath = _photoPath;
    u.resumePaths = _resumes;
    u.contact = _contact.text.trim();
    u.linkedin = _linkedin.text.trim();
    u.github = _github.text.trim();
    await ld.updateUser(u);

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Profile updated successfully')));
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Edit Profile')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ---------- PROFILE PHOTO ----------
              GestureDetector(
                onTap: _pickPhoto,
                child: CircleAvatar(
                  radius: 48,
                  backgroundImage: _buildImageProvider(_photoPath),
                  child: _photoPath == null
                      ? Icon(Icons.camera_alt, size: 32)
                      : null,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Tap to change profile photo',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              SizedBox(height: 12),

              // ---------- TEXT FIELDS ----------
              CustomTextField(controller: _name, hint: 'Full Name'),
              SizedBox(height: 8),
              CustomTextField(controller: _branch, hint: 'Branch (e.g., CSE)'),
              SizedBox(height: 8),
              CustomTextField(controller: _year, hint: 'Year (e.g., 3)'),
              SizedBox(height: 8),
              CustomTextField(controller: _contact, hint: 'Contact Number'),
              SizedBox(height: 8),
              CustomTextField(controller: _linkedin, hint: 'LinkedIn URL'),
              SizedBox(height: 8),
              CustomTextField(controller: _github, hint: 'GitHub URL'),

              SizedBox(height: 8),
              // ---------- CLICKABLE LINKS ----------
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_linkedin.text.isNotEmpty)
                    TextButton.icon(
                      onPressed: () => _launchUrl(_linkedin.text.trim()),
                      icon: Icon(Icons.link, color: Colors.blue),
                      label: Text('Open LinkedIn'),
                    ),
                  if (_github.text.isNotEmpty)
                    TextButton.icon(
                      onPressed: () => _launchUrl(_github.text.trim()),
                      icon: Icon(Icons.code, color: Colors.black87),
                      label: Text('Open GitHub'),
                    ),
                ],
              ),

              SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Resume History',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 6),

              // ---------- RESUME LIST ----------
              if (_resumes.isEmpty)
                Text('No resumes uploaded.')
              else
                ..._resumes.reversed.map(
                  (p) => Card(
                    child: ListTile(
                      leading: Icon(Icons.picture_as_pdf, color: Colors.red),
                      title: Text(p.split('/').last),
                      subtitle: Text(p),
                      trailing: IconButton(
                        icon: Icon(Icons.open_in_new, color: Colors.blue),
                        onPressed: () async {
                          if (kIsWeb) {
                            // On web, show the file info since we can't open PDFs directly
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: Text('Resume Information'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('File: ${p.split('/').last}'),
                                    SizedBox(height: 8),
                                    Text('Note: PDF viewing is not available on web. Download the file to view it.'),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text('OK')),
                                ],
                              ),
                            );
                          } else {
                            // On mobile, check if file exists and open it
                            final file = File(p);
                            if (file.existsSync()) {
                              try {
                                await OpenFilex.open(p);
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Could not open file: $e')),
                                );
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('File not found: ${p.split('/').last}')),
                              );
                            }
                          }
                        },
                      ),
                    ),
                  ),
                ),

              SizedBox(height: 6),

              // ---------- UPLOAD BUTTON ----------
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _pickResume,
                      icon: Icon(Icons.upload_file),
                      label: Text('Upload Resume'),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12),
              CustomButton(text: 'Save Profile', onPressed: _save),
            ],
          ),
        ),
      ),
    );
  }
}
