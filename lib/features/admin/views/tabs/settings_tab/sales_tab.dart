import 'package:flutter/material.dart';
import 'package:the_legit_smoothie/core/constants/app_colors.dart';

class AdminSalesView extends StatefulWidget {
  final VoidCallback? onBack;

  const AdminSalesView({super.key, this.onBack});

  @override
  State<AdminSalesView> createState() => _AdminSalesViewState();
}

class _AdminSalesViewState extends State<AdminSalesView> {
  String _selectedFilter = 'This Week';

  // Comprehensive mock datasets mapped to different filters
  final Map<String, Map<String, dynamic>> _salesData = {
    'Today': {
      'revenue': '₱4,250.00',
      'revenueChange': '+15.2%',
      'isRevenuePositive': true,
      'orders': '28',
      'ordersChange': '+5.4%',
      'isOrdersPositive': true,
      'avgOrderValue': '₱151.78',
      'topProducts': [
        {
          'name': 'Hokkaido Special Milk Tea',
          'sales': '9 sold',
          'revenue': '₱1,080.00',
        },
        {
          'name': 'Dark Choco Smoothie',
          'sales': '7 sold',
          'revenue': '₱980.00',
        },
        {
          'name': 'Taro Milk Tea w/ Cheese Foam',
          'sales': '6 sold',
          'revenue': '₱900.00',
        },
      ],
      'categoryBreakdown': {'Milk Tea': 60, 'Smoothies': 30, 'Add-ons': 10},
    },
    'This Week': {
      'revenue': '₱24,850.00',
      'revenueChange': '+12.4%',
      'isRevenuePositive': true,
      'orders': '142',
      'ordersChange': '+8.1%',
      'isOrdersPositive': true,
      'avgOrderValue': '₱175.00',
      'topProducts': [
        {
          'name': 'Hokkaido Special Milk Tea',
          'sales': '48 sold',
          'revenue': '₱5,760.00',
        },
        {
          'name': 'Dark Choco Smoothie',
          'sales': '36 sold',
          'revenue': '₱5,040.00',
        },
        {
          'name': 'Taro Milk Tea w/ Cheese Foam',
          'sales': '29 sold',
          'revenue': '₱4,350.00',
        },
      ],
      'categoryBreakdown': {'Milk Tea': 55, 'Smoothies': 35, 'Add-ons': 10},
    },
    'This Month': {
      'revenue': '₱98,400.00',
      'revenueChange': '+18.9%',
      'isRevenuePositive': true,
      'orders': '580',
      'ordersChange': '+14.3%',
      'isOrdersPositive': true,
      'avgOrderValue': '₱169.65',
      'topProducts': [
        {
          'name': 'Hokkaido Special Milk Tea',
          'sales': '190 sold',
          'revenue': '₱22,800.00',
        },
        {
          'name': 'Taro Milk Tea w/ Cheese Foam',
          'sales': '145 sold',
          'revenue': '₱21,750.00',
        },
        {
          'name': 'Dark Choco Smoothie',
          'sales': '130 sold',
          'revenue': '₱18,200.00',
        },
      ],
      'categoryBreakdown': {'Milk Tea': 50, 'Smoothies': 40, 'Add-ons': 10},
    },
    'This Year': {
      'revenue': '₱1,185,000.00',
      'revenueChange': '+24.5%',
      'isRevenuePositive': true,
      'orders': '6,950',
      'ordersChange': '+21.0%',
      'isOrdersPositive': true,
      'avgOrderValue': '₱170.50',
      'topProducts': [
        {
          'name': 'Hokkaido Special Milk Tea',
          'sales': '2,300 sold',
          'revenue': '₱276,000.00',
        },
        {
          'name': 'Dark Choco Smoothie',
          'sales': '1,850 sold',
          'revenue': '₱259,000.00',
        },
        {
          'name': 'Taro Milk Tea w/ Cheese Foam',
          'sales': '1,620 sold',
          'revenue': '₱243,000.00',
        },
      ],
      'categoryBreakdown': {'Milk Tea': 52, 'Smoothies': 38, 'Add-ons': 10},
    },
  };

  void _exportReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Sales report for $_selectedFilter exported successfully (PDF/CSV).',
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.secondary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardColor = isDark ? AppColors.darkText : AppColors.cardWhite;
    final primaryTextColor = isDark ? AppColors.cream : AppColors.darkText;
    final secondaryTextColor = isDark
        ? AppColors.cream.withValues(alpha: 0.7)
        : AppColors.greyText;

