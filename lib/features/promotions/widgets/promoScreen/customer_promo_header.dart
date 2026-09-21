import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class CustomerPromoHeader
    extends StatelessWidget {
  const CustomerPromoHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        18,
        16,
        18,
        18,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color:
                  AppColors.textPrimary,
              borderRadius:
                  BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.local_offer_outlined,
              size: 19,
              color: Colors.white,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'EXCLUSIVE OFFERS',
                  style: TextStyle(
                    fontSize: 7,
                    height: 1,
                    fontWeight:
                        FontWeight.w900,
                    letterSpacing: 1.2,
                    color: AppColors
                        .textSecondary
                        .withValues(
                      alpha: 0.50,
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  'Deals',
                  style: TextStyle(
                    fontSize: 24,
                    height: 1,
                    fontWeight:
                        FontWeight.w900,
                    letterSpacing: -0.7,
                    color:
                        AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  'More value in every order.',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight:
                        FontWeight.w500,
                    color: AppColors
                        .textSecondary
                        .withValues(
                      alpha: 0.70,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius:
                  BorderRadius.circular(30),
              border: Border.all(
                color: AppColors.border
                    .withValues(
                  alpha: 0.30,
                ),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.auto_awesome_outlined,
                  size: 12,
                  color:
                      AppColors.textPrimary,
                ),
                SizedBox(width: 5),
                Text(
                  'PROMOS',
                  style: TextStyle(
                    fontSize: 6.5,
                    fontWeight:
                        FontWeight.w900,
                    letterSpacing: 0.6,
                    color:
                        AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}