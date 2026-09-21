import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import 'receipt_card.dart';
import 'receipt_order_item.dart';

class ReceiptItemsCard extends StatelessWidget {
  final List<Map<String, dynamic>> items;

  const ReceiptItemsCard({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return ReceiptCard(
      padding: EdgeInsets.zero,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, __) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            height: 1,
            color: AppColors.border.withValues(alpha: 0.20),
          ),
        ),
        itemBuilder: (_, index) {
          return ReceiptOrderItem(
            item: items[index],
          );
        },
      ),
    );
  }
}