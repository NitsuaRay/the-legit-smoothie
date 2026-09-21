import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class CheckoutSecurityMessage extends StatelessWidget {
  const CheckoutSecurityMessage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.verified_user_outlined,
          size: 12,
          color: AppColors.textSecondary.withValues(
            alpha: 0.48,
          ),
        ),

        const SizedBox(width: 6),

        Text(
          'Your order details are securely submitted',
          style: TextStyle(
            fontSize: 8.5,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary.withValues(
              alpha: 0.52,
            ),
          ),
        ),
      ],
    );
  }
}