import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:the_legit_smoothie/core/constants/app_colors.dart';

class DiscountsVouchersTab extends StatefulWidget {
  const DiscountsVouchersTab({super.key});

  @override
  State<DiscountsVouchersTab> createState() => _DiscountsVouchersTabState();
}

class _DiscountsVouchersTabState extends State<DiscountsVouchersTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock list of promotional vouchers
  final List<Map<String, dynamic>> _vouchers = [
    {
      'code': 'SMOOTHIE20',
      'discount': '20% OFF',
      'title': 'Summer Smoothie Craze',
      'minSpend': 'Min. spend ₱250',
      'expiry': 'Valid until Aug 31, 2026',
      'isActive': true,
      'usageCount': 42,
    },
    {
      'code': 'BOBAFREESHIP',
      'discount': 'FREE DELIVERY',
      'title': 'Free Shipping Promo',
      'minSpend': 'Min. spend ₱300',
      'expiry': 'Valid until Aug 15, 2026',
      'isActive': true,
      'usageCount': 89,
    },
    {
      'code': 'WELCOME50',
      'discount': '₱50 OFF',
      'title': 'First Order Special',
      'minSpend': 'No min. spend',
      'expiry': 'Expired on Jul 01, 2026',
      'isActive': false,
      'usageCount': 150,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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

    final activeVouchers =
        _vouchers.where((v) => v['isActive'] == true).toList();
    final expiredVouchers =
        _vouchers.where((v) => v['isActive'] == false).toList();

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
          'Discounts & Vouchers',
          style: TextStyle(
            color: primaryTextColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          // --- Tab Bar Selector ---
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.cream.withValues(alpha: 0.08)
                  : AppColors.greyBorder.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(14),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: isDark ? AppColors.bobaBrown : AppColors.cardWhite,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              labelColor: isDark ? AppColors.cream : AppColors.bobaBrown,
              unselectedLabelColor: secondaryTextColor,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'Active Promos'),
                Tab(text: 'Expired / Inactive'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // --- Tab Views ---
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildVoucherList(
                  vouchers: activeVouchers,
                  cardColor: cardColor,
                  isDark: isDark,
                  primaryTextColor: primaryTextColor,
                  secondaryTextColor: secondaryTextColor,
                ),
                _buildVoucherList(
                  vouchers: expiredVouchers,
                  cardColor: cardColor,
                  isDark: isDark,
                  primaryTextColor: primaryTextColor,
                  secondaryTextColor: secondaryTextColor,
                ),
              ],
            ),
          ),
        ],
      ),

      // --- Floating Create Promo Button ---
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreatePromoModal(context, isDark),
        backgroundColor: isDark ? AppColors.cream : AppColors.bobaBrown,
        icon: Icon(
          Icons.add_rounded,
          color: isDark ? AppColors.bobaBrown : AppColors.cardWhite,
        ),
        label: Text(
          'Create Voucher',
          style: TextStyle(
            color: isDark ? AppColors.bobaBrown : AppColors.cardWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // --- Voucher List Builder ---
  Widget _buildVoucherList({
    required List<Map<String, dynamic>> vouchers,
    required Color cardColor,
    required bool isDark,
    required Color primaryTextColor,
    required Color secondaryTextColor,
  }) {
    if (vouchers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_offer_outlined,
              size: 48,
              color: secondaryTextColor.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'No vouchers found',
              style: TextStyle(
                color: secondaryTextColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      itemCount: vouchers.length,
      separatorBuilder: (context, index) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final voucher = vouchers[index];
        final isActive = voucher['isActive'] as bool;

        return Container(
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
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Promo Discount Tag
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? (isDark
                                ? AppColors.cream.withValues(alpha: 0.15)
                                : AppColors.bobaBrown.withValues(alpha: 0.1))
                            : Colors.grey.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        voucher['discount'],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isActive
                              ? (isDark
                                  ? AppColors.cream
                                  : AppColors.bobaBrown)
                              : Colors.grey,
                        ),
                      ),
                    ),

                    // Copy Code Action Button
                    InkWell(
                      onTap: () {
                        Clipboard.setData(
                          ClipboardData(text: voucher['code']),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Code ${voucher['code']} copied!'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Text(
                            voucher['code'],
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: primaryTextColor,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.copy_rounded,
                            size: 14,
                            color: secondaryTextColor,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  voucher['title'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primaryTextColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  voucher['minSpend'],
                  style: TextStyle(
                    fontSize: 12,
                    color: secondaryTextColor,
                  ),
                ),
                const SizedBox(height: 12),
                Divider(
                  height: 1,
                  color: isDark
                      ? AppColors.bobaBrown.withValues(alpha: 0.3)
                      : AppColors.greyBorder,
                ),
                const SizedBox(height: 10),
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
                        const SizedBox(width: 6),
                        Text(
                          voucher['expiry'],
                          style: TextStyle(
                            fontSize: 11,
                            color: secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Used: ${voucher['usageCount']}x',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- Modal Bottom Sheet: Create New Promo Voucher ---
  void _showCreatePromoModal(BuildContext context, bool isDark) {
    final titleController = TextEditingController();
    final codeController = TextEditingController();
    final discountController = TextEditingController();

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
                'Create New Voucher',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.cream : AppColors.darkText,
                ),
              ),
              const SizedBox(height: 16),
              _buildInputField(
                controller: titleController,
                label: 'Campaign Title',
                hint: 'e.g., Weekend Smoothie Fest',
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              _buildInputField(
                controller: codeController,
                label: 'Voucher Code',
                hint: 'e.g., WEEKEND20',
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              _buildInputField(
                controller: discountController,
                label: 'Discount Value',
                hint: 'e.g., 20% OFF or ₱50 OFF',
                isDark: isDark,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (codeController.text.isNotEmpty &&
                        titleController.text.isNotEmpty) {
                      setState(() {
                        _vouchers.insert(0, {
                          'code': codeController.text.toUpperCase(),
                          'discount': discountController.text.isEmpty
                              ? 'PROMO'
                              : discountController.text,
                          'title': titleController.text,
                          'minSpend': 'Min. spend ₱100',
                          'expiry': 'Valid until Sep 30, 2026',
                          'isActive': true,
                          'usageCount': 0,
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
                    'Publish Voucher',
                    style: TextStyle(
                      color:
                          isDark ? AppColors.bobaBrown : AppColors.cardWhite,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
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

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.cream : AppColors.darkText,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          style: TextStyle(
            color: isDark ? AppColors.cream : AppColors.darkText,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: isDark ? Colors.white38 : Colors.black38,
              fontSize: 13,
            ),
            filled: true,
            fillColor: isDark
                ? AppColors.cream.withValues(alpha: 0.05)
                : AppColors.background,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: isDark
                    ? AppColors.bobaBrown.withValues(alpha: 0.4)
                    : AppColors.greyBorder,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: isDark
                    ? AppColors.bobaBrown.withValues(alpha: 0.4)
                    : AppColors.greyBorder,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: isDark ? AppColors.cream : AppColors.bobaBrown,
              ),
            ),
          ),
        ),
      ],
    );
  }
}