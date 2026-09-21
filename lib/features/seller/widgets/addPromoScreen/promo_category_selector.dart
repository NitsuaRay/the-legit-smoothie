import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class PromoCategorySelector extends StatelessWidget {
  final List<Map<String, dynamic>> categories;
  final Set<String> selectedIds;
  final ValueChanged<String> onToggle;

  const PromoCategorySelector({
    super.key,
    required this.categories,
    required this.selectedIds,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const Text(
        'No categories available.',
        style: TextStyle(fontSize: 11),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories.map((category) {
        final id = category['id'].toString();
        final selected = selectedIds.contains(id);

        return InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () => onToggle(id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 9,
            ),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.textPrimary
                  : AppColors.background,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: selected
                    ? AppColors.textPrimary
                    : AppColors.textPrimary.withValues(alpha: 0.1),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  selected
                      ? Icons.check_rounded
                      : Icons.add_rounded,
                  size: 14,
                  color: selected
                      ? Colors.white
                      : AppColors.textPrimary,
                ),
                const SizedBox(width: 5),
                Text(
                  category['name']?.toString() ?? 'Category',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: selected
                        ? Colors.white
                        : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}