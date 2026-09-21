import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class CheckoutOrderTypeSelector extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const CheckoutOrderTypeSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.30),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _OrderTypeButton(
              label: 'Delivery',
              subtitle: 'To your address',
              icon: Icons.delivery_dining_outlined,
              selected: value == 'delivery',
              onTap: () => onChanged('delivery'),
            ),
          ),

          const SizedBox(width: 5),

          Expanded(
            child: _OrderTypeButton(
              label: 'Store Pickup',
              subtitle: 'Collect in store',
              icon: Icons.storefront_outlined,
              selected: value == 'pickup',
              onTap: () => onChanged('pickup'),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderTypeButton extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _OrderTypeButton({
    required this.label,
    required this.subtitle,
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
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 11,
          ),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.textPrimary
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white.withValues(alpha: 0.12)
                      : AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 16,
                  color: selected
                      ? Colors.white
                      : AppColors.textPrimary,
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: selected
                            ? Colors.white
                            : AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 7.5,
                        fontWeight: FontWeight.w500,
                        color: selected
                            ? Colors.white.withValues(alpha: 0.60)
                            : AppColors.textSecondary.withValues(
                                alpha: 0.60,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}