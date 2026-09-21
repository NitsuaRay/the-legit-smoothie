import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class SellerProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final bool isUpdatingAvailability;
  final VoidCallback onEdit;
  final ValueChanged<bool> onAvailabilityChanged;

  const SellerProductCard({
    super.key,
    required this.product,
    required this.onEdit,
    required this.onAvailabilityChanged,
    this.isUpdatingAvailability = false,
  });

  @override
  Widget build(BuildContext context) {
    // ============================================================
    // PRODUCT DATA
    // ============================================================

    final String name = (product['name'] ?? 'Unnamed Product').toString();

    final String description = (product['description'] ?? '').toString().trim();

    final String imageUrl = (product['image_url'] ?? '').toString().trim();

    final double price = (product['base_price'] as num?)?.toDouble() ?? 0;

    final bool isAvailable = product['is_available'] == true;

    final dynamic categoryData = product['categories'];

    String categoryName = 'Uncategorized';

    if (categoryData is Map) {
      categoryName = (categoryData['name'] ?? 'Uncategorized').toString();
    }

    // ============================================================
    // RATING DATA
    //
    // These are safe defaults.
    // Later we can connect these to the reviews table.
    // ============================================================

    final double rating = (product['average_rating'] as num?)?.toDouble() ?? 0;

    final int reviewCount = (product['review_count'] as num?)?.toInt() ?? 0;

    // ============================================================
    // CARD
    // ============================================================

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.42)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 20,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ======================================================
          // PRODUCT IMAGE
          // ======================================================
          _ProductImage(imageUrl: imageUrl, isAvailable: isAvailable),

          const SizedBox(width: 14),

          // ======================================================
          // PRODUCT DETAILS
          // ======================================================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==================================================
                // NAME + EDIT
                // ==================================================
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.35,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),

                    const SizedBox(width: 6),

                    _EditButton(onTap: onEdit),
                  ],
                ),

                const SizedBox(height: 7),

                // ==================================================
                // CATEGORY + RATING
                // ==================================================
                Row(
                  children: [
                    Flexible(child: _CategoryBadge(categoryName: categoryName)),

                    const SizedBox(width: 8),

                    Container(
                      width: 3,
                      height: 3,
                      decoration: BoxDecoration(
                        color: AppColors.textSecondary.withValues(alpha: 0.35),
                        shape: BoxShape.circle,
                      ),
                    ),

                    const SizedBox(width: 8),

                    _RatingDisplay(rating: rating, reviewCount: reviewCount),
                  ],
                ),

                // ==================================================
                // DESCRIPTION
                // ==================================================
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 8),

                  Text(
                    description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10.5,
                      height: 1.3,
                      color: AppColors.textSecondary.withValues(alpha: 0.82),
                    ),
                  ),
                ],
                const SizedBox(height: 14),

                // ==================================================
                // PRICE + SWITCH
                // ==================================================
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'REGULAR PRICE',
                            style: TextStyle(
                              fontSize: 7.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.7,
                              color: AppColors.textSecondary.withValues(
                                alpha: 0.55,
                              ),
                            ),
                          ),

                          const SizedBox(height: 2),

                          Text(
                            '₱${price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 17,
                              height: 1,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.4,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (isUpdatingAvailability)
                      const SizedBox(
                        width: 36,
                        height: 36,
                        child: Center(
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      )
                    else
                      Transform.scale(
                        scale: 0.78,
                        child: Switch(
                          value: isAvailable,
                          onChanged: onAvailabilityChanged,
                          activeThumbColor: Colors.white,
                          activeTrackColor: AppColors.primary,
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 6),

                // ==================================================
                // AVAILABILITY
                // ==================================================
                _AvailabilityLabel(isAvailable: isAvailable),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ===================================================================
// PRODUCT IMAGE
// ===================================================================

class _ProductImage extends StatelessWidget {
  final String imageUrl;
  final bool isAvailable;

  const _ProductImage({required this.imageUrl, required this.isAvailable});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 118,
      height: 138,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.38)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              color: Colors.white,
              child: imageUrl.isEmpty
                  ? _placeholder()
                  : Padding(
                      padding: const EdgeInsets.all(6),
                      child: Image.network(
                        imageUrl,

                        // Keeps the COMPLETE product visible.
                        fit: BoxFit.contain,
                        alignment: Alignment.center,

                        loadingBuilder: (context, child, loadingProgress) {
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

                        errorBuilder: (context, error, stackTrace) {
                          return _placeholder();
                        },
                      ),
                    ),
            ),

            // -------------------------------------------------------
            // Unavailable image treatment
            // -------------------------------------------------------
            if (!isAvailable)
              Positioned.fill(
                child: Container(color: Colors.white.withValues(alpha: 0.64)),
              ),

            // -------------------------------------------------------
            // Availability dot
            // -------------------------------------------------------
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: isAvailable
                      ? AppColors.success
                      : AppColors.textSecondary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.10),
                      blurRadius: 5,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_drink_outlined,
            size: 31,
            color: AppColors.textSecondary.withValues(alpha: 0.28),
          ),

          const SizedBox(height: 5),

          Text(
            'No image',
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary.withValues(alpha: 0.45),
            ),
          ),
        ],
      ),
    );
  }
}

// ===================================================================
// CATEGORY BADGE
// ===================================================================

class _CategoryBadge extends StatelessWidget {
  final String categoryName;

  const _CategoryBadge({required this.categoryName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.065),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        categoryName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 8.5,
          fontWeight: FontWeight.w800,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

// ===================================================================
// RATING
// ===================================================================

class _RatingDisplay extends StatelessWidget {
  final double rating;
  final int reviewCount;

  const _RatingDisplay({required this.rating, required this.reviewCount});

  @override
  Widget build(BuildContext context) {
    // No reviews yet.
    if (reviewCount <= 0) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star_outline_rounded,
            size: 14,
            color: AppColors.textSecondary.withValues(alpha: 0.55),
          ),

          const SizedBox(width: 3),

          Text(
            'New',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary.withValues(alpha: 0.70),
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star_rounded, size: 14, color: Color(0xFFF5A623)),

        const SizedBox(width: 3),

        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(width: 3),

        Text(
          '($reviewCount)',
          style: TextStyle(
            fontSize: 8.5,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary.withValues(alpha: 0.70),
          ),
        ),
      ],
    );
  }
}

// ===================================================================
// AVAILABILITY
// ===================================================================

class _AvailabilityLabel extends StatelessWidget {
  final bool isAvailable;

  const _AvailabilityLabel({required this.isAvailable});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: isAvailable ? AppColors.success : AppColors.textSecondary,
            shape: BoxShape.circle,
          ),
        ),

        const SizedBox(width: 5),

        Text(
          isAvailable ? 'Available' : 'Unavailable',
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: isAvailable ? AppColors.success : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

// ===================================================================
// EDIT BUTTON
// ===================================================================

class _EditButton extends StatelessWidget {
  final VoidCallback onTap;

  const _EditButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11),
        child: Ink(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.40)),
          ),
          child: const Icon(
            Icons.edit_outlined,
            size: 16,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
