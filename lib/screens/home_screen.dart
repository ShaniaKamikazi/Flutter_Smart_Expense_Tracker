import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../config/app_theme.dart';
import '../providers/expense_provider.dart';
import '../widgets/glassmorphism_card.dart';
import 'add_expense_screen.dart';
import 'add_savings_goal_screen.dart';
import 'budget_screen.dart';
import 'reports_screen.dart';
import 'savings_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _isLoading = true;

  final List<Widget> _screens = [
    const DashboardTab(),
    const ExpensesTab(),
    const BudgetScreen(),
    const SavingsScreen(),
    const ReportsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() {
        _isLoading = true;
      });
      try {
        await Provider.of<ExpenseProvider>(context, listen: false).initialize();
      } catch (e) {
        print('Error initializing ExpenseProvider: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to initialize app: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _screens[_currentIndex],
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                ),
              ),
            ),        ],
      ),        bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1A1A1A)
              : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF1A1A1A).withOpacity(0.95)
                    : Colors.white.withOpacity(0.95),
              ),
              child: SafeArea(                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildNavItem(0, Icons.home_outlined, 'Home'),
                        _buildNavItem(1, Icons.receipt_long_outlined, 'Expenses'),
                        _buildNavItem(2, Icons.account_balance_wallet_outlined, 'Budget'),
                        _buildNavItem(3, Icons.savings_outlined, 'Savings'),
                        _buildNavItem(4, Icons.analytics_outlined, 'Reports'),
                      ],
                    ),
                  ),
              ),
            ),
          ),
        ),
      ),      floatingActionButton: _currentIndex == 1          ? FloatingActionButton.extended(            heroTag: 'addExpense',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddExpenseScreen()),
              ),
              backgroundColor: AppTheme.primaryColor,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Expense'),
            )
          : null,
    );
  }
  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        tween: Tween(begin: 0.0, end: isSelected ? 1.0 : 0.0),
        builder: (context, value, child) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Color.lerp(
                Colors.transparent,
                isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF0F0F5),
                value,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: Color.lerp(
                    isDark ? const Color(0xFF808080) : const Color(0xFF8E8E93),
                    AppTheme.primaryColor,
                    value,
                  ),
                ),
                const SizedBox(height: 4),
                // Indicator dot
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Color.lerp(
                      Colors.transparent,
                      AppTheme.primaryColor,
                      value,
                    ),
                    shape: BoxShape.circle,
                  ),
                ),              ],
            ),
          );
        },
      ),
    );
  }
}

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, child) {
        final currentMonth = DateTime.now();
        final monthExpenses = provider.getExpensesForMonth(currentMonth);        final totalThisMonth = monthExpenses.fold(0.0, (sum, expense) => sum + expense.amount);        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Custom App Bar
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dashboard',
                              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('EEEE, MMM d').format(DateTime.now()),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),                        const Spacer(),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: Theme.of(context).brightness == Brightness.dark
                                  ? [
                                      Colors.white.withOpacity(0.1),
                                      Colors.white.withOpacity(0.05),
                                    ]
                                  : [
                                      Colors.white,
                                      Colors.white,
                                    ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              width: 2,
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? AppTheme.primaryColor.withOpacity(0.5)
                                  : AppTheme.primaryColor.withOpacity(0.3),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryColor.withOpacity(0.2),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.person_outline_rounded),
                            color: AppTheme.primaryColor,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ProfileScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Content
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        try {
                          await provider.loadExpenses();
                          await provider.loadBudgets();
                          await provider.loadSavingsGoals();
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to refresh: $e'),
                              backgroundColor: AppTheme.errorColor,
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        }
                      },
                      color: AppTheme.primaryColor,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Summary Cards with Glassmorphism
                            Row(
                              children: [
                                Expanded(
                                  child: _buildGlassSummaryCard(
                                    context,
                                    'This Month',
                                    '\$${totalThisMonth.toStringAsFixed(2)}',
                                    Icons.calendar_month_rounded,
                                    AppTheme.primaryColor,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildGlassSummaryCard(
                                    context,
                                    'Total',
                                    '\$${provider.getTotalExpenses().toStringAsFixed(2)}',
                                    Icons.receipt_rounded,
                                    AppTheme.secondaryColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildGlassSummaryCard(
                                    context,
                                    'Budgets',
                                    '${provider.budgets.length}',
                                    Icons.account_balance_wallet_rounded,
                                    AppTheme.warningColor,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildGlassSummaryCard(
                                    context,
                                    'Goals',
                                    '${provider.savingsGoals.length}',
                                    Icons.savings_rounded,
                                    AppTheme.accentColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                            
                            // Recent Expenses Section
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [                                Text(
                                  'Recent Expenses',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).textPrimary,
                                  ),
                                ),
                                if (provider.expenses.isNotEmpty)
                                  TextButton(
                                    onPressed: () {
                                      // Switch to expenses tab
                                    },
                                    child: const Text('View All'),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                              if (provider.expenses.isEmpty)
                              GlassmorphismCard(
                                padding: const EdgeInsets.all(40),
                                backgroundColor: Colors.white,
                                opacity: 1.0,
                                child: Column(
                                  children: [                                  Icon(
                                      Icons.receipt_long_outlined,
                                      size: 64,
                                      color: Theme.of(context).textSecondary.withOpacity(0.5),
                                    ),
                                    const SizedBox(height: 16),                                    Text(
                                      'No expenses yet',
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        color: Theme.of(context).textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Start tracking by adding your first expense',
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              )                            else
                              ...provider.expenses.take(5).map(
                                (expense) => GlassmorphismCard(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
                                  backgroundColor: Colors.white,
                                  opacity: 1.0,
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: _getCategoryColor(expense.category).withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          _getCategoryIcon(expense.category),
                                          color: _getCategoryColor(expense.category),
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              expense.title,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Theme.of(context).textPrimary,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${expense.category} • ${expense.date}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Theme.of(context).textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        '\$${expense.amount.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  Widget _buildGlassSummaryCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color,
            color.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
  Color _getCategoryColor(String category) {
    final colors = {
      'Food & Dining': AppTheme.warningColor,
      'Transportation': AppTheme.primaryColor,
      'Shopping': AppTheme.accentColor,
      'Entertainment': Color(0xFF9B59B6),
      'Bills & Utilities': AppTheme.secondaryColor,
      'Education': Color(0xFF27AE60),
      'Healthcare': AppTheme.errorColor,
      'Others': AppTheme.textSecondary,
    };
    return colors[category] ?? AppTheme.textSecondary;
  }

  IconData _getCategoryIcon(String category) {
    final icons = {
      'Food & Dining': Icons.restaurant_rounded,
      'Transportation': Icons.directions_car_rounded,
      'Shopping': Icons.shopping_bag_rounded,
      'Entertainment': Icons.movie_rounded,
      'Bills & Utilities': Icons.receipt_long_rounded,
      'Education': Icons.school_rounded,
      'Healthcare': Icons.local_hospital_rounded,
      'Others': Icons.category_rounded,
    };
    return icons[category] ?? Icons.category_rounded;
  }
}

class ExpensesTab extends StatefulWidget {
  const ExpensesTab({super.key});

  @override
  State<ExpensesTab> createState() => _ExpensesTabState();
}

class _ExpensesTabState extends State<ExpensesTab> {
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, child) {
        // Filter expenses based on selected category
        final filteredExpenses = _selectedCategory == null
            ? provider.expenses
            : provider.expenses
                .where((expense) => expense.category == _selectedCategory)
                .toList();        return Scaffold(
          backgroundColor: AppTheme.primaryColor,
          body: SafeArea(
            child: Column(
              children: [
                // Header with Gradient
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.primaryColor,
                        AppTheme.primaryColor.withOpacity(0.8),
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        const Text(
                          'Expenses',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: Icon(
                              _selectedCategory == null
                                  ? Icons.filter_list_rounded
                                  : Icons.filter_list_off_rounded,
                              color: Colors.white,
                            ),
                            onPressed: () => _showFilterDialog(context, provider),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),                // White Content Area with Rounded Top Corners
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                      child: RefreshIndicator(
                    onRefresh: () async {
                      try {
                        await provider.loadExpenses();
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to refresh: $e'),
                            backgroundColor: AppTheme.errorColor,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }
                    },
                    color: AppTheme.primaryColor,
                    child: filteredExpenses.isEmpty
                        ? Center(
                            child: GlassmorphismCard(
                              margin: const EdgeInsets.all(24),
                              padding: const EdgeInsets.all(40),
                              backgroundColor: Colors.white,
                              opacity: 1.0,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [                                  Icon(
                                    Icons.receipt_long_outlined,
                                    size: 80,
                                    color: Theme.of(context).textSecondary.withOpacity(0.5),
                                  ),
                                  const SizedBox(height: 24),                                  Text(
                                    _selectedCategory == null 
                                        ? 'No Expenses Yet'
                                        : 'No Expenses in $_selectedCategory',
                                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    _selectedCategory == null
                                        ? 'Start tracking your expenses\nby adding your first expense'
                                        : 'Try a different category filter',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(20),
                            itemCount: filteredExpenses.length,
                            itemBuilder: (context, index) {
                              final expense = filteredExpenses[index];
                              return GlassmorphismCard(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                backgroundColor: Colors.white,
                                opacity: 1.0,                                child: InkWell(                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AddExpenseScreen(expense: expense),
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: _getCategoryColor(expense.category).withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          _getCategoryIcon(expense.category),
                                          color: _getCategoryColor(expense.category),
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [                                            Text(
                                              expense.title,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Theme.of(context).textPrimary,
                                              ),
                                            ),                                            const SizedBox(height: 4),
                                            Text(
                                              '${expense.category} • ${_formatDate(expense.date)}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Theme.of(context).textSecondary,
                                              ),
                                            ),                                            if (expense.description != null && expense.description!.isNotEmpty) ...[
                                              const SizedBox(height: 4),
                                              Text(
                                                expense.description!,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Theme.of(context).textSecondary.withOpacity(0.7),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        '\$${expense.amount.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.errorColor,
                                        ),                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFilterDialog(BuildContext context, ExpenseProvider provider) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Dialog Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryColor,
                      AppTheme.primaryColor.withOpacity(0.8),
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
                        Icons.filter_list_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Filter by Category',
                        style: TextStyle(
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

              // Filter Options
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [                    // All Categories Option
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _selectedCategory == null
                              ? AppTheme.primaryColor.withOpacity(0.2)
                              : Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white.withOpacity(0.05)
                                  : Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                          border: _selectedCategory == null
                              ? Border.all(
                                  color: AppTheme.primaryColor,
                                  width: 2,
                                )
                              : null,
                        ),
                        child: Icon(
                          Icons.all_inclusive_rounded,
                          color: _selectedCategory == null
                              ? AppTheme.primaryColor
                              : Theme.of(context).textSecondary,
                        ),
                      ),
                      title: Text(
                        'All Categories',
                        style: TextStyle(
                          color: Theme.of(context).textPrimary,
                          fontWeight: _selectedCategory == null ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      trailing: _selectedCategory == null
                          ? const Icon(Icons.check_circle, color: AppTheme.primaryColor)
                          : null,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onTap: () {
                        setState(() {
                          _selectedCategory = null;
                        });
                        Navigator.pop(context);
                      },
                    ),
                    const Divider(),                    // Category Options
                    ...provider.categories.map((category) => ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: _getCategoryColor(category).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: _selectedCategory == category
                                  ? Border.all(
                                      color: _getCategoryColor(category),
                                      width: 2,
                                    )
                                  : null,
                            ),
                            child: Icon(
                              _getCategoryIcon(category),
                              color: _getCategoryColor(category),
                            ),
                          ),
                          title: Text(
                            category,
                            style: TextStyle(
                              color: Theme.of(context).textPrimary,
                              fontWeight: _selectedCategory == category ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          trailing: _selectedCategory == category
                              ? Icon(
                                  Icons.check_circle,
                                  color: _getCategoryColor(category),
                                )
                              : null,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          onTap: () {
                            setState(() {
                              _selectedCategory = category;
                            });
                            Navigator.pop(context);
                          },
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    final colors = {
      'Food & Dining': AppTheme.warningColor,
      'Transportation': AppTheme.primaryColor,
      'Shopping': AppTheme.accentColor,
      'Entertainment': Color(0xFF9B59B6),
      'Bills & Utilities': AppTheme.secondaryColor,
      'Education': Color(0xFF27AE60),
      'Healthcare': AppTheme.errorColor,
      'Others': AppTheme.textSecondary,
    };
    return colors[category] ?? AppTheme.textSecondary;
  }

  IconData _getCategoryIcon(String category) {
    final icons = {
      'Food & Dining': Icons.restaurant_rounded,
      'Transportation': Icons.directions_car_rounded,
      'Shopping': Icons.shopping_bag_rounded,
      'Entertainment': Icons.movie_rounded,
      'Bills & Utilities': Icons.receipt_long_rounded,
      'Education': Icons.school_rounded,
      'Healthcare': Icons.local_hospital_rounded,
      'Others': Icons.category_rounded,
    };
    return icons[category] ?? Icons.category_rounded;
  }

  String _formatDate(String date) {
    try {
      final parsedDate = DateFormat('yyyy-MM-dd').parse(date);
      return DateFormat('MMM d, yyyy').format(parsedDate);
    } catch (e) {
      return date;    }
  }
}
