import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class CustomerPromoBadge
    extends StatelessWidget {
  final IconData icon;
  final String text;

  const CustomerPromoBadge({
    super.key,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius:
            BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 11,
            color:
                AppColors.textSecondary,
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              text,
              overflow:
                  TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 7.5,
                fontWeight:
                    FontWeight.w700,
                color: AppColors
                    .textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}