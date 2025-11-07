import 'package:uuid/uuid.dart';

class CompanyModel {
  String id;
  String name;
  String description;
  bool allowedForUnplaced;

  CompanyModel({
    required this.id,
    required this.name,
    required this.description,
    required this.allowedForUnplaced,
  });

  factory CompanyModel.create({required String name, required String description, bool allowed = false}) {
    return CompanyModel(id: Uuid().v4(), name: name, description: description, allowedForUnplaced: allowed);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'allowedForUnplaced': allowedForUnplaced,
      };

  factory CompanyModel.fromJson(Map<String, dynamic> j) {
    return CompanyModel(
      id: j['id'],
      name: j['name'],
      description: j['description'],
      allowedForUnplaced: j['allowedForUnplaced'] ?? false,
    );
  }
}
