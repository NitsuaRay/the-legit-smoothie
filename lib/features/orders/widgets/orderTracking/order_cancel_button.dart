import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class OrderCancelButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const OrderCancelButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border.withValues(
            alpha: 0.28,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'NEED TO MAKE A CHANGE?',
            style: TextStyle(
              fontSize: 6.5,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'You can cancel while the order is still pending.',
            style: TextStyle(
              fontSize: 9,
              height: 1.4,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary.withValues(
                alpha: 0.72,
              ),
            ),
          ),

          const SizedBox(height: 13),

          SizedBox(
            width: double.infinity,
            height: 46,
            child: OutlinedButton(
              onPressed:
                  isLoading ? null : onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: BorderSide(
                  color: AppColors.error.withValues(
                    alpha: 0.28,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(14),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.error,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons
                              .close_rounded,
                          size: 16,
                        ),
                        SizedBox(width: 7),
                        Text(
                          'Cancel order',
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
    );
  }
}