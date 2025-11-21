import 'package:hive_flutter/hive_flutter.dart';
import '../models/expense.dart';
import '../models/budget.dart';
import '../models/savings_goal.dart';
import 'auth_service.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  final AuthService _authService = AuthService();

  // Hive boxes - these will be opened and ready after init() is called
  late Box<Expense> _expensesBox;
  late Box<Budget> _budgetsBox;
  late Box<SavingsGoal> _savingsGoalsBox;

  // Get current user's email for data filtering
  String? get _currentUserEmail => _authService.getCurrentUserEmail();
  // New initialization method for Hive
  Future<void> init() async {
    try {
      // Open the boxes. If a box doesn't exist, Hive creates it.
      _expensesBox = await Hive.openBox<Expense>('expenses'); // Box name 'expenses'
      _budgetsBox = await Hive.openBox<Budget>('budgets');     // Box name 'budgets'
      _savingsGoalsBox = await Hive.openBox<SavingsGoal>('savings_goals'); // Box name 'savings_goals'
    } catch (e) {
      // If there's a schema mismatch error, delete the old boxes and recreate them
      print('Error opening boxes: $e');
      print('Deleting old boxes and creating new ones...');
      
      await Hive.deleteBoxFromDisk('expenses');
      await Hive.deleteBoxFromDisk('budgets');
      await Hive.deleteBoxFromDisk('savings_goals');
      
      // Retry opening the boxes
      _expensesBox = await Hive.openBox<Expense>('expenses');
      _budgetsBox = await Hive.openBox<Budget>('budgets');
      _savingsGoalsBox = await Hive.openBox<SavingsGoal>('savings_goals');
    }
  }
  // Expense CRUD operations
  Future<int> insertExpense(Expense expense) async {
    // Hive's .add() method automatically assigns an auto-incrementing integer key.
    // We'll use this key as the 'id' for consistency with your model.
    final key = await _expensesBox.add(expense);
    // Create a new Expense object with the assigned ID and user email
    final newExpense = Expense(
      id: key,
      title: expense.title,
      amount: expense.amount,
      category: expense.category,
      date: expense.date,
      description: expense.description,
      userEmail: _currentUserEmail,
    );
    await _expensesBox.put(key, newExpense); // Update the entry with the ID
    return key;
  }

  Future<List<Expense>> getExpenses() async {
    // Hive returns an Iterable. Convert to List.
    // Filter by current user's email
    final expenses = _expensesBox.values
        .where((expense) => expense.userEmail == _currentUserEmail)
        .toList();
    // For sorting (like SQL's ORDER BY), you'll need to do it in Dart.
    // Assuming 'date' is in a sortable string format like 'YYYY-MM-DD'.
    expenses.sort((a, b) => b.date.compareTo(a.date)); // Sort by date descending
    return expenses;
  }

  Future<void> updateExpense(Expense expense) async {
    if (expense.id != null) {
      // Use the 'id' of the Expense object (which is the Hive key) to update
      // Hive's put() method will replace an existing entry if the key matches.
      await _expensesBox.put(expense.id!, expense);
    } else {
      // If an expense doesn't have an ID, it means it was never inserted or its ID was lost.
      // In a real app, you might throw an error or insert it as a new expense.
      print('Warning: Attempting to update an expense without an ID. Consider inserting it instead.');
    }
  }

  Future<void> deleteExpense(int id) async {
    // Delete by the Hive-assigned key (which is stored in your object's 'id' field)
    await _expensesBox.delete(id);
  }
  // Budget CRUD operations
  Future<int> insertBudget(Budget budget) async {
    final key = await _budgetsBox.add(budget);
    final newBudget = Budget(
      id: key,
      category: budget.category,
      amount: budget.amount,
      month: budget.month,
      spent: budget.spent,
      userEmail: _currentUserEmail,
    );
    await _budgetsBox.put(key, newBudget);
    return key;
  }

  Future<List<Budget>> getBudgets() async {
    // Filter by current user's email
    return _budgetsBox.values
        .where((budget) => budget.userEmail == _currentUserEmail)
        .toList();
  }

  Future<void> updateBudget(Budget budget) async {
    if (budget.id != null) {
      await _budgetsBox.put(budget.id!, budget);
    }
  }

  Future<void> deleteBudget(int id) async {
    await _budgetsBox.delete(id);
  }
  // Savings Goal CRUD operations
  Future<int> insertSavingsGoal(SavingsGoal goal) async {
    final key = await _savingsGoalsBox.add(goal);
    final newGoal = SavingsGoal(
      id: key,
      title: goal.title,
      targetAmount: goal.targetAmount,
      currentAmount: goal.currentAmount,
      targetDate: goal.targetDate,
      description: goal.description,
      userEmail: _currentUserEmail,
    );
    await _savingsGoalsBox.put(key, newGoal);
    return key;
  }

  Future<List<SavingsGoal>> getSavingsGoals() async {
    // Filter by current user's email
    return _savingsGoalsBox.values
        .where((goal) => goal.userEmail == _currentUserEmail)
        .toList();
  }

  Future<void> updateSavingsGoal(SavingsGoal goal) async {
    if (goal.id != null) {
      await _savingsGoalsBox.put(goal.id!, goal);
    }
  }

  Future<void> deleteSavingsGoal(int id) async {
    await _savingsGoalsBox.delete(id);
  }
}