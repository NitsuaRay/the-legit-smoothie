import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import 'promo_section_card.dart';

class PromoBannerSection extends StatelessWidget {
  final Uint8List? imageBytes;
  final bool isPicking;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  const PromoBannerSection({
    super.key,
    required this.imageBytes,
    required this.isPicking,
    required this.onPick,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return PromoSectionCard(
      eyebrow: 'Creative',
      title: 'Promotion banner',
      description:
          'Add an image customers will see with this promotion.',
      child: imageBytes == null
          ? _buildEmpty()
          : _buildPreview(),
    );
  }

  Widget _buildEmpty() {
    return InkWell(
      onTap: isPicking ? null : onPick,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        height: 170,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.textPrimary.withValues(
              alpha: 0.10,
            ),
          ),
        ),
        child: isPicking
            ? const Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.textPrimary,
                  ),
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 22,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Add banner image',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'JPG or PNG • Landscape recommended',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary.withValues(
                        alpha: 0.65,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildPreview() {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.memory(
              imageBytes!,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ),

        const SizedBox(height: 11),

        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: isPicking ? null : onPick,
                icon: const Icon(
                  Icons.photo_library_outlined,
                  size: 17,
                ),
                label: const Text(
                  'Replace',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 9),

            SizedBox(
              width: 46,
              height: 46,
              child: OutlinedButton(
                onPressed: isPicking ? null : onRemove,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.zero,
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}