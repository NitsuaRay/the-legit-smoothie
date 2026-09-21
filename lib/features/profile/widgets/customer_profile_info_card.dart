import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class CustomerProfileInfoItem {
  final IconData icon;
  final String label;
  final String value;

  const CustomerProfileInfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });
}

class CustomerProfileInfoCard extends StatelessWidget {
  final List<CustomerProfileInfoItem> items;

  const CustomerProfileInfoCard({
    super.key,
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
            'CONTACT',
            style: TextStyle(
              fontSize: 7,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.1,
              color: AppColors.textSecondary.withValues(alpha: 0.58),
            ),
          ),
          const SizedBox(height: 3),
          const Text(
            'Contact information',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.35,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          for (int index = 0; index < items.length; index++) ...[
            _InfoRow(item: items[index]),
            if (index != items.length - 1)
              Padding(
                padding: const EdgeInsets.only(
                  left: 52,
                  top: 12,
                  bottom: 12,
                ),
                child: Divider(
                  height: 1,
                  color: AppColors.border.withValues(alpha: 0.20),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final CustomerProfileInfoItem item;

  const _InfoRow({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasValue = item.value.trim().isNotEmpty;

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.border.withValues(alpha: 0.20),
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
                  color: AppColors.textSecondary.withValues(alpha: 0.58),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                hasValue ? item.value.trim() : 'Not provided',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10.5,
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                  color: hasValue
                      ? AppColors.textPrimary
                      : AppColors.textSecondary.withValues(alpha: 0.62),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}