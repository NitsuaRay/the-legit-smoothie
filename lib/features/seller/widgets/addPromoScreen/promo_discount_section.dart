import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';
import 'promo_section_card.dart';

class PromoDiscountSection extends StatelessWidget {
  final String discountType;
  final TextEditingController valueController;
  final bool discountOptions;
  final ValueChanged<String> onTypeChanged;
  final ValueChanged<bool> onDiscountOptionsChanged;

  const PromoDiscountSection({
    super.key,
    required this.discountType,
    required this.valueController,
    required this.discountOptions,
    required this.onTypeChanged,
    required this.onDiscountOptionsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PromoSectionCard(
      eyebrow: 'Reward',
      title: 'Discount',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _Choice(
                  title: 'Percentage',
                  selected: discountType == 'percentage',
                  onTap: () => onTypeChanged('percentage'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Choice(
                  title: 'Fixed amount',
                  selected: discountType == 'fixed_amount',
                  onTap: () => onTypeChanged('fixed_amount'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          TextFormField(
            controller: valueController,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                RegExp(r'^\d*\.?\d{0,2}'),
              ),
            ],
            decoration: InputDecoration(
              labelText: discountType == 'percentage'
                  ? 'Discount percentage'
                  : 'Discount amount',
              prefixText:
                  discountType == 'fixed_amount' ? '₱ ' : null,
              suffixText:
                  discountType == 'percentage' ? '%' : null,
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            validator: (value) {
              final parsed = double.tryParse(value ?? '');

              if (parsed == null || parsed <= 0) {
                return 'Enter a valid discount.';
              }

              if (discountType == 'percentage' && parsed > 100) {
                return 'Percentage cannot exceed 100%.';
              }

              return null;
            },
          ),
          const SizedBox(height: 10),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: discountOptions,
            activeThumbColor: AppColors.textPrimary,
            title: const Text(
              'Discount product options',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
            subtitle: const Text(
              'Also discount paid sizes and add-ons.',
              style: TextStyle(fontSize: 9.5),
            ),
            onChanged: onDiscountOptionsChanged,
          ),
        ],
      ),
    );
  }
}

class _Choice extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _Choice({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.textPrimary
              : AppColors.background,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: selected
                ? Colors.white
                : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}