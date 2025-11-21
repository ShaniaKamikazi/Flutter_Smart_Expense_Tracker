import 'package:hive_flutter/hive_flutter.dart';
import '../models/user.dart';

class AuthService {
  static const String _userBoxName = 'users';
  static const String _sessionBoxName = 'session';
  static const String _currentUserKey = 'currentUser';

  // Get user box
  Box<User> get _userBox => Hive.box<User>(_userBoxName);
  
  // Get session box
  Box get _sessionBox => Hive.box(_sessionBoxName);

  // Initialize authentication boxes
  static Future<void> init() async {
    await Hive.openBox<User>(_userBoxName);
    await Hive.openBox(_sessionBoxName);
  }

  // Register new user
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
    String? phoneNumber,
  }) async {
    try {
      // Check if user already exists
      final existingUser = _userBox.values.firstWhere(
        (user) => user.email.toLowerCase() == email.toLowerCase(),
        orElse: () => User(
          email: '',
          password: '',
          name: '',
          createdAt: DateTime.now(),
        ),
      );

      if (existingUser.email.isNotEmpty) {
        return {
          'success': false,
          'message': 'User with this email already exists',
        };
      }

      // Create new user
      final newUser = User(
        email: email.toLowerCase(),
        password: password, // In production, hash this!
        name: name,
        phoneNumber: phoneNumber,
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );

      // Save user to Hive
      await _userBox.add(newUser);

      // Save session
      await _sessionBox.put(_currentUserKey, email.toLowerCase());

      return {
        'success': true,
        'message': 'Registration successful',
        'user': newUser,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Registration failed: $e',
      };
    }
  }

  // Login user
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      // Find user by email
      final user = _userBox.values.firstWhere(
        (user) => user.email.toLowerCase() == email.toLowerCase(),
        orElse: () => User(
          email: '',
          password: '',
          name: '',
          createdAt: DateTime.now(),
        ),
      );

      if (user.email.isEmpty) {
        return {
          'success': false,
          'message': 'No account found with this email. Please sign up first.',
        };
      }

      // Check password
      if (!user.checkPassword(password)) {
        return {
          'success': false,
          'message': 'Incorrect password',
        };
      }

      // Update last login
      user.lastLogin = DateTime.now();
      await user.save();

      // Save session
      await _sessionBox.put(_currentUserKey, email.toLowerCase());

      return {
        'success': true,
        'message': 'Login successful',
        'user': user,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Login failed: $e',
      };
    }
  }

  // Logout user
  Future<void> logout() async {
    await _sessionBox.delete(_currentUserKey);
  }

  // Check if user is logged in
  bool isLoggedIn() {
    return _sessionBox.containsKey(_currentUserKey);
  }

  // Get current logged-in user
  User? getCurrentUser() {
    if (!isLoggedIn()) return null;

    final email = _sessionBox.get(_currentUserKey) as String?;
    if (email == null) return null;

    try {
      return _userBox.values.firstWhere(
        (user) => user.email.toLowerCase() == email.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  // Get current user's email
  String? getCurrentUserEmail() {
    return _sessionBox.get(_currentUserKey) as String?;
  }

  // Update user profile
  Future<bool> updateUserProfile({
    required String name,
    String? newPassword,
    String? phoneNumber,
  }) async {
    try {
      final user = getCurrentUser();
      if (user == null) return false;

      user.name = name;
      if (newPassword != null && newPassword.isNotEmpty) {
        user.password = newPassword; // In production, hash this!
      }
      if (phoneNumber != null) {
        user.phoneNumber = phoneNumber;
      }

      await user.save();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Delete user account
  Future<bool> deleteAccount() async {
    try {
      final user = getCurrentUser();
      if (user == null) return false;

      await user.delete();
      await logout();
      return true;
    } catch (e) {
      return false;
    }
  }
}
