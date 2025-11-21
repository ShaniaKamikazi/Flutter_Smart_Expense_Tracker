import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../config/app_theme.dart';
import '../models/savings_goal.dart';
import '../providers/expense_provider.dart';
import '../widgets/glassmorphism_card.dart';

class SavingsScreen extends StatefulWidget {
  const SavingsScreen({super.key});

  @override
  _SavingsScreenState createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() {
        _isLoading = true;
      });
      try {        await Provider.of<ExpenseProvider>(context, listen: false).loadSavingsGoals();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load savings goals: $e'),
            backgroundColor: AppTheme.errorColor,
            duration: const Duration(seconds: 3),
          ),
        );
      }finally {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: AppTheme.primaryColor,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar - Purple
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Savings Goals',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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
                          if (provider.savingsGoals.isEmpty) {
                            return _buildEmptyState(context, provider);
                          }
                          return RefreshIndicator(
                            onRefresh: () async {
                              setState(() {
                                _isLoading = true;
                              });
                              try {
                                await provider.loadSavingsGoals();
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
                              itemCount: provider.savingsGoals.length,
                              itemBuilder: (context, index) {
                                final goal = provider.savingsGoals[index];
                                return _buildSavingsGoalCard(goal, provider);
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
                              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),        ),
      ),      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: FloatingActionButton.extended(
          heroTag: 'addSavingsGoal',
          onPressed: _isLoading ? null : () => _showAddGoalDialog(context),
          backgroundColor: AppTheme.primaryColor,
          icon: const Icon(Icons.add),
          label: const Text('Add Goal'),
          elevation: 6,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
  Widget _buildEmptyState(BuildContext context, ExpenseProvider provider) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _isLoading = true;
        });
        try {
          await provider.loadSavingsGoals();
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
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height - kToolbarHeight - kBottomNavigationBarHeight,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.savings_outlined,
                    size: 64,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 24),                Text(
                  'No Savings Goals',
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
                    'Create your first savings goal to start building your future',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildSavingsGoalCard(SavingsGoal goal, ExpenseProvider provider) {
    final progress = goal.progress;
    final remaining = goal.targetAmount - goal.currentAmount;
    int daysLeft;
    try {
      final parsedTargetDate = DateFormat('yyyy-MM-dd').parse(goal.targetDate);
      daysLeft = parsedTargetDate.difference(DateTime.now()).inDays;
    } catch (e) {
      print('Error parsing targetDate: $e');      daysLeft = 0; // Fallback
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GlassmorphismCard(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [                        Text(
                          goal.title,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textPrimary,
                          ),
                        ),
                        if (goal.description != null && goal.description!.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            goal.description!,
                            style: TextStyle(
                              color: Theme.of(context).textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ],
                    ),                  ),
                  PopupMenuButton(
                    icon: Icon(Icons.more_vert, color: Theme.of(context).textSecondary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onSelected: (value) {
                      if (value == 'add_money') {
                        _showAddMoneyDialog(context, goal);
                      } else if (value == 'edit') {
                        _showEditGoalDialog(context, goal);
                      } else if (value == 'delete') {
                        _deleteGoal(provider, goal.id!);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'add_money',
                        child: Row(
                          children: [
                            Icon(Icons.add_circle, size: 20, color: AppTheme.secondaryColor),
                            SizedBox(width: 8),
                            Text('Add Money'),
                          ],
                        ),
                      ),
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
              Row(
                children: [
                  SizedBox(
                    width: 90,
                    height: 90,
                    child: Stack(
                      children: [
                        SizedBox(
                          width: 90,
                          height: 90,
                          child: CircularProgressIndicator(                            value: progress > 1.0 ? 1.0 : progress,
                            strokeWidth: 8,
                            backgroundColor: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white.withOpacity(0.1)
                                : Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              progress >= 1.0
                                  ? AppTheme.secondaryColor
                                  : progress > 0.7
                                  ? AppTheme.primaryColor
                                  : progress > 0.3
                                  ? AppTheme.warningColor
                                  : AppTheme.errorColor,
                            ),
                          ),
                        ),
                        Center(                          child: Text(
                            '${(progress * 100).toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Theme.of(context).textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,                          children: [
                            Text(
                              'Saved',
                              style: TextStyle(
                                color: Theme.of(context).textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'Target',
                              style: TextStyle(
                                color: Theme.of(context).textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '\$${goal.currentAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.secondaryColor,
                              ),
                            ),                            Text(
                              '\$${goal.targetAmount.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),                          child: LinearProgressIndicator(
                            value: progress > 1.0 ? 1.0 : progress,
                            backgroundColor: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white.withOpacity(0.1)
                                : Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              progress >= 1.0
                                  ? AppTheme.secondaryColor
                                  : progress > 0.7
                                  ? AppTheme.primaryColor
                                  : progress > 0.3
                                  ? AppTheme.warningColor
                                  : AppTheme.errorColor,
                            ),
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryColor.withOpacity(0.1),
                      AppTheme.primaryColor.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [                        Text(
                          remaining > 0 ? 'Remaining' : 'Goal Achieved! 🎉',
                          style: TextStyle(
                            color: remaining > 0 ? Theme.of(context).textSecondary : AppTheme.secondaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (remaining > 0)
                          Text(
                            '\$${remaining.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.warningColor,
                            ),
                          ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [                        Text(
                          daysLeft > 0 ? 'Days Left' : daysLeft == 0 ? 'Due Today' : 'Overdue',
                          style: TextStyle(
                            color: Theme.of(context).textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          daysLeft > 0 ? '$daysLeft' : daysLeft == 0 ? 'Today' : '${-daysLeft} days',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: daysLeft > 0 ? AppTheme.primaryColor : AppTheme.errorColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Theme.of(context).textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    'Target Date: ${_formatDate(goal.targetDate)}',
                    style: TextStyle(
                      color: Theme.of(context).textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              if (remaining > 0) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showAddMoneyDialog(context, goal),
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('Add Money'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.secondaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String date) {
    try {
      final parsedDate = DateFormat('yyyy-MM-dd').parse(date);
      return DateFormat('MMM dd, yyyy').format(parsedDate);
    } catch (e) {
      print('Error parsing date: $e');
      return date; // Fallback to raw string
    }
  }

  void _showAddGoalDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const SavingsGoalDialog(),
    );
  }

  void _showEditGoalDialog(BuildContext context, SavingsGoal goal) {
    showDialog(
      context: context,
      builder: (context) => SavingsGoalDialog(goal: goal),
    );
  }

  void _showAddMoneyDialog(BuildContext context, SavingsGoal goal) {
    showDialog(
      context: context,
      builder: (context) => AddMoneyDialog(goal: goal),
    );
  }

  void _deleteGoal(ExpenseProvider provider, int goalId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Savings Goal'),
        content: const Text('Are you sure you want to delete this savings goal?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              setState(() {
                _isLoading = true;
              });              try {
                await provider.deleteSavingsGoal(goalId);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Savings goal deleted successfully'),
                    backgroundColor: AppTheme.errorColor,
                    duration: Duration(seconds: 3),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to delete savings goal: $e'),
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
        ],
      ),
    );
  }
}

class SavingsGoalDialog extends StatefulWidget {
  final SavingsGoal? goal;

  const SavingsGoalDialog({super.key, this.goal});

  @override
  _SavingsGoalDialogState createState() => _SavingsGoalDialogState();
}

class _SavingsGoalDialogState extends State<SavingsGoalDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _targetDate = DateTime.now().add(const Duration(days: 365));
  bool _isLoading = false; // Added _isLoading for dialog

  @override
  void initState() {
    super.initState();
    if (widget.goal != null) {
      _titleController.text = widget.goal!.title;
      _targetAmountController.text = widget.goal!.targetAmount.toString();
      _descriptionController.text = widget.goal!.description ?? '';
      try {
        _targetDate = DateFormat('yyyy-MM-dd').parse(widget.goal!.targetDate);
      } catch (e) {
        print('Error parsing targetDate: $e');
      }
    }
  }
  @override
  Widget build(BuildContext context) {
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
                      Icons.savings_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      widget.goal == null ? 'Add Savings Goal' : 'Edit Savings Goal',
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
                    children: [                      // Title Field
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
                          controller: _titleController,
                          enabled: !_isLoading,
                          style: TextStyle(color: Theme.of(context).textPrimary),
                          decoration: InputDecoration(
                            labelText: 'Goal Title',
                            labelStyle: TextStyle(color: Theme.of(context).textSecondary),
                            hintText: 'e.g., New Laptop',
                            hintStyle: TextStyle(color: Theme.of(context).textSecondary.withOpacity(0.6)),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            prefixIcon: const Icon(Icons.flag_rounded, color: AppTheme.primaryColor),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a title';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 20),                      // Target Amount Field
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
                          controller: _targetAmountController,
                          enabled: !_isLoading,
                          style: TextStyle(color: Theme.of(context).textPrimary),
                          decoration: InputDecoration(
                            labelText: 'Target Amount',
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
                              return 'Please enter a target amount';
                            }
                            if (double.tryParse(value) == null || double.parse(value) <= 0) {
                              return 'Please enter a valid amount';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 20),                      // Target Date Selector
                      InkWell(
                        onTap: _isLoading ? null : _selectTargetDate,
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
                                  color: AppTheme.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.calendar_today_rounded,
                                  color: AppTheme.primaryColor,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Target Date',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(context).textSecondary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      DateFormat('MMMM dd, yyyy').format(_targetDate),
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
                      const SizedBox(height: 20),

                      // Description Field
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
                          controller: _descriptionController,
                          enabled: !_isLoading,
                          style: TextStyle(color: Theme.of(context).textPrimary),
                          decoration: InputDecoration(
                            labelText: 'Description (Optional)',
                            labelStyle: TextStyle(color: Theme.of(context).textSecondary),
                            hintText: 'Add details about your goal...',
                            hintStyle: TextStyle(color: Theme.of(context).textSecondary.withOpacity(0.6)),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            prefixIcon: const Icon(Icons.notes_rounded, color: AppTheme.accentColor),
                          ),                          maxLines: 3,
                        ),
                      ),
                    ],                  ),
                ),
              ),
            ),

            // Dialog Actions
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF1A1A1A)
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
                    onPressed: _isLoading ? null : _saveGoal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
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
                            widget.goal == null ? 'Add Goal' : 'Update',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectTargetDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _targetDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).brightness == Brightness.dark
                ? ColorScheme.dark(
                    primary: AppTheme.primaryColor,
                    onPrimary: Colors.white,
                    surface: const Color(0xFF1A1A1A),
                    onSurface: Colors.white,
                    background: const Color(0xFF121212),
                    onBackground: Colors.white,
                  )
                : ColorScheme.light(
                    primary: AppTheme.primaryColor,
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: AppTheme.textPrimary,
                  ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _targetDate) {
      setState(() {
        _targetDate = picked;
      });
    }
  }

  void _saveGoal() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        final provider = Provider.of<ExpenseProvider>(context, listen: false);
        final targetAmount = double.parse(_targetAmountController.text);
        final targetDateString = DateFormat('yyyy-MM-dd').format(_targetDate);        if (widget.goal == null) {
          final goal = SavingsGoal(
            title: _titleController.text.trim(),
            targetAmount: targetAmount,
            targetDate: targetDateString,
            description: _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
            currentAmount: 0.0,
          );
          await provider.addSavingsGoal(goal);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Savings goal added successfully!'),
              backgroundColor: AppTheme.secondaryColor,
              duration: Duration(seconds: 3),
            ),
          );        } else {
          final updatedGoal = SavingsGoal(
            id: widget.goal!.id,
            title: _titleController.text.trim(),
            targetAmount: targetAmount,
            currentAmount: widget.goal!.currentAmount,
            targetDate: targetDateString,
            description: _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
            userEmail: widget.goal!.userEmail,
          );
          await provider.updateSavingsGoal(updatedGoal);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Savings goal updated successfully!'),
              backgroundColor: AppTheme.primaryColor,
              duration: Duration(seconds: 3),
            ),
          );
        }
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save savings goal: $e'),
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

  @override
  void dispose() {
    _titleController.dispose();
    _targetAmountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}

class AddMoneyDialog extends StatefulWidget {
  final SavingsGoal goal;

  const AddMoneyDialog({super.key, required this.goal});

  @override
  _AddMoneyDialogState createState() => _AddMoneyDialogState();
}

class _AddMoneyDialogState extends State<AddMoneyDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  bool _isLoading = false; // Added _isLoading for dialog
  @override
  Widget build(BuildContext context) {
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
                      Icons.add_circle_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Add Money to Goal',
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

            // Dialog Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [                      // Goal Info
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppTheme.secondaryColor.withOpacity(0.15)
                              : AppTheme.secondaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.secondaryColor.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.goal.title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Current: \$${widget.goal.currentAmount.toStringAsFixed(2)} / \$${widget.goal.targetAmount.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: Theme.of(context).textSecondary,
                                fontSize: 14,
                              ),
                            ),                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: widget.goal.currentAmount / widget.goal.targetAmount,
                              backgroundColor: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white.withOpacity(0.1)
                                  : Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.secondaryColor),
                              minHeight: 8,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),                      // Amount Field
                      Text(
                        'Amount to Add',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
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
                          style: TextStyle(color: Theme.of(context).textPrimary),
                          decoration: InputDecoration(
                            hintText: '0.00',
                            hintStyle: TextStyle(color: Theme.of(context).textSecondary.withOpacity(0.6)),
                            prefixIcon: Container(
                              padding: const EdgeInsets.all(12),
                              child: Text(
                                '\$',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.secondaryColor,
                                ),
                              ),
                            ),                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter an amount';
                            }
                            final amount = double.tryParse(value);
                            if (amount == null || amount <= 0) {
                              return 'Please enter a valid amount';
                            }
                            if (widget.goal.currentAmount + amount > widget.goal.targetAmount) {
                              return 'Amount exceeds target';
                            }
                            return null;
                          },
                          enabled: !_isLoading,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),            // Action Buttons
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF1A1A1A)
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
                    onPressed: _isLoading ? null : _addMoney,
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
                        : const Text(
                            'Add Money',
                            style: TextStyle(
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

  void _addMoney() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        final provider = Provider.of<ExpenseProvider>(context, listen: false);
        final amount = double.parse(_amountController.text);        final updatedGoal = SavingsGoal(
          id: widget.goal.id,
          title: widget.goal.title,
          targetAmount: widget.goal.targetAmount,
          currentAmount: widget.goal.currentAmount + amount,
          targetDate: widget.goal.targetDate,
          description: widget.goal.description,
          userEmail: widget.goal.userEmail,
        );        await provider.updateSavingsGoal(updatedGoal);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Money added successfully!'),
            backgroundColor: AppTheme.secondaryColor,
            duration: Duration(seconds: 3),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add money: $e'),
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

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }
}