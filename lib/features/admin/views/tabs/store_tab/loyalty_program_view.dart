import 'package:flutter/material.dart';

class LoyaltyProgramView extends StatelessWidget {
  final bool loyaltyEnabled;
  final double pointsPerPeso;
  final ValueChanged<bool> onLoyaltyToggle;
  final ValueChanged<double> onPointsChanged;
  final Color primaryAccent;
  final bool isDarkMode;

  const LoyaltyProgramView({
    super.key,
    required this.loyaltyEnabled,
    required this.pointsPerPeso,
    required this.onLoyaltyToggle,
    required this.onPointsChanged,
    required this.primaryAccent,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardBg = theme.cardColor.withOpacity(isDarkMode ? 0.65 : 0.85);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Customer Loyalty', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryAccent)),
              Switch.adaptive(
                value: loyaltyEnabled,
                activeColor: primaryAccent,
                onChanged: onLoyaltyToggle,
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Points earned per ₱100 spent'),
              Text('${(pointsPerPeso * 10).toInt()} Points', style: TextStyle(fontWeight: FontWeight.bold, color: primaryAccent)),
            ],
          ),
          Slider(
            value: pointsPerPeso,
            min: 0.5,
            max: 5.0,
            divisions: 9,
            activeColor: primaryAccent,
            onChanged: loyaltyEnabled ? onPointsChanged : null,
          ),
        ],
      ),
    );
  }
}