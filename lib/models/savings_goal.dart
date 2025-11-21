import 'package:hive/hive.dart';

part 'savings_goal.g.dart'; // This line is crucial for code generation

@HiveType(typeId: 2) // Unique typeId for SavingsGoal
class SavingsGoal {
  @HiveField(0)
  int? id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final double targetAmount;
  @HiveField(3)
  final double currentAmount;
  @HiveField(4)
  final String targetDate; // Stored as String (e.g., '2025-07-29')
  @HiveField(5)
  final String? description;
  @HiveField(6)
  final String? userEmail; // User identification

  SavingsGoal({
    this.id,
    required this.title,
    required this.targetAmount,
    this.currentAmount = 0.0,
    required this.targetDate,
    this.description,
    this.userEmail,
  });

  double get progress => currentAmount / targetAmount;
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'targetDate': targetDate,
      'description': description,
      'userEmail': userEmail,
    };
  }

  factory SavingsGoal.fromMap(Map<String, dynamic> map) {
    return SavingsGoal(
      id: map['id'],
      title: map['title'],
      targetAmount: map['targetAmount'],
      currentAmount: map['currentAmount'] ?? 0.0,
      targetDate: map['targetDate'],
      description: map['description'],
      userEmail: map['userEmail'],
    );
  }

  @override
  String toString() => 'SavingsGoal(id: $id, title: $title, targetAmount: $targetAmount, targetDate: $targetDate)';
}