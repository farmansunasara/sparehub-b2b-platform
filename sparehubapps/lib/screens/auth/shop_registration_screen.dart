import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';
import '../../services/api_service.dart';
import '../../utils/form_validators.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/common.dart';
import 'package:provider/provider.dart';

class ShopRegistrationScreen extends StatefulWidget {
  const ShopRegistrationScreen({super.key});

  @override
  State<ShopRegistrationScreen> createState() => _ShopRegistrationScreenState();
}

class _ShopRegistrationScreenState extends State<ShopRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Form Controllers and Focus Nodes
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _shopNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _gstNumberController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();

  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();
  final _shopNameFocus = FocusNode();
  final _ownerNameFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _gstNumberFocus = FocusNode();
  final _addressFocus = FocusNode();
  final _cityFocus = FocusNode();
  final _stateFocus = FocusNode();
  final _countryFocus = FocusNode();

  XFile? _shopLogoFile;
  bool _termsAccepted = false;
  final Logger _logger = Logger();

  // Business Type Variables
  String _selectedBusinessType = 'Retailer';
  final List<String> _businessTypes = ['Retailer', 'Wholesaler', 'Distributor'];

  final List<String> _steps = [
    'Account',
    'Shop Info',
    'Location',
    'Verification',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _shopNameController.dispose();
    _ownerNameController.dispose();
    _phoneController.dispose();
    _gstNumberController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    _shopNameFocus.dispose();
    _ownerNameFocus.dispose();
    _phoneFocus.dispose();
    _gstNumberFocus.dispose();
    _addressFocus.dispose();
    _cityFocus.dispose();
    _stateFocus.dispose();
    _countryFocus.dispose();
    super.dispose();
  }

  Future<bool> _confirmExit() async {
    if (_isLoading) return false;
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Exit Registration', style: GoogleFonts.poppins()),
            content: Text(
              'Are you sure you want to exit? Your progress will be lost.',
              style: GoogleFonts.poppins(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel', style: GoogleFonts.poppins()),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: Text('Exit', style: GoogleFonts.poppins()),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return WillPopScope(
      onWillPop: _confirmExit,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Join SpareHub as Shop Owner',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: theme.appBarTheme.foregroundColor,
            ),
          ),
          backgroundColor: theme.appBarTheme.backgroundColor,
          foregroundColor: theme.appBarTheme.foregroundColor,
          elevation: theme.appBarTheme.elevation,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              if (_currentStep > 0) {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              } else {
                if (await _confirmExit()) {
                  Navigator.pop(context);
                }
              }
            },
          ),
        ),
        body: LoadingOverlay(
          isLoading: _isLoading,
          child: Column(
            children: [
              // Progress Indicator
              Container(
                padding: const EdgeInsets.all(16),
                color: theme.cardTheme.color ?? Colors.white,
                child: Row(
                  children: List.generate(
                    _steps.length,
                    (index) => Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        child: Column(
                          children: [
                            Container(
                              height: 4,
                              decoration: BoxDecoration(
                                color: index <= _currentStep
                                    ? const Color(0xFFFF9800)
                                    : Colors.grey[300],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _steps[index],
                              style: GoogleFonts.poppins(
                                color: index <= _currentStep
                                    ? const Color(0xFFFF9800)
                                    : Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Form Pages
              Expanded(
                child: Form(
                  key: _formKey,
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (index) {
                      setState(() {
                        _currentStep = index;
                        FocusScope.of(context).unfocus();
                      });
                    },
                    children: [
                      _buildAccountDetailsPage(),
                      _buildShopInfoPage(),
                      _buildLocationDetailsPage(),
                      _buildVerificationPage(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountDetailsPage() {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Create Your Account',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: theme.primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Semantics(
            label: 'Email',
            child: TextFormField(
              key: const ValueKey('email'),
              controller: _emailController,
              focusNode: _emailFocus,
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
              onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_passwordFocus),
            ),
          ),
          const SizedBox(height: 16),
          Semantics(
            label: 'Password',
            child: TextFormField(
              key: const ValueKey('password'),
              controller: _passwordController,
              focusNode: _passwordFocus,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Create a strong password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
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
              onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_confirmPasswordFocus),
            ),
          ),
          const SizedBox(height: 16),
          Semantics(
            label: 'Confirm Password',
            child: TextFormField(
              key: const ValueKey('confirm_password'),
              controller: _confirmPasswordController,
              focusNode: _confirmPasswordFocus,
              obscureText: _obscureConfirmPassword,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                hintText: 'Re-enter your password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                  tooltip: _obscureConfirmPassword ? 'Show confirm password' : 'Hide confirm password',
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
              validator: (value) => FormValidators.validateConfirmPassword(
                value,
                _passwordController.text,
              ),
              onFieldSubmitted: (_) {
                if (_formKey.currentState?.validate() ?? false) {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              },
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            },
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
              'Next',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShopInfoPage() {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Shop Information',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: theme.primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Semantics(
            label: 'Shop Name',
            child: TextFormField(
              key: const ValueKey('shop_name'),
              controller: _shopNameController,
              focusNode: _shopNameFocus,
              decoration: InputDecoration(
                labelText: 'Shop Name',
                hintText: 'Enter your shop name',
                prefixIcon: const Icon(Icons.store_outlined),
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
              validator: FormValidators.validateRequiredField,
              onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_ownerNameFocus),
            ),
          ),
          const SizedBox(height: 16),
          Semantics(
            label: 'Owner Name',
            child: TextFormField(
              key: const ValueKey('owner_name'),
              controller: _ownerNameController,
              focusNode: _ownerNameFocus,
              decoration: InputDecoration(
                labelText: 'Owner Name',
                hintText: "Enter owner's name",
                prefixIcon: const Icon(Icons.person_outline),
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
              validator: FormValidators.validateRequiredField,
              onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_phoneFocus),
            ),
          ),
          const SizedBox(height: 16),
          Semantics(
            label: 'Phone Number',
            child: TextFormField(
              key: const ValueKey('phone'),
              controller: _phoneController,
              focusNode: _phoneFocus,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                hintText: 'Enter shop phone number',
                prefixIcon: const Icon(Icons.phone_outlined),
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
              validator: FormValidators.validatePhone,
              onFieldSubmitted: (_) {
                if (_formKey.currentState?.validate() ?? false) {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              },
            ),
          ),
          const SizedBox(height: 16),
          Semantics(
            label: 'Business Type',
            child: DropdownButtonFormField<String>(
              key: const ValueKey('business_type'),
              value: _selectedBusinessType,
              decoration: InputDecoration(
                labelText: 'Business Type',
                prefixIcon: const Icon(Icons.business_outlined),
                border: theme.inputDecorationTheme.border ??
                    OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                filled: true,
                fillColor: theme.inputDecorationTheme.fillColor ?? Colors.grey[100],
                labelStyle: GoogleFonts.poppins(),
                hintStyle: GoogleFonts.poppins(),
              ),
              items: _businessTypes.map((String type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(
                    type,
                    style: GoogleFonts.poppins(),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedBusinessType = newValue!;
                });
              },
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.primaryColor,
                    side: BorderSide(color: theme.primaryColor),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Back',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
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
                    'Next',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationDetailsPage() {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Location Details',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: theme.primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Semantics(
            label: 'Shop Address',
            child: TextFormField(
              key: const ValueKey('address'),
              controller: _addressController,
              focusNode: _addressFocus,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Shop Address',
                hintText: 'Enter your shop address',
                prefixIcon: const Icon(Icons.location_on_outlined),
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
              validator: FormValidators.validateRequiredField,
              onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_cityFocus),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Semantics(
                  label: 'City',
                  child: TextFormField(
                    key: const ValueKey('city'),
                    controller: _cityController,
                    focusNode: _cityFocus,
                    decoration: InputDecoration(
                      labelText: 'City',
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
                    validator: FormValidators.validateRequiredField,
                    onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_stateFocus),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Semantics(
                  label: 'State',
                  child: TextFormField(
                    key: const ValueKey('state'),
                    controller: _stateController,
                    focusNode: _stateFocus,
                    decoration: InputDecoration(
                      labelText: 'State',
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
                    validator: FormValidators.validateRequiredField,
                    onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_countryFocus),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Semantics(
            label: 'Country',
            child: TextFormField(
              key: const ValueKey('country'),
              controller: _countryController,
              focusNode: _countryFocus,
              decoration: InputDecoration(
                labelText: 'Country',
                hintText: 'Enter your country',
                prefixIcon: const Icon(Icons.flag_outlined),
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
              validator: FormValidators.validateRequiredField,
              onFieldSubmitted: (_) {
                if (_formKey.currentState?.validate() ?? false) {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              },
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.primaryColor,
                    side: BorderSide(color: theme.primaryColor),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Back',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
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
                    'Next',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationPage() {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Verification',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: theme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Semantics(
            label: 'GST Number',
            child: TextFormField(
              key: const ValueKey('gst_number'),
              controller: _gstNumberController,
              focusNode: _gstNumberFocus,
              decoration: InputDecoration(
                labelText: 'GST Number',
                hintText: 'Enter your GST number',
                prefixIcon: const Icon(Icons.numbers_outlined),
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
              validator: FormValidators.validateGST,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: theme.cardTheme.elevation ?? 2,
            shape: theme.cardTheme.shape ?? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: theme.cardTheme.color ?? Colors.white,
            child: InkWell(
              onTap: _pickShopLogo,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_shopLogoFile != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(_shopLogoFile!.path),
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            _logger.e('Failed to load logo preview: $error');
                            return const Icon(
                              Icons.error,
                              size: 100,
                              color: Colors.red,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 16,
                            color: const Color(0xFFFF9800),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Logo Selected',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFFFF9800),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: _pickShopLogo,
                            child: Text(
                              'Change',
                              style: GoogleFonts.poppins(
                                color: const Color(0xFFFF9800),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      Icon(
                        Icons.upload_file,
                        size: 32,
                        color: const Color(0xFFFF9800),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Upload Shop Logo (Optional)',
                        style: GoogleFonts.poppins(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Recommended size: 512x512px',
                        style: GoogleFonts.poppins(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Semantics(
            label: 'Terms and Conditions',
            child: CheckboxListTile(
              value: _termsAccepted,
              onChanged: (value) {
                setState(() {
                  _termsAccepted = value ?? false;
                });
              },
              title: Text(
                'I accept the terms and conditions',
                style: GoogleFonts.poppins(),
              ),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              activeColor: const Color(0xFFFF9800),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.primaryColor,
                    side: BorderSide(color: theme.primaryColor),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Back',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isLoading || !_termsAccepted ? null : _handleRegistration,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9800),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Register',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickShopLogo() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null) {
        final file = File(image.path);
        final sizeInBytes = await file.length();
        final sizeInMB = sizeInBytes / (1024 * 1024);

        if (sizeInMB > 2) {
          _showErrorSnackBar('Logo file size must be less than 2MB');
          return;
        }

        setState(() {
          _shopLogoFile = image;
        });
      }
    } catch (e) {
      _logger.e('Error picking logo: $e');
      _showErrorSnackBar('Error picking logo: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: GoogleFonts.poppins(),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: () async {
              if (_currentStep == _steps.length - 1) {
                _logger.i('Retrying registration for email: ${_emailController.text}');
                await _handleRegistration();
              }
            },
          ),
        ),
      );
    }
  }

  Future<void> _handleRegistration() async {
    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      _showErrorSnackBar('Please fill in all required fields correctly');
      return;
    }

    if (!_termsAccepted) {
      _showErrorSnackBar('Please accept the terms and conditions');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final apiService = Provider.of<ApiService>(context, listen: false);

      _logger.i('Attempting shop registration for email: ${_emailController.text}');

      final requestData = {
        'email': _emailController.text.trim(),
        'password': _passwordController.text,
        'shop_name': _shopNameController.text.trim(),
        'owner_name': _ownerNameController.text.trim(),
        'phone_number': _phoneController.text.trim(),
        'gst_number': _gstNumberController.text.trim(),
        'address': _addressController.text.trim(),
        'city': _cityController.text.trim(),
        'state': _stateController.text.trim(),
        'country': _countryController.text.trim(),
        'business_type': _selectedBusinessType,
        'terms_accepted': _termsAccepted.toString(),
      };

      var uri = Uri.parse('${ApiService.baseUrl}/users/register-shop/');
      var request = http.MultipartRequest('POST', uri);
      request.fields.addAll({
        for (var entry in requestData.entries) entry.key: entry.value.toString(),
      });

      if (_shopLogoFile != null) {
        final logoExtension = _shopLogoFile!.path.split('.').last.toLowerCase();
        final mimeType = logoExtension == 'png' ? 'image/png' : 'image/jpeg';
        final file = await http.MultipartFile.fromPath(
          'logo',
          _shopLogoFile!.path,
          contentType: MediaType.parse(mimeType),
        );
        request.files.add(file);
      }

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Connection timed out. Please try again.');
        },
      );

      final response = await http.Response.fromStream(streamedResponse);
      final responseData = json.decode(response.body);

      if (response.statusCode == 201) {
        await authProvider.login(
          _emailController.text.trim(),
          _passwordController.text,
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'Registration successful!',
                  style: GoogleFonts.poppins(),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/shop/home');
          }
        });
      } else {
        String errorMessage = 'Registration failed';
        if (responseData.containsKey('error')) {
          errorMessage = responseData['error'];
        } else if (responseData.containsKey('detail')) {
          errorMessage = responseData['detail'];
        } else if (response.statusCode == 400) {
          errorMessage = responseData.entries
              .map((e) => '${e.key}: ${e.value is List ? e.value.join(", ") : e.value}')
              .join('; ');
        } else if (response.statusCode == 409) {
          errorMessage = 'An account with this email already exists.';
        } else if (response.statusCode >= 500) {
          errorMessage = 'Server error. Please try again later.';
        }
        throw Exception(errorMessage);
      }
    } on TimeoutException {
      _showErrorSnackBar('Connection timed out. Please check your internet connection.');
    } on http.ClientException catch (e) {
      _showErrorSnackBar('Network error: ${e.message}');
    } catch (e) {
      String errorMessage = 'Registration failed';
      if (e.toString().contains('already exists')) {
        errorMessage = 'An account with this email already exists.';
      } else if (e.toString().contains('Invalid GST')) {
        errorMessage = 'Please enter a valid GST number.';
      } else if (e.toString().contains('Server error')) {
        errorMessage = 'Server error. Please try again later.';
      }
      _showErrorSnackBar(errorMessage);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}