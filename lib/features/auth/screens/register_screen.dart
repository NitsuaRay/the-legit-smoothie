import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:the_legit_smoothie/widgets/main_navigation_screen.dart';

import '../../../core/constants/app_colors.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _nameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  final _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // =============================================================
  // LIFECYCLE
  // =============================================================

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();

    super.dispose();
  }

  // =============================================================
  // REGISTER
  // =============================================================

  Future<void> _handleRegister() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.signUpWithEmail(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      _showMessage('Account created successfully! Welcome!', isSuccess: true);

      // ==========================================================
      // NAVIGATE TO HOME
      // ==========================================================

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const MainNavigationScreen(initialIndex: 0),
        ),
        (route) => false,
      );
    } on AuthException catch (error) {
      if (!mounted) return;

      _showMessage(error.message, isError: true);
    } catch (error) {
      debugPrint('Registration error: $error');

      if (!mounted) return;

      _showMessage(
        'An error occurred during registration. Please try again.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // =============================================================
  // MESSAGE
  // =============================================================

  void _showMessage(
    String message, {
    bool isError = false,
    bool isSuccess = false,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.textPrimary,
          margin: const EdgeInsets.fromLTRB(18, 0, 18, 18),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: isError
                      ? AppColors.error.withValues(alpha: 0.16)
                      : AppColors.success.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  isError ? Icons.error_outline_rounded : Icons.check_rounded,
                  size: 16,
                  color: Colors.white,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 11,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  // =============================================================
  // BUILD
  // =============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,

      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // =================================================
                  // TOP BAR
                  // =================================================
                  _buildTopBar(context),

                  const SizedBox(height: 34),

                  // =================================================
                  // HERO
                  // =================================================
                  _buildHero(),

                  const SizedBox(height: 26),

                  // =================================================
                  // FORM CARD
                  // =================================================
                  _buildRegistrationCard(),

                  const SizedBox(height: 18),

                  // =================================================
                  // EXISTING ACCOUNT
                  // =================================================
                  _buildSignInCard(context),

                  const SizedBox(height: 26),

                  // =================================================
                  // FOOTER
                  // =================================================
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // =============================================================
  // TOP BAR
  // =============================================================

  Widget _buildTopBar(BuildContext context) {
    return Row(
      children: [
        // =========================================================
        // BACK
        // =========================================================
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _isLoading
                ? null
                : () {
                    Navigator.of(context).maybePop();
                  },
            borderRadius: BorderRadius.circular(13),
            child: Ink(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.28),
                ),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // =========================================================
        // BRAND
        // =========================================================
        Container(
          width: 44,
          height: 44,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.28)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(9),
            child: Image.asset(
              'assets/logoSmoothie.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.local_drink_outlined,
                  size: 21,
                  color: AppColors.textPrimary,
                );
              },
            ),
          ),
        ),

        const SizedBox(width: 10),

        // =========================================================
        // BRAND NAME
        // =========================================================
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'THE LEGIT',
                style: TextStyle(
                  fontSize: 8,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.4,
                  color: AppColors.textSecondary,
                ),
              ),

              SizedBox(height: 4),

              Text(
                'SMOOTHIE',
                style: TextStyle(
                  fontSize: 15,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.4,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),

        // =========================================================
        // SECURE BADGE
        // =========================================================
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.28)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.lock_outline_rounded,
                size: 11,
                color: AppColors.textSecondary.withValues(alpha: 0.72),
              ),

              const SizedBox(width: 5),

              const Text(
                'SECURE',
                style: TextStyle(
                  fontSize: 7,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.7,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // =============================================================
  // HERO
  // =============================================================

  Widget _buildHero() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // =========================================================
        // BADGE
        // =========================================================
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.textPrimary.withValues(alpha: 0.055),
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.person_add_alt_1_outlined,
                size: 12,
                color: AppColors.textPrimary,
              ),

              SizedBox(width: 5),

              Text(
                'CREATE YOUR ACCOUNT',
                style: TextStyle(
                  fontSize: 8,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.9,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // =========================================================
        // TITLE
        // =========================================================
        const Text(
          'Your next favorite\nblend starts here.',
          style: TextStyle(
            fontSize: 32,
            height: 1.03,
            fontWeight: FontWeight.w900,
            letterSpacing: -1.15,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: 11),

        Text(
          'Create your account to order faster, save your details, '
          'discover promotions, and track every order.',
          style: TextStyle(
            fontSize: 12,
            height: 1.55,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary.withValues(alpha: 0.72),
          ),
        ),

        const SizedBox(height: 17),

        // =========================================================
        // BENEFITS
        // =========================================================
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: const [
            _BenefitChip(icon: Icons.bolt_outlined, label: 'Faster checkout'),
            _BenefitChip(
              icon: Icons.receipt_long_outlined,
              label: 'Order tracking',
            ),
            _BenefitChip(
              icon: Icons.local_offer_outlined,
              label: 'Exclusive deals',
            ),
          ],
        ),
      ],
    );
  }

  // =============================================================
  // REGISTRATION CARD
  // =============================================================

  Widget _buildRegistrationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withValues(alpha: 0.045)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 26,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // =======================================================
          // CARD HEADER
          // =======================================================
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  size: 18,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(width: 11),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Account Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.4,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      'Fill in your information to get started.',
                      style: TextStyle(
                        fontSize: 10,
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary.withValues(alpha: 0.62),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 23),

          // =======================================================
          // FULL NAME
          // =======================================================
          _buildFieldLabel(
            label: 'FULL NAME',
            icon: Icons.person_outline_rounded,
          ),

          const SizedBox(height: 8),

          TextFormField(
            controller: _nameController,
            focusNode: _nameFocusNode,
            enabled: !_isLoading,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.name],
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            onFieldSubmitted: (_) {
              _emailFocusNode.requestFocus();
            },
            decoration: _buildInputDecoration(
              hint: 'Enter your full name',
              icon: Icons.person_outline_rounded,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your full name';
              }

              if (value.trim().length < 2) {
                return 'Please enter a valid name';
              }

              return null;
            },
          ),

          const SizedBox(height: 18),

          // =======================================================
          // EMAIL
          // =======================================================
          _buildFieldLabel(
            label: 'EMAIL ADDRESS',
            icon: Icons.mail_outline_rounded,
          ),

          const SizedBox(height: 8),

          TextFormField(
            controller: _emailController,
            focusNode: _emailFocusNode,
            enabled: !_isLoading,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
            autocorrect: false,
            enableSuggestions: false,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            onFieldSubmitted: (_) {
              _passwordFocusNode.requestFocus();
            },
            decoration: _buildInputDecoration(
              hint: 'you@example.com',
              icon: Icons.mail_outline_rounded,
            ),
            validator: (value) {
              final email = value?.trim() ?? '';

              if (email.isEmpty) {
                return 'Please enter your email address';
              }

              final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

              if (!emailPattern.hasMatch(email)) {
                return 'Enter a valid email address';
              }

              return null;
            },
          ),

          const SizedBox(height: 18),

          // =======================================================
          // PASSWORD
          // =======================================================
          _buildFieldLabel(label: 'PASSWORD', icon: Icons.lock_outline_rounded),

          const SizedBox(height: 8),

          TextFormField(
            controller: _passwordController,
            focusNode: _passwordFocusNode,
            enabled: !_isLoading,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.newPassword],
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            onChanged: (_) {
              setState(() {});
            },
            onFieldSubmitted: (_) {
              _confirmPasswordFocusNode.requestFocus();
            },
            decoration: _buildInputDecoration(
              hint: 'Create a password',
              icon: Icons.lock_outline_rounded,
              suffixIcon: IconButton(
                tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 18,
                  color: AppColors.textSecondary.withValues(alpha: 0.72),
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please create a password';
              }

              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }

              return null;
            },
          ),

          const SizedBox(height: 10),

          // =======================================================
          // PASSWORD REQUIREMENT
          // =======================================================
          _buildPasswordRequirement(),

          const SizedBox(height: 18),

          // =======================================================
          // CONFIRM PASSWORD
          // =======================================================
          _buildFieldLabel(
            label: 'CONFIRM PASSWORD',
            icon: Icons.verified_user_outlined,
          ),

          const SizedBox(height: 8),

          TextFormField(
            controller: _confirmPasswordController,
            focusNode: _confirmPasswordFocusNode,
            enabled: !_isLoading,
            obscureText: _obscureConfirmPassword,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.newPassword],
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            onFieldSubmitted: (_) {
              if (!_isLoading) {
                _handleRegister();
              }
            },
            decoration: _buildInputDecoration(
              hint: 'Re-enter your password',
              icon: Icons.verified_user_outlined,
              suffixIcon: IconButton(
                tooltip: _obscureConfirmPassword
                    ? 'Show password'
                    : 'Hide password',
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 18,
                  color: AppColors.textSecondary.withValues(alpha: 0.72),
                ),
              ),
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

          const SizedBox(height: 22),

          // =======================================================
          // CREATE ACCOUNT BUTTON
          // =======================================================
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleRegister,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.textPrimary,
                disabledBackgroundColor: AppColors.textPrimary.withValues(
                  alpha: 0.52,
                ),
                foregroundColor: Colors.white,
                disabledForegroundColor: Colors.white.withValues(alpha: 0.75),
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: _isLoading
                    ? const SizedBox(
                        key: ValueKey('loading'),
                        width: 21,
                        height: 21,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : const Row(
                        key: ValueKey('register'),
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_add_alt_1_rounded,
                            size: 17,
                            color: Colors.white,
                          ),

                          SizedBox(width: 9),

                          Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.15,
                              color: Colors.white,
                            ),
                          ),

                          SizedBox(width: 9),

                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 17,
                            color: Colors.white,
                          ),
                        ],
                      ),
              ),
            ),
          ),

          const SizedBox(height: 13),

          // =======================================================
          // SECURITY NOTE
          // =======================================================
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shield_outlined,
                size: 12,
                color: AppColors.textSecondary.withValues(alpha: 0.50),
              ),

              const SizedBox(width: 5),

              Text(
                'Your account information is securely handled',
                style: TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary.withValues(alpha: 0.55),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =============================================================
  // PASSWORD REQUIREMENT
  // =============================================================

  Widget _buildPasswordRequirement() {
    final password = _passwordController.text;

    final bool hasMinimumLength = password.length >= 6;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      decoration: BoxDecoration(
        color: hasMinimumLength
            ? AppColors.success.withValues(alpha: 0.055)
            : AppColors.background,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: hasMinimumLength
              ? AppColors.success.withValues(alpha: 0.14)
              : AppColors.border.withValues(alpha: 0.22),
        ),
      ),
      child: Row(
        children: [
          Icon(
            hasMinimumLength
                ? Icons.check_circle_rounded
                : Icons.info_outline_rounded,
            size: 14,
            color: hasMinimumLength
                ? AppColors.success
                : AppColors.textSecondary,
          ),

          const SizedBox(width: 7),

          Expanded(
            child: Text(
              hasMinimumLength
                  ? 'Password length looks good'
                  : 'Use at least 6 characters',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: hasMinimumLength
                    ? AppColors.success
                    : AppColors.textSecondary.withValues(alpha: 0.70),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =============================================================
  // SIGN IN CARD
  // =============================================================

  Widget _buildSignInCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.28)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.login_rounded,
              size: 17,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Already have an account?',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.15,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'Sign in and continue your order.',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary.withValues(alpha: 0.62),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _isLoading
                  ? null
                  : () {
                      Navigator.of(context).pop();
                    },
              borderRadius: BorderRadius.circular(11),
              child: Ink(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.textPrimary,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),

                    SizedBox(width: 5),

                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 13,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =============================================================
  // FOOTER
  // =============================================================

  Widget _buildFooter() {
    return Center(
      child: Column(
        children: [
          Text(
            'THE LEGIT SMOOTHIE',
            style: TextStyle(
              fontSize: 7.5,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.4,
              color: AppColors.textSecondary.withValues(alpha: 0.42),
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Fresh blends. Simple ordering.',
            style: TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary.withValues(alpha: 0.45),
            ),
          ),
        ],
      ),
    );
  }

  // =============================================================
  // BENEFIT CHIP
  // =============================================================

  // See _BenefitChip below.

  // =============================================================
  // FIELD LABEL
  // =============================================================

  Widget _buildFieldLabel({required String label, required IconData icon}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 12,
          color: AppColors.textSecondary.withValues(alpha: 0.62),
        ),

        const SizedBox(width: 6),

        Text(
          label,
          style: TextStyle(
            fontSize: 8,
            height: 1,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.9,
            color: AppColors.textSecondary.withValues(alpha: 0.65),
          ),
        ),
      ],
    );
  }

  // =============================================================
  // INPUT DECORATION
  // =============================================================

  InputDecoration _buildInputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    final borderRadius = BorderRadius.circular(15);

    return InputDecoration(
      hintText: hint,

      hintStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary.withValues(alpha: 0.43),
      ),

      filled: true,

      fillColor: AppColors.background.withValues(alpha: 0.70),

      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 17),

      // ===========================================================
      // PREFIX ICON
      // ===========================================================
      prefixIcon: Padding(
        padding: const EdgeInsets.only(left: 9, right: 7),
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.25)),
          ),
          child: Icon(icon, size: 17, color: AppColors.textPrimary),
        ),
      ),

      prefixIconConstraints: const BoxConstraints(minWidth: 57, minHeight: 56),

      suffixIcon: suffixIcon,

      // ===========================================================
      // BORDERS
      // ===========================================================
      border: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: AppColors.border.withValues(alpha: 0.32)),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: AppColors.border.withValues(alpha: 0.32)),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: const BorderSide(color: AppColors.textPrimary, width: 1.35),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: AppColors.error.withValues(alpha: 0.65)),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: const BorderSide(color: AppColors.error, width: 1.35),
      ),

      disabledBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: AppColors.border.withValues(alpha: 0.20)),
      ),

      errorStyle: const TextStyle(
        fontSize: 9.5,
        height: 1.25,
        fontWeight: FontWeight.w600,
        color: AppColors.error,
      ),
    );
  }
}

// ===================================================================
// BENEFIT CHIP
// ===================================================================

class _BenefitChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _BenefitChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.26)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textPrimary),

          const SizedBox(width: 6),

          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