    final currentData = _salesData[_selectedFilter]!;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bobaBrown : AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Header with Back Button & Export Action ---
              Row(
                children: [
                  InkWell(
                    onTap: widget.onBack ?? () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.cream.withValues(alpha: 0.15)
                            : AppColors.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: isDark ? AppColors.cream : AppColors.secondary,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sales & Analytics',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: primaryTextColor,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          'Monitor revenue reports, trends, and sales summaries',
                          style: TextStyle(
                            fontSize: 13,
                            color: secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _exportReport,
                    tooltip: 'Export Report',
                    icon: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.cream.withValues(alpha: 0.15)
                            : AppColors.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.download_rounded,
                        color: isDark ? AppColors.cream : AppColors.secondary,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // --- Filter Chips ---
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['Today', 'This Week', 'This Month', 'This Year']
                      .map((filter) {
                        final isSelected = _selectedFilter == filter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(filter),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _selectedFilter = filter;
                              });
                            },
                            selectedColor: isDark
                                ? AppColors.cream
                                : AppColors.secondary,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? (isDark
                                        ? AppColors.bobaBrown
                                        : AppColors.cardWhite)
                                  : primaryTextColor,
                              fontWeight: FontWeight.w600,
                            ),
                            backgroundColor: cardColor,
                            side: BorderSide(
                              color: isSelected
                                  ? Colors.transparent
                                  : (isDark
                                        ? AppColors.secondary.withValues(
                                            alpha: 0.4,
                                          )
                                        : AppColors.greyBorder),
                            ),
                          ),
                        );
                      })
                      .toList(),
                ),
              ),

              const SizedBox(height: 24),

              // --- Summary Metrics Cards ---
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Total Revenue',
                      value: currentData['revenue'],
                      change: currentData['revenueChange'],
                      isPositive: currentData['isRevenuePositive'],
                      cardColor: cardColor,
                      primaryTextColor: primaryTextColor,
                      secondaryTextColor: secondaryTextColor,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Total Orders',
                      value: currentData['orders'],
                      change: currentData['ordersChange'],
                      isPositive: currentData['isOrdersPositive'],
                      cardColor: cardColor,
                      primaryTextColor: primaryTextColor,
                      secondaryTextColor: secondaryTextColor,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Average Order Value',
                      value: currentData['avgOrderValue'],
                      change: '+3.1%',
                      isPositive: true,
                      cardColor: cardColor,
                      primaryTextColor: primaryTextColor,
                      secondaryTextColor: secondaryTextColor,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Conversion Rate',
                      value: '94.2%',
                      change: '+1.5%',
                      isPositive: true,
                      cardColor: cardColor,
                      primaryTextColor: primaryTextColor,
                      secondaryTextColor: secondaryTextColor,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // --- Visual Revenue Trend Placeholder / Mini Chart ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? AppColors.secondary.withValues(alpha: 0.4)
                        : AppColors.greyBorder,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.2 : 0.04,
                      ),
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
                          'REVENUE PERFORMANCE',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.cream.withValues(alpha: 0.6)
                                : AppColors.secondary,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Icon(
                          Icons.insights_rounded,
                          size: 18,
                          color: secondaryTextColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 100,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildChartBar('Mon', 0.4, isDark),
                          _buildChartBar('Tue', 0.6, isDark),
                          _buildChartBar('Wed', 0.5, isDark),
                          _buildChartBar('Thu', 0.8, isDark),
                          _buildChartBar('Fri', 0.9, isDark),
                          _buildChartBar(
                            'Sat',
                            1.0,
                            isDark,
                            isHighlighted: true,
                          ),
                          _buildChartBar('Sun', 0.7, isDark),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // --- Section Title ---
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 12),
                child: Text(
                  'TOP SELLING PRODUCTS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.cream.withValues(alpha: 0.6)
                        : AppColors.secondary,
                    letterSpacing: 1.2,
                  ),
                ),
              ),

              // --- Top Products List ---
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? AppColors.secondary.withValues(alpha: 0.4)
                        : AppColors.greyBorder,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.2 : 0.04,
                      ),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    for (
                      int i = 0;
                      i < currentData['topProducts'].length;
                      i++
                    ) ...[
                      _buildProductRow(
                        name: currentData['topProducts'][i]['name'],
                        sales: currentData['topProducts'][i]['sales'],
                        revenue: currentData['topProducts'][i]['revenue'],
                        primaryTextColor: primaryTextColor,
                        secondaryTextColor: secondaryTextColor,
                      ),
                      if (i < currentData['topProducts'].length - 1)
                        const Divider(height: 24, color: AppColors.greyBorder),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String change,
    required bool isPositive,
    required Color cardColor,
    required Color primaryTextColor,
    required Color secondaryTextColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppColors.secondary.withValues(alpha: 0.4)
              : AppColors.greyBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: secondaryTextColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryTextColor,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                isPositive
                    ? Icons.trending_up_rounded
                    : Icons.trending_down_rounded,
                size: 16,
                color: AppColors.success,
              ),
              const SizedBox(width: 4),
              Text(
                change,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartBar(
    String day,
    double heightFactor,
    bool isDark, {
    bool isHighlighted = false,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 24,
          height: 70 * heightFactor,
          decoration: BoxDecoration(
            color: isHighlighted
                ? (isDark ? AppColors.cream : AppColors.secondary)
                : (isDark
                      ? AppColors.cream.withValues(alpha: 0.3)
                      : AppColors.secondary.withValues(alpha: 0.2)),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          day,
          style: TextStyle(
            fontSize: 11,
            color: isDark
                ? AppColors.cream.withValues(alpha: 0.7)
                : AppColors.greyText,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildProductRow({
    required String name,
    required String sales,
    required String revenue,
    required Color primaryTextColor,
    required Color secondaryTextColor,
  }) {
    return Row(
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
                sales,
                style: TextStyle(fontSize: 12, color: secondaryTextColor),
              ),
            ],
          ),
        ),
        Text(
          revenue,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: primaryTextColor,
          ),
        ),
      ],
    );
  }
}
