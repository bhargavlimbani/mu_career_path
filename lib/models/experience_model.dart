import 'package:uuid/uuid.dart';

class ExperienceModel {
  String id;
  String studentId;
  String studentName;
  String companyName;
  String role;
  String package;
  String tips;
  bool approved;
  DateTime timestamp;

  ExperienceModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.companyName,
    required this.role,
    required this.package,
    required this.tips,
    this.approved = false,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory ExperienceModel.create({
    required String studentId,
    required String studentName,
    required String companyName,
    required String role,
    required String package,
    required String tips,
  }) {
    return ExperienceModel(
      id: Uuid().v4(),
      studentId: studentId,
      studentName: studentName,
      companyName: companyName,
      role: role,
      package: package,
      tips: tips,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'studentId': studentId,
        'studentName': studentName,
        'companyName': companyName,
        'role': role,
        'package': package,
        'tips': tips,
        'approved': approved,
        'timestamp': timestamp.toIso8601String(),
      };

  factory ExperienceModel.fromJson(Map<String, dynamic> j) {
    return ExperienceModel(
      id: j['id'],
      studentId: j['studentId'],
      studentName: j['studentName'],
      companyName: j['companyName'],
      role: j['role'],
      package: j['package'],
      tips: j['tips'],
      approved: j['approved'] ?? false,
      timestamp: DateTime.parse(j['timestamp']),
    );
  }
}
