import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import 'seller_order_status.dart';

class SellerOrderTimeline extends StatelessWidget {
  final List<Map<String, dynamic>> history;
  final String currentStatus;

  const SellerOrderTimeline({
    super.key,
    required this.history,
    required this.currentStatus,
  });

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return _buildCard(
        child: Row(
          children: [
            const Icon(
              Icons.history_rounded,
              size: 20,
              color: AppColors.textSecondary,
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Text(
                'Current status: ${formatSellerOrderStatus(currentStatus)}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return _buildCard(
      child: Column(
        children: List.generate(
          history.length,
          (index) {
            final Map<String, dynamic> entry =
                history[index];

            final String status =
                entry['status']?.toString() ?? '';

            final DateTime? createdAt =
                DateTime.tryParse(
              entry['created_at']?.toString() ?? '',
            )?.toLocal();

            final bool isLast =
                index == history.length - 1;

            final config =
                sellerOrderStatusConfig(status);

            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // ========================================
                  // TIMELINE INDICATOR
                  // ========================================
                  SizedBox(
                    width: 28,
                    child: Column(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: config.color,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),

                        if (!isLast)
                          Expanded(
                            child: Container(
                              width: 2,
                              margin:
                                  const EdgeInsets.symmetric(
                                vertical: 4,
                              ),
                              color: AppColors.border,
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // ========================================
                  // STATUS
                  // ========================================
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: isLast ? 0 : 18,
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            formatSellerOrderStatus(
                              status,
                            ),
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight:
                                  FontWeight.w800,
                              color:
                                  AppColors.textPrimary,
                            ),
                          ),

                          if (createdAt != null) ...[
                            const SizedBox(height: 3),

                            Text(
                              DateFormat(
                                'MMM d • h:mm a',
                              ).format(createdAt),
                              style: const TextStyle(
                                fontSize: 8.5,
                                color: AppColors
                                    .textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCard({
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: AppColors.border.withValues(
            alpha: 0.40,
          ),
        ),
      ),
      child: child,
    );
  }
}