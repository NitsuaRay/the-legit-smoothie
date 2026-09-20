import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

// ===================================================================
// CHECKOUT SECTION HEADER
// ===================================================================

class CheckoutSectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData? icon;
  final String? eyebrow;

  const CheckoutSectionHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon,
    this.eyebrow,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // =========================================================
        // OPTIONAL SECTION ICON
        // =========================================================
        if (icon != null) ...[
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: AppColors.border.withValues(
                  alpha: 0.32,
                ),
              ),
            ),
            child: Icon(
              icon,
              size: 18,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(width: 12),
        ],

        // =========================================================
        // TEXT
        // =========================================================
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (eyebrow != null &&
                  eyebrow!.trim().isNotEmpty) ...[
                Text(
                  eyebrow!.toUpperCase(),
                  style: TextStyle(
                    fontSize: 8,
                    height: 1,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.15,
                    color: AppColors.textSecondary.withValues(
                      alpha: 0.50,
                    ),
                  ),
                ),

                const SizedBox(height: 6),
              ],

              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  height: 1.1,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.45,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  height: 1.35,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary.withValues(
                    alpha: 0.70,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ===================================================================
// ORDER TYPE TAB
// ===================================================================

class OrderTypeTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;
  final String groupValue;
  final ValueChanged<String> onTap;

  const OrderTypeTab({
    super.key,
    required this.label,
    required this.icon,
    required this.value,
    required this.groupValue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelected = value == groupValue;

    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onTap(value),
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: const Duration(
              milliseconds: 220,
            ),
            curve: Curves.easeOutCubic,
            height: 54,
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.textPrimary
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: 0.10,
                        ),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(
                    milliseconds: 220,
                  ),
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withValues(
                            alpha: 0.12,
                          )
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(
                    icon,
                    size: 16,
                    color: isSelected
                        ? Colors.white
                        : AppColors.textPrimary,
                  ),
                ),

                const SizedBox(width: 8),

                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.15,
                      color: isSelected
                          ? Colors.white
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ===================================================================
// CHECKOUT INPUT DECORATION
// ===================================================================

InputDecoration buildCheckoutInputDecoration({
  required String label,
  required String hint,
  required IconData icon,
  Widget? suffixIcon,
}) {
  final borderRadius = BorderRadius.circular(15);

  return InputDecoration(
    // =============================================================
    // TEXT
    // =============================================================
    labelText: label,
    hintText: hint,

    labelStyle: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: AppColors.textSecondary.withValues(
        alpha: 0.78,
      ),
    ),

    floatingLabelStyle: const TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w800,
      color: AppColors.textPrimary,
    ),

    hintStyle: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: AppColors.textSecondary.withValues(
        alpha: 0.45,
      ),
    ),

    // =============================================================
    // ICON
    // =============================================================
    prefixIcon: Padding(
      padding: const EdgeInsets.only(
        left: 10,
        right: 8,
      ),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color: AppColors.border.withValues(
              alpha: 0.28,
            ),
          ),
        ),
        child: Icon(
          icon,
          size: 17,
          color: AppColors.textPrimary,
        ),
      ),
    ),

    prefixIconConstraints: const BoxConstraints(
      minWidth: 58,
      minHeight: 54,
    ),

    suffixIcon: suffixIcon,

    // =============================================================
    // SURFACE
    // =============================================================
    filled: true,

    fillColor: AppColors.background.withValues(
      alpha: 0.72,
    ),

    contentPadding: const EdgeInsets.symmetric(
      horizontal: 14,
      vertical: 17,
    ),

    // =============================================================
    // BORDERS
    // =============================================================
    border: OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(
        color: AppColors.border.withValues(
          alpha: 0.38,
        ),
      ),
    ),

    enabledBorder: OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(
        color: AppColors.border.withValues(
          alpha: 0.38,
        ),
      ),
    ),

    focusedBorder: OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: const BorderSide(
        color: AppColors.textPrimary,
        width: 1.4,
      ),
    ),

    errorBorder: OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(
        color: AppColors.error.withValues(
          alpha: 0.70,
        ),
      ),
    ),

    focusedErrorBorder: OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: const BorderSide(
        color: AppColors.error,
        width: 1.4,
      ),
    ),

    // =============================================================
    // ERROR
    // =============================================================
    errorStyle: const TextStyle(
      fontSize: 10,
      height: 1.25,
      fontWeight: FontWeight.w600,
      color: AppColors.error,
    ),
  );
}

// ===================================================================
// SUMMARY ROW
// ===================================================================

class SummaryRowItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  final IconData? icon;
  final String? subtitle;

  const SummaryRowItem({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.icon,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // =========================================================
        // OPTIONAL ICON
        // =========================================================
        if (icon != null) ...[
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              icon,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(width: 11),
        ],

        // =========================================================
        // LABEL
        // =========================================================
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.1,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),

              if (subtitle != null &&
                  subtitle!.trim().isNotEmpty) ...[
                const SizedBox(height: 4),

                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 9,
                    height: 1.25,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary.withValues(
                      alpha: 0.55,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(width: 12),

        // =========================================================
        // VALUE
        // =========================================================
        Text(
          value,
          textAlign: TextAlign.right,
          style: TextStyle(
            fontSize: 13,
            height: 1,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.15,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

// ===================================================================
// PREMIUM CHECKOUT CARD
// ===================================================================

class CheckoutCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const CheckoutCard({
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
          color: Colors.black.withValues(
            alpha: 0.05,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.025,
            ),
            blurRadius: 22,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ===================================================================
// CHECKOUT DIVIDER
// ===================================================================

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

// ===================================================================
// CHECKOUT INFO BADGE
// ===================================================================

class CheckoutInfoBadge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? color;

  const CheckoutInfoBadge({
    super.key,
    required this.label,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor =
        color ?? AppColors.textPrimary;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: effectiveColor.withValues(
          alpha: 0.065,
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: effectiveColor.withValues(
            alpha: 0.10,
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 12,
              color: effectiveColor,
            ),

            const SizedBox(width: 5),
          ],

          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              height: 1,
              fontWeight: FontWeight.w800,
              color: effectiveColor,
            ),
          ),
        ],
      ),
    );
  }
}