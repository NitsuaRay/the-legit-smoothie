import 'package:flutter/material.dart';
import 'package:the_legit_smoothie/core/constants/app_colors.dart';

class CustomerSettingsTab extends StatelessWidget {
  final VoidCallback onLogout;
  final ThemeMode currentThemeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  const CustomerSettingsTab({
    super.key,
    required this.onLogout,
    required this.currentThemeMode,
    required this.onThemeModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardColor = isDark ? AppColors.bobaBrown : AppColors.cardWhite;
    final primaryTextColor = isDark ? AppColors.cream : AppColors.darkText;
    final secondaryTextColor = isDark
        ? AppColors.cream.withValues(alpha: 0.7)
        : AppColors.greyText;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Header Section ---
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.cream.withValues(alpha: 0.15)
                      : AppColors.bobaBrown.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.settings_rounded,
                  color: isDark ? AppColors.cream : AppColors.bobaBrown,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: primaryTextColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    'Manage your account & app preferences',
                    style: TextStyle(
                      fontSize: 13,
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          // --- User Profile Header Card ---
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? AppColors.bobaBrown.withValues(alpha: 0.4)
                    : AppColors.greyBorder,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: isDark
                      ? AppColors.cream.withValues(alpha: 0.15)
                      : AppColors.bobaBrown.withValues(alpha: 0.1),
                  child: Icon(
                    Icons.person_rounded,
                    size: 30,
                    color: isDark ? AppColors.cream : AppColors.bobaBrown,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Valued Customer',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: primaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'customer@legitsmoothie.com',
                        style: TextStyle(
                          fontSize: 13,
                          color: secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.edit_outlined,
                    color: isDark ? AppColors.cream : AppColors.bobaBrown,
                    size: 20,
                  ),
                  onPressed: () {
                    // Edit Profile Action
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // --- Section Title: Account ---
          _buildSectionHeader(context, 'ACCOUNT', isDark: isDark),

          _buildSettingsCard(
            context,
            cardColor: cardColor,
            isDark: isDark,
            children: [
              _buildListTile(
                context,
                icon: Icons.receipt_long_rounded,
                title: 'Order History',
                subtitle: 'View your previous smoothie orders',
                primaryTextColor: primaryTextColor,
                secondaryTextColor: secondaryTextColor,
                isDark: isDark,
                onTap: () {},
              ),
              Divider(
                height: 1,
                color: isDark
                    ? AppColors.bobaBrown.withValues(alpha: 0.3)
                    : AppColors.greyBorder,
              ),
              _buildListTile(
                context,
                icon: Icons.location_on_rounded,
                title: 'Delivery Addresses',
                subtitle: 'Manage saved delivery locations',
                primaryTextColor: primaryTextColor,
                secondaryTextColor: secondaryTextColor,
                isDark: isDark,
                onTap: () {},
              ),
              Divider(
                height: 1,
                color: isDark
                    ? AppColors.bobaBrown.withValues(alpha: 0.3)
                    : AppColors.greyBorder,
              ),
              _buildListTile(
                context,
                icon: Icons.payment_rounded,
                title: 'Payment Methods',
                subtitle: 'Manage saved cards & GCash',
                primaryTextColor: primaryTextColor,
                secondaryTextColor: secondaryTextColor,
                isDark: isDark,
                onTap: () {},
              ),
            ],
          ),

          const SizedBox(height: 28),

          // --- Section Title: Appearance ---
          _buildSectionHeader(context, 'APPEARANCE', isDark: isDark),

          // --- Modern Theme Cards Grid ---
          Column(
            children: [
              _buildModernThemeOption(
                context,
                title: 'Light Mode',
                subtitle: 'Clean white background with boba accents',
                icon: Icons.wb_sunny_rounded,
                mode: ThemeMode.light,
                cardColor: cardColor,
                primaryTextColor: primaryTextColor,
                secondaryTextColor: secondaryTextColor,
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              _buildModernThemeOption(
                context,
                title: 'Dark Mode',
                subtitle: 'Rich Boba Brown background with cream text',
                icon: Icons.nightlight_round,
                mode: ThemeMode.dark,
                cardColor: cardColor,
                primaryTextColor: primaryTextColor,
                secondaryTextColor: secondaryTextColor,
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              _buildModernThemeOption(
                context,
                title: 'System Default',
                subtitle: 'Automatically match your device theme settings',
                icon: Icons.settings_suggest_rounded,
                mode: ThemeMode.system,
                cardColor: cardColor,
                primaryTextColor: primaryTextColor,
                secondaryTextColor: secondaryTextColor,
                isDark: isDark,
              ),
            ],
          ),

          const SizedBox(height: 28),

          // --- Section Title: Support & Legal ---
          _buildSectionHeader(context, 'SUPPORT & LEGAL', isDark: isDark),

          _buildSettingsCard(
            context,
            cardColor: cardColor,
            isDark: isDark,
            children: [
              _buildListTile(
                context,
                icon: Icons.help_outline_rounded,
                title: 'Help Center & Support',
                subtitle: 'FAQs and direct contact',
                primaryTextColor: primaryTextColor,
                secondaryTextColor: secondaryTextColor,
                isDark: isDark,
                onTap: () {},
              ),
              Divider(
                height: 1,
                color: isDark
                    ? AppColors.bobaBrown.withValues(alpha: 0.3)
                    : AppColors.greyBorder,
              ),
              _buildListTile(
                context,
                icon: Icons.privacy_tip_rounded,
                title: 'Privacy Policy',
                subtitle: 'Terms of service & privacy details',
                primaryTextColor: primaryTextColor,
                secondaryTextColor: secondaryTextColor,
                isDark: isDark,
                onTap: () {},
              ),
            ],
          ),

          const SizedBox(height: 40),

          // --- Logout Button ---
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.error.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: OutlinedButton.icon(
              onPressed: () => _showLogoutConfirmation(context, isDark: isDark),
              icon: const Icon(Icons.logout_rounded,
                  color: AppColors.error, size: 20),
              label: const Text(
                'Logout Account',
                style: TextStyle(
                  color: AppColors.error,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: cardColor,
                side: BorderSide(
                  color: AppColors.error.withValues(alpha: 0.3),
                  width: 1.5,
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title,
      {required bool isDark}) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: isDark
              ? AppColors.cream.withValues(alpha: 0.6)
              : AppColors.bobaBrown,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(
    BuildContext context, {
    required List<Widget> children,
    required Color cardColor,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppColors.bobaBrown.withValues(alpha: 0.4)
              : AppColors.greyBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required Color primaryTextColor,
    required Color secondaryTextColor,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.bobaBrown.withValues(alpha: 0.5)
              : AppColors.cardWhite,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isDark ? AppColors.cream : AppColors.bobaBrown,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: primaryTextColor,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: secondaryTextColor,
              ),
            )
          : null,
      trailing: Icon(
        Icons.chevron_right_rounded,
        size: 20,
        color: secondaryTextColor,
      ),
      onTap: onTap,
    );
  }

  Widget _buildModernThemeOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required ThemeMode mode,
    required Color cardColor,
    required Color primaryTextColor,
    required Color secondaryTextColor,
    required bool isDark,
  }) {
    final isSelected = currentThemeMode == mode;
    final activeBorderColor = isDark ? AppColors.cream : AppColors.bobaBrown;
    final activeIconBg = isDark
        ? AppColors.bobaBrown.withValues(alpha: 0.6)
        : AppColors.bobaBrown;

    final activeIconColor = isDark ? AppColors.cream : AppColors.cardWhite;

    return InkWell(
      onTap: () => onThemeModeChanged(mode),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? activeBorderColor
                : (isDark
                    ? AppColors.bobaBrown.withValues(alpha: 0.4)
                    : AppColors.greyBorder),
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? activeIconBg
                    : (isDark
                        ? AppColors.bobaBrown.withValues(alpha: 0.5)
                        : AppColors.background),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 20,
                color: isSelected ? activeIconColor : secondaryTextColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w600,
                      color: primaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: secondaryTextColor,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? activeBorderColor : Colors.transparent,
                border: isSelected
                    ? null
                    : Border.all(
                        color: isDark
                            ? AppColors.cream.withValues(alpha: 0.4)
                            : AppColors.greyBorder,
                        width: 1.5,
                      ),
              ),
              child: isSelected
                  ? Icon(
                      Icons.check_rounded,
                      size: 16,
                      color:
                          isDark ? AppColors.bobaBrown : AppColors.cardWhite,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context, {required bool isDark}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkText : AppColors.cardWhite,
        title: Text(
          'Confirm Logout',
          style: TextStyle(
            color: isDark ? AppColors.cream : AppColors.darkText,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to log out of your account?',
          style: TextStyle(
            color: isDark
                ? AppColors.cream.withValues(alpha: 0.8)
                : AppColors.greyText,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark
                    ? AppColors.cream.withValues(alpha: 0.7)
                    : AppColors.greyText,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.cardWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              onLogout();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}