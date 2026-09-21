import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import 'promo_section_card.dart';

class PromoDetailsSection extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController tagController;

  const PromoDetailsSection({
    super.key,
    required this.titleController,
    required this.descriptionController,
    required this.tagController,
  });

  InputDecoration _decoration({
    required String label,
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: AppColors.background,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(
          color: AppColors.textPrimary.withValues(alpha: 0.08),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: AppColors.textPrimary,
          width: 1.4,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PromoSectionCard(
      eyebrow: 'Promotion',
      title: 'Promotion details',
      description:
          'Give the offer a clear name and customer-facing discount tag.',
      child: Column(
        children: [
          TextFormField(
            controller: titleController,
            textCapitalization: TextCapitalization.words,
            decoration: _decoration(
              label: 'Promotion title',
              hint: 'Weekend Smoothie Sale',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Promotion title is required.';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: descriptionController,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            decoration: _decoration(
              label: 'Description',
              hint: 'Describe the promotion...',
            ),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: tagController,
            textCapitalization: TextCapitalization.characters,
            decoration: _decoration(
              label: 'Display tag',
              hint: '20% OFF',
            ),
          ),
        ],
      ),
    );
  }
}