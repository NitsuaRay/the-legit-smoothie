import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

// =============================================================
// CONTACT ITEM MODEL
// =============================================================

class SellerProfileInfoItem {
  final IconData icon;
  final String label;
  final String value;

  const SellerProfileInfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });
}

// =============================================================
// CONTACT INFORMATION CARD
// =============================================================

class SellerProfileInfoCard extends StatelessWidget {
  final String eyebrow;
  final String title;
  final List<SellerProfileInfoItem> items;

  const SellerProfileInfoCard({
    super.key,
    this.eyebrow = 'Contact',
    this.title = 'Contact information',
    required this.items,
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
          color: AppColors.border.withValues(alpha: 0.30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
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

          const SizedBox(height: 14),

          for (int index = 0; index < items.length; index++) ...[
            _ContactRow(
              item: items[index],
            ),

            if (index < items.length - 1)
              Padding(
                padding: const EdgeInsets.only(
                  left: 52,
                  top: 12,
                  bottom: 12,
                ),
                child: Divider(
                  height: 1,
                  color: AppColors.border.withValues(
                    alpha: 0.20,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

// =============================================================
// CONTACT ROW
// =============================================================

class _ContactRow extends StatelessWidget {
  final SellerProfileInfoItem item;

  const _ContactRow({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasValue =
        item.value.trim().isNotEmpty;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.border.withValues(
                alpha: 0.20,
              ),
            ),
          ),
          child: Icon(
            item.icon,
            size: 17,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.label.toUpperCase(),
                style: TextStyle(
                  fontSize: 6.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                  color: AppColors.textSecondary.withValues(
                    alpha: 0.58,
                  ),
                ),
              ),

              const SizedBox(height: 4),

              Text(
                hasValue
                    ? item.value.trim()
                    : 'Not provided',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10.5,
                  height: 1.3,
                  fontWeight: FontWeight.w700,
                  color: hasValue
                      ? AppColors.textPrimary
                      : AppColors.textSecondary.withValues(
                          alpha: 0.62,
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}