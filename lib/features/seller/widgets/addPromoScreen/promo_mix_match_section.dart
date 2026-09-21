import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';
import 'promo_mix_match_group_card.dart';
import 'promo_section_card.dart';

class PromoMixMatchSection extends StatelessWidget {
  final TextEditingController bundlePriceController;
  final List<Map<String, dynamic>> groups;
  final List<Map<String, dynamic>> categories;
  final List<Map<String, dynamic>> products;

  final VoidCallback onAddGroup;
  final void Function(int index) onRemoveGroup;
  final void Function(int index, String value) onNameChanged;
  final void Function(int index, int value) onQuantityChanged;
  final void Function(int index, String id) onCategoryToggle;
  final void Function(int index, String id) onProductToggle;

  const PromoMixMatchSection({
    super.key,
    required this.bundlePriceController,
    required this.groups,
    required this.categories,
    required this.products,
    required this.onAddGroup,
    required this.onRemoveGroup,
    required this.onNameChanged,
    required this.onQuantityChanged,
    required this.onCategoryToggle,
    required this.onProductToggle,
  });

  @override
  Widget build(BuildContext context) {
    return PromoSectionCard(
      eyebrow: 'Bundle',
      title: 'Mix & Match',
      description:
          'Create selection groups and define how many items customers choose from each group.',
      child: Column(
        children: [
          TextFormField(
            controller: bundlePriceController,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                RegExp(r'^\d*\.?\d{0,2}'),
              ),
            ],
            decoration: InputDecoration(
              labelText: 'Bundle price',
              prefixText: '₱ ',
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            validator: (value) {
              final price = double.tryParse(value ?? '');

              if (price == null || price <= 0) {
                return 'Enter a valid bundle price.';
              }

              return null;
            },
          ),
          const SizedBox(height: 18),
          ...List.generate(groups.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: PromoMixMatchGroupCard(
                key: ValueKey(groups[index]['localId']),
                index: index,
                group: groups[index],
                categories: categories,
                products: products,
                onNameChanged: (value) =>
                    onNameChanged(index, value),
                onQuantityChanged: (value) =>
                    onQuantityChanged(index, value),
                onCategoryToggle: (id) =>
                    onCategoryToggle(index, id),
                onProductToggle: (id) =>
                    onProductToggle(index, id),
                onRemove: groups.length > 2
                    ? () => onRemoveGroup(index)
                    : null,
              ),
            );
          }),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onAddGroup,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add another group'),
            ),
          ),
        ],
      ),
    );
  }
}