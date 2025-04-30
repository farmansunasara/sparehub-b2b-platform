import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';
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
  late Animation<double> _scaleAnimation;
  final Logger _logger = Logger();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _controller.forward().then((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    final startTime = DateTime.now();
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.loadProfile();

      if (!mounted) return;

      // Ensure minimum splash duration (1.5 seconds)
      final elapsed = DateTime.now().difference(startTime).inMilliseconds;
      final remaining = 1500 - elapsed;
      if (remaining > 0) {
        await Future.delayed(Duration(milliseconds: remaining));
      }

      if (authProvider.currentUser != null) {
        if (authProvider.currentUser!.role == 'manufacturer') {
          Navigator.pushReplacementNamed(context, '/manufacturer/home');
        } else {
          Navigator.pushReplacementNamed(context, '/shop/home');
        }
      } else {
        await _navigateToLoginOrOnboarding();
      }
    } catch (e) {
      _logger.e('Initialization error: $e');
      if (!mounted) return;

      final errorMessage = e.toString();
      if (errorMessage.contains('Authentication required')) {
        await _navigateToLoginOrOnboarding();
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              'Error',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            content: Text(
              'Failed to initialize app: $errorMessage',
              style: GoogleFonts.poppins(),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _initializeApp();
                },
                child: Text(
                  'Retry',
                  style: GoogleFonts.poppins(color: const Color(0xFFFF9800)),
                ),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  await authProvider.logout();
                  if (!mounted) return;
                  Navigator.pushReplacementNamed(context, '/auth/login');
                },
                child: Text(
                  'Go to Login',
                  style: GoogleFonts.poppins(color: Colors.red),
                ),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _navigateToLoginOrOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
    if (!mounted) return;

    if (hasSeenOnboarding) {
      Navigator.pushReplacementNamed(context, '/auth/login');
    } else {
      Navigator.pushReplacementNamed(context, '/onboarding');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<ThemeProvider>().isDarkMode;
    final backgroundGradient = isDarkMode
        ? LinearGradient(
            colors: [
              const Color(0xFF121212),
              const Color(0xFF1E1E1E),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          )
        : LinearGradient(
            colors: [
              const Color(0xFF1976D2), // Primary blue
              const Color(0xFFFF9800), // Orange accent
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: backgroundGradient,
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Semantics(
                label: 'SpareHub Splash Screen',
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/logos/sparehub_ic_logo.png',
                        width: MediaQuery.of(context).size.width * 0.3,
                        height: MediaQuery.of(context).size.width * 0.3,
                        semanticLabel: 'SpareHub Logo',
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.storefront,
                          size: MediaQuery.of(context).size.width * 0.3,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'SpareHub',
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 1.2,
                        shadows: [
                          Shadow(
                            blurRadius: 4,
                            color: Colors.black.withOpacity(0.3),
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                      semanticsLabel: 'SpareHub',
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Empowering Auto Parts Trade',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.white70,
                      ),
                      semanticsLabel: 'Empowering Auto Parts Trade',
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF9800)),
                        strokeWidth: 3,
                      ),
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
}