import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:smart_expense_tracker/config/app_theme.dart';
import 'package:smart_expense_tracker/providers/expense_provider.dart';
import 'package:smart_expense_tracker/providers/theme_provider.dart';
import 'package:smart_expense_tracker/screens/enhanced_landing_screen.dart';
import 'package:smart_expense_tracker/screens/home_screen.dart';
import 'package:smart_expense_tracker/services/database_helper.dart';
import 'package:smart_expense_tracker/services/auth_service.dart';

import 'models/budget.dart';
import 'models/expense.dart';
import 'models/savings_goal.dart';
import 'models/user.dart';


void main() async {
  // Ensure Flutter widgets are initialized before any plugin calls
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Hive for Flutter applications. This sets up the storage location.
  await Hive.initFlutter();

  // 2. Register your generated TypeAdapters.
  // These adapters tell Hive how to convert your Dart objects to/from binary.
  Hive.registerAdapter(ExpenseAdapter());
  Hive.registerAdapter(BudgetAdapter());
  Hive.registerAdapter(SavingsGoalAdapter());
  Hive.registerAdapter(UserAdapter());

  // 3. Initialize your DatabaseHelper and AuthService to open the Hive boxes.
  // This must happen AFTER Hive has been initialized and adapters registered.
  await DatabaseHelper().init();
  await AuthService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); // Added const constructor for better performance
  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final isLoggedIn = authService.isLoggedIn();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ExpenseProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Smart Expense Tracker',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: isLoggedIn ? const HomeScreen() : const EnhancedLandingScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
