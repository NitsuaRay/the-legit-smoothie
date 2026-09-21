import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class CheckoutCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const CheckoutCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(17),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 22,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: child,
    );
  }
}