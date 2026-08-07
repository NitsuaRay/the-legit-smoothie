import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:the_legit_smoothie/core/constants/app_colors.dart';
import 'package:the_legit_smoothie/features/auth/views/register_screen.dart';
import 'package:the_legit_smoothie/main.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  final ThemeMode currentThemeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  const LoginScreen({
    super.key,
    required this.currentThemeMode,
    required this.onThemeModeChanged,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  late AnimationController _floatController;
  bool _isLoading = false;
  bool _obscurePassword = true;

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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final role = await _authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;

      if (role == 'admin' || role == 'seller') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => AuthGate(
              currentThemeMode: widget.currentThemeMode,
              onThemeModeChanged: widget.onThemeModeChanged,
            ),
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Welcome back, ${role == 'admin' ? 'Admin' : 'Seller'} Austin! 🥤',
            ),
            backgroundColor: AppColors.bobaBrown,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        // TODO: Navigate to Customer Home
      }
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
    // Determine if light mode is active
    final bool isLightMode = widget.currentThemeMode == ThemeMode.light ||
        (widget.currentThemeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.light);

    // Select background image based on current theme mode
    final String backgroundImagePath =
        isLightMode ? 'assets/bgWhite.png' : 'assets/bgBrown.png';

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
                    child: _buildFloatingItem('assets/mangooreo.png', size: 75, angle: -0.2),
                  ),
                  Positioned(
                    top: 85 - offset,
                    right: 10,
                    child: _buildFloatingItem('assets/avocadograham.png', size: 85, angle: 0.15),
                  ),
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.45 + offset,
                    right: 15,
                    child: _buildFloatingItem('assets/dragonfruit.png', size: 70, angle: 0.3),
                  ),
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.48 - offset,
                    left: 15,
                    child: _buildFloatingItem('assets/camel.png', size: 65, angle: -0.25),
                  ),
                  Positioned(
                    bottom: 45 + offset,
                    left: 15,
                    child: _buildFloatingItem('assets/cookiesandcream.png', size: 80, angle: -0.1),
                  ),
                  Positioned(
                    bottom: 55 - offset,
                    right: 15,
                    child: _buildFloatingItem('assets/lemon.png', size: 75, angle: 0.2),
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
                    final nextMode =
                        isLightMode ? ThemeMode.dark : ThemeMode.light;
                    widget.onThemeModeChanged(nextMode);
                  },
                  icon: Icon(
                    isLightMode
                        ? Icons.dark_mode_rounded
                        : Icons.light_mode_rounded,
                    color: AppColors.bobaBrown,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.cardWhite.withValues(alpha: 0.85),
                  ),
                ),
              ),
            ),
          ),

          // --- Main Interactive Content ---
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 32.0,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // --- Elevated Logo Container ---
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
                              color: AppColors.bobaBrown.withValues(alpha: 0.18),
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

                      // --- Title & Subtitle Header ---
                      const Text(
                        'The Legit Smoothie',
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
                        'Crafted fresh. Log in to your account.',
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

                      // --- Main Form Card ---
                      Container(
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
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Email Input
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
                                ),
                                validator: (value) =>
                                    value == null || value.trim().isEmpty
                                        ? 'Please enter your email'
                                        : null,
                               ),
                              const SizedBox(height: 20),

                              // Password Input
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
                                validator: (value) =>
                                    value == null || value.trim().isEmpty
                                        ? 'Please enter your password'
                                        : null,
                              ),

                              // --- Forgot Password Link ---
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    // TODO: Navigate to Forgot Password Screen
                                  },
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.only(
                                      top: 8,
                                      bottom: 12,
                                    ),
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text(
                                    'Forgot password?',
                                    style: TextStyle(
                                      color: AppColors.bobaBrown,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Sign In Button
                              SizedBox(
                                height: 54,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _handleLogin,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.bobaBrown,
                                    foregroundColor: AppColors.cream,
                                    elevation: 2,
                                    shadowColor: AppColors.bobaBrown.withValues(
                                      alpha: 0.4,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          height: 22,
                                          width: 22,
                                          child: CircularProgressIndicator(
                                            color: AppColors.cream,
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                      : const Text(
                                          'Sign In',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // --- Register Link ---
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Don't have an account? ",
                                    style: TextStyle(
                                      color: AppColors.greyText,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => RegisterScreen(
                                            currentThemeMode:
                                                widget.currentThemeMode,
                                            onThemeModeChanged:
                                                widget.onThemeModeChanged,
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'Register',
                                      style: TextStyle(
                                        color: AppColors.bobaBrown,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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