import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    _controller.forward().then((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    try {
      // Check auth status directly
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.loadProfile();

      if (!mounted) return;

      // Navigate based on auth status
      if (authProvider.currentUser != null) {
        // User is logged in, navigate to appropriate home screen
        if (authProvider.currentUser!.role == 'manufacturer') {
          Navigator.pushReplacementNamed(context, '/manufacturer/home');
        } else {
          Navigator.pushReplacementNamed(context, '/shop/home');
        }
      } else {
        // Check if first time launch
        final prefs = await SharedPreferences.getInstance();
        final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;

        if (hasSeenOnboarding) {
          Navigator.pushReplacementNamed(context, '/auth/login');
        } else {
          Navigator.pushReplacementNamed(context, '/onboarding');
        }
      }
    } catch (e) {
      if (!mounted) return;

      final errorMessage = e.toString();
      if (errorMessage.contains('Authentication required')) {
        // Clear auth state and navigate to login screen
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.logout();
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/auth/login');
        return;
      }

      // Show error dialog if initialization fails for other reasons
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('Failed to initialize app: $errorMessage'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _initializeApp(); // Retry initialization
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use theme from ThemeProvider
    final isDarkMode = context.watch<ThemeProvider>().isDarkMode;
    final backgroundColor = isDarkMode ?
    const Color(0xFF121212) :
    Theme.of(context).primaryColor;
    final textColor = isDarkMode ? Colors.white : Colors.white;
    final subtitleColor = isDarkMode ? Colors.white70 : Colors.white70;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logos/sparehub_ic_logo.png',
                width: 150,
                height: 150,
              ),
              const SizedBox(height: 24),
              Text(
                'SpareHub',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your B2B Auto Parts Marketplace',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: subtitleColor,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(textColor),
                  strokeWidth: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
