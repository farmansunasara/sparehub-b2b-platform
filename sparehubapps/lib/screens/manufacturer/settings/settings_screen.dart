import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/common/common.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoading = false;
  bool _notificationsEnabled = true;
  bool _emailNotificationsEnabled = true;
  bool _lowStockAlertsEnabled = true;
  bool _orderUpdatesEnabled = true;
  String _selectedCurrency = '₹ (INR)';
  String _selectedLanguage = 'English';
  ThemeMode _selectedTheme = ThemeMode.system;

  final List<String> _availableCurrencies = [
    '₹ (INR)',
    '\$ (USD)',
    '€ (EUR)',
    '£ (GBP)',
  ];

  final List<String> _availableLanguages = [
    'English',
    'Hindi',
    'Tamil',
    'Telugu',
    'Marathi',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Notifications Section
            _buildSection(
              title: 'Notifications',
              children: [
                SwitchListTile(
                  title: const Text('Push Notifications'),
                  subtitle: const Text('Receive notifications on your device'),
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text('Email Notifications'),
                  subtitle: const Text('Receive notifications via email'),
                  value: _emailNotificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _emailNotificationsEnabled = value;
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text('Low Stock Alerts'),
                  subtitle: const Text('Get notified when products are low in stock'),
                  value: _lowStockAlertsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _lowStockAlertsEnabled = value;
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text('Order Updates'),
                  subtitle: const Text('Get notified about order status changes'),
                  value: _orderUpdatesEnabled,
                  onChanged: (value) {
                    setState(() {
                      _orderUpdatesEnabled = value;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),
            // Preferences Section
            _buildSection(
              title: 'Preferences',
              children: [
                ListTile(
                  title: const Text('Currency'),
                  subtitle: Text(_selectedCurrency),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    _showSelectionDialog(
                      title: 'Select Currency',
                      options: _availableCurrencies,
                      selectedValue: _selectedCurrency,
                      onSelected: (value) {
                        setState(() {
                          _selectedCurrency = value;
                        });
                      },
                    );
                  },
                ),
                ListTile(
                  title: const Text('Language'),
                  subtitle: Text(_selectedLanguage),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    _showSelectionDialog(
                      title: 'Select Language',
                      options: _availableLanguages,
                      selectedValue: _selectedLanguage,
                      onSelected: (value) {
                        setState(() {
                          _selectedLanguage = value;
                        });
                      },
                    );
                  },
                ),
                ListTile(
                  title: const Text('Theme'),
                  subtitle: Text(_getThemeText(_selectedTheme)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    _showThemeSelectionDialog();
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),
            // Security Section
            _buildSection(
              title: 'Security',
              children: [
                ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: const Text('Change Password'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Implement change password
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.key_outlined),
                  title: const Text('API Keys'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Implement API keys management
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.verified_user_outlined),
                  title: const Text('Two-Factor Authentication'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Implement 2FA
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),
            // Support Section
            _buildSection(
              title: 'Support',
              children: [
                ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: const Text('Help Center'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Navigate to help center
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.chat_outlined),
                  title: const Text('Contact Support'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Implement contact support
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: const Text('Terms of Service'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Show terms of service
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const Text('Privacy Policy'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Show privacy policy
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),
            // Account Section
            _buildSection(
              title: 'Account',
              children: [
                ListTile(
                  leading: const Icon(Icons.delete_outline),
                  title: const Text('Delete Account'),
                  textColor: Colors.red,
                  iconColor: Colors.red,
                  onTap: () {
                    _showDeleteAccountDialog();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Logout'),
                  textColor: Colors.red,
                  iconColor: Colors.red,
                  onTap: () {
                    _showLogoutDialog();
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),
            // App Info
            Center(
              child: Text(
                'SpareHub v1.0.0',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Future<void> _showSelectionDialog({
    required String title,
    required List<String> options,
    required String selectedValue,
    required ValueChanged<String> onSelected,
  }) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: options.map((option) {
              return RadioListTile<String>(
                title: Text(option),
                value: option,
                groupValue: selectedValue,
                onChanged: (value) {
                  Navigator.pop(context, value);
                },
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (result != null) {
      onSelected(result);
    }
  }

  Future<void> _showThemeSelectionDialog() async {
    final result = await showDialog<ThemeMode>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Theme'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: ThemeMode.values.map((theme) {
              return RadioListTile<ThemeMode>(
                title: Text(_getThemeText(theme)),
                value: theme,
                groupValue: _selectedTheme,
                onChanged: (value) {
                  Navigator.pop(context, value);
                },
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() {
        _selectedTheme = result;
      });
    }
  }

  String _getThemeText(ThemeMode theme) {
    switch (theme) {
      case ThemeMode.system:
        return 'System Default';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }

  Future<void> _showDeleteAccountDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      // TODO: Implement account deletion
    }
  }

  Future<void> _showLogoutDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      final provider = Provider.of<AuthProvider>(context, listen: false);
      await provider.logout();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/auth/login');
      }
    }
  }
}
