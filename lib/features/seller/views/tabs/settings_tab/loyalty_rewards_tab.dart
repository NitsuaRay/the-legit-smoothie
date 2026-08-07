import 'package:flutter/material.dart';
import 'package:the_legit_smoothie/core/constants/app_colors.dart';

class LoyaltyRewardsTab extends StatefulWidget {
  const LoyaltyRewardsTab({super.key});

  @override
  State<LoyaltyRewardsTab> createState() => _LoyaltyRewardsTabState();
}

class _LoyaltyRewardsTabState extends State<LoyaltyRewardsTab> {
  bool _isProgramEnabled = true;

  // Controllers for configurable parameters
  final TextEditingController _earnRateController =
      TextEditingController(text: '10'); // 1 Point per ₱10 spent
  final TextEditingController _redemptionRateController =
      TextEditingController(text: '1'); // 1 Point = ₱1 discount

  // Mock list of active rewards available to customers
  final List<Map<String, dynamic>> _rewardsList = [
    {
      'id': '1',
      'title': 'Free Boba Topping',
      'pointsRequired': 50,
      'description': 'Add free pearls or jelly to any beverage',
      'icon': Icons.add_reaction_outlined,
    },
    {
      'id': '2',
      'title': '₱50 Off Total Order',
      'pointsRequired': 100,
      'description': 'Applicable on orders with min. spend of ₱200',
      'icon': Icons.local_offer_outlined,
    },
    {
      'id': '3',
      'title': 'Free Large Smoothie Upgrade',
      'pointsRequired': 150,
      'description': 'Size up any classic or signature drink',
      'icon': Icons.local_drink_rounded,
    },
  ];

