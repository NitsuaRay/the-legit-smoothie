import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class CartEmptyState
    extends StatelessWidget {
  final VoidCallback onExplore;

  const CartEmptyState({
    super.key,
    required this.onExplore,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 42,
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius:
                    BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.border
                      .withValues(alpha: 0.32),
                ),
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                size: 30,
                color:
                    AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              'YOUR CART',
              style: TextStyle(
                fontSize: 7,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.1,
                color: AppColors.textSecondary
                    .withValues(alpha: 0.55),
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Nothing here yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
                color:
                    AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Add your favorite smoothies, drinks '
              'and snacks to start your order.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10.5,
                height: 1.5,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary
                    .withValues(alpha: 0.72),
              ),
            ),

            const SizedBox(height: 22),

            SizedBox(
              height: 47,
              child: ElevatedButton(
                onPressed: onExplore,
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      AppColors.textPrimary,
                  foregroundColor:
                      Colors.white,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 22,
                  ),
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      14,
                    ),
                  ),
                ),
                child: const Row(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    Icon(
                      Icons
                          .storefront_outlined,
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Explore Menu',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight:
                            FontWeight.w800,
                      ),
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
}