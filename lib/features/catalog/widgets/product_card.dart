import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/helpers.dart';
import '../models/product_model.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;
  final VoidCallback? onAddTap;

  // Ready for real review data later.
  final double? rating;
  final int reviewCount;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.onAddTap,
    this.rating,
    this.reviewCount = 0,
  });

  @override
  Widget build(BuildContext context) {

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: AppColors.border.withValues(
                alpha: 0.42,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: 0.035,
                ),
                blurRadius: 18,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(9),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ================================================
                // PRODUCT IMAGE
                // ================================================

                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(17),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(17),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(7),
                            child: _buildProductImage(),
                          ),

                          // Rating / New badge
                          Positioned(
                            top: 8,
                            left: 8,
                            child: _RatingBadge(
                              rating: rating,
                              reviewCount: reviewCount,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 11),

                // ================================================
                // NAME
                // ================================================

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 3,
                  ),
                  child: Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.1,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.3,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),

                const SizedBox(height: 5),

                // ================================================
                // DESCRIPTION
                // ================================================

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 3,
                  ),
                  child: Text(
                    product.description?.trim().isNotEmpty == true
                        ? product.description!
                        : 'Freshly prepared for you',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 9.5,
                      height: 1.3,
                      color: AppColors.textSecondary.withValues(
                        alpha: 0.72,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 11),

                // ================================================
                // PRICE + ADD
                // ================================================

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 3,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'FROM',
                              style: TextStyle(
                                fontSize: 7,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.7,
                                color: AppColors.textSecondary
                                    .withValues(
                                  alpha: 0.52,
                                ),
                              ),
                            ),

                            const SizedBox(height: 2),

                            Text(
                              AppHelpers.formatCurrency(
                                product.basePrice,
                              ),
                              style: const TextStyle(
                                fontSize: 16,
                                height: 1,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.4,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: onAddTap ?? onTap,
                          borderRadius:
                              BorderRadius.circular(13),
                          child: Ink(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius:
                                  BorderRadius.circular(13),
                            ),
                            child: const Icon(
                              Icons.add_rounded,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    final String? imageUrl = product.imageUrl;

    if (imageUrl == null || imageUrl.trim().isEmpty) {
      return _buildPlaceholder();
    }

    return Image.network(
      imageUrl,

      // IMPORTANT:
      // Don't crop seller-uploaded product photos.
      fit: BoxFit.contain,
      alignment: Alignment.center,

      loadingBuilder: (
        context,
        child,
        loadingProgress,
      ) {
        if (loadingProgress == null) {
          return child;
        }

        return const Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
        );
      },

      errorBuilder: (
        context,
        error,
        stackTrace,
      ) {
        return _buildPlaceholder();
      },
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.background,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(
                  alpha: 0.06,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.local_drink_outlined,
                size: 25,
                color: AppColors.primary,
              ),
            ),

            const SizedBox(height: 7),

            Text(
              'No image',
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary.withValues(
                  alpha: 0.55,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// RATING BADGE
// ================================================================

class _RatingBadge extends StatelessWidget {
  final double? rating;
  final int reviewCount;

  const _RatingBadge({
    required this.rating,
    required this.reviewCount,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasReviews =
        rating != null && reviewCount > 0;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(
          alpha: 0.94,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.black.withValues(
            alpha: 0.04,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.05,
            ),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasReviews
                ? Icons.star_rounded
                : Icons.star_outline_rounded,
            size: 12,
            color: hasReviews
                ? const Color(0xFFF5A623)
                : AppColors.textSecondary,
          ),

          const SizedBox(width: 3),

          Text(
            hasReviews
                ? rating!.toStringAsFixed(1)
                : 'New',
            style: TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.w800,
              color: hasReviews
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}