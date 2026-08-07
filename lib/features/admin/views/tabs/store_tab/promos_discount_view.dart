import 'package:flutter/material.dart';
import 'package:the_legit_smoothie/core/constants/app_colors.dart';

class PromosDiscountView extends StatelessWidget {
  final List<Map<String, dynamic>> promos;
  final Color primaryAccent;
  final bool isDarkMode;

  const PromosDiscountView({
    super.key,
    required this.promos,
    required this.primaryAccent,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardBg = theme.cardColor.withOpacity(isDarkMode ? 0.65 : 0.85);

    return Column(
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: promos.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final promo = promos[index];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(promo['code'], style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary)),
                      Text(promo['discount'], style: TextStyle(fontWeight: FontWeight.w900, color: primaryAccent)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(promo['description']),
                  Text(promo['expiry'], style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}