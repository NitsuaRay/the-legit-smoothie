import 'package:flutter/material.dart';
import 'package:the_legit_smoothie/core/constants/app_colors.dart';

class SellerOrdersTab extends StatefulWidget {
  const SellerOrdersTab({super.key});

  @override
  State<SellerOrdersTab> createState() => _SellerOrdersTabState();
}

class _SellerOrdersTabState extends State<SellerOrdersTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Sample order data tailored for the orders management queue
  final List<Map<String, dynamic>> _allOrders = [
    {
      'id': 'ORD-2001',
      'customer': 'Angelica Cruz',
      'items': '1x Avocado Smoothie, 2x Cheese Foam',
      'total': 280.0,
      'status': 'Pending',
      'time': '3 mins ago',
      'type': 'Pickup',
    },
    {
      'id': 'ORD-2002',
      'customer': 'Mark Reyes',
      'items': '2x Classic Pearl Boba',
      'total': 240.0,
      'status': 'Preparing',
      'time': '10 mins ago',
      'type': 'Delivery',
    },
    {
      'id': 'ORD-2003',
      'customer': 'Sarah Jenkins',
      'items': '1x Taro Smoothie Supreme',
      'total': 140.0,
      'status': 'Ready',
      'time': '20 mins ago',
      'type': 'Pickup',
    },
    {
      'id': 'ORD-2004',
      'customer': 'Kevin Tan',
      'items': '1x Mango Graham Special',
      'total': 150.0,
      'status': 'Completed',
      'time': '1 hour ago',
      'type': 'Pickup',
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Preparing':
        return Colors.blue;
      case 'Ready':
        return Colors.green;
      case 'Completed':
        return AppColors.greyText;
      default:
        return AppColors.bobaBrown;
    }
  }

  void _updateOrderStatus(String orderId, String newStatus) {
    setState(() {
      final index = _allOrders.indexWhere((o) => o['id'] == orderId);
      if (index != -1) {
        _allOrders[index]['status'] = newStatus;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardColor = isDark ? AppColors.darkText : AppColors.cardWhite;
    final primaryTextColor = isDark ? AppColors.cream : AppColors.darkText;
    final secondaryTextColor = isDark
        ? AppColors.cream.withOpacity(0.7)
        : AppColors.greyText;

    // Filter active vs history orders
    final activeOrders = _allOrders
        .where((o) => o['status'] != 'Completed' && o['status'] != 'Cancelled')
        .toList();
    final pastOrders = _allOrders
        .where((o) => o['status'] == 'Completed' || o['status'] == 'Cancelled')
        .toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
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
                      Icons.receipt_long_rounded,
                      color: isDark ? AppColors.cream : AppColors.bobaBrown,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Customer Orders',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: primaryTextColor,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        'Monitor incoming queue & fulfillment',
                        style: TextStyle(
                          fontSize: 13,
                          color: secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // --- Tab Bar Toggle (Active vs History) ---
              Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.bobaBrown.withOpacity(0.3)
                      : AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? AppColors.bobaBrown.withOpacity(0.4)
                        : AppColors.greyBorder,
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: AppColors.bobaBrown,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelColor: AppColors.cream,
                  unselectedLabelColor: secondaryTextColor,
                  labelStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                  tabs: const [
                    Tab(text: 'Active Queue'),
                    Tab(text: 'History'),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // --- Tab Views ---
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOrdersList(activeOrders, cardColor, primaryTextColor,
                        secondaryTextColor, isDark),
                    _buildOrdersList(pastOrders, cardColor, primaryTextColor,
                        secondaryTextColor, isDark),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrdersList(
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
            Icon(
              Icons.inbox_rounded,
              size: 48,
              color: secondaryTextColor.withOpacity(0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'No orders found',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: secondaryTextColor,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: orders.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final order = orders[index];
        final status = order['status'] as String;
        final statusColor = _getStatusColor(status);

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
              // Row ID & Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        order['id'],
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: primaryTextColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.bobaBrown.withOpacity(0.4)
                              : AppColors.background,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          order['type'],
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: secondaryTextColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Customer Details & Items
              Text(
                'Customer: ${order['customer']}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: primaryTextColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                order['items'],
                style: TextStyle(
                  fontSize: 13,
                  color: secondaryTextColor,
                ),
              ),

              const SizedBox(height: 12),
              Divider(
                height: 1,
                color: isDark
                    ? AppColors.bobaBrown.withOpacity(0.3)
                    : AppColors.greyBorder,
              ),
              const SizedBox(height: 12),

              // Price & Action Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '₱${(order['total'] as double).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.cream : AppColors.bobaBrown,
                        ),
                      ),
                      Text(
                        order['time'],
                        style: TextStyle(
                          fontSize: 11,
                          color: secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                  if (status != 'Completed')
                    PopupMenuButton<String>(
                      onSelected: (newStatus) =>
                          _updateOrderStatus(order['id'], newStatus),
                      color: cardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.bobaBrown,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Text(
                              'Advance Status',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.cream,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.arrow_drop_down_rounded,
                              color: AppColors.cream,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'Preparing',
                          child: Text('Mark as Preparing'),
                        ),
                        const PopupMenuItem(
                          value: 'Ready',
                          child: Text('Mark as Ready'),
                        ),
                        const PopupMenuItem(
                          value: 'Completed',
                          child: Text('Mark as Completed'),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}