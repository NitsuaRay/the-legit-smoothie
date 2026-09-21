import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class SellerProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool destructive;
  final Widget? trailing;

  const SellerProfileMenuItem({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.destructive = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final Color foreground =
        destructive ? Colors.red.shade700 : AppColors.textPrimary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: destructive
                      ? Colors.red.withValues(alpha: 0.06)
                      : AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: foreground,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: foreground,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 8.5,
                        height: 1.3,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary.withValues(
                          alpha: 0.68,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              trailing ??
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: destructive
                        ? Colors.red.shade300
                        : AppColors.textSecondary.withValues(
                            alpha: 0.55,
                          ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}