import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:philippines_rpcmb/philippines_rpcmb.dart';
import 'package:the_legit_smoothie/core/constants/app_colors.dart';
import 'package:the_legit_smoothie/main.dart';
import '../services/auth_service.dart';
import 'package:flutter/services.dart';

class RegisterScreen extends StatefulWidget {
  final ThemeMode currentThemeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  const RegisterScreen({
    super.key,
    required this.currentThemeMode,
    required this.onThemeModeChanged,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKeyStep1 = GlobalKey<FormState>();
  final _formKeyStep2 = GlobalKey<FormState>();
  final _formKeyStep3 = GlobalKey<FormState>();

  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 4;

  // Step 1: Account
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _acceptedTerms = false;

  // Step 2: Personal
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();

  // Step 3: Address
  dynamic _selectedRegion;
  dynamic _selectedProvince;
  dynamic _selectedMunicipality;
  dynamic _selectedBarangay;
  final _streetAddressController = TextEditingController();

  final AuthService _authService = AuthService();

  late AnimationController _floatController;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _phoneController.text = '+63 9';
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    _pageController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _streetAddressController.dispose();
    super.dispose();
  }

  String _getLocationName(dynamic locationItem) {
    if (locationItem == null) return '';
    if (locationItem is String) return locationItem;

    try {
      // Priority check for common object properties in location packages
      final name =
          locationItem.name ??
          locationItem.regionName ??
          locationItem.provinceName ??
          locationItem.municipalityName ??
          locationItem.barangayName;

      if (name != null && name.toString().isNotEmpty) {
        return name.toString();
      }
    } catch (_) {}

    // Fallback cleanup if toString() produces "Region(name: NCR, id: 1)" or similar
    String str = locationItem.toString();
    if (str.contains('name:')) {
      final match = RegExp(r'name:\s*([^,\)}]+)').firstMatch(str);
      if (match != null && match.group(1) != null) {
        return match.group(1)!.trim();
      }
    }

    return str;
  }

  double _getCardHeight() {
    switch (_currentStep) {
      case 0:
        return 400; // Increased from 330 to fit validation errors cleanly
      case 1:
        return 420; // Increased from 340
      case 2:
        return 460;
      case 3:
        return 440;
      default:
        return 420;
    }
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (!_formKeyStep1.currentState!.validate()) return;
      if (!_acceptedTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please accept the Terms of Service & Privacy Policy to continue.',
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      _animateToPage(1);
    } else if (_currentStep == 1) {
      if (_formKeyStep2.currentState!.validate()) _animateToPage(2);
    } else if (_currentStep == 2) {
      if (!_formKeyStep3.currentState!.validate()) return;

      if (_selectedRegion == null ||
          _selectedProvince == null ||
          _selectedMunicipality == null ||
          _selectedBarangay == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select your complete location details.'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      _animateToPage(3);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) _animateToPage(_currentStep - 1);
  }

  void _animateToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() => _currentStep = page);
  }

  void _handleRegister() async {
    setState(() => _isLoading = true);

    try {
      await _authService.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        firstName: _firstNameController.text.trim(),
        middleName: _middleNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        region: _getLocationName(_selectedRegion),
        province: _getLocationName(_selectedProvince),
        cityMunicipality: _getLocationName(_selectedMunicipality),
        barangay: _getLocationName(_selectedBarangay),
        streetAddress: _streetAddressController.text.trim(),
        termsAccepted: _acceptedTerms,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Customer account created successfully! 🥤'),
          backgroundColor: AppColors.bobaBrown,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Navigate to AuthGate passing the current theme mode & theme switcher
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => AuthGate(
            currentThemeMode: widget.currentThemeMode,
            onThemeModeChanged: widget.onThemeModeChanged,
          ),
        ),
        (route) =>
            false, // Clears the back stack so user cannot pop back to RegisterScreen
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showTermsDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.bobaBrown,
          ),
        ),
        content: SingleChildScrollView(child: Text(content)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Close',
              style: TextStyle(color: AppColors.bobaBrown),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine if light mode is active
    final bool isLightMode =
        widget.currentThemeMode == ThemeMode.light ||
        (widget.currentThemeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.light);

    // Select background image based on current theme mode
    final String backgroundImagePath = isLightMode
        ? 'assets/bgWhite.png'
        : 'assets/bgBrown.png';

    return Scaffold(
      backgroundColor: isLightMode ? AppColors.background : AppColors.darkText,
      body: Stack(
        children: [
          // --- Dynamic Full Screen Background Image ---
          Positioned.fill(
            child: Image.asset(
              backgroundImagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: isLightMode ? AppColors.background : AppColors.darkText,
              ),
            ),
          ),

          // --- Floating Full-Color Image Background ---
          AnimatedBuilder(
            animation: _floatController,
            builder: (context, child) {
              final offset = math.sin(_floatController.value * math.pi) * 10;

              return Stack(
                children: [
                  Positioned(
                    top: 65 + offset,
                    left: 10,
                    child: _buildFloatingItem(
                      'assets/mangooreo.png',
                      size: 75,
                      angle: -0.2,
                    ),
                  ),
                  Positioned(
                    top: 85 - offset,
                    right: 10,
                    child: _buildFloatingItem(
                      'assets/avocadograham.png',
                      size: 85,
                      angle: 0.15,
                    ),
                  ),
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.45 + offset,
                    right: 15,
                    child: _buildFloatingItem(
                      'assets/dragonfruit.png',
                      size: 70,
                      angle: 0.3,
                    ),
                  ),
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.48 - offset,
                    left: 15,
                    child: _buildFloatingItem(
                      'assets/camel.png',
                      size: 65,
                      angle: -0.25,
                    ),
                  ),
                  Positioned(
                    bottom: 45 + offset,
                    left: 15,
                    child: _buildFloatingItem(
                      'assets/cookiesandcream.png',
                      size: 80,
                      angle: -0.1,
                    ),
                  ),
                  Positioned(
                    bottom: 55 - offset,
                    right: 15,
                    child: _buildFloatingItem(
                      'assets/lemon.png',
                      size: 75,
                      angle: 0.2,
                    ),
                  ),
                ],
              );
            },
          ),

          // --- Theme Toggle Button ---
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: IconButton.filledTonal(
                  onPressed: () {
                    final nextMode = isLightMode
                        ? ThemeMode.dark
                        : ThemeMode.light;
                    widget.onThemeModeChanged(nextMode);
                  },
                  icon: Icon(
                    isLightMode
                        ? Icons.dark_mode_rounded
                        : Icons.light_mode_rounded,
                    color: AppColors.bobaBrown,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.cardWhite.withValues(
                      alpha: 0.85,
                    ),
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 32.0,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    children: [
                      Container(
                        width: 170,
                        height: 170,
                        decoration: BoxDecoration(
                          color: AppColors.cardWhite,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.bobaBrown.withValues(alpha: 0.3),
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.bobaBrown.withValues(
                                alpha: 0.18,
                              ),
                              blurRadius: 28,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(16),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/logoSmoothie.png',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.local_drink_rounded,
                                size: 80,
                                color: AppColors.bobaBrown,
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        _getStepTitle(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: AppColors.bobaBrown,
                          letterSpacing: -0.8,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Step ${_currentStep + 1} of $_totalSteps',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isLightMode
                              ? AppColors.darkText.withValues(alpha: 0.8)
                              : AppColors.cardWhite,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Card Container (Dynamically resizes smooth per step)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        height: _getCardHeight(),
                        padding: const EdgeInsets.all(32.0),
                        decoration: BoxDecoration(
                          color: AppColors.cardWhite.withValues(
                            alpha: isLightMode ? 0.92 : 0.96,
                          ),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: Colors.white, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.darkText.withValues(alpha: 0.08),
                              blurRadius: 32,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: PageView(
                          controller: _pageController,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            _buildStep1Form(),
                            _buildStep2Form(),
                            _buildStep3AddressForm(),
                            _buildStep4ReviewForm(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 0:
        return 'Customer Registration';
      case 1:
        return 'Personal Info';
      case 2:
        return 'Address Details';
      case 3:
        return 'Review Details';
      default:
        return '';
    }
  }

  Widget _buildStep1Form() {
    return Form(
      key: _formKeyStep1,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(
                      color: AppColors.darkText,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: _buildInputDecoration(
                      label: 'Email Address',
                      icon: Icons.email_outlined,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppColors.greyText,
                          size: 20,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                    ),
                    validator: (v) {
                      final email = v?.trim() ?? '';
                      if (email.isEmpty) return 'Email is required';
                      final emailRegex = RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      );
                      if (!emailRegex.hasMatch(email)) {
                        return 'Enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: const TextStyle(
                      color: AppColors.darkText,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: _buildInputDecoration(
                      label: 'Password',
                      icon: Icons.lock_outline_rounded,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppColors.greyText,
                          size: 20,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                    ),
                    validator: (v) =>
                        (v == null || v.length < 6) ? 'Min 6 chars' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    style: const TextStyle(
                      color: AppColors.darkText,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: _buildInputDecoration(
                      label: 'Confitm Password',
                      icon: Icons.lock_outline_rounded,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          size: 20,
                        ),
                        onPressed: () => setState(
                          () => _obscureConfirmPassword =
                              !_obscureConfirmPassword,
                        ),
                      ),
                    ),

                    validator: (v) => v != _passwordController.text
                        ? 'Passwords do not match'
                        : null,
                  ),
                  const SizedBox(height: 10),

                  // Terms & Privacy Agreement Checkbox
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: _acceptedTerms,
                          activeColor: AppColors.bobaBrown,
                          checkColor:
                              Colors.white, // Colors the checkmark icon white
                          side: BorderSide(
                            color: AppColors.bobaBrown,
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          onChanged: (val) =>
                              setState(() => _acceptedTerms = val ?? false),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              color: AppColors.darkText,
                              fontSize: 11,
                            ),
                            children: [
                              const TextSpan(text: 'I agree to the '),
                              TextSpan(
                                text: 'Terms of Service',
                                style: const TextStyle(
                                  color: AppColors.bobaBrown,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () => _showTermsDialog(
                                    'Terms of Service',
                                    'By using The Legit Smoothie, you agree to place legitimate orders and provide accurate delivery information.',
                                  ),
                              ),
                              const TextSpan(text: ' and '),
                              TextSpan(
                                text: 'Privacy Policy',
                                style: const TextStyle(
                                  color: AppColors.bobaBrown,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () => _showTermsDialog(
                                    'Privacy Policy',
                                    'We value your privacy. Your address and contact details are strictly used for order processing and delivery.',
                                  ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: _nextStep,
              style: _buttonStyle(),
              child: const Text('Next: Personal Info'),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Already have an account? ",
                style: TextStyle(color: AppColors.greyText, fontSize: 13),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const Text(
                  'Sign In',
                  style: TextStyle(
                    color: AppColors.bobaBrown,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep2Form() {
    return Form(
      key: _formKeyStep2,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  TextFormField(
                    controller: _firstNameController,
                    style: const TextStyle(
                      color: AppColors.darkText,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: _buildInputDecoration(
                      label: 'First Name',
                      icon: Icons.person_outline,
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _middleNameController,
                    style: const TextStyle(
                      color: AppColors.darkText,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: _buildInputDecoration(
                      label: 'MIddle Name (Optional)',
                      icon: Icons.person_outline,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _lastNameController,
                    style: const TextStyle(
                      color: AppColors.darkText,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: _buildInputDecoration(
                      label: 'Last Name',
                      icon: Icons.person_outline,
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(
                      color: AppColors.darkText,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLength: 14,
                    inputFormatters: [
                      TextInputFormatter.withFunction((oldValue, newValue) {
                        const prefix = '+63 9';
                        if (!newValue.text.startsWith(prefix)) {
                          return oldValue.text.isNotEmpty
                              ? oldValue
                              : const TextEditingValue(
                                  text: prefix,
                                  selection: TextSelection.collapsed(
                                    offset: prefix.length,
                                  ),
                                );
                        }
                        return newValue;
                      }),
                      FilteringTextInputFormatter.allow(RegExp(r'^\+63 9\d*')),
                    ],
                    decoration: _buildInputDecoration(
                      label: '+63 9XXXXXXXXX',
                      icon: Icons.phone_outlined,
                    ).copyWith(counterText: ''),
                    validator: (v) {
                      final phone = v?.trim() ?? '';
                      if (phone.isEmpty || phone == '+63 9') {
                        return 'Phone number is required';
                      }
                      final phoneRegex = RegExp(r'^\+63 9\d{9}$');
                      if (!phoneRegex.hasMatch(phone)) {
                        return 'Must be formatted as +63 9XXXXXXXXX';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          _buildNavigationButtons(_nextStep, labelNext: 'Next: Address'),
        ],
      ),
    );
  }

  // --- Step 3: Address Selection ---
  Widget _buildStep3AddressForm() {
    return Form(
      key: _formKeyStep3,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildDropdownContainer(
                    child: PhilippineRegionDropdownView(
                      value: _selectedRegion,
                      onChanged: (value) {
                        setState(() {
                          _selectedRegion = value;
                          _selectedProvince = null;
                          _selectedMunicipality = null;
                          _selectedBarangay = null;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildDropdownContainer(
                    child: PhilippineProvinceDropdownView(
                      provinces: _selectedRegion?.provinces ?? [],
                      value: _selectedProvince,
                      onChanged: (value) {
                        setState(() {
                          _selectedProvince = value;
                          _selectedMunicipality = null;
                          _selectedBarangay = null;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildDropdownContainer(
                    child: PhilippineMunicipalityDropdownView(
                      municipalities: _selectedProvince?.municipalities ?? [],
                      value: _selectedMunicipality,
                      onChanged: (value) {
                        setState(() {
                          _selectedMunicipality = value;
                          _selectedBarangay = null;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildDropdownContainer(
                    child: PhilippineBarangayDropdownView(
                      barangays: _selectedMunicipality?.barangays ?? [],
                      value: _selectedBarangay,
                      onChanged: (value) {
                        setState(() {
                          _selectedBarangay = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _streetAddressController,
                    decoration: _buildInputDecoration(
                      label: 'House No. / Street Address',
                      icon: Icons.email_outlined,
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          _buildNavigationButtons(_nextStep, labelNext: 'Next: Review'),
        ],
      ),
    );
  }

  // --- Step 4 ---
  Widget _buildStep4ReviewForm() {
    final fullName = [
      _firstNameController.text.trim(),
      _middleNameController.text.trim(),
      _lastNameController.text.trim(),
    ].where((s) => s.isNotEmpty).join(' ');

    final regionStr = _getLocationName(_selectedRegion);
    final provinceStr = _getLocationName(_selectedProvince);
    final cityStr = _getLocationName(_selectedMunicipality);
    final barangayStr = _getLocationName(_selectedBarangay);
    final streetStr = _streetAddressController.text.trim();

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section 1: Account & Personal Info
                _buildReviewSectionHeader(
                  Icons.person_outline,
                  'Personal Details',
                ),
                const SizedBox(height: 6),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.background.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.greyBorder.withValues(alpha: 0.5),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Column(
                    children: [
                      _buildSummaryRow(
                        'Account Type',
                        'Customer',
                        isBadge: true,
                        badgeColor: AppColors.bobaBrown,
                      ),
                      const Divider(
                        height: 12,
                        thickness: 0.5,
                        color: AppColors.greyBorder,
                      ),
                      _buildSummaryRow('Full Name', fullName),
                      const Divider(
                        height: 12,
                        thickness: 0.5,
                        color: AppColors.greyBorder,
                      ),
                      _buildSummaryRow('Email', _emailController.text.trim()),
                      const Divider(
                        height: 12,
                        thickness: 0.5,
                        color: AppColors.greyBorder,
                      ),
                      _buildSummaryRow('Phone', _phoneController.text.trim()),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Section 2: Address Info (Renamed Header + Cleaned Itemized Layout)
                _buildReviewSectionHeader(
                  Icons.location_on_outlined,
                  'Address',
                ),
                const SizedBox(height: 6),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.background.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.greyBorder.withValues(alpha: 0.5),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Column(
                    children: [
                      _buildSummaryRow('Region', regionStr),
                      const Divider(
                        height: 12,
                        thickness: 0.5,
                        color: AppColors.greyBorder,
                      ),
                      _buildSummaryRow('Province', provinceStr),
                      const Divider(
                        height: 12,
                        thickness: 0.5,
                        color: AppColors.greyBorder,
                      ),
                      _buildSummaryRow('City/Muni', cityStr),
                      const Divider(
                        height: 12,
                        thickness: 0.5,
                        color: AppColors.greyBorder,
                      ),
                      _buildSummaryRow('Barangay', barangayStr),
                      const Divider(
                        height: 12,
                        thickness: 0.5,
                        color: AppColors.greyBorder,
                      ),
                      _buildSummaryRow('Street', streetStr, isMultiline: true),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Section 3: Legal
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.green.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        color: Colors.green,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Terms & Privacy Policy Accepted',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkText,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'VERIFIED',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildNavigationButtons(
          _handleRegister,
          labelNext: 'Complete Sign Up',
          isFinal: true,
        ),
      ],
    );
  }

  // Helper: Section Headers
  Widget _buildReviewSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.bobaBrown),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.bobaBrown,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  // Helper: Customized Professional Summary Row
  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isBadge = false,
    Color? badgeColor,
    bool isMultiline = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: isMultiline
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.greyText,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: isBadge
                ? Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: (badgeColor ?? AppColors.bobaBrown).withValues(
                          alpha: 0.15,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        value,
                        style: TextStyle(
                          color: badgeColor ?? AppColors.bobaBrown,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  )
                : Text(
                    value.isEmpty ? '-' : value,
                    textAlign: TextAlign.end,
                    maxLines: isMultiline ? 3 : 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                      color: AppColors.darkText,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.greyBorder),
      ),
      child: child,
    );
  }

  Widget _buildNavigationButtons(
    VoidCallback onNext, {
    required String labelNext,
    bool isFinal = false,
  }) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _previousStep,
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Back',
              style: TextStyle(color: AppColors.bobaBrown),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: _isLoading ? null : onNext,
            style: _buttonStyle(),
            child: _isLoading
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      color: AppColors.cream,
                      strokeWidth: 2,
                    ),
                  )
                : Text(labelNext),
          ),
        ),
      ],
    );
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.bobaBrown,
      foregroundColor: AppColors.cream,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _buildFloatingItem(
    String assetPath, {
    required double size,
    required double angle,
  }) {
    return Transform.rotate(
      angle: angle,
      child: Image.asset(
        assetPath,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        color: AppColors.greyText,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      prefixIcon: Icon(icon, color: AppColors.bobaBrown, size: 22),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.background.withValues(alpha: 0.6),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: AppColors.greyBorder.withValues(alpha: 0.8),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.bobaBrown, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
    );
  }
}
