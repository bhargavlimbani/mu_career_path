import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:open_filex/open_filex.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/user_model.dart';
import '../models/experience_model.dart';
import '../data/local_data.dart';

class StudentProfileView extends StatefulWidget {
  final UserModel student;
  const StudentProfileView({super.key, required this.student});

  @override
  _StudentProfileViewState createState() => _StudentProfileViewState();
}

class _StudentProfileViewState extends State<StudentProfileView> {
  final ld = LocalData();
  List<ExperienceModel> studentExperiences = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStudentExperiences();
  }

  Future<void> _loadStudentExperiences() async {
    await ld.init();
    setState(() {
      studentExperiences = ld.experiences
          .where((exp) => exp.studentId == widget.student.id)
          .toList();
      isLoading = false;
    });
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
  }

  ImageProvider? _buildImageProvider(String? path) {
    if (path == null) return null;
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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Student Profile')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.student.name)),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: _buildImageProvider(widget.student.photoPath),
                        child: widget.student.photoPath == null
                            ? Icon(Icons.person, size: 50)
                            : null,
                      ),
                      SizedBox(height: 16),
                      Text(
                        widget.student.name,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        widget.student.email,
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${widget.student.branch} • Year ${widget.student.year}',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Contact Information
              if (widget.student.contact != null || 
                  widget.student.linkedin != null || 
                  widget.student.github != null) ...[
                Text('Contact Information', 
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        if (widget.student.contact != null)
                          ListTile(
                            leading: Icon(Icons.phone, color: Colors.blue),
                            title: Text('Contact'),
                            subtitle: Text(widget.student.contact!),
                            trailing: IconButton(
                              icon: Icon(Icons.copy),
                              onPressed: () {
                                // Copy to clipboard functionality could be added here
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Contact copied to clipboard')),
                                );
                              },
                            ),
                          ),
                        if (widget.student.linkedin != null)
                          ListTile(
                            leading: Icon(Icons.work, color: Colors.blue[700]),
                            title: Text('LinkedIn'),
                            subtitle: Text(widget.student.linkedin!),
                            trailing: IconButton(
                              icon: Icon(Icons.open_in_new),
                              onPressed: () => _launchURL(widget.student.linkedin!),
                            ),
                          ),
                        if (widget.student.github != null)
                          ListTile(
                            leading: Icon(Icons.code, color: Colors.grey[800]),
                            title: Text('GitHub'),
                            subtitle: Text(widget.student.github!),
                            trailing: IconButton(
                              icon: Icon(Icons.open_in_new),
                              onPressed: () => _launchURL(widget.student.github!),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
              ],

              // Student Experiences
              Text('Placement Experiences', 
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              if (studentExperiences.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Text('No experiences submitted yet.', 
                          style: TextStyle(color: Colors.grey[600])),
                    ),
                  ),
                )
              else
                ...studentExperiences.map((exp) => Card(
                  margin: EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: exp.approved ? Colors.green : Colors.orange,
                      child: Icon(
                        exp.approved ? Icons.check : Icons.pending,
                        color: Colors.white,
                      ),
                    ),
                    title: Text('${exp.companyName} — ${exp.role}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Package: ${exp.package}'),
                        SizedBox(height: 4),
                        Text(
                          exp.tips,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    isThreeLine: true,
                    trailing: Text(
                      exp.approved ? 'Approved' : 'Pending',
                      style: TextStyle(
                        color: exp.approved ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )),
              SizedBox(height: 16),

              // Resumes Section
              Text('Resumes', 
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              if (widget.student.resumePaths.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Text('No resumes uploaded.', 
                          style: TextStyle(color: Colors.grey[600])),
                    ),
                  ),
                )
              else
                ...widget.student.resumePaths.reversed.map((p) => Card(
                  margin: EdgeInsets.only(bottom: 8),
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
                )),
            ],
          ),
        ),
      ),
    );
  }
}
