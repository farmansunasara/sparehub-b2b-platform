import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';
import '../../services/api_service.dart';
import '../../utils/form_validators.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/common.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  final Logger _logger = Logger();

  Future<void> _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Dismiss keyboard
      FocusScope.of(context).unfocus();

      setState(() {
        _isLoading = true;
      });

      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        _logger.i('Attempting login for email: ${_emailController.text}');

        await authProvider.login(
          _emailController.text,
          _passwordController.text,
        );

        if (!mounted) return;

        if (authProvider.isAuthenticated && authProvider.currentUser != null) {
          final userRole = authProvider.currentUser!.role;
          if (userRole == 'manufacturer') {
            Navigator.pushReplacementNamed(context, '/manufacturer/home');
          } else if (userRole == 'shop') {
            Navigator.pushReplacementNamed(context, '/shop/home');
          } else {
            throw Exception('Invalid user role: $userRole');
          }
        } else {
          throw Exception('Authentication failed: No user data available');
        }
      } catch (e) {
        _logger.e('Login failed: $e');
        if (!mounted) return;

        String errorMessage;
        if (e.toString().contains('Invalid credentials')) {
          errorMessage = 'Incorrect email or password. Please try again.';
        } else if (e.toString().contains('Network error')) {
          errorMessage = 'Network error. Please check your connection.';
        } else {
          errorMessage = 'Login failed. Please try again.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorMessage,
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _handleLogin,
            ),
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _handleForgotPassword() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter your email to reset password',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Placeholder for forgot password logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Password reset link sent to ${_emailController.text}',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: LoadingOverlay(
          isLoading: _isLoading,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 48),
                    // Logo and Welcome Text
                    Center(
                      child: Semantics(
                        label: 'SpareHub Logo',
                        child: Image.asset(
                          'assets/logos/sparehub_ic_logo.png',
                          height: MediaQuery.of(context).size.width * 0.2,
                          errorBuilder: (context, error, stackTrace) {
                            _logger.e('Failed to load logo: $error');
                            return Icon(
                              Icons.storefront,
                              size: MediaQuery.of(context).size.width * 0.2,
                              color: theme.primaryColor,
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Welcome to SpareHub!',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: theme.primaryColor,
                      ),
                      textAlign: TextAlign.center,
                      semanticsLabel: 'Welcome to SpareHub!',
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Login to manage your auto parts business',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                      semanticsLabel: 'Login to manage your auto parts business',
                    ),
                    const SizedBox(height: 48),
                    // Email Field
                    Semantics(
                      label: 'Email input',
                      child: TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          hintText: 'Enter your email',
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: theme.inputDecorationTheme.border ??
                              OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                          filled: true,
                          fillColor: theme.inputDecorationTheme.fillColor ?? Colors.grey[100],
                          labelStyle: GoogleFonts.poppins(),
                          hintStyle: GoogleFonts.poppins(),
                        ),
                        style: GoogleFonts.poppins(),
                        validator: FormValidators.validateEmail,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Password Field
                    Semantics(
                      label: 'Password input',
                      child: TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'Enter your password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                          ),
                          border: theme.inputDecorationTheme.border ??
                              OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                          filled: true,
                          fillColor: theme.inputDecorationTheme.fillColor ?? Colors.grey[100],
                          labelStyle: GoogleFonts.poppins(),
                          hintStyle: GoogleFonts.poppins(),
                        ),
                        style: GoogleFonts.poppins(),
                        validator: FormValidators.validatePassword,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _handleForgotPassword,
                        child: Text(
                          'Forgot Password?',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFFFF9800),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Login Button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF9800),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      child: Text(
                        'Login',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Register Option
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Don\'t have an account?',
                          style: GoogleFonts.poppins(
                            color: Colors.grey[600],
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/auth/role-selection');
                          },
                          child: Text(
                            'Register',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFFFF9800),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}