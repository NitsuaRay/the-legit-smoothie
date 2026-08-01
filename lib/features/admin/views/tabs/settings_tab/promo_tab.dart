import 'package:flutter/material.dart';
import 'package:the_legit_smoothie/core/constants/app_colors.dart';

class AdminPromosView extends StatefulWidget {
  final VoidCallback? onBack;

  const AdminPromosView({
    super.key,
    this.onBack,
  });

  @override
  State<AdminPromosView> createState() => _AdminPromosViewState();
}

class _AdminPromosViewState extends State<AdminPromosView> {
  String _selectedTab = 'All';

  // Expanded mock promos with usage statistics
  final List<Map<String, dynamic>> _promos = [
    {
      'code': 'BOBA15OFF',
      'discount': '15% OFF',
      'description': 'Valid on all special milk tea series',
      'validUntil': 'Aug 31, 2026',
      'isActive': true,
      'usage': 142,
      'limit': 500,
    },
    {
      'code': 'SUMMERSIP',
      'discount': '₱50 OFF',
      'description': 'Minimum spend of ₱300 required',
      'validUntil': 'Aug 15, 2026',
      'isActive': true,
      'usage': 89,
      'limit': 100,
    },
    {
      'code': 'FREETOPEARL',
      'discount': 'Free Toppings',
      'description': 'Complimentary pearls or cheese foam',
      'validUntil': 'Jul 01, 2026',
      'isActive': false,
      'usage': 350,
      'limit': 350,
    },
    {
      'code': 'NEWPANDA',
      'discount': '20% OFF',
      'description': 'First-time app users only',
      'validUntil': 'Dec 31, 2026',
      'isActive': true,
      'usage': 12,
      'limit': 1000,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardColor = isDark ? AppColors.darkText : AppColors.cardWhite;
    final primaryTextColor = isDark ? AppColors.cream : AppColors.darkText;
    final secondaryTextColor = isDark
        ? AppColors.cream.withValues(alpha: 0.7)
        : AppColors.greyText;

    // Filter promos based on tab
    final filteredPromos = _promos.where((promo) {
      if (_selectedTab == 'Active') return promo['isActive'] == true;
      if (_selectedTab == 'Expired') return promo['isActive'] == false;
      return true; // 'All'
    }).toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.bobaBrown : AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Header with Back Button & Add Button ---
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
                          'Promos & Discounts',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: primaryTextColor,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          'Manage voucher campaigns and codes',
                          style: TextStyle(
                            fontSize: 13,
                            color: secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // Handle create new promo action
                    },
                    icon: Icon(
                      Icons.add_circle_outline_rounded,
                      color: isDark ? AppColors.cream : AppColors.secondary,
                      size: 28,
                    ),
                    tooltip: 'Add Promo',
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // --- Quick Stats Section ---
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: 'Active Campaigns',
                      value: '3',
                      icon: Icons.campaign_rounded,
                      iconColor: AppColors.warning,
                      cardColor: cardColor,
                      primaryTextColor: primaryTextColor,
                      secondaryTextColor: secondaryTextColor,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      title: 'Total Redemptions',
                      value: '593',
                      icon: Icons.confirmation_number_rounded,
                      iconColor: AppColors.success,
                      cardColor: cardColor,
                      primaryTextColor: primaryTextColor,
                      secondaryTextColor: secondaryTextColor,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // --- Tab Filters ---
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['All', 'Active', 'Expired'].map((tab) {
                    final isSelected = _selectedTab == tab;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(tab),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedTab = tab;
                          });
                        },
                        selectedColor:
                            isDark ? AppColors.cream : AppColors.secondary,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? (isDark ? AppColors.bobaBrown : AppColors.cardWhite)
                              : primaryTextColor,
                          fontWeight: FontWeight.w600,
                        ),
                        backgroundColor: cardColor,
                        side: BorderSide(
                          color: isSelected
                              ? Colors.transparent
                              : (isDark
                                  ? AppColors.cream.withValues(alpha: 0.2)
                                  : AppColors.greyBorder),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 24),

              // --- Promos List ---
              if (filteredPromos.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Text(
                      'No promos found for this filter.',
                      style: TextStyle(color: secondaryTextColor),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredPromos.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final promo = filteredPromos[index];
                    final isActive = promo['isActive'] as bool;
                    final usage = promo['usage'] as int;
                    final limit = promo['limit'] as int;
                    final usagePercent = usage / limit;

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark
                              ? AppColors.cream.withValues(alpha: 0.1)
                              : AppColors.greyBorder,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: isDark ? 0.3 : 0.04,
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
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? AppColors.cream
                                          : AppColors.secondary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.local_offer_rounded,
                                      size: 16,
                                      color: isDark
                                          ? AppColors.bobaBrown
                                          : AppColors.cardWhite,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    promo['code'],
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: primaryTextColor,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: (isActive
                                          ? AppColors.success
                                          : AppColors.error)
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  isActive ? 'Active' : 'Expired',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isActive
                                        ? AppColors.success
                                        : AppColors.error,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            promo['discount'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.cream
                                  : AppColors.bobaBrown,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            promo['description'],
                            style: TextStyle(
                              fontSize: 13,
                              color: secondaryTextColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Usage Progress Bar
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Redemptions',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: secondaryTextColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '$usage / $limit',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: primaryTextColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          LinearProgressIndicator(
                            value: usagePercent,
                            backgroundColor: isDark
                                ? AppColors.darkText.withValues(alpha: 0.5)
                                : AppColors.background,
                            color: usagePercent >= 1.0
                                ? AppColors.error
                                : AppColors.secondary,
                            minHeight: 6,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          
                          const SizedBox(height: 16),
                          const Divider(color: AppColors.greyBorder, height: 1),
                          const SizedBox(height: 8),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time_rounded,
                                    size: 14,
                                    color: secondaryTextColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Until: ${promo['validUntil']}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: secondaryTextColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              TextButton.icon(
                                onPressed: () {
                                  // Handle edit promo action
                                },
                                icon: const Icon(
                                  Icons.edit_rounded,
                                  size: 16,
                                ),
                                label: const Text('Edit'),
                                style: TextButton.styleFrom(
                                  foregroundColor: isDark
                                      ? AppColors.cream
                                      : AppColors.secondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
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
              ? AppColors.cream.withValues(alpha: 0.1)
              : AppColors.greyBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: iconColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: secondaryTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: primaryTextColor,
            ),
          ),
        ],
      ),
    );
  }
}