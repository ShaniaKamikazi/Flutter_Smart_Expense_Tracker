import 'package:hive/hive.dart';

part 'budget.g.dart'; // This line is crucial for code generation

@HiveType(typeId: 1) // Unique typeId for Budget
class Budget {
  @HiveField(0)
  int? id;
  @HiveField(1)
  final String category;
  @HiveField(2)
  final double amount;
  @HiveField(3)
  final String month; // Stored as String (e.g., '2025-07')
  @HiveField(4)
  final double spent;
  @HiveField(5)
  final String? userEmail; // User identification

  Budget({
    this.id,
    required this.category,
    required this.amount,
    required this.month,
    this.spent = 0.0,
    this.userEmail,
  });
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'amount': amount,
      'month': month,
      'spent': spent,
      'userEmail': userEmail,
        };
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'],
      category: map['category'],
      amount: map['amount'],
      month: map['month'],
      spent: map['spent'] ?? 0.0,
            userEmail: map['userEmail'],
    );
  }

  @override
  String toString() => 'Budget(id: $id, category: $category, amount: $amount, month: $month)';
}