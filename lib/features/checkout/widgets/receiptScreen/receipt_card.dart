import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class ReceiptCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const ReceiptCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
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
          color: AppColors.border.withValues(alpha: 0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 20,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: child,
    );
  }
}

class ReceiptDivider extends StatelessWidget {
  final double verticalPadding;

  const ReceiptDivider({
    super.key,
    this.verticalPadding = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      child: Container(
        height: 1,
        color: AppColors.border.withValues(alpha: 0.20),
      ),
    );
  }
}