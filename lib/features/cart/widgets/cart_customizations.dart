import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/helpers.dart';

class CartCustomizations extends StatelessWidget {
  final List<dynamic> options;

  const CartCustomizations({
    super.key,
    required this.options,
  });

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.tune_rounded,
                size: 13,
                color: AppColors.textSecondary
                    .withValues(alpha: 0.65),
              ),

              const SizedBox(width: 6),

              Text(
                'CUSTOMIZATIONS',
                style: TextStyle(
                  fontSize: 7,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.9,
                  color: AppColors.textSecondary
                      .withValues(alpha: 0.55),
                ),
              ),
            ],
          ),

          const SizedBox(height: 9),

          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: options.map((option) {
              final String name =
                  option['name']?.toString() ?? '';

              final double extraPrice =
                  (option['extra_price'] as num?)
                          ?.toDouble() ??
                      0;

              return Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius:
                      BorderRadius.circular(9),
                  border: Border.all(
                    color: AppColors.border
                        .withValues(alpha: 0.30),
                  ),
                ),
                child: Row(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 9.5,
                        fontWeight:
                            FontWeight.w700,
                        color:
                            AppColors.textPrimary,
                      ),
                    ),

                    if (extraPrice > 0) ...[
                      const SizedBox(width: 4),

                      Text(
                        '+${AppHelpers.formatCurrency(extraPrice)}',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight:
                              FontWeight.w700,
                          color: AppColors
                              .textSecondary
                              .withValues(
                            alpha: 0.70,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}