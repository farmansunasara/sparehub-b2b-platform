import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  final Logger _logger = Logger();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _navigateTo(String route) async {
    try {
      Navigator.pushNamed(context, route);
      _logger.i('Navigated to: $route');
    } catch (e) {
      _logger.e('Navigation error to $route: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error navigating: $e',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: () => _navigateTo(route),
          ),
        ),
      );
    }
  }

  Future<void> _navigateToLogin() async {
    try {
      Navigator.pushReplacementNamed(context, '/auth/login');
      _logger.i('Navigated to login');
    } catch (e) {
      _logger.e('Navigation error to login: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error navigating: $e',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: _navigateToLogin,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final topPadding = screenHeight * 0.08; // 8% of screen height
    final bottomPadding = screenHeight * 0.05; // 5% of screen height

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(24.0, topPadding, 24.0, bottomPadding),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Semantics(
                        label: 'SpareHub Logo',
                        child: Image.asset(
                          'assets/logos/sparehub_ic_logo.png',
                          height: screenHeight * 0.15,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            _logger.e('Failed to load logo: $error');
                            return Icon(
                              Icons.storefront,
                              size: screenHeight * 0.15,
                              color: theme.primaryColor,
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.04),
                    Text(
                      'Join SpareHub',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: theme.primaryColor,
                      ),
                      textAlign: TextAlign.center,
                      semanticsLabel: 'Join SpareHub',
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Select your role to get started',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                      semanticsLabel: 'Select your role to get started',
                    ),
                    SizedBox(height: screenHeight * 0.06),
                    _buildRoleCard(
                      context,
                      title: 'Manufacturer',
                      description: 'List your products and reach thousands of auto parts retailers',
                      icon: Icons.factory_outlined,
                      onTap: () => _navigateTo('/auth/manufacturer'),
                    ),
                    const SizedBox(height: 16),
                    _buildRoleCard(
                      context,
                      title: 'Shop Owner',
                      description: 'Source quality spare parts directly from manufacturers',
                      icon: Icons.store_outlined,
                      onTap: () => _navigateTo('/auth/shop'),
                    ),
                    SizedBox(height: screenHeight * 0.06),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account?',
                          style: GoogleFonts.poppins(
                            color: Colors.grey[600],
                          ),
                        ),
                        TextButton(
                          onPressed: _navigateToLogin,
                          child: Text(
                            'Login',
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

  Widget _buildRoleCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: theme.cardTheme.elevation ?? 2,
      shape: theme.cardTheme.shape ?? RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: theme.cardTheme.color ?? Colors.white,
      child: InkWell(
        onTap: () {
          _logger.i('Role selected: $title');
          onTap();
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9800).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Semantics(
                  label: '$title icon',
                  child: Icon(
                    icon,
                    size: 28,
                    color: const Color(0xFFFF9800),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: theme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Semantics(
                label: 'Select $title',
                child: Icon(
                  Icons.chevron_right,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}