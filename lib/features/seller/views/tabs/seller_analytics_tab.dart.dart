import 'package:flutter/material.dart';
import 'package:the_legit_smoothie/core/constants/app_colors.dart';

class SellerAnalyticsTab extends StatelessWidget {
  const SellerAnalyticsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardColor = isDark ? AppColors.darkText : AppColors.cardWhite;
    final primaryTextColor = isDark ? AppColors.cream : AppColors.darkText;
    final secondaryTextColor = isDark
        ? AppColors.cream.withOpacity(0.7)
        : AppColors.greyText;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Header Section ---
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.cream.withOpacity(0.15)
                        : AppColors.bobaBrown.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.analytics_rounded,
                    color: isDark ? AppColors.cream : AppColors.bobaBrown,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Store Analytics',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: primaryTextColor,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      'Track sales performance & top drinks',
                      style: TextStyle(
                        fontSize: 13,
                        color: secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // --- Key Metrics Grid (Row 1) ---
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    title: 'Total Revenue',
                    value: '₱12,450',
                    subtitle: '+12.5% this week',
                    icon: Icons.payments_rounded,
                    iconColor: Colors.green,
                    cardColor: cardColor,
                    primaryTextColor: primaryTextColor,
                    secondaryTextColor: secondaryTextColor,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    title: 'Orders Sold',
                    value: '184',
                    subtitle: '+8 orders today',
                    icon: Icons.local_drink_rounded,
                    iconColor: AppColors.bobaBrown,
                    cardColor: cardColor,
                    primaryTextColor: primaryTextColor,
                    secondaryTextColor: secondaryTextColor,
                    isDark: isDark,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // --- Key Metrics Grid (Row 2 Added Content) ---
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    title: 'Average Order',
                    value: '₱185',
                    subtitle: 'Per transaction',
                    icon: Icons.receipt_long_rounded,
                    iconColor: Colors.blueAccent,
                    cardColor: cardColor,
                    primaryTextColor: primaryTextColor,
                    secondaryTextColor: secondaryTextColor,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    title: 'Store Rating',
                    value: '4.8 ⭐',
                    subtitle: 'From 96 reviews',
                    icon: Icons.star_rounded,
                    iconColor: Colors.amber,
                    cardColor: cardColor,
                    primaryTextColor: primaryTextColor,
                    secondaryTextColor: secondaryTextColor,
                    isDark: isDark,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // --- Weekly Sales Overview Chart Mockup (Added Content) ---
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 12),
              child: Text(
                'WEEKLY PERFORMANCE OVERVIEW',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.cream.withOpacity(0.6)
                      : AppColors.bobaBrown,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? AppColors.bobaBrown.withOpacity(0.4)
                      : AppColors.greyBorder,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Peak Hours: 2:00 PM - 5:00 PM',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: primaryTextColor,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.cream.withOpacity(0.15)
                              : AppColors.bobaBrown.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Active Status',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.cream : AppColors.bobaBrown,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildChartBar(day: 'Mon', heightFraction: 0.4, isDark: isDark),
                      _buildChartBar(day: 'Tue', heightFraction: 0.6, isDark: isDark),
                      _buildChartBar(day: 'Wed', heightFraction: 0.5, isDark: isDark),
                      _buildChartBar(day: 'Thu', heightFraction: 0.75, isDark: isDark),
                      _buildChartBar(day: 'Fri', heightFraction: 0.9, isDark: isDark, isHighlight: true),
                      _buildChartBar(day: 'Sat', heightFraction: 1.0, isDark: isDark, isHighlight: true),
                      _buildChartBar(day: 'Sun', heightFraction: 0.65, isDark: isDark),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // --- Top Selling Smoothies Section ---
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 12),
              child: Text(
                'TOP SELLING DRINKS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.cream.withOpacity(0.6)
                      : AppColors.bobaBrown,
                  letterSpacing: 1.2,
                ),
              ),
            ),

            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? AppColors.bobaBrown.withOpacity(0.4)
                      : AppColors.greyBorder,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildDrinkStatRow(
                    name: 'Classic Pearl Boba',
                    orders: '64 orders',
                    revenue: '₱4,480',
                    isDark: isDark,
                    primaryTextColor: primaryTextColor,
                    secondaryTextColor: secondaryTextColor,
                  ),
                  Divider(
                    height: 1,
                    color: isDark
                        ? AppColors.bobaBrown.withOpacity(0.3)
                        : AppColors.greyBorder,
                  ),
                  _buildDrinkStatRow(
                    name: 'Taro Smoothie Supreme',
                    orders: '42 orders',
                    revenue: '₱3,360',
                    isDark: isDark,
                    primaryTextColor: primaryTextColor,
                    secondaryTextColor: secondaryTextColor,
                  ),
                  Divider(
                    height: 1,
                    color: isDark
                        ? AppColors.bobaBrown.withOpacity(0.3)
                        : AppColors.greyBorder,
                  ),
                  _buildDrinkStatRow(
                    name: 'Mango Graham Special',
                    orders: '38 orders',
                    revenue: '₱3,040',
                    isDark: isDark,
                    primaryTextColor: primaryTextColor,
                    secondaryTextColor: secondaryTextColor,
                  ),
                  Divider(
                    height: 1,
                    color: isDark
                        ? AppColors.bobaBrown.withOpacity(0.3)
                        : AppColors.greyBorder,
                  ),
                  _buildDrinkStatRow(
                    name: 'Matcha Green Tea Frost',
                    orders: '28 orders',
                    revenue: '₱2,520',
                    isDark: isDark,
                    primaryTextColor: primaryTextColor,
                    secondaryTextColor: secondaryTextColor,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // --- Customer Insights Summary (Added Content) ---
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 12),
              child: Text(
                'CUSTOMER INSIGHTS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.cream.withOpacity(0.6)
                      : AppColors.bobaBrown,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? AppColors.bobaBrown.withOpacity(0.4)
                      : AppColors.greyBorder,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.cream.withOpacity(0.1)
                          : AppColors.bobaBrown.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.trending_up_rounded,
                      color: isDark ? AppColors.cream : AppColors.bobaBrown,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'High Repeat Customer Rate',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: primaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '78% of your customers ordered more than once this month.',
                          style: TextStyle(
                            fontSize: 12,
                            color: secondaryTextColor,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color cardColor,
    required Color primaryTextColor,
    required Color secondaryTextColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppColors.bobaBrown.withOpacity(0.4)
              : AppColors.greyBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: secondaryTextColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Icon(icon, size: 20, color: iconColor),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: primaryTextColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.cream.withOpacity(0.8) : AppColors.bobaBrown,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartBar({
    required String day,
    required double heightFraction,
    required bool isDark,
    bool isHighlight = false,
  }) {
    final barColor = isHighlight
        ? (isDark ? AppColors.cream : AppColors.bobaBrown)
        : (isDark ? AppColors.bobaBrown.withOpacity(0.6) : Colors.grey.shade300);

    return Column(
      children: [
        Container(
          width: 16,
          height: 100,
          alignment: Alignment.bottomCenter,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkText.withOpacity(0.4) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: FractionallySizedBox(
            heightFactor: heightFraction,
            child: Container(
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          day,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.cream.withOpacity(0.7) : AppColors.greyText,
          ),
        ),
      ],
    );
  }

  Widget _buildDrinkStatRow({
    required String name,
    required String orders,
    required String revenue,
    required bool isDark,
    required Color primaryTextColor,
    required Color secondaryTextColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: primaryTextColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  orders,
                  style: TextStyle(
                    fontSize: 12,
                    color: secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
          Text(
            revenue,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.cream : AppColors.bobaBrown,
            ),
          ),
        ],
      ),
    );
  }
}