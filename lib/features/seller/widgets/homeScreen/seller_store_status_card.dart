import 'package:flutter/material.dart';
import 'package:the_legit_smoothie/core/constants/app_colors.dart';

class SellerStoreStatusCard extends StatelessWidget {
  final bool isOpen;
  final bool isUpdating;
  final VoidCallback onTap;

  const SellerStoreStatusCard({
    super.key,
    required this.isOpen,
    required this.isUpdating,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color statusColor = isOpen
        ? AppColors.success
        : AppColors.textSecondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isUpdating ? null : onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: AppColors.border.withValues(
                alpha: 0.38,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: 0.025,
                ),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              // ===================================================
              // STORE ICON
              // ===================================================

              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isOpen
                      ? AppColors.success.withValues(
                          alpha: 0.08,
                        )
                      : AppColors.background,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: isOpen
                        ? AppColors.success.withValues(
                            alpha: 0.10,
                          )
                        : AppColors.border.withValues(
                            alpha: 0.22,
                          ),
                  ),
                ),
                child: Icon(
                  isOpen
                      ? Icons.storefront_rounded
                      : Icons.storefront_outlined,
                  size: 22,
                  color: isOpen
                      ? AppColors.success
                      : AppColors.textSecondary,
                ),
              ),

              const SizedBox(width: 13),

              // ===================================================
              // INFORMATION
              // ===================================================

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'STORE STATUS',
                          style: TextStyle(
                            fontSize: 7.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                            color: AppColors.textSecondary
                                .withValues(
                              alpha: 0.55,
                            ),
                          ),
                        ),

                        const SizedBox(width: 7),

                        Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 5),

                    Text(
                      isOpen
                          ? 'Store is open'
                          : 'Store is closed',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.25,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      isOpen
                          ? 'Customers can place new orders.'
                          : 'New customer orders are paused.',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary
                            .withValues(
                          alpha: 0.70,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // ===================================================
              // STATUS CONTROL
              // ===================================================

              if (isUpdating)
                const SizedBox(
                  width: 34,
                  height: 34,
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.textPrimary,
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.fromLTRB(
                    10,
                    7,
                    8,
                    7,
                  ),
                  decoration: BoxDecoration(
                    color: isOpen
                        ? AppColors.success.withValues(
                            alpha: 0.08,
                          )
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: isOpen
                          ? AppColors.success.withValues(
                              alpha: 0.12,
                            )
                          : AppColors.border.withValues(
                              alpha: 0.25,
                            ),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),

                      const SizedBox(width: 5),

                      Text(
                        isOpen ? 'OPEN' : 'CLOSED',
                        style: TextStyle(
                          fontSize: 7.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.6,
                          color: isOpen
                              ? AppColors.success
                              : AppColors.textSecondary,
                        ),
                      ),

                      const SizedBox(width: 5),

                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 14,
                        color: isOpen
                            ? AppColors.success
                            : AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}