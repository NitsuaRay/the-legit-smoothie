import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import 'promo_section_card.dart';

class PromoTypeSelector extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const PromoTypeSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PromoSectionCard(
      eyebrow: 'Deal type',
      title: 'How does this promotion work?',
      child: Column(
        children: [
          _Option(
            title: 'Simple Discount',
            description:
                'Discount the entire store, categories, or selected products.',
            icon: Icons.percent_rounded,
            selected: value == 'simple_discount',
            onTap: () => onChanged('simple_discount'),
          ),
          const SizedBox(height: 10),
          _Option(
            title: 'Mix & Match',
            description:
                'Let customers combine eligible items for one bundle price.',
            icon: Icons.grid_view_rounded,
            selected: value == 'mix_and_match',
            onTap: () => onChanged('mix_and_match'),
          ),
        ],
      ),
    );
  }
}

class _Option extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _Option({
    required this.title,
    required this.description,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(17),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.textPrimary
              : AppColors.background,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: selected
                ? AppColors.textPrimary
                : AppColors.textPrimary.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected
                  ? Colors.white
                  : AppColors.textPrimary,
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: selected
                          ? Colors.white
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 9.5,
                      height: 1.4,
                      color: selected
                          ? Colors.white.withValues(alpha: 0.68)
                          : AppColors.textPrimary.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(
              selected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: selected
                  ? Colors.white
                  : AppColors.textPrimary.withValues(alpha: 0.35),
            ),
          ],
        ),
      ),
    );
  }
}