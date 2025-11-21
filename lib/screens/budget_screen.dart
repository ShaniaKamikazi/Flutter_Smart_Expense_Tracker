import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../config/app_theme.dart';
import '../models/budget.dart';
import '../providers/expense_provider.dart';
import '../widgets/glassmorphism_card.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  _BudgetScreenState createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.secondaryColor,
              AppTheme.secondaryColor.withOpacity(0.7),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Budget Management',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.add, color: Colors.white),
                        onPressed: _isLoading ? null : () => _showAddBudgetDialog(context),
                      ),
                    ),
                  ],
                ),
              ),              // Content
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Consumer<ExpenseProvider>(
                        builder: (context, provider, child) {
                          if (provider.budgets.isEmpty) {
                            return _buildEmptyState();
                          }

                          return RefreshIndicator(
                            onRefresh: () async {
                              setState(() {
                                _isLoading = true;
                              });
                              try {
                                await provider.loadBudgets();
                                await provider.loadExpenses();
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Failed to refresh: $e'),
                                    backgroundColor: AppTheme.errorColor,
                                    duration: const Duration(seconds: 3),
                                  ),
                                );
                              } finally {
                                setState(() {
                                  _isLoading = false;
                                });
                              }
                            },
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: provider.budgets.length,
                              itemBuilder: (context, index) {
                                final budget = provider.budgets[index];
                                final spent = _calculateSpentAmount(provider, budget);

                                return _buildBudgetCard(budget, spent, provider);
                              },
                            ),
                          );
                        },
                      ),
                      if (_isLoading)
                        Container(
                          color: Colors.black26,
                          child: const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.secondaryColor),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.secondaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.account_balance_wallet_outlined,
              size: 64,
              color: AppTheme.secondaryColor,
            ),
          ),
          const SizedBox(height: 24),          Text(
            'No Budgets Set',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Create your first budget to start tracking your spending',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _isLoading ? null : () => _showAddBudgetDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Create Budget'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.secondaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
            ),
          ),
        ],
      ),
    );
  }  Widget _buildBudgetCard(Budget budget, double spent, ExpenseProvider provider) {
    final progress = budget.amount > 0 ? spent / budget.amount : 0.0;
    final remaining = budget.amount - spent;
    final categoryColor = _getCategoryColor(budget.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GlassmorphismCard(
        gradientStartColor: categoryColor,
        gradientEndColor: categoryColor.withOpacity(0.6),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _getCategoryColor(budget.category),
                              _getCategoryColor(budget.category).withOpacity(0.7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getCategoryIcon(budget.category),
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),                      Text(
                        budget.category,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textPrimary,
                        ),
                      ),
                    ],
                  ),                    PopupMenuButton(
                    icon: Icon(Icons.more_vert, color: Theme.of(context).textSecondary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showEditBudgetDialog(context, budget);
                      } else if (value == 'delete') {
                        _deleteBudget(provider, budget.id!);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20, color: AppTheme.primaryColor),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: AppTheme.errorColor),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: AppTheme.errorColor)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress > 1.0 ? 1.0 : progress,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progress > 1.0
                        ? AppTheme.errorColor
                        : progress > 0.8
                        ? AppTheme.warningColor
                        : progress > 0.6
                        ? AppTheme.accentColor
                        : AppTheme.secondaryColor,
                  ),
                  minHeight: 10,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Spent',
                        style: TextStyle(
                          color: Theme.of(context).textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),const SizedBox(height: 4),
                      Text(
                        '\$${spent.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: progress > 1.0 ? AppTheme.errorColor : Theme.of(context).textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Progress',
                        style: TextStyle(
                          color: Theme.of(context).textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(progress * 100).toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: progress > 1.0 ? AppTheme.errorColor : AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Budget',
                        style: TextStyle(
                          color: Theme.of(context).textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${budget.amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: remaining >= 0
                        ? [
                            AppTheme.secondaryColor.withOpacity(0.1),
                            AppTheme.secondaryColor.withOpacity(0.05),
                          ]
                        : [
                            AppTheme.errorColor.withOpacity(0.1),
                            AppTheme.errorColor.withOpacity(0.05),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      remaining >= 0 ? Icons.check_circle : Icons.warning_rounded,
                      color: remaining >= 0 ? AppTheme.secondaryColor : AppTheme.errorColor,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      remaining >= 0
                          ? 'Remaining: \$${remaining.toStringAsFixed(2)}'
                          : 'Over budget: \$${(-remaining).toStringAsFixed(2)}',
                      style: TextStyle(
                        color: remaining >= 0 ? AppTheme.secondaryColor : AppTheme.errorColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _calculateSpentAmount(ExpenseProvider provider, Budget budget) {
    final currentMonth = DateTime.now();
    DateTime budgetMonth;
    try {
      budgetMonth = DateFormat('yyyy-MM').parse(budget.month); // Parse 'yyyy-MM' format
      budgetMonth = DateTime(budgetMonth.year, budgetMonth.month, 1); // Set day to 1
    } catch (e) {
      print('Error parsing budget month: $e');
      budgetMonth = DateTime(currentMonth.year, currentMonth.month, 1); // Fallback
    }
    if (budgetMonth.year != currentMonth.year || budgetMonth.month != currentMonth.month) {
      return 0.0; // Return 0 if budget is not for current month
    }
    final monthExpenses = provider.getExpensesForMonth(currentMonth);
    return monthExpenses
        .where((expense) => expense.category == budget.category)
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  void _showAddBudgetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const BudgetDialog(),
    );
  }

  void _showEditBudgetDialog(BuildContext context, Budget budget) {
    showDialog(
      context: context,
      builder: (context) => BudgetDialog(budget: budget),
    );
  }

  void _deleteBudget(ExpenseProvider provider, int budgetId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Budget'),
        content: const Text('Are you sure you want to delete this budget?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              setState(() {
                _isLoading = true;
              });
              try {                await provider.deleteBudget(budgetId);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Budget deleted successfully'),
                    backgroundColor: AppTheme.errorColor,
                    duration: Duration(seconds: 2),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to delete budget: $e'),
                    backgroundColor: AppTheme.errorColor,
                    duration: const Duration(seconds: 3),
                  ),
                );
              } finally {
                setState(() {
                  _isLoading = false;
                });
              }
            },
            child: const Text('Delete', style: TextStyle(color: AppTheme.errorColor)),
          ),
        ],      ),
    );
  }

  Color _getCategoryColor(String category) {
    final colors = {
      'Food & Dining': AppTheme.warningColor,
      'Transportation': AppTheme.primaryColor,
      'Shopping': const Color(0xFFE91E63),
      'Entertainment': const Color(0xFF9C27B0),
      'Bills & Utilities': const Color(0xFF009688),
      'Education': AppTheme.secondaryColor,
      'Healthcare': AppTheme.errorColor,
      'Others': AppTheme.textSecondary,
    };
    return colors[category] ?? AppTheme.textSecondary;
  }

  IconData _getCategoryIcon(String category) {
    final icons = {
      'Food & Dining': Icons.restaurant,
      'Transportation': Icons.directions_car,
      'Shopping': Icons.shopping_bag,
      'Entertainment': Icons.movie,
      'Bills & Utilities': Icons.receipt_long,
      'Education': Icons.school,
      'Healthcare': Icons.local_hospital,
      'Others': Icons.category,
    };
    return icons[category] ?? Icons.category;
  }
}

