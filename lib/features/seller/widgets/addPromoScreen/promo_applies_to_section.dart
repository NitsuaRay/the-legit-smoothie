import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import 'promo_category_selector.dart';
import 'promo_product_selector.dart';
import 'promo_section_card.dart';

class PromoAppliesToSection extends StatelessWidget {
  final String appliesTo;
  final List<Map<String, dynamic>> categories;
  final List<Map<String, dynamic>> products;
  final Set<String> selectedCategoryIds;
  final Set<String> selectedProductIds;

  final ValueChanged<String> onAppliesToChanged;
  final ValueChanged<String> onCategoryToggle;
  final ValueChanged<String> onProductToggle;

  const PromoAppliesToSection({
    super.key,
    required this.appliesTo,
    required this.categories,
    required this.products,
    required this.selectedCategoryIds,
    required this.selectedProductIds,
    required this.onAppliesToChanged,
    required this.onCategoryToggle,
    required this.onProductToggle,
  });

  @override
  Widget build(BuildContext context) {
    return PromoSectionCard(
      eyebrow: 'Eligibility',
      title: 'Applies to',
      description:
          'Use the whole store or build a custom selection from categories and products.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _TargetButton(
                  title: 'Entire Store',
                  icon: Icons.storefront_outlined,
                  selected: appliesTo == 'store',
                  onTap: () => onAppliesToChanged('store'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _TargetButton(
                  title: 'Custom',
                  icon: Icons.tune_rounded,
                  selected: appliesTo == 'selection',
                  onTap: () => onAppliesToChanged('selection'),
                ),
              ),
            ],
          ),
          if (appliesTo == 'selection') ...[
            const SizedBox(height: 22),
            const Text(
              'CATEGORIES',
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            PromoCategorySelector(
              categories: categories,
              selectedIds: selectedCategoryIds,
              onToggle: onCategoryToggle,
            ),
            const SizedBox(height: 22),
            const Text(
              'SPECIFIC PRODUCTS',
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            PromoProductSelector(
              products: products,
              selectedIds: selectedProductIds,
              onToggle: onProductToggle,
            ),
          ],
        ],
      ),
    );
  }
}

class _TargetButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _TargetButton({
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.textPrimary
              : AppColors.background,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: selected
                  ? Colors.white
                  : AppColors.textPrimary,
            ),
            const SizedBox(height: 7),
            Text(
              title,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: selected
                    ? Colors.white
                    : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}