import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class PromoProductSelector extends StatelessWidget {
  final List<Map<String, dynamic>> products;
  final Set<String> selectedIds;
  final ValueChanged<String> onToggle;

  const PromoProductSelector({
    super.key,
    required this.products,
    required this.selectedIds,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const Text(
        'No products available.',
        style: TextStyle(fontSize: 11),
      );
    }

    return Column(
      children: products.map((product) {
        final id = product['id'].toString();
        final selected = selectedIds.contains(id);

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: () => onToggle(id),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.textPrimary
                    : AppColors.background,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  Icon(
                    selected
                        ? Icons.check_circle_rounded
                        : Icons.circle_outlined,
                    size: 19,
                    color: selected
                        ? Colors.white
                        : AppColors.textPrimary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      product['name']?.toString() ?? 'Product',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: selected
                            ? Colors.white
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    '₱${product['base_price'] ?? 0}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: selected
                          ? Colors.white.withValues(alpha: 0.7)
                          : AppColors.textPrimary.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}