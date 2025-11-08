import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/experience_model.dart';
import '../models/company_model.dart';

class LocalData {
  static final LocalData _instance = LocalData._internal();
  factory LocalData() => _instance;
  LocalData._internal();

  List<UserModel> users = [];
  List<ExperienceModel> experiences = [];
  List<CompanyModel> companies = [];
  UserModel? currentUser;

  // ---------------------- INIT ----------------------
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    // Load users
    String? ujson = prefs.getString('users');
    if (ujson != null) {
      List<dynamic> arr = json.decode(ujson);
      users = arr.map((e) => UserModel.fromJson(e)).toList();
    } else {
      // Default admin
      users = [UserModel.createAdmin('admin@marwadieducation.edu.in')];
    }

    // Load experiences
    String? ej = prefs.getString('experiences');
    if (ej != null) {
      List<dynamic> arr = json.decode(ej);
      experiences = arr.map((e) => ExperienceModel.fromJson(e)).toList();
    }

    // Load companies
    String? cj = prefs.getString('companies');
    if (cj != null) {
      List<dynamic> arr = json.decode(cj);
      companies = arr.map((e) => CompanyModel.fromJson(e)).toList();
    } else {
      companies = [
        CompanyModel(
          id: 'c1',
          name: 'TCS',
          description: 'Tech company',
          allowedForUnplaced: true,
        ),
        CompanyModel(
          id: 'c2',
          name: 'Infosys',
          description: 'IT Services',
          allowedForUnplaced: false,
        ),
      ];
    }

    // Load current user
    String? cur = prefs.getString('currentUserId');
    if (cur != null) {
      currentUser =
          users.firstWhere((u) => u.id == cur, orElse: () => users.first);
    }
  }

  // ---------------------- SAVE ALL ----------------------
  Future<void> _saveAll() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('users', json.encode(users.map((u) => u.toJson()).toList()));
    prefs.setString(
        'experiences', json.encode(experiences.map((e) => e.toJson()).toList()));
    prefs.setString(
        'companies', json.encode(companies.map((c) => c.toJson()).toList()));
    if (currentUser != null) prefs.setString('currentUserId', currentUser!.id);
  }

  // ---------------------- FILE MANAGEMENT ----------------------
  // Copy file (image/pdf) to safe app directory and return the path
  Future<String> copyFileToAppDir(File file) async {
    final dir = await getApplicationDocumentsDirectory();
    final filename = p.basename(file.path);
    final destPath =
        p.join(dir.path, '${DateTime.now().millisecondsSinceEpoch}_$filename');
    final newFile = await file.copy(destPath);
    return newFile.path;
  }

  // ---------------------- LOGIN FUNCTION ----------------------
  Future<UserModel?> login(String email, String password) async {
    // Ensure data loaded
    if (users.isEmpty && experiences.isEmpty && companies.isEmpty) await init();

    // --- Student login ---
    if (email.endsWith('@marwadiuniversity.ac.in')) {
      var exist = users.firstWhere(
        (u) => u.email == email,
        orElse: () {
          var nu = UserModel.createNew(email);
          users.add(nu);
          _saveAll();
          return nu;  
        },
      );
      currentUser = exist;
      await _saveAll();
      return exist;
    }

    // --- Admin login (restricted) ---
    if (email.endsWith('@marwadieducation.edu.in')) {
      const allowedAdmins = {
        'admin@marwadieducation.edu.in': '123456',
        'bhargav@marwadieducation.edu.in': '123456',
      };

      // Check if valid admin
      if (!allowedAdmins.containsKey(email)) return null;

      // Validate password
      if (allowedAdmins[email] != password.trim()) return null;

      // Find or create admin user
      var exist = users.firstWhere(
        (u) => u.email == email,
        orElse: () {
          var nu = UserModel.createAdmin(email);
          users.add(nu);
          _saveAll();
          return nu;
        },
      );
      currentUser = exist;
      await _saveAll();
      return exist;
    }

    // --- Invalid login ---
    return null;
  }

  // ---------------------- LOGOUT ----------------------
  Future<void> logout() async {
    currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('currentUserId');
  }

  // ---------------------- EXPERIENCE MANAGEMENT ----------------------
  Future<void> addExperience(ExperienceModel exp) async {
    experiences.add(exp);
    await _saveAll();
  }

  Future<void> approveExperience(String id) async {
    var idx = experiences.indexWhere((e) => e.id == id);
    if (idx >= 0) experiences[idx].approved = true;
    await _saveAll();
  }

  Future<void> rejectExperience(String id) async {
    experiences.removeWhere((e) => e.id == id);
    await _saveAll();
  }

  // ---------------------- COMPANY MANAGEMENT ----------------------
  Future<void> addCompany(CompanyModel c) async {
    companies.add(c);
    await _saveAll();
  }

  // ---------------------- USER MANAGEMENT ----------------------
  Future<void> updateUser(UserModel user) async {
    var idx = users.indexWhere((u) => u.id == user.id);
    if (idx >= 0) users[idx] = user;
    currentUser = user;
    await _saveAll();
  }

  Future<void> deleteUser(String userId) async {
    // Remove user
    users.removeWhere((u) => u.id == userId);
    
    // Remove all experiences by this user
    experiences.removeWhere((e) => e.studentId == userId);
    
    // If this was the current user, log them out
    if (currentUser?.id == userId) {
      currentUser = null;
    }
    
    await _saveAll();
  }
}
