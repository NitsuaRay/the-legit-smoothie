import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class CheckoutDivider extends StatelessWidget {
  final double verticalPadding;

  const CheckoutDivider({
    super.key,
    this.verticalPadding = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: verticalPadding,
      ),
      child: Container(
        height: 1,
        color: AppColors.border.withValues(
          alpha: 0.24,
        ),
      ),
    );
  }
}