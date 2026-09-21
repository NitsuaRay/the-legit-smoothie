import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class SellerPromoFilters extends StatelessWidget {
  final String selected;
  final int allCount;
  final int activeCount;
  final int upcomingCount;
  final int expiredCount;
  final ValueChanged<String> onChanged;

  const SellerPromoFilters({
    super.key,
    required this.selected,
    required this.allCount,
    required this.activeCount,
    required this.upcomingCount,
    required this.expiredCount,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildButton(
            id: 'all',
            label: 'All',
            count: allCount,
            icon: Icons.apps_rounded,
          ),
          const SizedBox(width: 8),
          _buildButton(
            id: 'active',
            label: 'Active',
            count: activeCount,
            icon: Icons.bolt_rounded,
          ),
          const SizedBox(width: 8),
          _buildButton(
            id: 'upcoming',
            label: 'Upcoming',
            count: upcomingCount,
            icon: Icons.schedule_rounded,
          ),
          const SizedBox(width: 8),
          _buildButton(
            id: 'expired',
            label: 'Expired',
            count: expiredCount,
            icon: Icons.history_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required String id,
    required String label,
    required int count,
    required IconData icon,
  }) {
    final bool isSelected = selected == id;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onChanged(id),
        borderRadius: BorderRadius.circular(15),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 46,
          padding: const EdgeInsets.symmetric(
            horizontal: 13,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.textPrimary
                : AppColors.surface,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: isSelected
                  ? AppColors.textPrimary
                  : AppColors.border.withValues(
                      alpha: 0.40,
                    ),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14,
                color: isSelected
                    ? Colors.white
                    : AppColors.textPrimary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: isSelected
                      ? Colors.white
                      : AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                constraints: const BoxConstraints(
                  minWidth: 19,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 5,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(
                          alpha: 0.13,
                        )
                      : AppColors.background,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  count > 99 ? '99+' : '$count',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 7,
                    fontWeight: FontWeight.w900,
                    color: isSelected
                        ? Colors.white
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}