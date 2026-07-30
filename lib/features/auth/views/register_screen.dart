import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:philippines_rpcmb/philippines_rpcmb.dart';
import 'package:the_legit_smoothie/core/constants/app_colors.dart';
import '../services/auth_service.dart';

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

  // Page controller for multi-step navigation
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 4;

  // Controllers - Step 1: Account Info
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Controllers - Step 2: Personal Info
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();

  // Controllers & States - Step 3: Address
  final _streetAddressController = TextEditingController();
  Region? _selectedRegion;
  Province? _selectedProvince;
  Municipality? _selectedMunicipality;
  String? _selectedBarangay;

  final AuthService _authService = AuthService();
  late AnimationController _floatController;

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
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

  void _nextStep() {
    if (_currentStep == 0) {
      if (_formKeyStep1.currentState!.validate()) {
        _animateToPage(1);
      }
    } else if (_currentStep == 1) {
      if (_formKeyStep2.currentState!.validate()) {
        _animateToPage(2);
      }
    } else if (_currentStep == 2) {
      if (!_formKeyStep3.currentState!.validate()) return;

      if (_selectedRegion == null ||
          _selectedProvince == null ||
          _selectedMunicipality == null ||
          _selectedBarangay == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select your complete address.'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      _animateToPage(3);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _animateToPage(_currentStep - 1);
    }
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
      final registrationData = {
        'email': _emailController.text.trim(),
        'password': _passwordController.text,
        'firstName': _firstNameController.text.trim(),
        'middleName': _middleNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'region': _selectedRegion.toString(),
        'province': _selectedProvince.toString(),
        'municipality': _selectedMunicipality.toString(),
        'barangay': _selectedBarangay,
        'streetAddress': _streetAddressController.text.trim(),
      };

      await Future.delayed(const Duration(seconds: 1)); // Mock API delay

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully! Please sign in.'),
          backgroundColor: AppColors.bobaBrown,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.of(context).pop();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background Asset
          Positioned.fill(
            child: Image.asset(
              'assets/bgBrown.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Container(color: AppColors.background),
            ),
          ),

          // Floating Smoothies Background Animation
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

          // Main Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 20.0,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          color: Colors.white,
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
                        padding: const EdgeInsets.all(10),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/logoSmoothie.png',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                                  Icons.local_drink_rounded,
                                  size: 50,
                                  color: AppColors.bobaBrown,
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Text(
                        _getStepTitle(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: AppColors.bobaBrown,
                          letterSpacing: -0.8,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Step ${_currentStep + 1} of $_totalSteps: ${_getStepSubtitle()}',
                        style: TextStyle(
                          color: AppColors.cardWhite,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Card Container
                      Container(
                        padding: const EdgeInsets.all(24.0),
                        decoration: BoxDecoration(
                          color: AppColors.cardWhite.withValues(alpha: 0.94),
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
                        child: SizedBox(
                          height: _getCardHeight(),
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

  // Header Title Helper
  String _getStepTitle() {
    switch (_currentStep) {
      case 0:
        return 'Create Account';
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

  // Header Subtitle Helper
  String _getStepSubtitle() {
    switch (_currentStep) {
      case 0:
        return 'Set up your login details';
      case 1:
        return 'Enter your full name & phone';
      case 2:
        return 'Select your location details';
      case 3:
        return 'Confirm your registration info';
      default:
        return '';
    }
  }

  // Card Height Adaptability
  double _getCardHeight() {
    switch (_currentStep) {
      case 0:
        return 380;
      case 1:
        return 330;
      case 2:
        return 410;
      case 3:
        return 440;
      default:
        return 400;
    }
  }

  // --- Step 1: Account Credentials ---
  Widget _buildStep1Form() {
    return Form(
      key: _formKeyStep1,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: _buildInputDecoration(
                label: 'Email Address',
                icon: Icons.email_outlined,
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Enter an email' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: _buildInputDecoration(
                label: 'Password',
                icon: Icons.lock_outline_rounded,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              validator: (v) => (v == null || v.length < 6)
                  ? 'At least 6 characters required'
                  : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              decoration: _buildInputDecoration(
                label: 'Confirm Password',
                icon: Icons.lock_reset_rounded,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: () => setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword,
                  ),
                ),
              ),
              validator: (v) => v != _passwordController.text
                  ? 'Passwords do not match'
                  : null,
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _nextStep,
                style: _buttonStyle(),
                child: const Text(
                  'Next: Personal Info',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Already have an account? ",
                  style: TextStyle(
                    color: AppColors.greyText.withValues(alpha: 0.9),
                    fontSize: 13,
                  ),
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
      ),
    );
  }

  // --- Step 2: Personal Details ---
  Widget _buildStep2Form() {
    return Form(
      key: _formKeyStep2,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _firstNameController,
              decoration: _buildInputDecoration(
                label: 'First Name',
                icon: Icons.person_outline,
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _middleNameController,
              decoration: _buildInputDecoration(
                label: 'Middle Name',
                icon: Icons.person_outline,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _lastNameController,
              decoration: _buildInputDecoration(
                label: 'Last Name',
                icon: Icons.person_outline,
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: _buildInputDecoration(
                label: 'Phone Number',
                icon: Icons.phone_outlined,
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 24),
            _buildNavigationButtons(_nextStep, labelNext: 'Next: Address'),
          ],
        ),
      ),
    );
  }

  // --- Step 3: Address Selection ---
  Widget _buildStep3AddressForm() {
    return Form(
      key: _formKeyStep3,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildDropdownContainer(
              child: PhilippineRegionDropdownView(
                value: _selectedRegion,
                onChanged: (Region? value) {
                  setState(() {
                    if (_selectedRegion != value) {
                      _selectedProvince = null;
                      _selectedMunicipality = null;
                      _selectedBarangay = null;
                    }
                    _selectedRegion = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 10),
            _buildDropdownContainer(
              child: PhilippineProvinceDropdownView(
                provinces: _selectedRegion?.provinces ?? [],
                value: _selectedProvince,
                onChanged: (Province? value) {
                  setState(() {
                    if (_selectedProvince != value) {
                      _selectedMunicipality = null;
                      _selectedBarangay = null;
                    }
                    _selectedProvince = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 10),
            _buildDropdownContainer(
              child: PhilippineMunicipalityDropdownView(
                municipalities: _selectedProvince?.municipalities ?? [],
                value: _selectedMunicipality,
                onChanged: (value) {
                  setState(() {
                    if (_selectedMunicipality != value) {
                      _selectedBarangay = null;
                    }
                    _selectedMunicipality = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 10),
            _buildDropdownContainer(
              child: PhilippineBarangayDropdownView(
                barangays: _selectedMunicipality?.barangays ?? [],
                value: _selectedBarangay,
                onChanged: (String? value) {
                  setState(() {
                    _selectedBarangay = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _streetAddressController,
              decoration: _buildInputDecoration(
                label: 'House No. / Street Address',
                icon: Icons.home_outlined,
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 20),
            _buildNavigationButtons(_nextStep, labelNext: 'Next: Review'),
          ],
        ),
      ),
    );
  }

  // --- Step 4: Final Review Summary & Submit ---
  Widget _buildStep4ReviewForm() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.background.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.greyBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.assignment_turned_in_outlined,
                      color: AppColors.bobaBrown,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Summary Overview',
                      style: TextStyle(
                        color: AppColors.bobaBrown,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                const Divider(color: AppColors.greyBorder, height: 20),
                _buildSummaryLine(
                  Icons.person_outline,
                  'Name',
                  '${_firstNameController.text} ${_middleNameController.text.isNotEmpty ? "${_middleNameController.text} " : ""}${_lastNameController.text}',
                ),
                _buildSummaryLine(
                  Icons.email_outlined,
                  'Email',
                  _emailController.text,
                ),
                _buildSummaryLine(
                  Icons.phone_outlined,
                  'Phone',
                  _phoneController.text,
                ),
                _buildSummaryLine(
                  Icons.map_outlined,
                  'Region',
                  _selectedRegion?.toString() ?? '-',
                ),
                _buildSummaryLine(
                  Icons.location_city_outlined,
                  'Province / City',
                  '${_selectedProvince?.toString() ?? "-"}, ${_selectedMunicipality?.toString() ?? "-"}',
                ),
                _buildSummaryLine(
                  Icons.grid_view_rounded,
                  'Barangay',
                  _selectedBarangay ?? '-',
                ),
                _buildSummaryLine(
                  Icons.home_outlined,
                  'Street',
                  _streetAddressController.text,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildNavigationButtons(
            _handleRegister,
            labelNext: 'Complete Sign Up',
            isFinal: true,
          ),
        ],
      ),
    );
  }

  // UI Components
  Widget _buildDropdownContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.greyBorder.withValues(alpha: 0.8)),
      ),
      child: child,
    );
  }

  Widget _buildSummaryLine(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.bobaBrown),
          const SizedBox(width: 10),
          SizedBox(
            width: 85,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.greyText,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.darkText,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
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
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: AppColors.bobaBrown),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Back',
              style: TextStyle(
                color: AppColors.bobaBrown,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: _isLoading ? null : onNext,
            style: _buttonStyle(),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: AppColors.cream,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    labelNext,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.bobaBrown,
      foregroundColor: AppColors.cream,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
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
      prefixIcon: Icon(icon, color: AppColors.bobaBrown, size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.background.withValues(alpha: 0.6),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
    );
  }
}
