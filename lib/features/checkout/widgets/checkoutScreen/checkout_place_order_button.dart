import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/helpers.dart';

class CheckoutPlaceOrderButton extends StatelessWidget {
  final bool isSubmitting;
  final double grandTotal;
  final VoidCallback onPressed;

  const CheckoutPlaceOrderButton({
    super.key,
    required this.isSubmitting,
    required this.grandTotal,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isSubmitting ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.textPrimary,
          disabledBackgroundColor:
              AppColors.textPrimary.withValues(alpha: 0.50),
          foregroundColor: Colors.white,
          disabledForegroundColor:
              Colors.white.withValues(alpha: 0.80),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
        ),
        child: isSubmitting
            ? const SizedBox(
                width: 21,
                height: 21,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    size: 17,
                  ),

                  const SizedBox(width: 8),

                  Flexible(
                    child: Text(
                      'Place Order  •  '
                      '${AppHelpers.formatCurrency(grandTotal)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                  ),
                ],
              ),
      ),
    );
  }
}