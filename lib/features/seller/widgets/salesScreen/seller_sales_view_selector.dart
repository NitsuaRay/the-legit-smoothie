import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class SellerSalesViewSelector extends StatelessWidget {
  final bool isMonthly;
  final VoidCallback onDailyPressed;
  final VoidCallback onMonthlyPressed;

  const SellerSalesViewSelector({
    super.key,
    required this.isMonthly,
    required this.onDailyPressed,
    required this.onMonthlyPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(17),
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
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _ViewButton(
              label: 'Daily',
              description: 'By day',
              icon: Icons.today_outlined,
              selected: !isMonthly,
              onTap: onDailyPressed,
            ),
          ),

          const SizedBox(width: 5),

          Expanded(
            child: _ViewButton(
              label: 'Monthly',
              description: 'By month',
              icon: Icons.calendar_month_outlined,
              selected: isMonthly,
              onTap: onMonthlyPressed,
            ),
          ),
        ],
      ),
    );
  }
}

class _ViewButton extends StatelessWidget {
  final String label;
  final String description;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ViewButton({
    required this.label,
    required this.description,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: AnimatedContainer(
          duration: const Duration(
            milliseconds: 220,
          ),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(
            horizontal: 11,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.textPrimary
                : Colors.transparent,
            borderRadius: BorderRadius.circular(13),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: 0.10,
                      ),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              // =================================================
              // ICON
              // =================================================

              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white.withValues(
                          alpha: 0.10,
                        )
                      : AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 15,
                  color: selected
                      ? Colors.white
                      : AppColors.textPrimary,
                ),
              ),

              const SizedBox(width: 9),

              // =================================================
              // TEXT
              // =================================================

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 10.5,
                        height: 1,
                        fontWeight: FontWeight.w900,
                        color: selected
                            ? Colors.white
                            : AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 7.5,
                        height: 1,
                        fontWeight: FontWeight.w500,
                        color: selected
                            ? Colors.white.withValues(
                                alpha: 0.55,
                              )
                            : AppColors.textSecondary
                                .withValues(
                                alpha: 0.60,
                              ),
                      ),
                    ),
                  ],
                ),
              ),

              if (selected)
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}