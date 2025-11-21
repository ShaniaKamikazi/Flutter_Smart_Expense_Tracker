import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../config/app_theme.dart';
import '../providers/expense_provider.dart';
import '../widgets/glassmorphism_card.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedMonth = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Custom Header with Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF009688),
                  const Color(0xFF009688).withOpacity(0.8),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        const Text(
                          'Reports & Analytics',
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
                            icon: const Icon(Icons.calendar_month_rounded, color: Colors.white),
                            onPressed: _isLoading ? null : _selectMonth,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Tab Bar
                  Container(
                    margin: const EdgeInsets.only(bottom: 2),
                    child: TabBar(
                      controller: _tabController,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white70,
                      indicatorColor: Colors.white,
                      indicatorWeight: 3,
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                      tabs: const [
                        Tab(text: 'Overview'),
                        Tab(text: 'Categories'),
                        Tab(text: 'Trends'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Tab Bar View
          Expanded(
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Stack(
                children: [
                  Consumer<ExpenseProvider>(
                    builder: (context, provider, child) {
                      return TabBarView(
                        controller: _tabController,
                        children: [
                          _buildOverviewTab(provider),
                          _buildCategoriesTab(provider),
                          _buildTrendsTab(provider),
                        ],
                      );
                    },
                  ),
                  if (_isLoading)
                    Container(
                      color: Colors.black26,
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF009688)),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(ExpenseProvider provider) {
    final monthExpenses = provider.getExpensesForMonth(_selectedMonth);
    final totalSpent = monthExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
    final monthString = DateFormat('yyyy-MM').format(_selectedMonth);
    final totalBudget = provider.budgets
        .where((budget) => budget.month == monthString)
        .fold(0.0, (sum, budget) => sum + budget.amount);
    final transactionCount = monthExpenses.length;

    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _isLoading = true;
        });
        try {
          await provider.loadExpenses();
          await provider.loadBudgets();
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMonthHeader(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Spent',
                    '\$${totalSpent.toStringAsFixed(2)}',
                    Icons.money_off,
                    AppTheme.errorColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Budget',
                    '\$${totalBudget.toStringAsFixed(2)}',
                    Icons.account_balance_wallet,
                    AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Remaining',
                    '\$${(totalBudget - totalSpent).toStringAsFixed(2)}',
                    Icons.savings,
                    totalBudget - totalSpent >= 0 ? AppTheme.secondaryColor : AppTheme.errorColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Transactions',
                    '$transactionCount',
                    Icons.receipt,
                    AppTheme.warningColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Budget Progress',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (provider.budgets.where((budget) => budget.month == monthString).isEmpty)
              SizedBox(
                height: 100,
                child: Center(
                  child: Text(
                    'No budgets set for this month',
                    style: TextStyle(color: Theme.of(context).textSecondary),
                  ),
                ),
              )
            else
              ...provider.budgets.where((budget) => budget.month == monthString).map((budget) {
                final spent = monthExpenses
                    .where((expense) => expense.category == budget.category)
                    .fold(0.0, (sum, expense) => sum + expense.amount);
                final progress = budget.amount > 0 ? spent / budget.amount : 0.0;

                return Column(
                  children: [
                    GlassmorphismCard(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      _getCategoryIcon(budget.category),
                                      color: _getCategoryColor(budget.category),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      budget.category,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Text(
                                  '\$${spent.toStringAsFixed(2)} / \$${budget.amount.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: progress > 1.0 ? Colors.red : Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: progress > 1.0 ? 1.0 : progress,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                progress > 1.0
                                    ? Colors.red
                                    : progress > 0.8
                                    ? Colors.orange
                                    : Colors.green,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${(progress * 100).toStringAsFixed(1)}% used',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesTab(ExpenseProvider provider) {
    final monthExpenses = provider.getExpensesForMonth(_selectedMonth);
    final categoryTotals = <String, double>{};

    for (var expense in monthExpenses) {
      categoryTotals[expense.category] =
          (categoryTotals[expense.category] ?? 0) + expense.amount;
    }

    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _isLoading = true;
        });
        try {
          await provider.loadExpenses();
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to refresh: $e'),
              backgroundColor: Colors.red,
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMonthHeader(),
            const SizedBox(height: 16),
            if (categoryTotals.isNotEmpty) ...[
              SizedBox(
                height: 300,
                child: PieChart(
                  PieChartData(
                    sections: _buildPieChartSections(categoryTotals),
                    centerSpaceRadius: 60,
                    sectionsSpace: 2,
                    startDegreeOffset: -90,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Category Breakdown',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...categoryTotals.entries.map((entry) {
                final total = categoryTotals.values.fold(0.0, (sum, amount) => sum + amount);
                final percentage = total > 0 ? (entry.value / total * 100) : 0.0;

                return Column(
                  children: [
                    GlassmorphismCard(
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Row(
                          children: [
                            Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: _getCategoryColor(entry.key),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: _getCategoryColor(entry.key).withOpacity(0.4),
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 14),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _getCategoryColor(entry.key).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                _getCategoryIcon(entry.key),
                                color: _getCategoryColor(entry.key),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                entry.key,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '\$${entry.value.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  '${percentage.toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    color: Theme.of(context).textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                );
              }).toList(),
            ] else
              _buildEmptyChart('No expenses found for this month'),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendsTab(ExpenseProvider provider) {
    final monthlyData = _getMonthlyData(provider);

    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _isLoading = true;
        });
        try {
          await provider.loadExpenses();
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to refresh: $e'),
              backgroundColor: Colors.red,
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Trends',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Enhanced Chart Container
            GlassmorphismCard(
              gradientStartColor: AppTheme.primaryColor,
              gradientEndColor: AppTheme.secondaryColor,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '6-Month Spending Trend',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Theme.of(context).textPrimary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Last 6 Months',
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 220,
                      child: LineChart(
                        _buildEnhancedLineChartData(provider, monthlyData),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildChartLegend(monthlyData),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Summary Statistics with Colors
            _buildTrendsSummary(monthlyData),

            const SizedBox(height: 24),

            Text(
              'Spending Insights',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            _buildEnhancedInsightCard(
              'Highest Spending Month',
              _getHighestSpendingMonth(monthlyData),
              Icons.trending_up,
              Colors.red,
            ),
            const SizedBox(height: 12),

            _buildEnhancedInsightCard(
              'Lowest Spending Month',
              _getLowestSpendingMonth(monthlyData),
              Icons.trending_down,
              Colors.green,
            ),
            const SizedBox(height: 12),

            _buildEnhancedInsightCard(
              'Average Monthly Spend',
              '\$${_getAverageMonthlySpend(monthlyData).toStringAsFixed(2)}',
              Icons.calculate,
              Colors.blue,
            ),
            const SizedBox(height: 12),

            _buildEnhancedInsightCard(
              'Total 6-Month Spend',
              '\$${_getTotalSixMonthSpend(monthlyData).toStringAsFixed(2)}',
              Icons.account_balance_wallet,
              Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal[400]!, Colors.teal[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            DateFormat('MMMM yyyy').format(_selectedMonth),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Icon(Icons.calendar_today, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
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
            color: color.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 6),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
            spreadRadius: 0,
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
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(String title, String value, IconData icon, Color color) {
    return GlassmorphismCard(
      gradientStartColor: color,
      gradientEndColor: color.withOpacity(0.7),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Theme.of(context).textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Theme.of(context).textPrimary,
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

  Widget _buildEnhancedInsightCard(String title, String value, IconData icon, Color color) {
    return GlassmorphismCard(
      gradientStartColor: color,
      gradientEndColor: color.withOpacity(0.7),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Theme.of(context).textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Theme.of(context).textPrimary,
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

  Widget _buildEmptyChart(String message) {
    return SizedBox(
      height: 300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pie_chart_outline, size: 64, color: Theme.of(context).textSecondary.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(color: Theme.of(context).textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections(Map<String, double> categoryTotals) {
    return categoryTotals.entries.map((entry) {
      final total = categoryTotals.values.fold(0.0, (sum, amount) => sum + amount);
      final percentage = total > 0 ? (entry.value / total * 100) : 0.0;

      return PieChartSectionData(
        color: _getCategoryColor(entry.key),
        value: entry.value,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  List<Map<String, dynamic>> _getMonthlyData(ExpenseProvider provider) {
    List<Map<String, dynamic>> monthlyData = [];
    final now = DateTime.now();

    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i);
      final monthExpenses = provider.getExpensesForMonth(month);
      final total = monthExpenses.fold(0.0, (sum, expense) => sum + expense.amount);

      monthlyData.add({
        'month': month,
        'total': total,
        'monthName': DateFormat('MMM').format(month),
        'year': DateFormat('yy').format(month),
        'fullMonthName': DateFormat('MMM yy').format(month),
      });
    }

    return monthlyData;
  }

  LineChartData _buildEnhancedLineChartData(ExpenseProvider provider, List<Map<String, dynamic>> monthlyData) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white70 : Colors.grey[700];
    final gridColor = isDark ? Colors.white.withOpacity(0.1) : Colors.grey[300]!;

    double maxY = monthlyData.map((data) => data['total'] as double).fold(0.0, (max, value) => value > max ? value : max);
    maxY = maxY * 1.2; // Add 20% padding

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        drawHorizontalLine: true,
        horizontalInterval: maxY > 0 ? maxY / 4 : 250,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: gridColor,
            strokeWidth: 1,
            dashArray: [5, 5],
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40, // Increased reserved size to prevent overflow
            interval: 1,
            getTitlesWidget: (double value, TitleMeta meta) {
              if (value >= 0 && value < monthlyData.length) {
                final data = monthlyData[value.toInt()];
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        data['monthName'],
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 11, // Reduced font size
                        ),
                      ),
                      Text(
                        data['year'],
                        style: TextStyle(
                          color: textColor?.withOpacity(0.7),
                          fontWeight: FontWeight.w500,
                          fontSize: 9, // Reduced font size
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox();
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: maxY > 0 ? maxY / 4 : 250,
            reservedSize: 48,
            getTitlesWidget: (double value, TitleMeta meta) {
              if (value == 0) return const SizedBox();
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text(
                  '\$${value.toInt()}',
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 10, // Reduced font size
                  ),
                  textAlign: TextAlign.right,
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(
          color: gridColor,
          width: 1,
        ),
      ),
      minX: 0,
      maxX: monthlyData.length > 0 ? monthlyData.length - 1 : 5,
      minY: 0,
      maxY: maxY > 0 ? maxY : 1000,
      lineBarsData: [
        LineChartBarData(
          spots: monthlyData.asMap().entries.map((entry) {
            return FlSpot(entry.key.toDouble(), entry.value['total']);
          }).toList(),
          isCurved: true,
          curveSmoothness: 0.3,
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryColor,
              AppTheme.primaryColor.withOpacity(0.6),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: Colors.white,
                strokeWidth: 2,
                strokeColor: AppTheme.primaryColor,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryColor.withOpacity(0.3),
                AppTheme.primaryColor.withOpacity(0.05),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          aboveBarData: BarAreaData(
            show: false,
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: isDark ? Colors.grey[800]! : Colors.white,
          tooltipRoundedRadius: 8,
          getTooltipItems: (List<LineBarSpot> touchedSpots) {
            return touchedSpots.map((spot) {
              final data = monthlyData[spot.x.toInt()];
              return LineTooltipItem(
                '${data['fullMonthName']}\n\$${spot.y.toStringAsFixed(2)}',
                TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              );
            }).toList();
          },
        ),
      ),
    );
  }

  Widget _buildChartLegend(List<Map<String, dynamic>> monthlyData) {
    final currentMonthData = monthlyData.isNotEmpty ? monthlyData.last : null;
    final previousMonthData = monthlyData.length > 1 ? monthlyData[monthlyData.length - 2] : null;

    double percentageChange = 0.0;
    if (previousMonthData != null && previousMonthData['total'] > 0) {
      final currentTotal = currentMonthData?['total'] ?? 0.0;
      final previousTotal = previousMonthData['total'];
      percentageChange = ((currentTotal - previousTotal) / previousTotal) * 100;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Month',
              style: TextStyle(
                color: Theme.of(context).textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '\$${(currentMonthData?['total'] ?? 0.0).toStringAsFixed(2)}',
              style: TextStyle(
                color: Theme.of(context).textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: percentageChange >= 0 ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                percentageChange >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                size: 14,
                color: percentageChange >= 0 ? Colors.red : Colors.green,
              ),
              const SizedBox(width: 4),
              Text(
                '${percentageChange.abs().toStringAsFixed(1)}%',
                style: TextStyle(
                  color: percentageChange >= 0 ? Colors.red : Colors.green,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTrendsSummary(List<Map<String, dynamic>> monthlyData) {
    final totalSpend = _getTotalSixMonthSpend(monthlyData);
    final averageSpend = _getAverageMonthlySpend(monthlyData);
    final highestMonth = _getHighestSpendingMonth(monthlyData);
    final lowestMonth = _getLowestSpendingMonth(monthlyData);

    return GlassmorphismCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: AppTheme.primaryColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  '6-Month Summary',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Theme.of(context).textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildColoredSummaryItem(
                  'Total Spend',
                  '\$${totalSpend.toStringAsFixed(2)}',
                  Icons.attach_money,
                  Colors.purple,
                ),
                const SizedBox(width: 12),
                _buildColoredSummaryItem(
                  'Monthly Avg',
                  '\$${averageSpend.toStringAsFixed(2)}',
                  Icons.timeline,
                  Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildColoredSummaryItem(
                  'Highest Month',
                  highestMonth,
                  Icons.arrow_upward,
                  Colors.red,
                ),
                const SizedBox(width: 12),
                _buildColoredSummaryItem(
                  'Lowest Month',
                  lowestMonth,
                  Icons.arrow_downward,
                  Colors.green,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withOpacity(0.05)
              : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 16,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: Theme.of(context).textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: Theme.of(context).textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColoredSummaryItem(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 16,
                    color: color,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Theme.of(context).textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: Theme.of(context).textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods for trends data
  String _getHighestSpendingMonth(List<Map<String, dynamic>> monthlyData) {
    if (monthlyData.isEmpty) return 'No data';
    final highest = monthlyData.reduce((a, b) => a['total'] > b['total'] ? a : b);
    return '${highest['fullMonthName']}\n\$${highest['total'].toStringAsFixed(2)}';
  }

  String _getLowestSpendingMonth(List<Map<String, dynamic>> monthlyData) {
    if (monthlyData.isEmpty) return 'No data';
    final lowest = monthlyData.reduce((a, b) => a['total'] < b['total'] ? a : b);
    return '${lowest['fullMonthName']}\n\$${lowest['total'].toStringAsFixed(2)}';
  }

  double _getAverageMonthlySpend(List<Map<String, dynamic>> monthlyData) {
    if (monthlyData.isEmpty) return 0.0;
    final total = monthlyData.fold(0.0, (sum, data) => sum + data['total']);
    return total / monthlyData.length;
  }

  double _getTotalSixMonthSpend(List<Map<String, dynamic>> monthlyData) {
    return monthlyData.fold(0.0, (sum, data) => sum + data['total']);
  }

  String _getHighestSpendingDay(ExpenseProvider provider) {
    final monthExpenses = provider.getExpensesForMonth(_selectedMonth);
    if (monthExpenses.isEmpty) return 'No data';

    final dayTotals = <int, double>{};
    for (var expense in monthExpenses) {
      try {
        final parsedDate = DateFormat('yyyy-MM-dd').parse(expense.date);
        final day = parsedDate.day;
        dayTotals[day] = (dayTotals[day] ?? 0) + expense.amount;
      } catch (e) {
        print('Error parsing expense date: $e');
      }
    }

    if (dayTotals.isEmpty) return 'No data';

    final highestDay = dayTotals.entries.reduce((a, b) => a.value > b.value ? a : b);
    return '${highestDay.key} (\$${highestDay.value.toStringAsFixed(2)})';
  }

  String _getMostFrequentCategory(ExpenseProvider provider) {
    final monthExpenses = provider.getExpensesForMonth(_selectedMonth);
    if (monthExpenses.isEmpty) return 'No data';

    final categoryCount = <String, int>{};
    for (var expense in monthExpenses) {
      categoryCount[expense.category] = (categoryCount[expense.category] ?? 0) + 1;
    }

    if (categoryCount.isEmpty) return 'No data';

    final mostFrequent = categoryCount.entries.reduce((a, b) => a.value > b.value ? a : b);
    return '${mostFrequent.key} (${mostFrequent.value} transactions)';
  }

  double _getAverageTransaction(ExpenseProvider provider) {
    final monthExpenses = provider.getExpensesForMonth(_selectedMonth);
    if (monthExpenses.isEmpty) return 0.0;

    final total = monthExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
    return total / monthExpenses.length;
  }

  double _getDailyAverage(ExpenseProvider provider) {
    final monthExpenses = provider.getExpensesForMonth(_selectedMonth);
    if (monthExpenses.isEmpty) return 0.0;

    final total = monthExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
    final daysInMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day;
    return total / daysInMonth;
  }

  Future<void> _selectMonth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).brightness == Brightness.dark
                ? ColorScheme.dark(
              primary: Colors.teal[400]!,
              onPrimary: Colors.white,
              surface: const Color(0xFF1A1A1A),
              onSurface: Colors.white,
              background: const Color(0xFF121212),
              onBackground: Colors.white,
            )
                : ColorScheme.light(
              primary: Colors.teal[600]!,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppTheme.textPrimary,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.teal[400]
                    : Colors.teal[600],
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedMonth) {
      setState(() {
        _isLoading = true;
        _selectedMonth = DateTime(picked.year, picked.month);
      });
      try {
        final provider = Provider.of<ExpenseProvider>(context, listen: false);
        await provider.loadExpenses();
        await provider.loadBudgets();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load data for selected month: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Color _getCategoryColor(String category) {
    final colors = {
      'Food & Dining': Colors.orange,
      'Transportation': Colors.blue,
      'Shopping': Colors.pink,
      'Entertainment': Colors.purple,
      'Bills & Utilities': Colors.teal,
      'Education': Colors.green,
      'Healthcare': Colors.red,
      'Others': Colors.grey,
    };
    return colors[category] ?? Colors.grey;
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
    _tabController.dispose();
    super.dispose();
  }
}