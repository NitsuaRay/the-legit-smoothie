import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import 'promo_section_card.dart';

class PromoScheduleSection extends StatelessWidget {
  final DateTime startsAt;
  final DateTime validUntil;
  final VoidCallback onStartTap;
  final VoidCallback onEndTap;

  const PromoScheduleSection({
    super.key,
    required this.startsAt,
    required this.validUntil,
    required this.onStartTap,
    required this.onEndTap,
  });

  @override
  Widget build(BuildContext context) {
    final format = DateFormat('MMM d, yyyy • h:mm a');

    return PromoSectionCard(
      eyebrow: 'Schedule',
      title: 'Promotion period',
      child: Column(
        children: [
          _DateTile(
            label: 'Starts',
            value: format.format(startsAt),
            onTap: onStartTap,
          ),
          const SizedBox(height: 10),
          _DateTile(
            label: 'Ends',
            value: format.format(validUntil),
            onTap: onEndTap,
          ),
        ],
      ),
    );
  }
}

class _DateTile extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _DateTile({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 18,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: TextStyle(
                      fontSize: 7.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                      color: AppColors.textPrimary
                          .withValues(alpha: 0.45),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
            ),
          ],
        ),
      ),
    );
  }
}