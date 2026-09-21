import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import 'promo_section_card.dart';

class PromoStatusSection extends StatelessWidget {
  final bool isActive;
  final ValueChanged<bool> onChanged;

  const PromoStatusSection({
    super.key,
    required this.isActive,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PromoSectionCard(
      eyebrow: 'Visibility',
      title: 'Promotion status',
      child: SwitchListTile.adaptive(
        contentPadding: EdgeInsets.zero,
        value: isActive,
        activeThumbColor: AppColors.textPrimary,
        title: Text(
          isActive ? 'Enabled' : 'Disabled',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
        subtitle: Text(
          isActive
              ? 'Customers can receive this promotion during its scheduled period.'
              : 'The promotion will be saved but cannot be used.',
          style: const TextStyle(
            fontSize: 9.5,
            height: 1.4,
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}