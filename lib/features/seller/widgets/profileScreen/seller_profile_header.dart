import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class SellerProfileHeader extends StatelessWidget {
  final VoidCallback? onRefresh;
  final bool isRefreshing;

  const SellerProfileHeader({
    super.key,
    this.onRefresh,
    this.isRefreshing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // =====================================================
        // ONE ICON ONLY
        // =====================================================

        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: AppColors.border.withValues(
                alpha: 0.35,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: 0.025,
                ),
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

        // =====================================================
        // TEXT BLOCK
        // =====================================================

        const Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
                'Manage your seller account',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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

        // =====================================================
        // REFRESH ACTION
        // =====================================================

        _HeaderActionButton(
          tooltip: 'Refresh profile',
          loading: isRefreshing,
          onTap: isRefreshing ? null : onRefresh,
        ),
      ],
    );
  }
}

// =============================================================
// REFRESH BUTTON
// =============================================================

class _HeaderActionButton extends StatelessWidget {
  final String tooltip;
  final bool loading;
  final VoidCallback? onTap;

  const _HeaderActionButton({
    required this.tooltip,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(13),
          child: Ink(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: AppColors.border.withValues(
                  alpha: 0.35,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: 0.025,
                  ),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: loading
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
    );
  }
}