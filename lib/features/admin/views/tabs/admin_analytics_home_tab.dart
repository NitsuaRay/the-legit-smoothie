import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:the_legit_smoothie/core/constants/app_colors.dart';

class AdminAnalyticsHomeTab extends StatelessWidget {
  const AdminAnalyticsHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent, // Transparent background to show dashboard image
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header Section
              _buildHeader(context, isDarkMode),

              const SizedBox(height: 12),

              // 2. Filter & Actions Row (Moved below the header)
              _buildFilterRow(context, isDarkMode),

              const SizedBox(height: 16),

              // 3. Primary Metrics Cards Row (Revenue, Orders, Active Users)
              _buildMetricsRow(context, isDarkMode),

              const SizedBox(height: 16),

              // 4. Secondary Compact Metrics Row (Conversion & Bounce Rate)
              _buildSecondaryMetricsRow(context, isDarkMode),

              const SizedBox(height: 16),

              // 5. Redesigned Modern Active Sessions Line Chart
              _buildActiveSessionsChart(context, isDarkMode),

              const SizedBox(height: 16),

              // 6. Realtime Users Online Banner
              _buildRealtimeUsersCard(context, isDarkMode),

              const SizedBox(height: 16),

              // 7. Top Products List
              _buildTopProductsCard(context, isDarkMode),
            ],
          ),
        ),
      ),
    );
  }

  // --- Header ---
  Widget _buildHeader(BuildContext context, bool isDarkMode) {
    final theme = Theme.of(context);
    final subTextColor = theme.textTheme.bodyMedium?.color?.withOpacity(0.6) ?? AppColors.greyText;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (isDarkMode ? AppColors.cream : AppColors.bobaBrown).withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.analytics_rounded,
            color: isDarkMode ? AppColors.cream : AppColors.bobaBrown,
            size: 20,
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Admin Analytics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? AppColors.cream : AppColors.bobaBrown,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Monitor store performance and metrics',
              style: TextStyle(
                fontSize: 11,
                color: subTextColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- Filter Row (Moved below the header) ---
  Widget _buildFilterRow(BuildContext context, bool isDarkMode) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? AppColors.darkText;
    final cardBg = theme.cardColor.withOpacity(isDarkMode ? 0.6 : 0.8);
    final borderColor = theme.dividerColor.withOpacity(0.5);

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 14, color: isDarkMode ? AppColors.cream : AppColors.bobaBrown),
                    const SizedBox(width: 8),
                    Text(
                      'Last 7 Days',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Icon(Icons.keyboard_arrow_down, color: textColor, size: 16),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.tune_rounded,
            color: isDarkMode ? AppColors.cream : AppColors.bobaBrown,
            size: 18,
          ),
        ),
      ],
    );
  }

  // --- Metrics KPI Row ---
  Widget _buildMetricsRow(BuildContext context, bool isDarkMode) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            context,
            isDarkMode: isDarkMode,
            title: 'Revenue',
            value: '₱25,890',
            percentage: '+16.7%',
            isPositive: true,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricCard(
            context,
            isDarkMode: isDarkMode,
            title: 'Orders',
            value: '3,150',
            percentage: '+9.3%',
            isPositive: true,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricCard(
            context,
            isDarkMode: isDarkMode,
            title: 'Active Users',
            value: '9,400',
            percentage: '-5.4%',
            isPositive: false,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required bool isDarkMode,
    required String title,
    required String value,
    required String percentage,
    required bool isPositive,
  }) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? AppColors.darkText;
    final subTextColor = theme.textTheme.bodyMedium?.color?.withOpacity(0.7) ?? AppColors.greyText;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor.withOpacity(isDarkMode ? 0.65 : 0.85),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.25 : 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: subTextColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                isPositive ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                color: isPositive ? AppColors.success : AppColors.error,
                size: 16,
              ),
              Text(
                percentage,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isPositive ? AppColors.success : AppColors.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Secondary Metrics Row ---
  Widget _buildSecondaryMetricsRow(BuildContext context, bool isDarkMode) {
    return Row(
      children: [
        Expanded(
          child: _buildMiniStatCard(
            context,
            isDarkMode: isDarkMode,
            label: 'Conversion Rate',
            stat: '3.42%',
            trend: '+0.8%',
            icon: Icons.trending_up,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMiniStatCard(
            context,
            isDarkMode: isDarkMode,
            label: 'Avg. Order Value',
            stat: '₱420',
            trend: '+₱15',
            icon: Icons.shopping_bag_outlined,
          ),
        ),
      ],
    );
  }

  Widget _buildMiniStatCard(
    BuildContext context, {
    required bool isDarkMode,
    required String label,
    required String stat,
    required String trend,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? AppColors.darkText;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.cardColor.withOpacity(isDarkMode ? 0.65 : 0.85),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.secondary, size: 16),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 10, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6)),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Text(
                    stat,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textColor),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '($trend)',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.success),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Active Sessions Line Chart ---
  Widget _buildActiveSessionsChart(BuildContext context, bool isDarkMode) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? AppColors.darkText;
    final subTextColor = theme.textTheme.bodyMedium?.color?.withOpacity(0.6) ?? AppColors.greyText;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor.withOpacity(isDarkMode ? 0.65 : 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.25 : 0.03),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Active Sessions',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Daily user engagement trend',
                    style: TextStyle(fontSize: 10, color: subTextColor),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Live Data',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.secondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: theme.dividerColor.withOpacity(0.2),
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        String text = '';
                        switch (value.toInt()) {
                          case 2:
                            text = '2k';
                            break;
                          case 4:
                            text = '4k';
                            break;
                          case 6:
                            text = '6k';
                            break;
                          case 8:
                            text = '8k';
                            break;
                        }
                        if (text.isEmpty) return const SizedBox.shrink();
                        return Text(
                          text,
                          style: TextStyle(color: subTextColor, fontSize: 10),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                        if (value.toInt() < 1 || value.toInt() > 7) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            days[value.toInt()],
                            style: TextStyle(color: subTextColor, fontSize: 10, fontWeight: FontWeight.w500),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minX: 1,
                maxX: 7,
                minY: 0,
                maxY: 10,
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(1, 3.2),
                      FlSpot(2, 5.8),
                      FlSpot(3, 4.2),
                      FlSpot(4, 7.5),
                      FlSpot(5, 6.1),
                      FlSpot(6, 8.4),
                      FlSpot(7, 9.1),
                    ],
                    isCurved: true,
                    color: AppColors.secondary,
                    barWidth: 3.5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                        radius: 4,
                        color: theme.cardColor,
                        strokeWidth: 2.5,
                        strokeColor: AppColors.secondary,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.secondary.withOpacity(0.35),
                          AppColors.secondary.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Realtime Users Card ---
  Widget _buildRealtimeUsersCard(BuildContext context, bool isDarkMode) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? AppColors.darkText;
    final subTextColor = theme.textTheme.bodyMedium?.color?.withOpacity(0.6) ?? AppColors.greyText;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: theme.cardColor.withOpacity(isDarkMode ? 0.65 : 0.85),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.25 : 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
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
                'Realtime Users Online',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: subTextColor,
                ),
              ),
              Row(
                children: [
                  const CircleAvatar(radius: 3, backgroundColor: AppColors.success),
                  const SizedBox(width: 6),
                  Text(
                    'Live',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.success),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '498',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  // --- Top Products List ---
  Widget _buildTopProductsCard(BuildContext context, bool isDarkMode) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? AppColors.darkText;

    final topProducts = [
      {'rank': '1', 'name': 'Mango Smoothie', 'sales': '1.5k orders', 'icon': '🥭'},
      {'rank': '2', 'name': 'Brown Sugar Milk Tea', 'sales': '1.2k orders', 'icon': '🧋'},
      {'rank': '3', 'name': 'Special Siomai Roll', 'sales': '980 orders', 'icon': '🥟'},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor.withOpacity(isDarkMode ? 0.65 : 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.25 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top Products',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),
          Column(
            children: topProducts.map((product) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      alignment: Alignment.center,
                      child: Text(
                        product['rank']!,
                        style: const TextStyle(
                          color: AppColors.secondary,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? Colors.white.withOpacity(0.08)
                            : AppColors.cream.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        product['icon']!,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        product['name']!,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      product['sales']!,
                      style: TextStyle(
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}