  @override
  void dispose() {
    _earnRateController.dispose();
    _redemptionRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryTextColor = isDark ? AppColors.cream : AppColors.darkText;
    final secondaryTextColor = isDark
        ? AppColors.cream.withValues(alpha: 0.7)
        : AppColors.greyText;
    final cardColor = isDark ? AppColors.darkText : AppColors.cardWhite;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkText : AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: primaryTextColor,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Loyalty Rewards Program',
          style: TextStyle(
            color: primaryTextColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Program Toggle Card ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? AppColors.bobaBrown.withValues(alpha: 0.4)
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
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.cream.withValues(alpha: 0.15)
                          : AppColors.bobaBrown.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.card_giftcard_rounded,
                      color: isDark ? AppColors.cream : AppColors.bobaBrown,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Smoothie Rewards',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: primaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _isProgramEnabled
                              ? 'Active • Customers are earning points'
                              : 'Paused • Point accumulation disabled',
                          style: TextStyle(
                            fontSize: 12,
                            color: _isProgramEnabled
                                ? (isDark
                                    ? AppColors.cream
                                    : AppColors.bobaBrown)
                                : secondaryTextColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _isProgramEnabled,
                    activeColor:
                        isDark ? AppColors.bobaBrown : AppColors.cardWhite,
                    activeTrackColor:
                        isDark ? AppColors.cream : AppColors.bobaBrown,
                    onChanged: (value) {
                      setState(() {
                        _isProgramEnabled = value;
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // --- Section 1: Rules & Earning Mechanics ---
            _buildSectionHeader('EARNING & REDEMPTION RULES', isDark),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? AppColors.bobaBrown.withValues(alpha: 0.4)
                      : AppColors.greyBorder,
                ),
              ),
              child: Column(
                children: [
                  _buildSettingRow(
                    label: 'Earn 1 Point for every:',
                    controller: _earnRateController,
                    prefixText: '₱ ',
                    isDark: isDark,
                    primaryTextColor: primaryTextColor,
                  ),
                  Divider(
                    height: 24,
                    color: isDark
                        ? AppColors.bobaBrown.withValues(alpha: 0.3)
                        : AppColors.greyBorder,
                  ),
                  _buildSettingRow(
                    label: '1 Point Discount Value:',
                    controller: _redemptionRateController,
                    prefixText: '₱ ',
                    isDark: isDark,
                    primaryTextColor: primaryTextColor,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // --- Section 2: Manage Redeemable Rewards ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionHeader('REDEEMABLE CATALOG', isDark),
                IconButton(
                  onPressed: () => _showAddRewardModal(context, isDark),
                  icon: Icon(
                    Icons.add_circle_outline_rounded,
                    color: isDark ? AppColors.cream : AppColors.bobaBrown,
                    size: 20,
                  ),
                  tooltip: 'Add Reward Item',
                ),
              ],
            ),
            const SizedBox(height: 8),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _rewardsList.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final reward = _rewardsList[index];
                return Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? AppColors.bobaBrown.withValues(alpha: 0.4)
                          : AppColors.greyBorder,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.cream.withValues(alpha: 0.1)
                                : AppColors.bobaBrown.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            reward['icon'] as IconData,
                            color:
                                isDark ? AppColors.cream : AppColors.bobaBrown,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                reward['title'],
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: primaryTextColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                reward['description'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: secondaryTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.bobaBrown.withValues(alpha: 0.5)
                                : AppColors.background,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${reward['pointsRequired']} pts',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.cream
                                  : AppColors.bobaBrown,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets & Methods ---

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: isDark
              ? AppColors.cream.withValues(alpha: 0.6)
              : AppColors.bobaBrown,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingRow({
    required String label,
    required TextEditingController controller,
    required String prefixText,
    required bool isDark,
    required Color primaryTextColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: primaryTextColor,
            ),
          ),
        ),
        SizedBox(
          width: 90,
          height: 38,
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: primaryTextColor,
            ),
            decoration: InputDecoration(
              prefixText: prefixText,
              prefixStyle: TextStyle(
                color: primaryTextColor,
                fontWeight: FontWeight.bold,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              filled: true,
              fillColor: isDark
                  ? AppColors.cream.withValues(alpha: 0.05)
                  : AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: isDark
                      ? AppColors.bobaBrown.withValues(alpha: 0.4)
                      : AppColors.greyBorder,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: isDark ? AppColors.cream : AppColors.bobaBrown,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showAddRewardModal(BuildContext context, bool isDark) {
    final titleController = TextEditingController();
    final pointsController = TextEditingController();
    final descController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkText : AppColors.cardWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[700] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Add Loyalty Reward Option',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.cream : AppColors.darkText,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                style: TextStyle(
                  color: isDark ? AppColors.cream : AppColors.darkText,
                ),
                decoration: InputDecoration(
                  labelText: 'Reward Title',
                  hintText: 'e.g., Free Smoothie Voucher',
                  labelStyle: TextStyle(
                    color: isDark ? AppColors.cream : AppColors.darkText,
                  ),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: pointsController,
                keyboardType: TextInputType.number,
                style: TextStyle(
                  color: isDark ? AppColors.cream : AppColors.darkText,
                ),
                decoration: InputDecoration(
                  labelText: 'Points Required',
                  hintText: 'e.g., 200',
                  labelStyle: TextStyle(
                    color: isDark ? AppColors.cream : AppColors.darkText,
                  ),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                style: TextStyle(
                  color: isDark ? AppColors.cream : AppColors.darkText,
                ),
                decoration: InputDecoration(
                  labelText: 'Short Description',
                  hintText: 'e.g., Valid for any large beverage',
                  labelStyle: TextStyle(
                    color: isDark ? AppColors.cream : AppColors.darkText,
                  ),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (titleController.text.isNotEmpty &&
                        pointsController.text.isNotEmpty) {
                      setState(() {
                        _rewardsList.add({
                          'id': DateTime.now().millisecondsSinceEpoch.toString(),
                          'title': titleController.text,
                          'pointsRequired':
                              int.tryParse(pointsController.text) ?? 100,
                          'description': descController.text,
                          'icon': Icons.card_giftcard_rounded,
                        });
                      });
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isDark ? AppColors.cream : AppColors.bobaBrown,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Save Reward Item',
                    style: TextStyle(
                      color:
                          isDark ? AppColors.bobaBrown : AppColors.cardWhite,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}