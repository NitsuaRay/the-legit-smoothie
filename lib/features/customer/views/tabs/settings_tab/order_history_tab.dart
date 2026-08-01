import 'package:flutter/material.dart';
import 'package:the_legit_smoothie/core/constants/app_colors.dart';

class OrderHistoryTab extends StatefulWidget {
  const OrderHistoryTab({super.key});

  @override
  State<OrderHistoryTab> createState() => _OrderHistoryTabState();
}

class _OrderHistoryTabState extends State<OrderHistoryTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock Data for Orders
  final List<Map<String, dynamic>> _orders = [
    {
      'id': 'LS-84920',
      'date': 'May 28, 2026 • 2:45 PM',
      'status': 'Completed',
      'total': '₱340.00',
      'items': [
        {'name': 'Hokkaido Boba Milk Tea', 'qty': 1, 'price': '₱170.00'},
        {'name': 'Mango Smoothie Supreme', 'qty': 1, 'price': '₱170.00'},
      ],
      'deliveryType': 'Delivery',
      'address': 'Unit 4B, Sunshine Residences, Quezon City',
      'paymentMethod': 'GCash',
    },
    {
      'id': 'LS-83104',
      'date': 'May 14, 2026 • 1:15 PM',
      'status': 'Completed',
      'total': '₱190.00',
      'items': [
        {'name': 'Matcha Green Tea Smoothie', 'qty': 1, 'price': '₱190.00'},
      ],
      'deliveryType': 'Store Pickup',
      'address': 'SM North EDSA Branch',
      'paymentMethod': 'Credit Card',
    },
    {
      'id': 'LS-81992',
      'date': 'April 30, 2026 • 4:20 PM',
      'status': 'Cancelled',
      'total': '₱220.00',
      'items': [
        {'name': 'Taro Milk Tea with Pudding', 'qty': 1, 'price': '₱220.00'},
      ],
      'deliveryType': 'Delivery',
      'address': 'Unit 4B, Sunshine Residences, Quezon City',
      'paymentMethod': 'Cash on Delivery',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardColor = isDark ? AppColors.darkText : AppColors.cardWhite;
    final primaryTextColor = isDark ? AppColors.cream : AppColors.darkText;
    final secondaryTextColor = isDark
        ? AppColors.cream.withValues(alpha: 0.7)
        : AppColors.greyText;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bobaBrown : AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Custom Header Section ---
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? AppColors.bobaBrown.withValues(alpha: 0.4)
                            : AppColors.greyBorder,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        color: isDark ? AppColors.cream : AppColors.bobaBrown,
                        size: 20,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order History',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: primaryTextColor,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          'Track & review your past smoothie purchases',
                          style: TextStyle(
                            fontSize: 13,
                            color: secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // --- Filter Tabs (All / Completed / Cancelled) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark
                        ? AppColors.bobaBrown.withValues(alpha: 0.4)
                        : AppColors.greyBorder,
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  dividerColor: Colors.transparent,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    color: isDark ? AppColors.cream : AppColors.bobaBrown,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelColor: isDark ? AppColors.darkText : AppColors.cardWhite,
                  unselectedLabelColor: secondaryTextColor,
                  labelStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                  tabs: const [
                    Tab(text: 'All'),
                    Tab(text: 'Completed'),
                    Tab(text: 'Cancelled'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            // --- Tab Views Content ---
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOrderList(context, _orders, cardColor, primaryTextColor, secondaryTextColor, isDark),
                  _buildOrderList(
                    context,
                    _orders.where((o) => o['status'] == 'Completed').toList(),
                    cardColor,
                    primaryTextColor,
                    secondaryTextColor,
                    isDark,
                  ),
                  _buildOrderList(
                    context,
                    _orders.where((o) => o['status'] == 'Cancelled').toList(),
                    cardColor,
                    primaryTextColor,
                    secondaryTextColor,
                    isDark,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderList(
    BuildContext context,
    List<Map<String, dynamic>> orders,
    Color cardColor,
    Color primaryTextColor,
    Color secondaryTextColor,
    bool isDark,
  ) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.cream.withValues(alpha: 0.1)
                    : AppColors.bobaBrown.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long_rounded,
                size: 48,
                color: isDark ? AppColors.cream : AppColors.bobaBrown,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No orders found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: primaryTextColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'You haven\'t placed any orders in this category yet.',
              style: TextStyle(fontSize: 13, color: secondaryTextColor),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        final isCompleted = order['status'] == 'Completed';

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order ID & Status Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.local_mall_rounded,
                        size: 18,
                        color: isDark ? AppColors.cream : AppColors.bobaBrown,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        order['id'],
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: primaryTextColor,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? AppColors.success.withValues(alpha: 0.12)
                          : AppColors.error.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      order['status'],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isCompleted ? AppColors.success : AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                order['date'],
                style: TextStyle(
                  fontSize: 12,
                  color: secondaryTextColor,
                ),
              ),

              Divider(
                height: 24,
                color: isDark
                    ? AppColors.bobaBrown.withValues(alpha: 0.3)
                    : AppColors.greyBorder,
              ),

              // Items List
              ...List.generate(order['items'].length, (itemIndex) {
                final item = order['items'][itemIndex];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${item['qty']}x ${item['name']}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: primaryTextColor,
                          ),
                        ),
                      ),
                      Text(
                        item['price'],
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: primaryTextColor,
                        ),
                      ),
                    ],
                  ),
                );
              }),

              Divider(
                height: 24,
                color: isDark
                    ? AppColors.bobaBrown.withValues(alpha: 0.3)
                    : AppColors.greyBorder,
              ),

              // Footer: Delivery Type & Total Price
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order['deliveryType'],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.cream : AppColors.bobaBrown,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Paid via ${order['paymentMethod']}',
                        style: TextStyle(fontSize: 11, color: secondaryTextColor),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Total Amount',
                        style: TextStyle(fontSize: 11, color: secondaryTextColor),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        order['total'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: primaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Action Buttons (Reorder / View Details)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _showOrderDetailsSheet(context, order, isDark, cardColor, primaryTextColor, secondaryTextColor);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(
                          color: isDark
                              ? AppColors.cream.withValues(alpha: 0.4)
                              : AppColors.bobaBrown,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'View Details',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.cream : AppColors.bobaBrown,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Items from ${order['id']} added to cart!'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? AppColors.cream : AppColors.bobaBrown,
                        foregroundColor: isDark ? AppColors.darkText : AppColors.cardWhite,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Reorder',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showOrderDetailsSheet(
    BuildContext context,
    Map<String, dynamic> order,
    bool isDark,
    Color cardColor,
    Color primaryTextColor,
    Color secondaryTextColor,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: secondaryTextColor.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order Receipt',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryTextColor,
                    ),
                  ),
                  Text(
                    order['id'],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.cream : AppColors.bobaBrown,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                order['date'],
                style: TextStyle(fontSize: 12, color: secondaryTextColor),
              ),
              Divider(height: 24, color: secondaryTextColor.withValues(alpha: 0.3)),
              Text(
                'Fulfillment & Location',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.cream.withValues(alpha: 0.6) : AppColors.bobaBrown,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                order['address'],
                style: TextStyle(fontSize: 14, color: primaryTextColor),
              ),
              const SizedBox(height: 16),
              Text(
                'Purchased Items',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.cream.withValues(alpha: 0.6) : AppColors.bobaBrown,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              ...List.generate(order['items'].length, (i) {
                final item = order['items'][i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${item['qty']}x ${item['name']}',
                          style: TextStyle(fontSize: 13, color: primaryTextColor)),
                      Text(item['price'],
                          style: TextStyle(fontSize: 13, color: primaryTextColor)),
                    ],
                  ),
                );
              }),
              Divider(height: 24, color: secondaryTextColor.withValues(alpha: 0.3)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Paid',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: primaryTextColor)),
                  Text(order['total'],
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryTextColor)),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? AppColors.cream : AppColors.bobaBrown,
                    foregroundColor: isDark ? AppColors.darkText : AppColors.cardWhite,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Close Receipt'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}