import 'package:uuid/uuid.dart';

enum UserRole { student, admin }

class UserModel {
  String id;
  String name;
  String email;
  UserRole role;
  String branch;
  String year;
  String? photoPath; // profile photo
  List<String> resumePaths; // resume file paths
  String? contact;
  String? linkedin;
  String? github;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.branch,
    required this.year,
    this.photoPath,
    this.contact,
    this.linkedin,
    this.github,
    List<String>? resumePaths,
  }) : resumePaths = resumePaths ?? [];

  factory UserModel.createNew(String email) {
    return UserModel(
      id: Uuid().v4(),
      name: '',
      email: email,
      role: UserRole.student,
      branch: '',
      year: '',
    );
  }

  factory UserModel.createAdmin(String email) {
    return UserModel(
      id: Uuid().v4(),
      name: 'Admin',
      email: email,
      role: UserRole.admin,
      branch: '',
      year: '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role.toString(),
        'branch': branch,
        'year': year,
        'photoPath': photoPath,
        'resumePaths': resumePaths,
        'contact': contact,
        'linkedin': linkedin,
        'github': github,
      };

  factory UserModel.fromJson(Map<String, dynamic> j) {
    return UserModel(
      id: j['id'],
      name: j['name'],
      email: j['email'],
      role: j['role'].toString().contains('admin')
          ? UserRole.admin
          : UserRole.student,
      branch: j['branch'] ?? '',
      year: j['year'] ?? '',
      photoPath: j['photoPath'],
      resumePaths: List<String>.from(j['resumePaths'] ?? []),
      contact: j['contact'],
      linkedin: j['linkedin'],
      github: j['github'],
    );
  }
}
