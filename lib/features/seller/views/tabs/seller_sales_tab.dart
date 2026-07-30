import 'package:flutter/material.dart';
import 'package:the_legit_smoothie/core/constants/app_colors.dart';

class SellerSalesTab extends StatefulWidget {
  const SellerSalesTab({super.key});

  @override
  State<SellerSalesTab> createState() => _SellerSalesTabState();
}

class _SellerSalesTabState extends State<SellerSalesTab> {
  // Sample order data
  final List<Map<String, dynamic>> _orders = [
    {
      'id': 'ORD-1001',
      'customer': 'Juan Dela Cruz',
      'items': '2x Classic Pearl Boba, 1x Taro Smoothie',
      'total': 380.0,
      'status': 'Pending',
      'time': '5 mins ago',
    },
    {
      'id': 'ORD-1002',
      'customer': 'Maria Santos',
      'items': '1x Mango Graham Special',
      'total': 150.0,
      'status': 'Preparing',
      'time': '12 mins ago',
    },
    {
      'id': 'ORD-1003',
      'customer': 'Austin Dev',
      'items': '3x Classic Pearl Boba',
      'total': 360.0,
      'status': 'Ready',
      'time': '25 mins ago',
    },
  ];

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

  void _updateOrderStatus(int index, String newStatus) {
    setState(() {
      _orders[index]['status'] = newStatus;
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
                      'Live Sales & Orders',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: primaryTextColor,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      'Manage active orders & order statuses',
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

            // --- Section Header ---
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 12),
              child: Text(
                'RECENT ORDERS',
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

            // --- Orders List ---
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _orders.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final order = _orders[index];
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
                      // Header: Order ID & Status Badge
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
                              Text(
                                '•  ${order['time']}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: secondaryTextColor,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
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

                      // Customer & Items Info
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

                      // Total Price & Quick Action Menu
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total: ₱${(order['total'] as double).toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.cream : AppColors.bobaBrown,
                            ),
                          ),
                          PopupMenuButton<String>(
                            onSelected: (newStatus) =>
                                _updateOrderStatus(index, newStatus),
                            color: cardColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.bobaBrown.withOpacity(0.4)
                                    : AppColors.background,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    'Update Status',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: primaryTextColor,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.arrow_drop_down_rounded,
                                    color: primaryTextColor,
                                    size: 18,
                                  ),
                                ],
                              ),
                            ),
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'Pending',
                                child: Text('Pending'),
                              ),
                              const PopupMenuItem(
                                value: 'Preparing',
                                child: Text('Preparing'),
                              ),
                              const PopupMenuItem(
                                value: 'Ready',
                                child: Text('Ready for Pickup'),
                              ),
                              const PopupMenuItem(
                                value: 'Completed',
                                child: Text('Completed'),
                              ),
                            ],
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
    );
  }
}