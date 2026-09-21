import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class CheckoutSummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final String value;
  final Color? valueColor;

  const CheckoutSummaryRow({
    super.key,
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(
            icon,
            size: 16,
            color: AppColors.textSecondary,
          ),
        ),

        const SizedBox(width: 11),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary.withValues(
                    alpha: 0.55,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.15,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}