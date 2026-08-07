import 'package:flutter/material.dart';
import 'package:the_legit_smoothie/core/constants/app_colors.dart';

class MerchantFaqsTab extends StatefulWidget {
  const MerchantFaqsTab({super.key});

  @override
  State<MerchantFaqsTab> createState() => _MerchantFaqsTabState();
}

class _MerchantFaqsTabState extends State<MerchantFaqsTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // FAQ Knowledge Base Data
  final List<Map<String, String>> _allFaqs = [
    {
      'category': 'Orders & Delivery',
      'question': 'How do I handle rider delays during peak hours?',
      'answer':
          'If a delivery rider is delayed, you can mark the order status as "Preparing" to extend the estimated pickup time. You can also contact support directly via the order tracking screen.',
    },
    {
      'category': 'Orders & Delivery',
      'question': 'What happens if a customer cancels an order after preparation?',
      'answer':
          'If the order was already marked as "In Preparation" or "Ready for Pickup", the full item cost will still be credited to your seller wallet according to our merchant protection policy.',
    },
    {
      'category': 'Payouts & Earnings',
      'question': 'When do store payouts get credited?',
      'answer':
          'Store earnings are automatically disbursed to your linked GCash or bank account every Tuesday and Friday at 12:00 PM (PST).',
    },
    {
      'category': 'Payouts & Earnings',
      'question': 'How are platform commission fees calculated?',
      'answer':
          'Platform fees are calculated per completed order based on your merchant agreement (typically 10-15%). You can view broken-down deductions under the Sales Analytics tab.',
    },
    {
      'category': 'Menu & Inventory',
      'question': 'How do I temporarily mark a beverage flavor as Out of Stock?',
      'answer':
          'Go to Menu Management, tap the item, and toggle off the "Available" switch. It will immediately hide the item on the customer storefront until you re-enable it.',
    },
    {
      'category': 'Promotions & Discounts',
      'question': 'Who funds the voucher codes created in the Seller App?',
      'answer':
          'Vouchers created via the "Discounts & Vouchers" tab are store-sponsored to help boost your sales. Platform-wide campaign vouchers are co-funded by The Legit Smoothie.',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
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

    // Filter FAQs based on search input
    final filteredFaqs = _allFaqs.where((faq) {
      final q = faq['question']!.toLowerCase();
      final a = faq['answer']!.toLowerCase();
      final c = faq['category']!.toLowerCase();
      final query = _searchQuery.toLowerCase();
      return q.contains(query) || a.contains(query) || c.contains(query);
    }).toList();

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
          'Merchant FAQs',
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
          // --- Search Bar Header ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
              style: TextStyle(
                color: primaryTextColor,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: 'Search answers, payouts, orders...',
                hintStyle: TextStyle(
                  color: secondaryTextColor.withValues(alpha: 0.7),
                  fontSize: 13,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: secondaryTextColor,
                  size: 20,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear_rounded,
                          color: secondaryTextColor,
                          size: 18,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: cardColor,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: isDark
                        ? AppColors.bobaBrown.withValues(alpha: 0.4)
                        : AppColors.greyBorder,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: isDark
                        ? AppColors.bobaBrown.withValues(alpha: 0.4)
                        : AppColors.greyBorder,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.cream : AppColors.bobaBrown,
                  ),
                ),
              ),
            ),
          ),

          // --- FAQ List ---
          Expanded(
            child: filteredFaqs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.help_outline_rounded,
                          size: 48,
                          color: secondaryTextColor.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No matching questions found',
                          style: TextStyle(
                            color: secondaryTextColor,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    itemCount: filteredFaqs.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final faq = filteredFaqs[index];
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
                              color: Colors.black.withValues(
                                alpha: isDark ? 0.2 : 0.04,
                              ),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            dividerColor: Colors.transparent,
                          ),
                          child: ExpansionTile(
                            iconColor:
                                isDark ? AppColors.cream : AppColors.bobaBrown,
                            collapsedIconColor: secondaryTextColor,
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AppColors.cream.withValues(alpha: 0.1)
                                        : AppColors.bobaBrown
                                            .withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    faq['category']!.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? AppColors.cream
                                          : AppColors.bobaBrown,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  faq['question']!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: primaryTextColor,
                                  ),
                                ),
                              ],
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 16,
                                  right: 16,
                                  bottom: 16,
                                ),
                                child: Text(
                                  faq['answer']!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: secondaryTextColor,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}