import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class CustomerProfileHeader extends StatelessWidget {
  final VoidCallback? onRefresh;
  final bool isRefreshing;

  const CustomerProfileHeader({
    super.key,
    this.onRefresh,
    this.isRefreshing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: AppColors.border.withValues(alpha: 0.35),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.025),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(
            Icons.person_outline_rounded,
            size: 20,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 11),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ACCOUNT',
                style: TextStyle(
                  fontSize: 6.5,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.15,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Profile',
                style: TextStyle(
                  fontSize: 18,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.45,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Manage your customer account',
                style: TextStyle(
                  fontSize: 8,
                  height: 1,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Tooltip(
          message: 'Refresh profile',
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isRefreshing ? null : onRefresh,
              borderRadius: BorderRadius.circular(13),
              child: Ink(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                    color: AppColors.border.withValues(alpha: 0.35),
                  ),
                ),
                child: Center(
                  child: isRefreshing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.textPrimary,
                          ),
                        )
                      : const Icon(
                          Icons.refresh_rounded,
                          size: 19,
                          color: AppColors.textPrimary,
                        ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}