import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:the_legit_smoothie/widgets/main_navigation_screen.dart';
import 'package:the_legit_smoothie/widgets/seller_main_navigation_screen.dart';

import '../../../core/constants/app_colors.dart';
import '../services/auth_service.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _authService = AuthService();

  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _isLoading = false;
  bool _obscurePassword = true;

  // =============================================================
  // LIFECYCLE
  // =============================================================

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();

    super.dispose();
  }

  // =============================================================
  // LOGIN
  // =============================================================

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // ==========================================================
      // AUTHENTICATE
      // ==========================================================

      final response = await _authService.signInWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (response.user == null) {
        throw Exception(
          'Unable to sign in.',
        );
      }

      // ==========================================================
      // GET ROLE
      // ==========================================================

      final String? role =
          await _authService.getCurrentUserRole();

      debugPrint(
        'Logged in user role: $role',
      );

      if (!mounted) return;

      // ==========================================================
      // SELLER
      // ==========================================================

      if (role == 'seller') {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) =>
                const SellerMainNavigationScreen(),
          ),
          (route) => false,
        );

        return;
      }

      // ==========================================================
      // CUSTOMER
      // ==========================================================

      if (role == 'customer') {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) =>
                const MainNavigationScreen(),
          ),
          (route) => false,
        );

        return;
      }

      // ==========================================================
      // INVALID ROLE
      // ==========================================================

      await _authService.signOut();

      if (!mounted) return;

      _showErrorMessage(
        'Your account does not have a valid role.',
      );
    } on AuthException catch (error) {
      if (!mounted) return;

      _showErrorMessage(
        error.message,
      );
    } catch (error) {
      debugPrint(
        'Login error: $error',
      );

      if (!mounted) return;

      _showErrorMessage(
        'An unexpected error occurred. Please try again.',
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
  // ERROR MESSAGE
  // =============================================================

  void _showErrorMessage(
    String message,
  ) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.textPrimary,
          margin: const EdgeInsets.fromLTRB(
            18,
            0,
            18,
            18,
          ),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              14,
            ),
          ),
          content: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(
                    alpha: 0.15,
                  ),
                  borderRadius: BorderRadius.circular(
                    9,
                  ),
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
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
    final mediaQuery = MediaQuery.of(context);

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
            keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior.onDrag,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              20,
              20,
              20,
              24 + mediaQuery.viewInsets.bottom * 0.08,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // =================================================
                  // BRAND HEADER
                  // =================================================

                  _buildBrandHeader(),

                  const SizedBox(height: 36),

                  // =================================================
                  // WELCOME
                  // =================================================

                  _buildWelcomeSection(),

                  const SizedBox(height: 24),

                  // =================================================
                  // LOGIN CARD
                  // =================================================

                  _buildLoginCard(),

                  const SizedBox(height: 22),

                  // =================================================
                  // REGISTER
                  // =================================================

                  _buildRegisterSection(),

                  const SizedBox(height: 28),

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
  // BRAND HEADER
  // =============================================================

  Widget _buildBrandHeader() {
    return Row(
      children: [
        // =========================================================
        // LOGO
        // =========================================================

        Container(
          width: 54,
          height: 54,
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(
              17,
            ),
            border: Border.all(
              color: AppColors.border.withValues(
                alpha: 0.28,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: 0.035,
                ),
                blurRadius: 18,
                offset: const Offset(
                  0,
                  6,
                ),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
              11,
            ),
            child: Image.asset(
              'assets/logoSmoothie.png',
              fit: BoxFit.contain,
              errorBuilder: (
                context,
                error,
                stackTrace,
              ) {
                return const Icon(
                  Icons.local_drink_outlined,
                  size: 25,
                  color: AppColors.textPrimary,
                );
              },
            ),
          ),
        ),

        const SizedBox(width: 12),

        // =========================================================
        // BRAND NAME
        // =========================================================

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                'THE LEGIT',
                style: TextStyle(
                  fontSize: 10,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.7,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                'SMOOTHIE',
                style: TextStyle(
                  fontSize: 18,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
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
          padding: const EdgeInsets.symmetric(
            horizontal: 9,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(
              30,
            ),
            border: Border.all(
              color: AppColors.border.withValues(
                alpha: 0.28,
              ),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.lock_outline_rounded,
                size: 11,
                color: AppColors.textSecondary
                    .withValues(
                  alpha: 0.75,
                ),
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
  // WELCOME SECTION
  // =============================================================

  Widget _buildWelcomeSection() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        // =========================================================
        // EYEBROW
        // =========================================================

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 9,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: AppColors.textPrimary.withValues(
              alpha: 0.055,
            ),
            borderRadius: BorderRadius.circular(
              30,
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.waving_hand_outlined,
                size: 12,
                color: AppColors.textPrimary,
              ),

              SizedBox(width: 5),

              Text(
                'WELCOME BACK',
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
          'Good to see\nyou again.',
          style: TextStyle(
            fontSize: 34,
            height: 1.02,
            fontWeight: FontWeight.w900,
            letterSpacing: -1.25,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: 11),

        Text(
          'Sign in to order your favorites, discover deals, '
          'and keep track of every order.',
          style: TextStyle(
            fontSize: 12,
            height: 1.55,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary.withValues(
              alpha: 0.72,
            ),
          ),
        ),
      ],
    );
  }

  // =============================================================
  // LOGIN CARD
  // =============================================================

  Widget _buildLoginCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        18,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          24,
        ),
        border: Border.all(
          color: Colors.black.withValues(
            alpha: 0.045,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.035,
            ),
            blurRadius: 26,
            offset: const Offset(
              0,
              8,
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          // =======================================================
          // FORM HEADER
          // =======================================================

          const Text(
            'Sign in to your account',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            'Enter your account details below.',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary
                  .withValues(
                alpha: 0.62,
              ),
            ),
          ),

          const SizedBox(height: 22),

          // =======================================================
          // EMAIL LABEL
          // =======================================================

          _buildFieldLabel(
            label: 'EMAIL ADDRESS',
            icon: Icons.mail_outline_rounded,
          ),

          const SizedBox(height: 8),

          // =======================================================
          // EMAIL FIELD
          // =======================================================

          TextFormField(
            controller: _emailController,
            focusNode: _emailFocusNode,
            enabled: !_isLoading,
            keyboardType:
                TextInputType.emailAddress,
            textInputAction:
                TextInputAction.next,
            autofillHints: const [
              AutofillHints.email,
              AutofillHints.username,
            ],
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
              hint:
                  'you@example.com',
              icon:
                  Icons.mail_outline_rounded,
            ),
            validator: (value) {
              final email =
                  value?.trim() ?? '';

              if (email.isEmpty) {
                return 'Please enter your email address';
              }

              final emailPattern = RegExp(
                r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
              );

              if (!emailPattern.hasMatch(
                email,
              )) {
                return 'Enter a valid email address';
              }

              return null;
            },
          ),

          const SizedBox(height: 18),

          // =======================================================
          // PASSWORD LABEL
          // =======================================================

          _buildFieldLabel(
            label: 'PASSWORD',
            icon: Icons.lock_outline_rounded,
          ),

          const SizedBox(height: 8),

          // =======================================================
          // PASSWORD FIELD
          // =======================================================

          TextFormField(
            controller:
                _passwordController,
            focusNode:
                _passwordFocusNode,
            enabled: !_isLoading,
            obscureText:
                _obscurePassword,
            textInputAction:
                TextInputAction.done,
            autofillHints: const [
              AutofillHints.password,
            ],
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            onFieldSubmitted: (_) {
              if (!_isLoading) {
                _handleLogin();
              }
            },
            decoration:
                _buildInputDecoration(
              hint: 'Enter your password',
              icon:
                  Icons.lock_outline_rounded,
              suffixIcon: IconButton(
                splashRadius: 20,
                tooltip: _obscurePassword
                    ? 'Show password'
                    : 'Hide password',
                onPressed: () {
                  setState(() {
                    _obscurePassword =
                        !_obscurePassword;
                  });
                },
                icon: Icon(
                  _obscurePassword
                      ? Icons
                          .visibility_off_outlined
                      : Icons
                          .visibility_outlined,
                  size: 18,
                  color: AppColors
                      .textSecondary
                      .withValues(
                    alpha: 0.75,
                  ),
                ),
              ),
            ),
            validator: (value) {
              if (value == null ||
                  value.isEmpty) {
                return 'Please enter your password';
              }

              return null;
            },
          ),

          const SizedBox(height: 22),

          // =======================================================
          // LOGIN BUTTON
          // =======================================================

          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : _handleLogin,
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    AppColors.textPrimary,
                disabledBackgroundColor:
                    AppColors.textPrimary
                        .withValues(
                  alpha: 0.55,
                ),
                foregroundColor:
                    Colors.white,
                disabledForegroundColor:
                    Colors.white.withValues(
                  alpha: 0.75,
                ),
                elevation: 0,
                shadowColor:
                    Colors.transparent,
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    16,
                  ),
                ),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(
                  milliseconds: 180,
                ),
                child: _isLoading
                    ? const SizedBox(
                        key: ValueKey(
                          'loading',
                        ),
                        width: 21,
                        height: 21,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : const Row(
                        key: ValueKey(
                          'login',
                        ),
                        mainAxisAlignment:
                            MainAxisAlignment
                                .center,
                        children: [
                          Icon(
                            Icons
                                .login_rounded,
                            size: 17,
                            color:
                                Colors.white,
                          ),

                          SizedBox(width: 9),

                          Text(
                            'Sign In',
                            style:
                                TextStyle(
                              fontSize: 14,
                              fontWeight:
                                  FontWeight
                                      .w900,
                              letterSpacing:
                                  -0.15,
                              color:
                                  Colors.white,
                            ),
                          ),

                          SizedBox(width: 9),

                          Icon(
                            Icons
                                .arrow_forward_rounded,
                            size: 17,
                            color:
                                Colors.white,
                          ),
                        ],
                      ),
              ),
            ),
          ),

          const SizedBox(height: 13),

          // =======================================================
          // LOGIN NOTE
          // =======================================================

          Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Icon(
                Icons
                    .verified_user_outlined,
                size: 12,
                color: AppColors
                    .textSecondary
                    .withValues(
                  alpha: 0.50,
                ),
              ),

              const SizedBox(width: 5),

              Text(
                'Secure account sign in',
                style: TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors
                      .textSecondary
                      .withValues(
                    alpha: 0.55,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =============================================================
  // REGISTER SECTION
  // =============================================================

  Widget _buildRegisterSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        15,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          18,
        ),
        border: Border.all(
          color: AppColors.border.withValues(
            alpha: 0.28,
          ),
        ),
      ),
      child: Row(
        children: [
          // =======================================================
          // ICON
          // =======================================================

          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(
                12,
              ),
            ),
            child: const Icon(
              Icons.person_add_alt_1_outlined,
              size: 17,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(width: 11),

          // =======================================================
          // TEXT
          // =======================================================

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'New to The Legit Smoothie?',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.15,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'Create an account and start ordering.',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: AppColors
                        .textSecondary
                        .withValues(
                      alpha: 0.62,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // =======================================================
          // REGISTER BUTTON
          // =======================================================

          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _isLoading
                  ? null
                  : () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              const RegisterScreen(),
                        ),
                      );
                    },
              borderRadius: BorderRadius.circular(
                11,
              ),
              child: Ink(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.textPrimary,
                  borderRadius:
                      BorderRadius.circular(
                    11,
                  ),
                ),
                child: const Text(
                  'Register',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
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
              color: AppColors.textSecondary
                  .withValues(
                alpha: 0.42,
              ),
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Fresh blends. Simple ordering.',
            style: TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary
                  .withValues(
                alpha: 0.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =============================================================
  // FIELD LABEL
  // =============================================================

  Widget _buildFieldLabel({
    required String label,
    required IconData icon,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 12,
          color: AppColors.textSecondary
              .withValues(
            alpha: 0.62,
          ),
        ),

        const SizedBox(width: 6),

        Text(
          label,
          style: TextStyle(
            fontSize: 8,
            height: 1,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.9,
            color: AppColors.textSecondary
                .withValues(
              alpha: 0.65,
            ),
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
    final borderRadius =
        BorderRadius.circular(
      15,
    );

    return InputDecoration(
      hintText: hint,

      hintStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary
            .withValues(
          alpha: 0.43,
        ),
      ),

      filled: true,

      fillColor: AppColors.background
          .withValues(
        alpha: 0.70,
      ),

      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 17,
      ),

      // ===========================================================
      // PREFIX
      // ===========================================================

      prefixIcon: Padding(
        padding: const EdgeInsets.only(
          left: 9,
          right: 7,
        ),
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius:
                BorderRadius.circular(
              11,
            ),
            border: Border.all(
              color: AppColors.border
                  .withValues(
                alpha: 0.25,
              ),
            ),
          ),
          child: Icon(
            icon,
            size: 17,
            color: AppColors.textPrimary,
          ),
        ),
      ),

      prefixIconConstraints:
          const BoxConstraints(
        minWidth: 57,
        minHeight: 56,
      ),

      suffixIcon: suffixIcon,

      // ===========================================================
      // BORDER
      // ===========================================================

      border: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(
          color: AppColors.border
              .withValues(
            alpha: 0.32,
          ),
        ),
      ),

      enabledBorder:
          OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(
          color: AppColors.border
              .withValues(
            alpha: 0.32,
          ),
        ),
      ),

      focusedBorder:
          OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: const BorderSide(
          color: AppColors.textPrimary,
          width: 1.35,
        ),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(
          color: AppColors.error
              .withValues(
            alpha: 0.65,
          ),
        ),
      ),

      focusedErrorBorder:
          OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: const BorderSide(
          color: AppColors.error,
          width: 1.35,
        ),
      ),

      disabledBorder:
          OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(
          color: AppColors.border
              .withValues(
            alpha: 0.20,
          ),
        ),
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