import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:the_legit_smoothie/core/constants/app_colors.dart';
import 'package:the_legit_smoothie/main.dart'; // Import AuthGate from main.dart
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
    // Continuous subtle floating animation for background elements
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
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

      if (role == 'admin') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => AuthGate(
              currentThemeMode: widget.currentThemeMode,
              onThemeModeChanged: widget.onThemeModeChanged,
            ),
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Welcome back, Admin Austin! 🥤'),
            backgroundColor: AppColors.bobaBrown,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (role == 'seller') {
        // TODO: Navigate to Seller Dashboard
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
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // --- Floating Ambient Food Background ---
          AnimatedBuilder(
            animation: _floatController,
            builder: (context, child) {
              return CustomPaint(
                size: size,
                painter: FloatingFoodPainter(
                  progress: _floatController.value,
                  accentColor: AppColors.bobaBrown,
                ),
              );
            },
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
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // --- Elevated Logo Container ---
                      Container(
                        width: 140,
                        height: 140,
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
                        padding: const EdgeInsets.all(16),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/logoSmoothie.png',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.local_drink_rounded,
                                size: 64,
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
                          color: AppColors.greyText.withValues(alpha: 0.9),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 36),

                      // --- Main Form Card ---
                      Container(
                        padding: const EdgeInsets.all(32.0),
                        decoration: BoxDecoration(
                          color: AppColors.cardWhite.withValues(alpha: 0.95),
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
                                      () =>
                                          _obscurePassword = !_obscurePassword,
                                    ),
                                  ),
                                ),
                                validator: (value) =>
                                    value == null || value.trim().isEmpty
                                    ? 'Please enter your password'
                                    : null,
                              ),
                              const SizedBox(height: 32),

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

/// --- Custom Painter for Floating Boba, Milk Tea, Smoothie, and Siomai Elements ---
class FloatingFoodPainter extends CustomPainter {
  final double progress;
  final Color accentColor;

  FloatingFoodPainter({required this.progress, required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final baseAlpha = 0.12;
    final floatOffset = math.sin(progress * math.pi * 2);

    // 1. Floating Boba Pearls (Circles)
    paint.color = accentColor.withValues(alpha: baseAlpha);
    _drawBoba(
      canvas,
      paint,
      Offset(size.width * 0.15, size.height * 0.2 + (floatOffset * 15)),
      12,
    );
    _drawBoba(
      canvas,
      paint,
      Offset(size.width * 0.22, size.height * 0.24 - (floatOffset * 10)),
      16,
    );
    _drawBoba(
      canvas,
      paint,
      Offset(size.width * 0.12, size.height * 0.28 + (floatOffset * 8)),
      10,
    );

    _drawBoba(
      canvas,
      paint,
      Offset(size.width * 0.82, size.height * 0.72 - (floatOffset * 18)),
      14,
    );
    _drawBoba(
      canvas,
      paint,
      Offset(size.width * 0.88, size.height * 0.76 + (floatOffset * 12)),
      18,
    );

    // 2. Milk Tea Cup Accent
    _drawMilkTeaCup(
      canvas,
      paint,
      Offset(size.width * 0.82, size.height * 0.18 + (floatOffset * 20)),
      alpha: baseAlpha,
    );

    // 3. Smoothie Jar Accent
    _drawSmoothie(
      canvas,
      paint,
      Offset(size.width * 0.12, size.height * 0.78 - (floatOffset * 16)),
      alpha: baseAlpha,
    );

    // 4. Floating Siomai Dim Sum Outline
    _drawSiomai(
      canvas,
      paint,
      Offset(size.width * 0.85, size.height * 0.45 + (floatOffset * 14)),
      alpha: baseAlpha,
    );
  }

  void _drawBoba(Canvas canvas, Paint paint, Offset center, double radius) {
    canvas.drawCircle(center, radius, paint);
  }

  void _drawMilkTeaCup(
    Canvas canvas,
    Paint paint,
    Offset center, {
    required double alpha,
  }) {
    paint.color = accentColor.withValues(alpha: alpha);

    // Cup body
    final path = Path()
      ..moveTo(center.dx - 20, center.dy - 30)
      ..lineTo(center.dx + 20, center.dy - 30)
      ..lineTo(center.dx + 15, center.dy + 30)
      ..lineTo(center.dx - 15, center.dy + 30)
      ..close();
    canvas.drawPath(path, paint);

    // Straw
    final strawPaint = Paint()
      ..color = accentColor.withValues(alpha: alpha * 1.2)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(center.dx, center.dy - 30),
      Offset(center.dx + 10, center.dy - 45),
      strawPaint,
    );
  }

  void _drawSmoothie(
    Canvas canvas,
    Paint paint,
    Offset center, {
    required double alpha,
  }) {
    paint.color = accentColor.withValues(alpha: alpha);

    // Smoothie Glass Body
    final RRect glassRRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: 36, height: 50),
      const Radius.circular(12),
    );
    canvas.drawRRect(glassRRect, paint);

    // Dome Lid
    paint.color = accentColor.withValues(alpha: alpha * 0.8);
    canvas.drawArc(
      Rect.fromLTWH(center.dx - 18, center.dy - 35, 36, 20),
      math.pi,
      math.pi,
      true,
      paint,
    );
  }

  void _drawSiomai(
    Canvas canvas,
    Paint paint,
    Offset center, {
    required double alpha,
  }) {
    paint.color = accentColor.withValues(alpha: alpha);

    // Pleated Siomai Shape
    final path = Path()
      ..moveTo(center.dx - 18, center.dy + 12)
      ..cubicTo(
        center.dx - 22,
        center.dy - 4,
        center.dx - 12,
        center.dy - 16,
        center.dx,
        center.dy - 12,
      )
      ..cubicTo(
        center.dx + 12,
        center.dy - 16,
        center.dx + 22,
        center.dy - 4,
        center.dx + 18,
        center.dy + 12,
      )
      ..cubicTo(
        center.dx + 10,
        center.dy + 18,
        center.dx - 10,
        center.dy + 18,
        center.dx - 18,
        center.dy + 12,
      )
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant FloatingFoodPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
