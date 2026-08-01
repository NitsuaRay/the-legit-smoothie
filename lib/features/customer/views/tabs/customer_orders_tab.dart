import 'package:flutter/material.dart';
import 'package:the_legit_smoothie/core/constants/app_colors.dart';

class CustomerOrderTab extends StatefulWidget {
  const CustomerOrderTab({super.key});

  @override
  State<CustomerOrderTab> createState() => _CustomerOrderTabState();
}

class _CustomerOrderTabState extends State<CustomerOrderTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Enhanced mock data for active orders with fine-grained tracking steps
  final List<Map<String, dynamic>> _activeOrders = [
    {
      'orderId': '#LS-8942',
      'status': 'Preparing',
      'currentStepIndex': 1, // 0: Received, 1: Preparing, 2: Out for Delivery, 3: Delivered
      'steps': ['Order Received', 'Blending & Packing', 'Out for Delivery', 'Delivered'],
      'items': [
        {'name': 'Tropical Mango Splash', 'size': 'Regular', 'quantity': 2, 'price': 120.00},
        {'name': 'Acai Energy Bowl', 'size': 'Large', 'quantity': 1, 'price': 180.00},
      ],
      'subtotal': 420.00,
      'deliveryFee': 45.00,
      'discount': 30.00,
      'total': 435.00,
      'time': 'Today, 2:15 PM',
      'paymentMethod': 'GCash (Online Payment)',
      'deliveryAddress': 'Tower 2, Unit 4B, Grand Residences, QC',
      'progress': 0.6,
    },
  ];

  // Enhanced mock data for order history with full breakdown
  final List<Map<String, dynamic>> _historyOrders = [
    {
      'orderId': '#LS-8810',
      'status': 'Completed',
      'items': [
        {'name': 'Green Detox Booster', 'size': 'Regular', 'quantity': 1, 'price': 110.00},
        {'name': 'Berry Blast Smoothie', 'size': 'Regular', 'quantity': 1, 'price': 140.00},
      ],
      'subtotal': 250.00,
      'deliveryFee': 45.00,
      'discount': 0.00,
      'total': 295.00,
      'time': 'May 24, 2026',
      'paymentMethod': 'Cash on Delivery',
      'deliveryAddress': 'Tower 2, Unit 4B, Grand Residences, QC',
      'progress': 1.0,
    },
    {
      'orderId': '#LS-8754',
      'status': 'Cancelled',
      'items': [
        {'name': 'Classic Avocado Smoothie', 'size': 'Large', 'quantity': 1, 'price': 130.00},
      ],
      'subtotal': 130.00,
      'deliveryFee': 45.00,
      'discount': 0.00,
      'total': 175.00,
      'time': 'May 20, 2026',
      'paymentMethod': 'GCash (Online Payment)',
      'deliveryAddress': 'Tower 2, Unit 4B, Grand Residences, QC',
      'progress': 0.0,
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = Colors.transparent;
    final surfaceColor = isDarkMode ? AppColors.bobaBrown : AppColors.cardWhite;
    final textColor = isDarkMode ? AppColors.cream : AppColors.darkText;
    final subtextColor = isDarkMode ? AppColors.cream.withOpacity(0.7) : AppColors.greyText;
    final borderColor = isDarkMode ? AppColors.cream.withOpacity(0.2) : AppColors.greyBorder;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Modern Header
            _buildModernHeader(textColor, subtextColor, isDarkMode),
            const SizedBox(height: 12),

            // Custom Segmented Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                height: 46,
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                ),
                child: TabBar(
                  controller: _tabController,
                  dividerColor: Colors.transparent,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  labelColor: AppColors.cardWhite,
                  unselectedLabelColor: subtextColor,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  tabs: const [
                    Tab(text: 'Active Orders'),
                    Tab(text: 'History'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Tab Views Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOrderList(_activeOrders, textColor, subtextColor, surfaceColor, borderColor, isDarkMode, isActive: true),
                  _buildOrderList(_historyOrders, textColor, subtextColor, surfaceColor, borderColor, isDarkMode, isActive: false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Modern Header Widget
  Widget _buildModernHeader(Color textColor, Color subtextColor, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '📦 My Orders',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Track your delicious blends in real-time',
                style: TextStyle(
                  fontSize: 13,
                  color: subtextColor,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.darkText.withOpacity(0.3) : AppColors.cardWhite,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDarkMode ? AppColors.cream.withOpacity(0.2) : AppColors.greyBorder,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              color: AppColors.secondary,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  // List builder for orders
  Widget _buildOrderList(
    List<Map<String, dynamic>> orders,
    Color textColor,
    Color subtextColor,
    Color surfaceColor,
    Color borderColor,
    bool isDarkMode, {
    required bool isActive,
  }) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? Icons.hourglass_empty_rounded : Icons.history_rounded,
              size: 56,
              color: subtextColor,
            ),
            const SizedBox(height: 12),
            Text(
              isActive ? 'No active orders right now' : 'No order history yet',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isActive ? 'Place an order from your cart to track it here.' : 'Your past orders will show up here.',
              style: TextStyle(color: subtextColor, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        final statusColor = _getStatusColor(order['status']);
        final itemsList = order['items'] as List<dynamic>;

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.04),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order ID & Status Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order['orderId'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: textColor,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      order['status'],
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                order['time'],
                style: TextStyle(
                  color: subtextColor,
                  fontSize: 12,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: Divider(height: 1),
              ),

              // Itemized Breakdown List
              ...itemsList.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${item['quantity']}x ${item['name']} (${item['size']})',
                            style: TextStyle(color: textColor, fontSize: 13),
                          ),
                        ),
                        Text(
                          '₱${(item['price'] * item['quantity']).toStringAsFixed(2)}',
                          style: TextStyle(color: subtextColor, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  )),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: Divider(height: 1),
              ),

              // Detailed Billing Metadata
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Delivery Address', style: TextStyle(color: subtextColor, fontSize: 12)),
                  Expanded(
                    child: Text(
                      order['deliveryAddress'],
                      textAlign: TextAlign.end,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Payment Method', style: TextStyle(color: subtextColor, fontSize: 12)),
                  Text(
                    order['paymentMethod'],
                    style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Live Stepper Tracker for Active Orders
              if (isActive && order['steps'] != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDarkMode ? AppColors.darkText.withOpacity(0.25) : AppColors.cardWhite,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Order Status Tracker',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          Text(
                            'Step ${(order['currentStepIndex'] as int) + 1} of 4',
                            style: TextStyle(
                              fontSize: 11,
                              color: subtextColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: order['progress'],
                          backgroundColor: borderColor,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Current Stage: ${order['steps'][order['currentStepIndex']]}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? AppColors.cream : AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Total Amount Footer & Action Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Amount',
                    style: TextStyle(
                      color: subtextColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '₱${(order['total'] as double).toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDarkMode ? AppColors.cream : AppColors.secondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: isDarkMode ? AppColors.cream.withOpacity(0.4) : AppColors.secondary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onPressed: () {
                    // Show detailed modal or tracking action sheet
                  },
                  child: Text(
                    isActive ? 'View Live Order Tracking' : 'Reorder Items',
                    style: TextStyle(
                      color: isDarkMode ? AppColors.cream : AppColors.secondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Preparing':
        return AppColors.secondary;
      case 'Completed':
        return AppColors.success;
      case 'Cancelled':
        return AppColors.error;
      default:
        return AppColors.greyText;
    }
  }
}