import 'package:hive/hive.dart';

part 'expense.g.dart'; // This line is crucial for code generation

@HiveType(typeId: 0) // Assign a unique typeId for each model (0-223)
class Expense {
  @HiveField(0)
  int? id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final double amount;
  @HiveField(3)
  final String category;
  @HiveField(4)
  final String date; // Stored as String (e.g., '2025-07-29')
  @HiveField(5)
  final String? description;
  @HiveField(6)
  final String? userEmail; // User identification

  Expense({
    this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.description,
    this.userEmail,  });

  // You can keep toMap and fromMap if you use them elsewhere, but Hive will use its generated adapters
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'date': date,
      'description': description,
      'userEmail': userEmail,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      category: map['category'],
      date: map['date'],
      description: map['description'],
      userEmail: map['userEmail'],
    );
  }

  @override
  String toString() => 'Expense(id: $id, title: $title, amount: $amount, date: $date)';
}