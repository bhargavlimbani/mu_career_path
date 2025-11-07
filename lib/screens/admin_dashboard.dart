import 'dart:convert';
import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/local_data.dart';
import '../models/company_model.dart';
import '../models/user_model.dart';
import '../widgets/custom_textfield.dart';
import 'student_profile_view.dart'; // ✅ new import

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final ld = LocalData();

  final _cName = TextEditingController();
  final _cDesc = TextEditingController();
  final _cPackage = TextEditingController();
  final _cDomain = TextEditingController();

  bool _allow = false;
  String? _photo;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await ld.init();
    setState(() {
      _photo = ld.currentUser?.photoPath;
    });
  }

  Future<void> _pickAdminPhoto() async {
    final picker = ImagePicker();
    final XFile? picked =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;

    String? savedPath;
    if (kIsWeb) {
      final bytes = await picked.readAsBytes();
      savedPath = base64Encode(bytes);
    } else {
      final copied = await ld.copyFileToAppDir(File(picked.path));
      savedPath = copied;
    }

    var user = ld.currentUser!;
    user.photoPath = savedPath;
    await ld.updateUser(user);

    setState(() {
      _photo = savedPath;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Profile photo updated')),
    );
  }

  void _openEditDialog() {
    final nameCtrl = TextEditingController(text: ld.currentUser?.name ?? '');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: _pickAdminPhoto,
              child: CircleAvatar(
                radius: 40,
                backgroundImage: _buildImageProvider(),
                child: _photo == null ? Icon(Icons.camera_alt, size: 30) : null,
              ),
            ),
            SizedBox(height: 10),
            CustomTextField(controller: nameCtrl, hint: 'Admin Name'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              var u = ld.currentUser!;
              u.name = nameCtrl.text.trim();
              u.photoPath = _photo;
              await ld.updateUser(u);
              Navigator.pop(context);
              setState(() {});
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  ImageProvider? _buildImageProvider() {
    if (_photo == null) return null;
    if (kIsWeb) {
      try {
        return MemoryImage(base64Decode(_photo!));
      } catch (_) {
        return null;
      }
    } else {
      final file = File(_photo!);
      if (file.existsSync()) return FileImage(file);
      return null;
    }
  }

  // ✅ Universal function for loading profile photo (works on web + Android + desktop)
  ImageProvider? _buildStudentImageProvider(String? path) {
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

  void _addCompany() async {
    if (_cName.text.trim().isEmpty) return;

    final descText =
        "Package: ${_cPackage.text.trim()}\nDomain: ${_cDomain.text.trim()}\nInfo: ${_cDesc.text.trim()}";

    var c = CompanyModel.create(
      name: _cName.text.trim(),
      description: descText,
      allowed: _allow,
    );

    await ld.addCompany(c);

    _cName.clear();
    _cDesc.clear();
    _cDomain.clear();
    _cPackage.clear();

    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Company added successfully')),
    );
  }

  void _removeCompany(String id) async {
    ld.companies.removeWhere((c) => c.id == id);
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(
        'companies', jsonEncode(ld.companies.map((c) => c.toJson()).toList()));
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Company removed')),
    );
  }

  void _deleteStudent(String studentId, String studentName) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Student'),
        content: Text('Are you sure you want to delete $studentName? This will also remove all their experiences and cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await ld.deleteUser(studentId);
              Navigator.pop(context);
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$studentName deleted successfully')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var pending = ld.experiences.where((e) => !e.approved).toList();
    var students = ld.users.where((u) => u.role == UserRole.student).toList();
    var approved = ld.experiences.where((e) => e.approved).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () async {
              await ld.logout();
              Navigator.pushReplacementNamed(context, '/');
            },
          )
        ],
      ),
      body: DefaultTabController(
        length: 4,
        child: Column(
          children: [
            // Profile Section
            Card(
              margin: EdgeInsets.all(12),
              child: ListTile(
                leading: CircleAvatar(
                  radius: 28,
                  backgroundImage: _buildImageProvider(),
                  child: _photo == null ? Icon(Icons.person, size: 28) : null,
                ),
                title: Text(ld.currentUser?.name ?? 'Admin'),
                subtitle: Text('Admin • MU Career Path'),
                trailing: ElevatedButton(onPressed: _openEditDialog, child: Text('Edit')),
              ),
            ),
            
            // Tab Bar
            TabBar(
              isScrollable: true,
              tabs: [
                Tab(text: 'All Students (${students.length})'),
                Tab(text: 'Pending (${pending.length})'),
                Tab(text: 'Approved (${approved.length})'),
                Tab(text: 'Companies'),
              ],
            ),
            
            // Tab Content
            Expanded(
              child: TabBarView(
                children: [
                  // All Students Tab
                  _buildAllStudentsTab(students),
                  
                  // Pending Experiences Tab
                  _buildPendingExperiencesTab(pending),
                  
                  // Approved Experiences Tab
                  _buildApprovedExperiencesTab(approved),
                  
                  // Companies Tab
                  _buildCompaniesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllStudentsTab(List<UserModel> students) {
    if (students.isEmpty) {
      return Center(child: Text('No students registered yet.'));
    }

    return ListView.builder(
      padding: EdgeInsets.all(12),
      itemCount: students.length,
      itemBuilder: (context, index) {
        final student = students[index];
        final studentExperiences = ld.experiences.where((e) => e.studentId == student.id).toList();
        final approvedCount = studentExperiences.where((e) => e.approved).length;
        final pendingCount = studentExperiences.where((e) => !e.approved).length;

        return Card(
          margin: EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StudentProfileView(student: student),
                ),
              );
            },
            leading: CircleAvatar(
              radius: 30,
              backgroundImage: _buildStudentImageProvider(student.photoPath),
              child: student.photoPath == null
                  ? Text(
                      student.name.isNotEmpty ? student.name[0].toUpperCase() : 'S',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    )
                  : null,
            ),
            title: Text(student.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(student.email),
                Text('${student.branch} • Year ${student.year}'),
                if (studentExperiences.isNotEmpty)
                  Text(
                    'Experiences: $approvedCount approved, $pendingCount pending',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                if (student.resumePaths.isNotEmpty)
                  Text(
                    'Resumes: ${student.resumePaths.length} uploaded',
                    style: TextStyle(fontSize: 12, color: Colors.blue[600]),
                  ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (student.resumePaths.isNotEmpty)
                  Icon(Icons.picture_as_pdf, color: Colors.red, size: 20),
                SizedBox(width: 8),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'view') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => StudentProfileView(student: student),
                        ),
                      );
                    } else if (value == 'delete') {
                      _deleteStudent(student.id, student.name);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'view',
                      child: Row(
                        children: [
                          Icon(Icons.visibility, size: 20),
                          SizedBox(width: 8),
                          Text('View Profile'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red, size: 20),
                          SizedBox(width: 8),
                          Text('Delete Student', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  child: Icon(Icons.more_vert),
                ),
              ],
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  Widget _buildPendingExperiencesTab(List<dynamic> pending) {
    if (pending.isEmpty) {
      return Center(child: Text('No pending experiences.'));
    }

    return ListView.builder(
      padding: EdgeInsets.all(12),
      itemCount: pending.length,
      itemBuilder: (context, i) {
        var e = pending[i];
        return Card(
          margin: EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            onTap: () {
              final student = ld.users.firstWhere(
                (u) => u.id == e.studentId,
                orElse: () => ld.currentUser ?? UserModel.createNew(""),
              );
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StudentProfileView(student: student),
                ),
              );
            },
            title: Text('${e.companyName} — ${e.role}'),
            subtitle: Text(
              'By ${e.studentName} • ${e.package}\n${e.tips}',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.check, color: Colors.green),
                  onPressed: () async {
                    await ld.approveExperience(e.id);
                    setState(() {});
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    await ld.rejectExperience(e.id);
                    setState(() {});
                  },
                ),
              ],
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  Widget _buildApprovedExperiencesTab(List<dynamic> approved) {
    if (approved.isEmpty) {
      return Center(child: Text('No approved experiences yet.'));
    }

    return ListView.builder(
      padding: EdgeInsets.all(12),
      itemCount: approved.length,
      itemBuilder: (context, i) {
        var e = approved[i];
        return Card(
          margin: EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            onTap: () {
              final student = ld.users.firstWhere(
                (u) => u.id == e.studentId,
                orElse: () => ld.currentUser ?? UserModel.createNew(""),
              );
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StudentProfileView(student: student),
                ),
              );
            },
            leading: CircleAvatar(
              backgroundColor: Colors.green[100],
              child: Icon(Icons.check, color: Colors.green),
            ),
            title: Text('${e.companyName} — ${e.role}'),
            subtitle: Text(
              'By ${e.studentName} • ${e.package}\n${e.tips}',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Text(
              'Approved',
              style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  Widget _buildCompaniesTab() {
    return Padding(
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Add Company Section
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Add Company', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),
                  CustomTextField(controller: _cName, hint: 'Company Name'),
                  SizedBox(height: 6),
                  CustomTextField(controller: _cPackage, hint: 'Package (e.g. 6 LPA)'),
                  SizedBox(height: 6),
                  CustomTextField(controller: _cDomain, hint: 'Domain (e.g. Web, AI, etc.)'),
                  SizedBox(height: 6),
                  CustomTextField(controller: _cDesc, hint: 'Information / Description'),
                  SizedBox(height: 6),
                  Row(
                    children: [
                      Checkbox(
                          value: _allow,
                          onChanged: (v) => setState(() => _allow = v ?? false)),
                      Text('Allowed for unplaced students'),
                      Spacer(),
                      ElevatedButton(
                          onPressed: _addCompany, child: Text('Add Company')),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(height: 16),
          
          // Companies List
          Text('Companies (${ld.companies.length})', 
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          
          if (ld.companies.isEmpty)
            Center(child: Text('No companies added yet.'))
          else
            Expanded(
              child: ListView.builder(
                itemCount: ld.companies.length,
                itemBuilder: (context, index) {
                  final company = ld.companies[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      title: Text(company.name),
                      subtitle: Text(company.description),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeCompany(company.id),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
