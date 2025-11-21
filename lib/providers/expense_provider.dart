import 'package:flutter/foundation.dart';
import '../models/expense.dart';
import '../models/budget.dart';
import '../models/savings_goal.dart';
import '../services/database_helper.dart';
import '../services/notification_service.dart';

class ExpenseProvider with ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final NotificationService _notificationService = NotificationService();

  List<Expense> _expenses = [];
  List<Budget> _budgets = [];
  List<SavingsGoal> _savingsGoals = [];

  List<Expense> get expenses => _expenses;
  List<Budget> get budgets => _budgets;
  List<SavingsGoal> get savingsGoals => _savingsGoals;

  // Expense categories
  final List<String> categories = [
    'Food & Dining',
    'Transportation',
    'Shopping',
    'Entertainment',
    'Bills & Utilities',
    'Education',
    'Healthcare',
    'Others',
  ];

  // Initialize provider
  Future<void> initialize() async {
    try {
      await _notificationService.initialize();
      await loadExpenses();
      await loadBudgets();
      await loadSavingsGoals();
    } catch (e) {
      print('Error initializing provider: $e');
      rethrow; // Allow caller to handle initialization errors
    }
  }

  // Expense methods
  Future<void> loadExpenses() async {
    try {
      _expenses = await _databaseHelper.getExpenses();
      notifyListeners();
    } catch (e) {
      print('Error loading expenses: $e');
      rethrow;
    }
  }

  Future<void> addExpense(Expense expense) async {
    try {
      await _databaseHelper.insertExpense(expense);
      await loadExpenses();
      await _checkBudgetAlerts(expense);
    } catch (e) {
      print('Error adding expense: $e');
      rethrow;
    }
  }

  Future<void> updateExpense(Expense expense) async {
    try {
      await _databaseHelper.updateExpense(expense);
      await loadExpenses();
    } catch (e) {
      print('Error updating expense: $e');
      rethrow;
    }
  }

  Future<void> deleteExpense(int id) async {
    try {
      await _databaseHelper.deleteExpense(id);
      await loadExpenses();
    } catch (e) {
      print('Error deleting expense: $e');
      rethrow;
    }
  }

  // Budget methods
  Future<void> loadBudgets() async {
    try {
      _budgets = await _databaseHelper.getBudgets();
      notifyListeners();
    } catch (e) {
      print('Error loading budgets: $e');
      rethrow;
    }
  }

  Future<void> addBudget(Budget budget) async {
    try {
      await _databaseHelper.insertBudget(budget);
      await loadBudgets();
    } catch (e) {
      print('Error adding budget: $e');
      rethrow;
    }
  }

  Future<void> updateBudget(Budget budget) async {
    try {
      await _databaseHelper.updateBudget(budget);
      await loadBudgets();
    } catch (e) {
      print('Error updating budget: $e');
      rethrow;
    }
  }

  Future<void> deleteBudget(int id) async {
    try {
      await _databaseHelper.deleteBudget(id);
      await loadBudgets();
    } catch (e) {
      print('Error deleting budget: $e');
      rethrow;
    }
  }

  // Savings Goal methods
  Future<void> loadSavingsGoals() async {
    try {
      _savingsGoals = await _databaseHelper.getSavingsGoals();
      notifyListeners();
    } catch (e) {
      print('Error loading savings goals: $e');
      rethrow;
    }
  }

  Future<void> addSavingsGoal(SavingsGoal goal) async {
    try {
      await _databaseHelper.insertSavingsGoal(goal);
      await loadSavingsGoals();
    } catch (e) {
      print('Error adding savings goal: $e');
      rethrow;
    }
  }

  Future<void> updateSavingsGoal(SavingsGoal goal) async {
    try {
      await _databaseHelper.updateSavingsGoal(goal);
      await loadSavingsGoals();
    } catch (e) {
      print('Error updating savings goal: $e');
      rethrow;
    }
  }

  Future<void> deleteSavingsGoal(int id) async {
    try {
      await _databaseHelper.deleteSavingsGoal(id);
      await loadSavingsGoals();
    } catch (e) {
      print('Error deleting savings goal: $e');
      rethrow;
    }
  }

  // Analytics methods
  double getTotalExpenses() {
    return _expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  double getTotalExpensesForMonth(DateTime month) {
    final monthExpenses = getExpensesForMonth(month);
    return monthExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  Map<String, double> getExpensesByCategory() {
    Map<String, double> categoryTotals = {};
    for (var expense in _expenses) {
      categoryTotals[expense.category] = (categoryTotals[expense.category] ?? 0) + expense.amount;
    }
    return categoryTotals;
  }

  List<Expense> getExpensesForMonth(DateTime month) {
    return _expenses.where((expense) {
      final expenseDate = DateTime.parse(expense.date); // Parse String to DateTime
      return expenseDate.year == month.year && expenseDate.month == month.month;
    }).toList();
  }

  double getBudgetUtilization(String category) {
    final budget = _budgets.firstWhere(
          (b) => b.category == category,
      orElse: () => Budget(category: category, amount: 0, month: DateTime.now().toIso8601String()),
    );

    if (budget.amount == 0) return 0.0;

    final currentMonth = DateTime.now();
    final monthExpenses = getExpensesForMonth(currentMonth);
    final categoryExpenses = monthExpenses
        .where((expense) => expense.category == category)
        .fold(0.0, (sum, expense) => sum + expense.amount);

    return categoryExpenses / budget.amount;
  }

  Future<void> _checkBudgetAlerts(Expense expense) async {
    try {
      final budget = _budgets.firstWhere(
            (b) => b.category == expense.category,
        orElse: () => Budget(category: expense.category, amount: 0, month: DateTime.now().toIso8601String()),
      );

      if (budget.amount > 0) {
        final utilization = getBudgetUtilization(expense.category);

        if (utilization >= 0.8 && utilization < 1.0) {
          await _notificationService.showBudgetWarning(
            expense.category,
            (utilization * 100).toInt(),
          );
        } else if (utilization >= 1.0) {
          await _notificationService.showBudgetExceeded(
            expense.category,
            (utilization * 100).toInt(),
          );
        }
      }
    } catch (e) {
      print('Error checking budget alerts: $e');
    }
  }
}