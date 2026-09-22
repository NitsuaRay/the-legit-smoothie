import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/constants/app_colors.dart';

class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({
    super.key,
  });

  @override
  State<ChangePasswordDialog> createState() =>
      _ChangePasswordDialogState();
}

class _ChangePasswordDialogState
    extends State<ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _currentPasswordController =
      TextEditingController();

  final TextEditingController _newPasswordController =
      TextEditingController();

  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  bool _isSubmitting = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  // ===============================================================
  // CHANGE PASSWORD
  // ===============================================================

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      _showError(
        'Your session has expired. Please log in again.',
      );
      return;
    }

    final String? email = user.email;

    if (email == null || email.isEmpty) {
      _showError(
        'No email address is connected to this account.',
      );
      return;
    }

    final String currentPassword =
        _currentPasswordController.text.trim();

    final String newPassword =
        _newPasswordController.text.trim();

    setState(() {
      _isSubmitting = true;
    });

    try {
      // ============================================================
      // VERIFY CURRENT PASSWORD
      // ============================================================

      await supabase.auth.signInWithPassword(
        email: email,
        password: currentPassword,
      );

      // ============================================================
      // UPDATE PASSWORD
      // ============================================================

      await supabase.auth.updateUser(
        UserAttributes(
          password: newPassword,
        ),
      );

      if (!mounted) return;

      Navigator.pop(
        context,
        true,
      );
    } on AuthException catch (error) {
      if (!mounted) return;

      String message = error.message;

      final normalized =
          error.message.toLowerCase();

      if (normalized.contains('invalid login') ||
          normalized.contains('invalid credentials')) {
        message =
            'Your current password is incorrect.';
      }

      _showError(message);
    } catch (error) {
      if (!mounted) return;

      _showError(
        'Unable to change your password right now.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ===============================================================
  // BUILD
  // ===============================================================

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(
          maxWidth: 430,
        ),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: AppColors.border.withValues(
              alpha: 0.30,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: 0.10,
              ),
              blurRadius: 35,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                // =================================================
                // HEADER
                // =================================================

                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius:
                            BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.border.withValues(
                            alpha: 0.25,
                          ),
                        ),
                      ),
                      child: const Icon(
                        Icons.lock_outline_rounded,
                        size: 21,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const Spacer(),

                    IconButton(
                      onPressed: _isSubmitting
                          ? null
                          : () {
                              Navigator.pop(context);
                            },
                      icon: const Icon(
                        Icons.close_rounded,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Text(
                  'SECURITY',
                  style: TextStyle(
                    fontSize: 7,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.3,
                    color:
                        AppColors.textSecondary.withValues(
                      alpha: 0.58,
                    ),
                  ),
                ),

                const SizedBox(height: 5),

                const Text(
                  'Change password',
                  style: TextStyle(
                    fontSize: 24,
                    height: 1.05,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.7,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Create a new password for your account. '
                  'You will need to confirm your current password first.',
                  style: TextStyle(
                    fontSize: 10,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                    color:
                        AppColors.textSecondary.withValues(
                      alpha: 0.72,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // =================================================
                // CURRENT PASSWORD
                // =================================================

                _PasswordField(
                  controller:
                      _currentPasswordController,
                  label: 'Current password',
                  hint: 'Enter current password',
                  obscureText: !_showCurrentPassword,
                  onVisibilityPressed: () {
                    setState(() {
                      _showCurrentPassword =
                          !_showCurrentPassword;
                    });
                  },
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Enter your current password.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 15),

                // =================================================
                // NEW PASSWORD
                // =================================================

                _PasswordField(
                  controller:
                      _newPasswordController,
                  label: 'New password',
                  hint: 'Enter new password',
                  obscureText: !_showNewPassword,
                  onVisibilityPressed: () {
                    setState(() {
                      _showNewPassword =
                          !_showNewPassword;
                    });
                  },
                  validator: (value) {
                    final password =
                        value?.trim() ?? '';

                    if (password.isEmpty) {
                      return 'Enter a new password.';
                    }

                    if (password.length < 8) {
                      return 'Use at least 8 characters.';
                    }

                    if (password ==
                        _currentPasswordController
                            .text
                            .trim()) {
                      return 'New password must be different.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 15),

                // =================================================
                // CONFIRM
                // =================================================

                _PasswordField(
                  controller:
                      _confirmPasswordController,
                  label: 'Confirm password',
                  hint: 'Re-enter new password',
                  obscureText: !_showConfirmPassword,
                  onVisibilityPressed: () {
                    setState(() {
                      _showConfirmPassword =
                          !_showConfirmPassword;
                    });
                  },
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Confirm your new password.';
                    }

                    if (value.trim() !=
                        _newPasswordController.text
                            .trim()) {
                      return 'Passwords do not match.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 12),

                // =================================================
                // SECURITY NOTE
                // =================================================

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius:
                        BorderRadius.circular(14),
                    border: Border.all(
                      color:
                          AppColors.border.withValues(
                        alpha: 0.22,
                      ),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.shield_outlined,
                        size: 15,
                        color: AppColors.textPrimary,
                      ),

                      const SizedBox(width: 9),

                      Expanded(
                        child: Text(
                          'For your security, your current '
                          'password is verified before any changes are made.',
                          style: TextStyle(
                            fontSize: 8.5,
                            height: 1.45,
                            fontWeight: FontWeight.w500,
                            color: AppColors
                                .textSecondary
                                .withValues(
                              alpha: 0.72,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // =================================================
                // SAVE BUTTON
                // =================================================

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed:
                        _isSubmitting
                            ? null
                            : _changePassword,
                    style: FilledButton.styleFrom(
                      backgroundColor:
                          AppColors.textPrimary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          AppColors.textPrimary
                              .withValues(
                        alpha: 0.55,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(16),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons
                                    .lock_reset_rounded,
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Change password',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight:
                                      FontWeight.w900,
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
    );
  }
}

// =================================================================
// PASSWORD FIELD
// =================================================================

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool obscureText;
  final VoidCallback onVisibilityPressed;
  final String? Function(String?) validator;

  const _PasswordField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.obscureText,
    required this.onVisibilityPressed,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 7,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.9,
            color:
                AppColors.textSecondary.withValues(
              alpha: 0.65,
            ),
          ),
        ),

        const SizedBox(height: 7),

        TextFormField(
          controller: controller,
          obscureText: obscureText,
          validator: validator,
          enableSuggestions: false,
          autocorrect: false,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color:
                  AppColors.textSecondary.withValues(
                alpha: 0.48,
              ),
            ),
            filled: true,
            fillColor: AppColors.background,
            prefixIcon: const Icon(
              Icons.key_outlined,
              size: 18,
            ),
            suffixIcon: IconButton(
              onPressed: onVisibilityPressed,
              icon: Icon(
                obscureText
                    ? Icons
                        .visibility_outlined
                    : Icons
                        .visibility_off_outlined,
                size: 18,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(15),
              borderSide: BorderSide(
                color: AppColors.border.withValues(
                  alpha: 0.30,
                ),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(15),
              borderSide: BorderSide(
                color: AppColors.border.withValues(
                  alpha: 0.30,
                ),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(15),
              borderSide: const BorderSide(
                color: AppColors.textPrimary,
                width: 1.2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}