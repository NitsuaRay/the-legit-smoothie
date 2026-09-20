import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../main.dart';
import '../widgets/seller_dashboard_header.dart';
import '../widgets/seller_quick_action.dart';
import '../widgets/seller_recent_order_card.dart';
import '../widgets/seller_stat_card.dart';

class SellerHomeScreen extends StatefulWidget {
  const SellerHomeScreen({super.key});

  @override
  State<SellerHomeScreen> createState() => _SellerHomeScreenState();
}

class _SellerHomeScreenState extends State<SellerHomeScreen> {
  bool _isLoading = true;

  String _sellerName = 'Seller';

  int _pendingOrders = 0;
  int _activeOrders = 0;
  int _totalProducts = 0;

  double _todaySales = 0;

  List<Map<String, dynamic>> _recentOrders = [];

  @override
  void initState() {
    super.initState();

    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      await Future.wait([_loadSellerProfile(), _loadProducts(), _loadOrders()]);
    } catch (e) {
      debugPrint('Seller dashboard error: $e');
    }

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });
  }

  // ============================================================
  // SELLER PROFILE
  // ============================================================

  Future<void> _loadSellerProfile() async {
    final user = supabase.auth.currentUser;

    if (user == null) return;

    try {
      final response = await supabase
          .from('profiles')
          .select('full_name')
          .eq('id', user.id)
          .maybeSingle();

      if (response != null) {
        final String name = (response['full_name'] ?? '').toString().trim();

        if (name.isNotEmpty) {
          _sellerName = name;
        }
      }
    } catch (e) {
      debugPrint('Failed to load seller profile: $e');
    }
  }

  // ============================================================
  // PRODUCTS
  // ============================================================

  Future<void> _loadProducts() async {
    try {
      final response = await supabase.from('products').select('id');

      _totalProducts = response.length;
    } catch (e) {
      debugPrint('Failed to load products: $e');
    }
  }

  // ============================================================
  // ORDERS
  // ============================================================

  Future<void> _loadOrders() async {
    try {
      final response = await supabase
          .from('orders')
          .select('id, status, order_type, total_price, created_at')
          .order('created_at', ascending: false);

      final List<Map<String, dynamic>> orders = List<Map<String, dynamic>>.from(
        response,
      );

      _pendingOrders = orders.where((order) {
        return (order['status'] ?? '').toString().toLowerCase() == 'pending';
      }).length;

      const activeStatuses = {
        'pending',
        'accepted',
        'preparing',
        'out_for_delivery',
        'ready_for_pickup',
      };

      _activeOrders = orders.where((order) {
        final String status = (order['status'] ?? '').toString().toLowerCase();

        return activeStatuses.contains(status);
      }).length;

      // ========================================================
      // TODAY SALES
      // Only completed orders count as sales.
      // ========================================================

      final DateTime now = DateTime.now();

      double sales = 0;

      for (final order in orders) {
        final String status = (order['status'] ?? '').toString().toLowerCase();

        if (status != 'completed') continue;

        final dynamic rawDate = order['created_at'];

        if (rawDate == null) continue;

        final DateTime createdAt = DateTime.parse(rawDate.toString()).toLocal();

        final bool isToday =
            createdAt.year == now.year &&
            createdAt.month == now.month &&
            createdAt.day == now.day;

        if (!isToday) continue;

        sales += (order['total_price'] as num?)?.toDouble() ?? 0;
      }

      _todaySales = sales;

      _recentOrders = orders.take(5).toList();
    } catch (e) {
      debugPrint('Failed to load seller orders: $e');
    }
  }

  // ============================================================
  // MONEY
  // ============================================================

  String _formatMoney(double amount) {
    return '₱${amount.toStringAsFixed(2)}';
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _loadDashboard,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            children: [
              // ==================================================
              // HEADER
              // ==================================================
              SellerDashboardHeader(
                sellerName: _sellerName,
                notificationCount: _pendingOrders,
                onNotificationTap: () {
                  // Later:
                  // navigate to seller Orders tab
                },
              ),

              const SizedBox(height: 24),

              // ==================================================
              // OVERVIEW
              // ==================================================
              const Text(
                'Store Overview',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 4),

              const Text(
                'A quick look at your store today.',
                style: TextStyle(
                  fontSize: 11.5,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 14),

              if (_isLoading)
                const SizedBox(
                  height: 160,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2.5,
                    ),
                  ),
                )
              else
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.12,
                  children: [
                    SellerStatCard(
                      title: 'Pending Orders',
                      value: _pendingOrders.toString(),
                      subtitle: 'Waiting for confirmation',
                      icon: Icons.pending_actions_rounded,
                    ),

                    SellerStatCard(
                      title: 'Active Orders',
                      value: _activeOrders.toString(),
                      subtitle: 'Currently being processed',
                      icon: Icons.receipt_long_rounded,
                    ),

                    SellerStatCard(
                      title: 'Today\'s Sales',
                      value: _formatMoney(_todaySales),
                      subtitle: 'From completed orders',
                      icon: Icons.payments_outlined,
                    ),

                    SellerStatCard(
                      title: 'Products',
                      value: _totalProducts.toString(),
                      subtitle: 'Products in your catalog',
                      icon: Icons.inventory_2_outlined,
                    ),
                  ],
                ),

              const SizedBox(height: 26),

              // ==================================================
              // QUICK ACTIONS
              // ==================================================
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 12),

              SellerQuickAction(
                title: 'Manage Orders',
                subtitle: 'View and process customer orders',
                icon: Icons.receipt_long_outlined,
                onTap: () {
                  // We will connect this to the
                  // seller Orders tab next.
                },
              ),

              const SizedBox(height: 10),

              SellerQuickAction(
                title: 'Manage Products',
                subtitle: 'Add or update your store products',
                icon: Icons.inventory_2_outlined,
                onTap: () {
                  // We will connect this to the
                  // seller Products tab next.
                },
              ),

              const SizedBox(height: 10),

              SellerQuickAction(
                title: 'Create Promotion',
                subtitle: 'Create deals for your customers',
                icon: Icons.local_offer_outlined,
                onTap: () {
                  // We will connect this later.
                },
              ),

              const SizedBox(height: 26),

              // ==================================================
              // RECENT ORDERS
              // ==================================================
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Recent Orders',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),

                  if (_recentOrders.isNotEmpty)
                    Text(
                      '${_recentOrders.length} recent',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary.withValues(alpha: 0.75),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              if (!_isLoading && _recentOrders.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 30,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppColors.border.withValues(alpha: 0.55),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 34,
                        color: AppColors.textSecondary.withValues(alpha: 0.45),
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        'No orders yet',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 4),

                      const Text(
                        'New customer orders will appear here.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ..._recentOrders.map(
                  (order) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: SellerRecentOrderCard(order: order),
                  ),
                ),

              // Extra space above bottom navigation.
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