class BudgetDialog extends StatefulWidget {
  final Budget? budget;

  const BudgetDialog({super.key, this.budget});

  @override
  _BudgetDialogState createState() => _BudgetDialogState();
}

class _BudgetDialogState extends State<BudgetDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  String _selectedCategory = 'Food & Dining';
  DateTime _selectedMonth = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.budget != null) {
      _amountController.text = widget.budget!.amount.toString();
      _selectedCategory = widget.budget!.category;
      try {
        _selectedMonth = DateFormat('yyyy-MM').parse(widget.budget!.month); // Parse 'yyyy-MM'
      } catch (e) {
        print('Error parsing budget month: $e');
        _selectedMonth = DateTime.now();
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context, listen: false);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Dialog Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.secondaryColor,
                    AppTheme.secondaryColor.withOpacity(0.8),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      widget.budget == null ? 'Add Budget' : 'Edit Budget',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Dialog Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [                      // Category Dropdown
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white.withOpacity(0.2)
                                : Colors.grey[300]!,
                          ),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          dropdownColor: Theme.of(context).colorScheme.surface,
                          decoration: InputDecoration(
                            labelText: 'Category',
                            labelStyle: TextStyle(color: Theme.of(context).textSecondary),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            prefixIcon: Icon(
                              _getCategoryIcon(_selectedCategory),
                              color: _getCategoryColor(_selectedCategory),
                            ),
                          ),
                          style: TextStyle(color: Theme.of(context).textPrimary),
                          items: provider.categories.map((category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Row(
                                children: [
                                  Icon(
                                    _getCategoryIcon(category),
                                    color: _getCategoryColor(category),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(category, style: TextStyle(color: Theme.of(context).textPrimary)),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: _isLoading ? null : (value) {
                            setState(() {
                              _selectedCategory = value!;
                            });
                          },
                          validator: (value) {
                            if (value == null || !provider.categories.contains(value)) {
                              return 'Please select a valid category';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 20),                      // Amount Field
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white.withOpacity(0.2)
                                : Colors.grey[300]!,
                          ),
                        ),
                        child: TextFormField(
                          controller: _amountController,
                          enabled: !_isLoading,
                          style: TextStyle(color: Theme.of(context).textPrimary),
                          decoration: InputDecoration(
                            labelText: 'Budget Amount',
                            labelStyle: TextStyle(color: Theme.of(context).textSecondary),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            prefixIcon: const Icon(Icons.attach_money_rounded, color: AppTheme.secondaryColor),
                            prefixText: '\$',
                            prefixStyle: TextStyle(color: Theme.of(context).textPrimary),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter an amount';
                            }
                            if (double.tryParse(value) == null || double.parse(value) <= 0) {
                              return 'Please enter a valid amount';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 20),                      // Month Selector
                      InkWell(
                        onTap: _isLoading ? null : _selectMonth,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            border: Border.all(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white.withOpacity(0.2)
                                  : Colors.grey[300]!,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.secondaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.calendar_month_rounded,
                                  color: AppTheme.secondaryColor,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Budget Month',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(context).textSecondary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      DateFormat('MMMM yyyy').format(_selectedMonth),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(context).textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Theme.of(context).textSecondary),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),            // Dialog Actions
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF1F1F1F)
                    : Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveBudget,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.secondaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            widget.budget == null ? 'Add Budget' : 'Update',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Future<void> _selectMonth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).brightness == Brightness.dark
                ? ColorScheme.dark(
                    primary: AppTheme.secondaryColor,
                    onPrimary: Colors.white,
                    surface: const Color(0xFF1A1A1A),
                    onSurface: Colors.white,
                    background: const Color(0xFF121212),
                    onBackground: Colors.white,
                  )
                : ColorScheme.light(
                    primary: AppTheme.secondaryColor,
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: AppTheme.textPrimary,
                  ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.secondaryColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedMonth) {
      setState(() {
        _selectedMonth = DateTime(picked.year, picked.month); // Set to first of month
      });
    }
  }

  Future<void> _saveBudget() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      final provider = Provider.of<ExpenseProvider>(context, listen: false);
      final amount = double.parse(_amountController.text);
      final month = DateFormat('yyyy-MM').format(_selectedMonth); // Ensure 'yyyy-MM' format

      try {
        if (widget.budget == null) {
          final budget = Budget(
            category: _selectedCategory,
            amount: amount,
            month: month,
          );          await provider.addBudget(budget);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Budget added successfully!'),
              backgroundColor: AppTheme.secondaryColor,
              duration: Duration(seconds: 2),
            ),
          );        } else {
          final updatedBudget = Budget(
            id: widget.budget!.id,
            category: _selectedCategory,
            amount: amount,
            month: month,
            spent: widget.budget!.spent,
            userEmail: widget.budget!.userEmail,
          );
          await provider.updateBudget(updatedBudget);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Budget updated successfully!'),
              backgroundColor: AppTheme.primaryColor,
              duration: Duration(seconds: 2),
            ),
          );
        }
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save budget: $e'),
            backgroundColor: AppTheme.errorColor,
            duration: const Duration(seconds: 3),
          ),
        );
      }finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  Color _getCategoryColor(String category) {
    final colors = {
      'Food & Dining': AppTheme.warningColor,
      'Transportation': AppTheme.primaryColor,
      'Shopping': const Color(0xFFE91E63),
      'Entertainment': const Color(0xFF9C27B0),
      'Bills & Utilities': const Color(0xFF009688),
      'Education': AppTheme.secondaryColor,
      'Healthcare': AppTheme.errorColor,
      'Others': AppTheme.textSecondary,
    };
    return colors[category] ?? AppTheme.textSecondary;
  }

  IconData _getCategoryIcon(String category) {
    final icons = {
      'Food & Dining': Icons.restaurant,
      'Transportation': Icons.directions_car,
      'Shopping': Icons.shopping_bag,
      'Entertainment': Icons.movie,
      'Bills & Utilities': Icons.receipt_long,
      'Education': Icons.school,
      'Healthcare': Icons.local_hospital,
      'Others': Icons.category,
    };
    return icons[category] ?? Icons.category;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }
}