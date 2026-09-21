import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';

class PromotionDetailValidity
    extends StatelessWidget {
  final Map<String, dynamic> promotion;

  const PromotionDetailValidity({
    super.key,
    required this.promotion,
  });

  DateTime? _parse(dynamic value) {
    return DateTime.tryParse(
      value?.toString() ?? '',
    )?.toLocal();
  }

  String _format(DateTime? date) {
    if (date == null) {
      return 'No set date';
    }

    return DateFormat(
      'MMM d, yyyy • h:mm a',
    ).format(date);
  }

  @override
  Widget build(BuildContext context) {
    final DateTime? startsAt =
        _parse(promotion['starts_at']);

    final DateTime? validUntil =
        _parse(promotion['valid_until']);

    final DateTime now = DateTime.now();

    final bool upcoming =
        startsAt != null &&
            now.isBefore(startsAt);

    final bool expired =
        validUntil != null &&
            now.isAfter(validUntil);

    final String status = expired
        ? 'Expired'
        : upcoming
            ? 'Upcoming'
            : 'Active';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(
          color: AppColors.border.withValues(
            alpha: 0.30,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'PROMOTION PERIOD',
            style: TextStyle(
              fontSize: 7,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 6),

          Row(
            children: [
              const Expanded(
                child: Text(
                  'Availability',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight:
                        FontWeight.w900,
                    letterSpacing: -0.4,
                    color:
                        AppColors.textPrimary,
                  ),
                ),
              ),

              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius:
                      BorderRadius.circular(30),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 7,
                    fontWeight:
                        FontWeight.w900,
                    letterSpacing: 0.7,
                    color:
                        AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          _DateRow(
            icon: Icons.play_circle_outline_rounded,
            label: 'Starts',
            value: _format(startsAt),
          ),

          const SizedBox(height: 13),

          _DateRow(
            icon: Icons.event_busy_outlined,
            label: 'Valid until',
            value: _format(validUntil),
          ),
        ],
      ),
    );
  }
}

class _DateRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DateRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius:
                BorderRadius.circular(11),
          ),
          child: Icon(
            icon,
            size: 17,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                  color:
                      AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                value,
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color:
                      AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}