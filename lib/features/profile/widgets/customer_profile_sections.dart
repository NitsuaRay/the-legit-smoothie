import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import 'customer_profile_menu_item.dart';

class CustomerProfileSections extends StatelessWidget {
  final VoidCallback onEditProfile;
  final VoidCallback onChangePassword;
  final VoidCallback onLogout;
  final bool isLoggingOut;
  final DateTime? customerSince;

  const CustomerProfileSections({
    super.key,
    required this.onEditProfile,
    required this.onChangePassword,
    required this.onLogout,
    required this.isLoggingOut,
    required this.customerSince,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ============================================================
        // ACCOUNT
        // ============================================================

        _Section(
          eyebrow: 'Settings',
          title: 'Account',
          child: CustomerProfileMenuItem(
            icon: Icons.edit_outlined,
            title: 'Edit profile',
            subtitle:
                'Update your name, phone number and delivery address.',
            onTap: onEditProfile,
          ),
        ),

        const SizedBox(height: 14),

        // ============================================================
        // SECURITY
        // ============================================================

        _Section(
          eyebrow: 'Security',
          title: 'Session',
          child: Column(
            children: [
              // ======================================================
              // CHANGE PASSWORD
              // ======================================================

              CustomerProfileMenuItem(
                icon: Icons.lock_outline_rounded,
                title: 'Change password',
                subtitle:
                    'Update your password and keep your account secure.',
                onTap: onChangePassword,
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 8,
                ),
                child: Divider(
                  height: 1,
                  color: AppColors.border.withValues(
                    alpha: 0.22,
                  ),
                ),
              ),

              // ======================================================
              // LOGOUT
              // ======================================================

              CustomerProfileMenuItem(
                icon: Icons.logout_rounded,
                title: 'Log out',
                subtitle: 'Sign out of this device.',
                destructive: true,
                onTap: isLoggingOut ? null : onLogout,
                trailing: isLoggingOut
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.textPrimary,
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),

        const SizedBox(height: 22),

        _Footer(
          customerSince: customerSince,
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  final String eyebrow;
  final String title;
  final Widget child;

  const _Section({
    required this.eyebrow,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.border.withValues(
            alpha: 0.30,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.025,
            ),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            eyebrow.toUpperCase(),
            style: TextStyle(
              fontSize: 7,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.1,
              color: AppColors.textSecondary.withValues(
                alpha: 0.58,
              ),
            ),
          ),

          const SizedBox(height: 3),

          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.35,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 12),

          child,
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  final DateTime? customerSince;

  const _Footer({
    required this.customerSince,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.border.withValues(
                  alpha: 0.30,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(4),
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
                    size: 15,
                    color: AppColors.textSecondary,
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'THE LEGIT SMOOTHIE',
            style: TextStyle(
              fontSize: 7,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.1,
              color: AppColors.textSecondary,
            ),
          ),

          if (customerSince != null) ...[
            const SizedBox(height: 4),

            Text(
              'Customer since ${_format(customerSince!)}',
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary.withValues(
                  alpha: 0.65,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _format(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${months[date.month - 1]} ${date.year}';
  }
}