import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import 'promo_category_selector.dart';
import 'promo_product_selector.dart';

class PromoMixMatchGroupCard extends StatelessWidget {
  final int index;
  final Map<String, dynamic> group;
  final List<Map<String, dynamic>> categories;
  final List<Map<String, dynamic>> products;

  final ValueChanged<String> onNameChanged;
  final ValueChanged<int> onQuantityChanged;
  final ValueChanged<String> onCategoryToggle;
  final ValueChanged<String> onProductToggle;
  final VoidCallback? onRemove;

  const PromoMixMatchGroupCard({
    super.key,
    required this.index,
    required this.group,
    required this.categories,
    required this.products,
    required this.onNameChanged,
    required this.onQuantityChanged,
    required this.onCategoryToggle,
    required this.onProductToggle,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final categoryIds =
        Set<String>.from(group['categoryIds'] ?? <String>{});

    final productIds =
        Set<String>.from(group['productIds'] ?? <String>{});

    final quantity =
        (group['requiredQuantity'] as int?) ?? 1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.textPrimary.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.textPrimary,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Selection Group ${index + 1}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (onRemove != null)
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          TextFormField(
            initialValue: group['name']?.toString() ?? '',
            onChanged: onNameChanged,
            decoration: InputDecoration(
              labelText: 'Group name',
              hintText: index == 0 ? 'Drink' : 'Snack',
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Customer chooses',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton(
                onPressed: quantity > 1
                    ? () => onQuantityChanged(quantity - 1)
                    : null,
                icon: const Icon(
                  Icons.remove_circle_outline_rounded,
                ),
              ),
              Text(
                '$quantity',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              IconButton(
                onPressed: () =>
                    onQuantityChanged(quantity + 1),
                icon: const Icon(
                  Icons.add_circle_outline_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'ELIGIBLE CATEGORIES',
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 9),
          PromoCategorySelector(
            categories: categories,
            selectedIds: categoryIds,
            onToggle: onCategoryToggle,
          ),
          const SizedBox(height: 18),
          const Text(
            'ELIGIBLE PRODUCTS',
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 9),
          PromoProductSelector(
            products: products,
            selectedIds: productIds,
            onToggle: onProductToggle,
          ),
        ],
      ),
    );
  }
}