import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class ProfileInfoTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback? onEdit;
  final String? subtitle;

  const ProfileInfoTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.onEdit,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final bool isNotSet = value == 'Not set';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: AppColors.textSecondary,
          size: 20,
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isNotSet
                      ? AppColors.textSecondary
                      : AppColors.textPrimary,
                ),
              ),

              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),

        if (onEdit != null)
          IconButton(
            icon: const Icon(
              Icons.edit_outlined,
              size: 20,
              color: AppColors.primary,
            ),
            onPressed: onEdit,
            tooltip: 'Edit $label',
          ),
      ],
    );
  }
}