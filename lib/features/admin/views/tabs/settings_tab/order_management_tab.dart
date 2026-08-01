import 'package:flutter/material.dart';
import 'package:the_legit_smoothie/core/constants/app_colors.dart';

class AdminOrdersView extends StatefulWidget {
  final VoidCallback? onBack;

  const AdminOrdersView({
    super.key,
    this.onBack,
  });

  @override
  State<AdminOrdersView> createState() => _AdminOrdersViewState();
}

class _AdminOrdersViewState extends State<AdminOrdersView> {
  // Filter and search state
  String _selectedFilter = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Expanded mock order list with additional professional details (timestamps, payment methods, order notes)
  final List<Map<String, dynamic>> _orders = [
    {
      'id': '#LS-1089',
      'customer': 'Maria Santos',
      'email': 'maria.santos@gmail.com',
      'phone': '+63 917 123 4567',
      'items': '2x Taro Milk Tea, 1x Cheese Foam',
      'total': '₱380.00',
      'status': 'Pending',
      'paymentMethod': 'GCash',
      'timestamp': 'Today, 3:15 PM',
      'notes': 'Less ice, extra pearls please.',
    },
    {
      'id': '#LS-1088',
      'customer': 'Juan Dela Cruz',
      'email': 'juandc@yahoo.com',
      'phone': '+63 918 987 6543',
      'items': '1x Dark Choco Smoothie',
      'total': '₱160.00',
      'status': 'Processing',
      'paymentMethod': 'Cash on Delivery',
      'timestamp': 'Today, 2:50 PM',
      'notes': 'Deliver to lobby front desk.',
    },
    {
      'id': '#LS-1087',
      'customer': 'Ana Reyes',
      'email': 'ana.reyes@outlook.com',
      'phone': '+63 922 456 7890',
      'items': '2x Mango Fruit Tea, 2x Pearls',
      'total': '₱320.00',
      'status': 'Completed',
      'paymentMethod': 'Credit Card',
      'timestamp': 'Today, 1:40 PM',
      'notes': 'Regular sugar level.',
    },
    {
      'id': '#LS-1086',
      'customer': 'Carlos Miguel',
      'email': 'carlos_m@gmail.com',
      'phone': '+63 915 555 1234',
      'items': '1x Matcha Green Tea Latte, 1x Egg Pudding',
      'total': '₱210.00',
      'status': 'Cancelled',
      'paymentMethod': 'Maya',
      'timestamp': 'Today, 11:20 AM',
      'notes': 'Customer requested cancellation.',
    },
    {
      'id': '#LS-1085',
      'customer': 'Bea Alonzo',
      'email': 'bea.a@gmail.com',
      'phone': '+63 919 444 8888',
      'items': '3x Wintermelon Milk Tea, 3x Crystal Boba',
      'total': '₱540.00',
      'status': 'Completed',
      'paymentMethod': 'GCash',
      'timestamp': 'Today, 10:05 AM',
      'notes': 'Corporate office order.',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Filter logic based on status and search query
  List<Map<String, dynamic>> get _filteredOrders {
    return _orders.where((order) {
      final matchesFilter =
          _selectedFilter == 'All' || order['status'] == _selectedFilter;
      final query = _searchQuery.toLowerCase();
      final matchesSearch = order['id'].toLowerCase().contains(query) ||
          order['customer'].toLowerCase().contains(query) ||
          order['items'].toLowerCase().contains(query);
      return matchesFilter && matchesSearch;
    }).toList();
  }

  void _updateOrderStatus(String orderId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkText : AppColors.cardWhite,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Update Order Status ($orderId)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.cream : AppColors.darkText,
                ),
              ),
              const SizedBox(height: 16),
              ...['Pending', 'Processing', 'Completed', 'Cancelled']
                  .map((status) => ListTile(
                        leading: Icon(
                          Icons.circle,
                          size: 12,
                          color: _getStatusColor(status),
                        ),
                        title: Text(
                          status,
                          style: TextStyle(
                            color: isDark ? AppColors.cream : AppColors.darkText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            final index = _orders.indexWhere((o) => o['id'] == orderId);
                            if (index != -1) {
                              _orders[index]['status'] = status;
                            }
                          });
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Order $orderId status updated to $status'),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: AppColors.bobaBrown,
                            ),
                          );
                        },
                      )),
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
        ? AppColors.cream.withValues(alpha: 0.7)
        : AppColors.greyText;

    final filteredList = _filteredOrders;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bobaBrown : AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Header with Back Button & Analytics Quick Badge ---
              Row(
                children: [
                  InkWell(
                    onTap: widget.onBack ?? () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkText : AppColors.cardWhite,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: isDark ? AppColors.cream : AppColors.bobaBrown,
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
                          'Orders Management',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: primaryTextColor,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          'Comprehensive real-time transaction processing',
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

              const SizedBox(height: 24),

              // --- Statistics Overview Cards ---
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Total Orders',
                      value: '${_orders.length}',
                      icon: Icons.receipt_long_rounded,
                      cardColor: cardColor,
                      isDark: isDark,
                      primaryTextColor: primaryTextColor,
                      secondaryTextColor: secondaryTextColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Pending Queue',
                      value: '${_orders.where((o) => o['status'] == 'Pending').length}',
                      icon: Icons.hourglass_top_rounded,
                      cardColor: cardColor,
                      isDark: isDark,
                      primaryTextColor: primaryTextColor,
                      secondaryTextColor: secondaryTextColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // --- Search Bar ---
              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark
                        ? AppColors.bobaBrown.withValues(alpha: 0.4)
                        : AppColors.greyBorder,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  style: TextStyle(color: primaryTextColor, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search by order ID, customer, or items...',
                    hintStyle: TextStyle(color: secondaryTextColor, fontSize: 14),
                    prefixIcon: Icon(Icons.search_rounded, color: secondaryTextColor),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear_rounded, color: secondaryTextColor),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // --- Status Filter Chips ---
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['All', 'Pending', 'Processing', 'Completed', 'Cancelled']
                      .map((status) {
                    final isSelected = _selectedFilter == status;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(status),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedFilter = status;
                          });
                        },
                        selectedColor: isDark ? AppColors.cream : AppColors.bobaBrown,
                        backgroundColor: cardColor,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? (isDark ? AppColors.darkText : AppColors.cardWhite)
                              : primaryTextColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: isSelected
                                ? Colors.transparent
                                : (isDark
                                    ? AppColors.bobaBrown.withValues(alpha: 0.4)
                                    : AppColors.greyBorder),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 24),

              // --- Section Header ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'TRANSACTION QUEUE (${filteredList.length})',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.cream.withValues(alpha: 0.6)
                          : AppColors.bobaBrown,
                      letterSpacing: 1.2,
                    ),
                  ),
                  if (filteredList.isNotEmpty)
                    Text(
                      'Showing active filters',
                      style: TextStyle(
                        fontSize: 11,
                        color: secondaryTextColor,
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // --- Orders List or Empty State ---
              filteredList.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 48.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 48,
                              color: secondaryTextColor,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No matching orders found',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: primaryTextColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Try adjusting your search query or status filter.',
                              style: TextStyle(
                                fontSize: 13,
                                color: secondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredList.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final order = filteredList[index];
                        return Container(
                          padding: const EdgeInsets.all(18),
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Top Row: ID, Timestamp & Status Badge
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        order['id'],
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: primaryTextColor,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        order['timestamp'],
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: secondaryTextColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(order['status'])
                                          .withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      order['status'],
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: _getStatusColor(order['status']),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12.0),
                                child: Divider(height: 1),
                              ),

                              // Customer Details
                              Row(
                                children: [
                                  Icon(Icons.person_outline_rounded,
                                      size: 16, color: secondaryTextColor),
                                  const SizedBox(width: 8),
                                  Text(
                                    order['customer'],
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: primaryTextColor,
                                    ),
                                  ),
                                  const Spacer(),
                                  Icon(Icons.payment_rounded,
                                      size: 14, color: secondaryTextColor),
                                  const SizedBox(width: 4),
                                  Text(
                                    order['paymentMethod'],
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: secondaryTextColor,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              // Items Ordered
                              Text(
                                order['items'],
                                style: TextStyle(
                                  fontSize: 13,
                                  color: secondaryTextColor,
                                ),
                              ),

                              // Customer Notes if available
                              if (order['notes'] != null &&
                                  order['notes'].toString().isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AppColors.bobaBrown.withValues(alpha: 0.3)
                                        : AppColors.background,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.note_alt_outlined,
                                          size: 14,
                                          color: secondaryTextColor),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Note: ${order['notes']}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontStyle: FontStyle.italic,
                                            color: primaryTextColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              const SizedBox(height: 14),

                              // Bottom Row: Total Price & Update Status Action Button
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Total Amount',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: secondaryTextColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
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
                                  ElevatedButton.icon(
                                    onPressed: () =>
                                        _updateOrderStatus(order['id']),
                                    icon: const Icon(
                                      Icons.edit_note_rounded,
                                      size: 16,
                                    ),
                                    label: const Text('Update Status'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isDark
                                          ? AppColors.cream
                                          : AppColors.bobaBrown,
                                      foregroundColor: isDark
                                          ? AppColors.bobaBrown
                                          : AppColors.cardWhite,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 8,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
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

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color cardColor,
    required bool isDark,
    required Color primaryTextColor,
    required Color secondaryTextColor,
  }) {
    return Container(
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
              color: (isDark ? AppColors.cream : AppColors.bobaBrown)
                  .withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 20,
              color: isDark ? AppColors.cream : AppColors.bobaBrown,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    color: secondaryTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryTextColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Processing':
        return Colors.blue;
      case 'Completed':
        return Colors.green;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}