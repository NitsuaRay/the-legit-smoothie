import 'package:flutter/material.dart';
import 'package:the_legit_smoothie/core/constants/app_colors.dart';

class SellerSettingsTab extends StatelessWidget {
  final VoidCallback onLogout;
  final ThemeMode currentThemeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  const SellerSettingsTab({
    super.key,
    required this.onLogout,
    required this.currentThemeMode,
    required this.onThemeModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardColor = isDark ? AppColors.darkText : AppColors.cardWhite;
    final primaryTextColor = isDark ? AppColors.cream : AppColors.darkText;
    final secondaryTextColor = isDark
        ? AppColors.cream.withOpacity(0.7)
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
                      ? AppColors.cream.withOpacity(0.15)
                      : AppColors.bobaBrown.withOpacity(0.1),
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
                    'Seller Settings',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: primaryTextColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    'Customize your shop app experience',
                    style: TextStyle(
                      fontSize: 13,
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 28),

          // --- Section Title: Appearance ---
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'APPEARANCE',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.cream.withOpacity(0.6)
                    : AppColors.bobaBrown,
                letterSpacing: 1.2,
              ),
            ),
          ),

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

          const SizedBox(height: 40),

          // --- Logout Button ---
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.error.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: OutlinedButton.icon(
              onPressed: onLogout,
              icon: const Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
              label: const Text(
                'Logout Account',
                style: TextStyle(
                  color: AppColors.error,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: isDark 
                    ? AppColors.darkText 
                    : AppColors.cardWhite,
                side: BorderSide(
                  color: AppColors.error.withOpacity(0.3),
                  width: 1.5,
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
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
    final activeIconBg = isDark ? AppColors.cream : AppColors.bobaBrown;
    final activeIconColor = isDark ? AppColors.bobaBrown : AppColors.cardWhite;

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
                    ? AppColors.bobaBrown.withOpacity(0.4)
                    : AppColors.greyBorder),
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon container
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? activeIconBg
                    : (isDark
                        ? AppColors.bobaBrown.withOpacity(0.5)
                        : AppColors.background),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 20,
                color: isSelected
                    ? activeIconColor
                    : secondaryTextColor,
              ),
            ),
            const SizedBox(width: 16),

            // Text Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
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

            // Selection Badge Indicator
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
                        color: isDark ? AppColors.cream.withOpacity(0.4) : AppColors.greyBorder,
                        width: 1.5,
                      ),
              ),
              child: isSelected
                  ? Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: isDark ? AppColors.bobaBrown : AppColors.cardWhite,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}