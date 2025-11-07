import 'package:flutter/material.dart';
import '../data/local_data.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';
import '../models/experience_model.dart';

class AddExperienceScreen extends StatefulWidget {
  const AddExperienceScreen({super.key});

  @override
  _AddExperienceScreenState createState() => _AddExperienceScreenState();
}

class _AddExperienceScreenState extends State<AddExperienceScreen> {
  final _company = TextEditingController();
  final _role = TextEditingController();
  final _package = TextEditingController();
  final _tips = TextEditingController();
  final ld = LocalData();

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await ld.init(); // ✅ Make sure data is loaded
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _submit() async {
    if (_company.text.trim().isEmpty) return;

    final u = ld.currentUser;
    if (u == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not found — please log in again')),
      );
      return;
    }

    final exp = ExperienceModel.create(
      studentId: u.id,
      studentName: u.name,
      companyName: _company.text.trim(),
      role: _role.text.trim(),
      package: _package.text.trim(),
      tips: _tips.text.trim(),
    );

    await ld.addExperience(exp);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Experience submitted for admin approval')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Add Experience')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            CustomTextField(controller: _company, hint: 'Company Name'),
            SizedBox(height: 8),
            CustomTextField(controller: _role, hint: 'Role / Position'),
            SizedBox(height: 8),
            CustomTextField(controller: _package, hint: 'Package (e.g., 6 LPA)'),
            SizedBox(height: 8),
            TextField(
              controller: _tips,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Tips / Experience',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(height: 12),
            CustomButton(
              text: 'Submit (will require admin approval)',
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
