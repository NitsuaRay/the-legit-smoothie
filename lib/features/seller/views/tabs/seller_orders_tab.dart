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

  // Rich sample order data tailored for a complete seller management queue
  final List<Map<String, dynamic>> _allOrders = [
    {
      'id': 'ORD-2001',
      'customer': 'Angelica Cruz',
      'phone': '+63 917 123 4567',
      'items': [
        {
          'name': 'Avocado Smoothie',
          'qty': 1,
          'price': 120.0,
          'customization': 'Less Ice, 50% Sugar',
        },
        {
          'name': 'Cheese Foam',
          'qty': 2,
          'price': 80.0,
          'customization': 'Extra Salted Cheese',
        },
      ],
      'total': 280.0,
      'status': 'Pending',
      'time': '3 mins ago',
      'type': 'Pickup',
      'paymentMethod': 'GCash (Paid)',
      'notes':
          'Please pack the cheese foam in a separate container if possible.',
    },
    {
      'id': 'ORD-2002',
      'customer': 'Mark Reyes',
      'phone': '+63 928 987 6543',
      'items': [
        {
          'name': 'Classic Pearl Boba',
          'qty': 2,
          'price': 120.0,
          'customization': 'Regular Ice, Normal Sugar',
        },
      ],
      'total': 240.0,
      'status': 'Preparing',
      'time': '10 mins ago',
      'type': 'Delivery',
      'paymentMethod': 'Cash on Delivery',
      'notes': 'Deliver to Lobby security desk.',
    },
    {
      'id': 'ORD-2003',
      'customer': 'Sarah Jenkins',
      'phone': '+63 999 555 1122',
      'items': [
        {
          'name': 'Taro Smoothie Supreme',
          'qty': 1,
          'price': 140.0,
          'customization': 'No Pearls, Extra Pudding',
        },
      ],
      'total': 140.0,
      'status': 'Ready',
      'time': '20 mins ago',
      'type': 'Pickup',
      'paymentMethod': 'Credit Card (Paid)',
      'notes': '',
    },
    {
      'id': 'ORD-2004',
      'customer': 'Kevin Tan',
      'phone': '+63 918 333 4455',
      'items': [
        {
          'name': 'Mango Graham Special',
          'qty': 1,
          'price': 150.0,
          'customization': 'Extra Mangos',
        },
      ],
      'total': 150.0,
      'status': 'Completed',
      'time': '1 hour ago',
      'type': 'Pickup',
      'paymentMethod': 'GCash (Paid)',
      'notes': 'Thank you!',
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

  // Helper string generator for item summary preview
  String _getItemsSummary(List<dynamic> items) {
    return items.map((i) => '${i['qty']}x ${i['name']}').join(', ');
  }

  void _showOrderDetailsModal(
    BuildContext context,
    Map<String, dynamic> order,
    Color cardColor,
    Color primaryTextColor,
    Color secondaryTextColor,
    bool isDark,
  ) {
    final status = order['status'] as String;
    final statusColor = _getStatusColor(status);
    final items = order['items'] as List<dynamic>;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order['id'],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryTextColor,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Customer Information',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: primaryTextColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${order['customer']} (${order['phone']})',
                style: TextStyle(fontSize: 13, color: secondaryTextColor),
              ),
              const SizedBox(height: 8),
              Text(
                'Fulfillment Type: ${order['type']} | Payment: ${order['paymentMethod']}',
                style: TextStyle(fontSize: 13, color: secondaryTextColor),
              ),

              if (order['notes'].isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(isDark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.note_alt_rounded,
                        size: 18,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Note: ${order['notes']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: primaryTextColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),
              Text(
                'Order Items',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: primaryTextColor,
                ),
              ),
              const SizedBox(height: 8),
              ...items.map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${item['qty']}x ${item['name']}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: primaryTextColor,
                              ),
                            ),
                            if (item['customization'].isNotEmpty)
                              Text(
                                item['customization'],
                                style: TextStyle(
                                  fontSize: 11,
                                  color: secondaryTextColor,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Text(
                        '₱${(item['price'] * item['qty']).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: primaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Amount',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: primaryTextColor,
                    ),
                  ),
                  Text(
                    '₱${(order['total'] as double).toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.cream : AppColors.bobaBrown,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.bobaBrown,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Close',
                    style: TextStyle(
                      color: AppColors.cream,
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardColor = isDark ? AppColors.darkText : AppColors.cardWhite;
    final primaryTextColor = isDark ? AppColors.cream : AppColors.darkText;
    final secondaryTextColor = isDark
        ? AppColors.cream.withOpacity(0.7)
        : AppColors.greyText;

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
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                  tabs: [
                    Tab(text: 'Active Queue (${activeOrders.length})'),
                    Tab(text: 'History (${pastOrders.length})'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOrdersList(
                      activeOrders,
                      cardColor,
                      primaryTextColor,
                      secondaryTextColor,
                      isDark,
                    ),
                    _buildOrdersList(
                      pastOrders,
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
        final itemsSummary = _getItemsSummary(order['items']);

        return InkWell(
          onTap: () => _showOrderDetailsModal(
            context,
            order,
            cardColor,
            primaryTextColor,
            secondaryTextColor,
            isDark,
          ),
          borderRadius: BorderRadius.circular(16),
          child: Container(
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
                            horizontal: 8,
                            vertical: 2,
                          ),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
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
                  itemsSummary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: secondaryTextColor),
                ),
                const SizedBox(height: 12),
                Divider(
                  height: 1,
                  color: isDark
                      ? AppColors.bobaBrown.withOpacity(0.3)
                      : AppColors.greyBorder,
                ),
                const SizedBox(height: 12),
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
                            color: isDark
                                ? AppColors.cream
                                : AppColors.bobaBrown,
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
                            horizontal: 12,
                            vertical: 8,
                          ),
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
          ),
        );
      },
    );
  }
}
