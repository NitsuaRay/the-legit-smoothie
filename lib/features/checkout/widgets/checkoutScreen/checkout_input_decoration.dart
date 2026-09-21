import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

InputDecoration buildCheckoutInputDecoration({
  required String label,
  required String hint,
  required IconData icon,
  Widget? suffixIcon,
}) {
  final borderRadius = BorderRadius.circular(15);

  return InputDecoration(
    labelText: label,
    hintText: hint,

    labelStyle: TextStyle(
      fontSize: 10.5,
      fontWeight: FontWeight.w600,
      color: AppColors.textSecondary.withValues(alpha: 0.76),
    ),

    floatingLabelStyle: const TextStyle(
      fontSize: 10.5,
      fontWeight: FontWeight.w800,
      color: AppColors.textPrimary,
    ),

    hintStyle: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: AppColors.textSecondary.withValues(alpha: 0.43),
    ),

    prefixIcon: Padding(
      padding: const EdgeInsets.only(
        left: 9,
        right: 8,
      ),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color: AppColors.border.withValues(alpha: 0.26),
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: AppColors.textPrimary,
        ),
      ),
    ),

    prefixIconConstraints: const BoxConstraints(
      minWidth: 57,
      minHeight: 54,
    ),

    suffixIcon: suffixIcon,

    filled: true,
    fillColor: AppColors.background.withValues(alpha: 0.72),

    contentPadding: const EdgeInsets.symmetric(
      horizontal: 14,
      vertical: 17,
    ),

    border: OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(
        color: AppColors.border.withValues(alpha: 0.35),
      ),
    ),

    enabledBorder: OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(
        color: AppColors.border.withValues(alpha: 0.35),
      ),
    ),

    focusedBorder: OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: const BorderSide(
        color: AppColors.textPrimary,
        width: 1.3,
      ),
    ),

    errorBorder: OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: const BorderSide(
        color: AppColors.error,
      ),
    ),

    focusedErrorBorder: OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: const BorderSide(
        color: AppColors.error,
        width: 1.3,
      ),
    ),

    errorStyle: const TextStyle(
      fontSize: 9.5,
      fontWeight: FontWeight.w600,
      color: AppColors.error,
    ),
  );
}