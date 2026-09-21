import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class SellerStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;

  /// Optional visual emphasis for something requiring attention.
  final bool isAttention;

  final VoidCallback? onTap;

  const SellerStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    this.isAttention = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isAttention
              ? Colors.amber.shade700.withValues(alpha: 0.18)
              : AppColors.border.withValues(alpha: 0.42),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // =======================================================
          // ICON + OPTIONAL INDICATOR
          // =======================================================

          Row(
            children: [
              Container(
                width: 39,
                height: 39,
                decoration: BoxDecoration(
                  color: isAttention
                      ? Colors.amber.shade700.withValues(alpha: 0.08)
                      : AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isAttention
                        ? Colors.amber.shade700.withValues(alpha: 0.10)
                        : AppColors.border.withValues(alpha: 0.20),
                  ),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: isAttention
                      ? Colors.amber.shade800
                      : AppColors.textPrimary,
                ),
              ),

              const Spacer(),

              if (isAttention)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade700.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.amber.shade800,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'ACTION',
                        style: TextStyle(
                          fontSize: 6.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                          color: Colors.amber.shade900,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Icon(
                  Icons.more_horiz_rounded,
                  size: 17,
                  color: AppColors.textSecondary.withValues(alpha: 0.35),
                ),
            ],
          ),

          const Spacer(),

          // =======================================================
          // VALUE
          // =======================================================

          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 25,
              height: 1,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.7,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 6),

          // =======================================================
          // TITLE
          // =======================================================

          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.15,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 4),

          // =======================================================
          // SUBTITLE
          // =======================================================

          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary.withValues(alpha: 0.68),
            ),
          ),
        ],
      ),
    );

    if (onTap == null) {
      return card;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: card,
      ),
    );
  }
}