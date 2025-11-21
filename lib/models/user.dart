import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 3)
class User extends HiveObject {
  @HiveField(0)
  String email;

  @HiveField(1)
  String password; // In production, this should be hashed

  @HiveField(2)
  String name;

  @HiveField(3)
  DateTime createdAt;

  @HiveField(4)
  DateTime? lastLogin;

  @HiveField(5)
  String? phoneNumber;

  User({
    required this.email,
    required this.password,
    required this.name,
    required this.createdAt,
    this.lastLogin,
    this.phoneNumber,
  });

  // Helper method to check password
  bool checkPassword(String inputPassword) {
    return password == inputPassword;
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
      'phoneNumber': phoneNumber,
    };
  }

  // Create from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json['email'] as String,
      password: json['password'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLogin: json['lastLogin'] != null
          ? DateTime.parse(json['lastLogin'] as String)
          : null,
      phoneNumber: json['phoneNumber'] as String?,
    );
  }
}
