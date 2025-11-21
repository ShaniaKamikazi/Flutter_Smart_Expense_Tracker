// import 'package:flutter/material.dart';
// import 'package:smart_expense_tracker/config/app_theme.dart';
// import 'package:smart_expense_tracker/screens/home_screen.dart';
// import 'package:smart_expense_tracker/services/auth_service.dart';
//
// class SignUpScreen extends StatefulWidget {
//   final bool isLogin;
//
//   const SignUpScreen({Key? key, this.isLogin = false}) : super(key: key);
//
//   @override
//   State<SignUpScreen> createState() => _SignUpScreenState();
// }
//
// class _SignUpScreenState extends State<SignUpScreen>
//     with SingleTickerProviderStateMixin {
//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();
//   final _phoneController = TextEditingController();
//   final _authService = AuthService();
//
//   bool _isObscurePassword = true;
//   bool _isObscureConfirmPassword = true;
//   bool _isLoading = false;
//   late bool _isLogin;
//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;
//
//   @override
//   void initState() {
//     super.initState();
//     _isLogin = widget.isLogin;
//
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 800),
//       vsync: this,
//     );
//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
//     );
//
//     _animationController.forward();
//   }
//
//   @override
//   void dispose() {
//     _nameController.dispose();
//     _emailController.dispose();
//     _passwordController.dispose();
//     _confirmPasswordController.dispose();
//     _phoneController.dispose();
//     _animationController.dispose();
//     super.dispose();
//   }
//
//   void _toggleMode() {
//     setState(() {
//       _isLogin = !_isLogin;
//       _formKey.currentState?.reset();
//     });
//   }
//
//   Future<void> _submit() async {
//     if (!_formKey.currentState!.validate()) return;
//
//     setState(() => _isLoading = true);
//
//     try {
//       Map<String, dynamic> result;
//
//       if (_isLogin) {
//         // Login
//         result = await _authService.login(
//           email: _emailController.text.trim(),
//           password: _passwordController.text,
//         );
//       } else {
//         // Register
//         result = await _authService.register(
//           email: _emailController.text.trim(),
//           password: _passwordController.text,
//           name: _nameController.text.trim(),
//           phoneNumber: _phoneController.text.trim().isEmpty
//               ? null
//               : _phoneController.text.trim(),
//         );
//       }
//
//       if (!mounted) return;
//
//       setState(() => _isLoading = false);
//
//       if (result['success']) {
//         // Navigate to home screen
//         Navigator.pushAndRemoveUntil(
//           context,
//           _createRoute(const HomeScreen()),
//           (route) => false,
//         );
//       } else {
//         // Show error message
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(result['message'] ?? 'An error occurred'),
//             backgroundColor: AppTheme.errorColor,
//             behavior: SnackBarBehavior.floating,
//             duration: const Duration(seconds: 4),
//           ),
//         );
//       }
//     } catch (e) {
//       if (!mounted) return;
//
//       setState(() => _isLoading = false);
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('An error occurred: $e'),
//           backgroundColor: AppTheme.errorColor,
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//
//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: isDark
//                 ? [
//                     const Color(0xFF1A1A1A),
//                     const Color(0xFF121212),
//                   ]
//                 : [
//                     AppTheme.backgroundColor,
//                     Colors.white,
//                   ],
//           ),
//         ),
//         child: SafeArea(
//           child: FadeTransition(
//             opacity: _fadeAnimation,
//             child: Column(
//               children: [
//                 // Back Button
//                 Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Align(
//                     alignment: Alignment.topLeft,
//                     child: Container(
//                       decoration: BoxDecoration(
//                         color: isDark
//                             ? Colors.white.withOpacity(0.1)
//                             : Colors.white,
//                         borderRadius: BorderRadius.circular(12),
//                         border: isDark
//                             ? Border.all(color: Colors.white.withOpacity(0.2))
//                             : null,
//                       ),
//                       child: IconButton(
//                         icon: Icon(
//                           Icons.arrow_back_ios_rounded,
//                           color: isDark ? Colors.white : AppTheme.textPrimary,
//                         ),
//                         onPressed: () => Navigator.pop(context),
//                         style: IconButton.styleFrom(
//                           padding: const EdgeInsets.all(12),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//
//                 Expanded(
//                   child: SingleChildScrollView(
//                     padding: const EdgeInsets.all(24),
//                     child: Form(
//                       key: _formKey,
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // Title
//                           Text(
//                             _isLogin ? 'Welcome Back!' : 'Create Account',
//                             style: Theme.of(context).textTheme.displayLarge?.copyWith(
//                               color: Theme.of(context).textPrimary,
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           Text(
//                             _isLogin
//                                 ? 'Sign in to continue managing your finances'
//                                 : 'Sign up to start tracking your expenses',
//                             style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                               color: Theme.of(context).textSecondary,
//                             ),
//                           ),
//
//                           const SizedBox(height: 40),
//
//                           // Name Field (Only for Sign Up)
//                           if (!_isLogin) ...[
//                             _buildTextField(
//                               controller: _nameController,
//                               labelText: 'Full Name',
//                               hintText: 'Enter your full name',
//                               prefixIcon: Icons.person_outline_rounded,
//                               validator: (value) {
//                                 if (value == null || value.trim().isEmpty) {
//                                   return 'Please enter your name';
//                                 }
//                                 return null;
//                               },
//                             ),
//                             const SizedBox(height: 16),
//                             // Phone Number Field
//                             _buildTextField(
//                               controller: _phoneController,
//                               labelText: 'Phone Number (Optional)',
//                               hintText: 'Enter your phone number',
//                               prefixIcon: Icons.phone_outlined,
//                               keyboardType: TextInputType.phone,
//                             ),
//                             const SizedBox(height: 16),
//                           ],
//
//                           // Email Field
//                           _buildTextField(
//                             controller: _emailController,
//                             labelText: 'Email',
//                             hintText: 'Enter your email',
//                             prefixIcon: Icons.email_outlined,
//                             keyboardType: TextInputType.emailAddress,
//                             validator: (value) {
//                               if (value == null || value.trim().isEmpty) {
//                                 return 'Please enter your email';
//                               }
//                               if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
//                                   .hasMatch(value)) {
//                                 return 'Please enter a valid email';
//                               }
//                               return null;
//                             },
//                           ),
//                           const SizedBox(height: 16),
//
//                           // Password Field
//                           _buildTextField(
//                             controller: _passwordController,
//                             labelText: 'Password',
//                             hintText: 'Enter your password',
//                             prefixIcon: Icons.lock_outline_rounded,
//                             obscureText: _isObscurePassword,
//                             suffixIcon: IconButton(
//                               icon: Icon(
//                                 _isObscurePassword
//                                     ? Icons.visibility_outlined
//                                     : Icons.visibility_off_outlined,
//                                 color: Theme.of(context).textSecondary,
//                               ),
//                               onPressed: () {
//                                 setState(() {
//                                   _isObscurePassword = !_isObscurePassword;
//                                 });
//                               },
//                             ),
//                             validator: (value) {
//                               if (value == null || value.isEmpty) {
//                                 return 'Please enter your password';
//                               }
//                               if (!_isLogin && value.length < 6) {
//                                 return 'Password must be at least 6 characters';
//                               }
//                               return null;
//                             },
//                           ),
//                           const SizedBox(height: 16),
//
//                           // Confirm Password Field (Only for Sign Up)
//                           if (!_isLogin) ...[
//                             _buildTextField(
//                               controller: _confirmPasswordController,
//                               labelText: 'Confirm Password',
//                               hintText: 'Re-enter your password',
//                               prefixIcon: Icons.lock_outline_rounded,
//                               obscureText: _isObscureConfirmPassword,
//                               suffixIcon: IconButton(
//                                 icon: Icon(
//                                   _isObscureConfirmPassword
//                                       ? Icons.visibility_outlined
//                                       : Icons.visibility_off_outlined,
//                                   color: Theme.of(context).textSecondary,
//                                 ),
//                                 onPressed: () {
//                                   setState(() {
//                                     _isObscureConfirmPassword =
//                                         !_isObscureConfirmPassword;
//                                   });
//                                 },
//                               ),
//                               validator: (value) {
//                                 if (value == null || value.isEmpty) {
//                                   return 'Please confirm your password';
//                                 }
//                                 if (value != _passwordController.text) {
//                                   return 'Passwords do not match';
//                                 }
//                                 return null;
//                               },
//                             ),
//                             const SizedBox(height: 24),
//                           ],
//
//                           // Forgot Password (Only for Login)
//                           if (_isLogin) ...[
//                             Align(
//                               alignment: Alignment.centerRight,
//                               child: TextButton(
//                                 onPressed: () {
//                                   // Handle forgot password
//                                   ScaffoldMessenger.of(context).showSnackBar(
//                                     const SnackBar(
//                                       content:
//                                           Text('Forgot password feature coming soon!'),
//                                     ),
//                                   );
//                                 },
//                                 child: Text(
//                                   'Forgot Password?',
//                                   style: TextStyle(
//                                     color: AppTheme.primaryColor,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(height: 8),
//                           ],
//
//                           const SizedBox(height: 32),
//
//                           // Submit Button
//                           SizedBox(
//                             width: double.infinity,
//                             height: 56,
//                             child: ElevatedButton(
//                               onPressed: _isLoading ? null : _submit,
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: AppTheme.primaryColor,
//                                 foregroundColor: Colors.white,
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                                 elevation: 2,
//                               ),
//                               child: _isLoading
//                                   ? const SizedBox(
//                                       height: 24,
//                                       width: 24,
//                                       child: CircularProgressIndicator(
//                                         color: Colors.white,
//                                         strokeWidth: 2,
//                                       ),
//                                     )
//                                   : Text(
//                                       _isLogin ? 'Sign In' : 'Create Account',
//                                       style: const TextStyle(
//                                         fontSize: 18,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                             ),
//                           ),
//
//                           const SizedBox(height: 24),
//
//                           // Toggle Sign Up / Login
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Text(
//                                 _isLogin
//                                     ? "Don't have an account? "
//                                     : "Already have an account? ",
//                                 style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                                   color: Theme.of(context).textSecondary,
//                                 ),
//                               ),
//                               TextButton(
//                                 onPressed: _toggleMode,
//                                 child: Text(
//                                   _isLogin ? 'Sign Up' : 'Sign In',
//                                   style: const TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     color: AppTheme.primaryColor,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//
//                           const SizedBox(height: 24),
//
//                           // Or Divider
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: Divider(
//                                   color: Theme.of(context).textSecondary.withOpacity(0.3),
//                                 ),
//                               ),
//                               Padding(
//                                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                                 child: Text(
//                                   'OR',
//                                   style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                                     color: Theme.of(context).textSecondary,
//                                   ),
//                                 ),
//                               ),
//                               Expanded(
//                                 child: Divider(
//                                   color: Theme.of(context).textSecondary.withOpacity(0.3),
//                                 ),
//                               ),
//                             ],
//                           ),
//
//                           const SizedBox(height: 24),
//
//                           // Social Login Buttons
//                           _buildSocialButton(
//                             icon: Icons.g_mobiledata_rounded,
//                             label: 'Continue with Google',
//                             onPressed: () {
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 const SnackBar(
//                                   content:
//                                       Text('Google sign-in coming soon!'),
//                                 ),
//                               );
//                             },
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String labelText,
//     required String hintText,
//     required IconData prefixIcon,
//     TextInputType? keyboardType,
//     bool obscureText = false,
//     Widget? suffixIcon,
//     String? Function(String?)? validator,
//   }) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//
//     return Container(
//       decoration: BoxDecoration(
//         color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: isDark
//               ? Colors.white.withOpacity(0.2)
//               : Colors.grey[300]!,
//         ),
//       ),
//       child: TextFormField(
//         controller: controller,
//         keyboardType: keyboardType,
//         obscureText: obscureText,
//         style: TextStyle(color: Theme.of(context).textPrimary),
//         decoration: InputDecoration(
//           labelText: labelText,
//           labelStyle: TextStyle(color: Theme.of(context).textSecondary),
//           hintText: hintText,
//           hintStyle: TextStyle(color: Theme.of(context).textSecondary.withOpacity(0.6)),
//           prefixIcon: Icon(prefixIcon, color: AppTheme.primaryColor),
//           suffixIcon: suffixIcon,
//           border: InputBorder.none,
//           contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//         ),
//         validator: validator,
//       ),
//     );
//   }
//
//   Widget _buildSocialButton({
//     required IconData icon,
//     required String label,
//     required VoidCallback onPressed,
//   }) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//
//     return SizedBox(
//       width: double.infinity,
//       height: 56,
//       child: OutlinedButton.icon(
//         onPressed: onPressed,
//         icon: Icon(icon, size: 28),
//         label: Text(label),
//         style: OutlinedButton.styleFrom(
//           foregroundColor: Theme.of(context).textPrimary,
//           side: BorderSide(
//             color: isDark
//                 ? Colors.white.withOpacity(0.2)
//                 : Colors.grey.shade300,
//           ),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Route _createRoute(Widget destination) {
//     return PageRouteBuilder(
//       pageBuilder: (context, animation, secondaryAnimation) => destination,
//       transitionsBuilder: (context, animation, secondaryAnimation, child) {
//         const begin = Offset(1.0, 0.0);
//         const end = Offset.zero;
//         const curve = Curves.easeInOutCubic;
//
//         var tween = Tween(begin: begin, end: end).chain(
//           CurveTween(curve: curve),
//         );
//
//         return SlideTransition(
//           position: animation.drive(tween),
//           child: child,
//         );
//       },
//       transitionDuration: const Duration(milliseconds: 500),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:smart_expense_tracker/config/app_theme.dart';
import 'package:smart_expense_tracker/screens/home_screen.dart';
import 'package:smart_expense_tracker/services/auth_service.dart';

class SignUpScreen extends StatefulWidget {
  final bool isLogin;

  const SignUpScreen({Key? key, this.isLogin = false}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _authService = AuthService();

  bool _isObscurePassword = true;
  bool _isObscureConfirmPassword = true;
  bool _isLoading = false;
  late bool _isLogin;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _isLogin = widget.isLogin;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOutBack),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _isLogin = !_isLogin;
      _formKey.currentState?.reset();
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      Map<String, dynamic> result;

      if (_isLogin) {
        // Login
        result = await _authService.login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        // Register
        result = await _authService.register(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          name: _nameController.text.trim(),
          phoneNumber: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
        );
      }

      if (!mounted) return;

      setState(() => _isLoading = false);

      if (result['success']) {
        // Navigate to home screen
        Navigator.pushAndRemoveUntil(
          context,
          _createRoute(const HomeScreen()),
              (route) => false,
        );
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Expanded(child: Text(result['message'] ?? 'An error occurred')),
              ],
            ),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Expanded(child: Text('An error occurred: $e')),
            ],
          ),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
              const Color(0xFF1E1E1E),
              const Color(0xFF121212),
              const Color(0xFF0A0A0A),
            ]
                : [
              AppTheme.backgroundColor,
              Colors.white,
              Color(0xFFF8FAFF),
            ],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // Header with Back Button
                _buildHeader(isDark),

                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                        horizontal: size.width > 600 ? 40 : 24,
                        vertical: 8
                    ),
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title Section
                              _buildTitleSection(context),
                              SizedBox(height: size.height * 0.04),

                              // Form Fields
                              _buildFormFields(context),
                              SizedBox(height: size.height * 0.02),

                              // Forgot Password (Only for Login)
                              if (_isLogin) _buildForgotPassword(),

                              SizedBox(height: size.height * 0.04),

                              // Submit Button
                              _buildSubmitButton(),

                              SizedBox(height: size.height * 0.04),

                              // Toggle Section
                              _buildToggleSection(context),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Back Button
          Container(
            decoration: BoxDecoration(
              gradient: isDark
                  ? LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.05),
                ],
              )
                  : LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.9),
                  Colors.white.withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: isDark
                  ? Border.all(color: Colors.white.withOpacity(0.15))
                  : Border.all(color: Colors.grey.withOpacity(0.2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_rounded,
                color: isDark ? Colors.white : AppTheme.textPrimary,
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
              style: IconButton.styleFrom(
                padding: const EdgeInsets.all(14),
              ),
            ),
          ),

          Spacer(),

          // App Logo/Title
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.primaryColor.withOpacity(0.2),
              ),
            ),
            child: Text(
              'Expense Tracker',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w700,
                fontSize: 14,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Animated Title
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: Text(
            _isLogin ? 'Welcome Back!' : 'Create Account',
            key: ValueKey(_isLogin),
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              color: Theme.of(context).textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 32,
              height: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Animated Subtitle
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: Text(
            _isLogin
                ? 'Sign in to continue tracking your expenses'
                : 'Join us to start your financial journey',
            key: ValueKey(_isLogin),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).textSecondary,
              fontSize: 16,
              height: 1.4,
            ),
          ),
        ),

        // Progress Indicator for Sign Up
        if (!_isLogin) ...[
          const SizedBox(height: 24),
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).textSecondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(2),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryColor,
                          AppTheme.primaryColor.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFormFields(BuildContext context) {
    return Column(
      children: [
        // Name Field (Only for Sign Up)
        if (!_isLogin) ...[
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _buildTextField(
              key: ValueKey('name_field'),
              controller: _nameController,
              labelText: 'Full Name',
              hintText: 'Enter your full name',
              prefixIcon: Icons.person_outline_rounded,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 20),

          // Phone Number Field
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _buildTextField(
              key: ValueKey('phone_field'),
              controller: _phoneController,
              labelText: 'Phone Number (Optional)',
              hintText: 'Enter your phone number',
              prefixIcon: Icons.phone_iphone_outlined,
              keyboardType: TextInputType.phone,
            ),
          ),
          const SizedBox(height: 20),
        ],

        // Email Field
        _buildTextField(
          controller: _emailController,
          labelText: 'Email Address',
          hintText: 'Enter your email',
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your email';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                .hasMatch(value)) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),

        // Password Field
        _buildTextField(
          controller: _passwordController,
          labelText: 'Password',
          hintText: 'Enter your password',
          prefixIcon: Icons.lock_outline_rounded,
          obscureText: _isObscurePassword,
          suffixIcon: IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                _isObscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                key: ValueKey(_isObscurePassword),
                color: Theme.of(context).textSecondary.withOpacity(0.6),
                size: 20,
              ),
            ),
            onPressed: () {
              setState(() {
                _isObscurePassword = !_isObscurePassword;
              });
            },
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your password';
            }
            if (!_isLogin && value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),

        // Confirm Password Field (Only for Sign Up)
        if (!_isLogin) ...[
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _buildTextField(
              key: ValueKey('confirm_password_field'),
              controller: _confirmPasswordController,
              labelText: 'Confirm Password',
              hintText: 'Re-enter your password',
              prefixIcon: Icons.lock_reset_outlined,
              obscureText: _isObscureConfirmPassword,
              suffixIcon: IconButton(
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    _isObscureConfirmPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    key: ValueKey(_isObscureConfirmPassword),
                    color: Theme.of(context).textSecondary.withOpacity(0.6),
                    size: 20,
                  ),
                ),
                onPressed: () {
                  setState(() {
                    _isObscureConfirmPassword = !_isObscureConfirmPassword;
                  });
                },
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm your password';
                }
                if (value != _passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Expanded(child: Text('Forgot password feature coming soon!')),
                  ],
                ),
                backgroundColor: AppTheme.primaryColor.withOpacity(0.9),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.primaryColor.withOpacity(0.1),
              ),
            ),
            child: Text(
              'Forgot Password?',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryColor,
              AppTheme.primaryColor.withOpacity(0.9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            elevation: 0,
          ),
          child: _isLoading
              ? SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2.5,
            ),
          )
              : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _isLogin ? 'Sign In' : 'Create Account',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                _isLogin ? Icons.arrow_forward_rounded : Icons.rocket_launch_rounded,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleSection(BuildContext context) {
    return Column(
      children: [
        // Divider with text
        Row(
          children: [
            Expanded(
              child: Divider(
                color: Theme.of(context).textSecondary.withOpacity(0.15),
                thickness: 1,
                height: 1,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                _isLogin ? 'New here?' : 'Already have an account?',
                style: TextStyle(
                  color: Theme.of(context).textSecondary.withOpacity(0.7),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: Theme.of(context).textSecondary.withOpacity(0.15),
                thickness: 1,
                height: 1,
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Toggle button
        SizedBox(
          width: double.infinity,
          height: 54,
          child: OutlinedButton(
            onPressed: _toggleMode,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primaryColor,
              side: BorderSide(
                color: AppTheme.primaryColor.withOpacity(0.3),
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: AppTheme.primaryColor.withOpacity(0.03),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isLogin ? Icons.person_add_alt_1_rounded : Icons.login_rounded,
                  size: 20,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  _isLogin ? 'Create New Account' : 'Sign In to Existing Account',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    Key? key,
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      key: key,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.grey.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: TextStyle(
          color: Theme.of(context).textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(
            color: Theme.of(context).textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          hintText: hintText,
          hintStyle: TextStyle(
            color: Theme.of(context).textSecondary.withOpacity(0.6),
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.only(left: 16, right: 12),
            child: Icon(
              prefixIcon,
              color: AppTheme.primaryColor,
              size: 22,
            ),
          ),
          suffixIcon: suffixIcon != null
              ? Container(
            margin: const EdgeInsets.only(right: 12),
            child: suffixIcon,
          )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 18),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
        ),
        validator: validator,
      ),
    );
  }

  Route _createRoute(Widget destination) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => destination,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 600),
    );
  }
}