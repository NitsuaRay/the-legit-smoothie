import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:the_legit_smoothie/core/models/app_notification.dart';
import 'package:the_legit_smoothie/core/services/notification_service.dart';
import 'package:the_legit_smoothie/features/notifications/screens/notifications_screen.dart';

import 'package:the_legit_smoothie/features/seller/widgets/homeScreen/seller_dashboard_header.dart';
import 'package:the_legit_smoothie/features/seller/widgets/homeScreen/seller_quick_action.dart';
import 'package:the_legit_smoothie/features/seller/widgets/homeScreen/seller_recent_order_card.dart';
import 'package:the_legit_smoothie/features/seller/widgets/homeScreen/seller_sales_card.dart';
import 'package:the_legit_smoothie/features/seller/widgets/homeScreen/seller_stat_card.dart';
import 'package:the_legit_smoothie/features/seller/widgets/homeScreen/seller_store_status_card.dart';

import '../../../core/constants/app_colors.dart';

class SellerHomeScreen extends StatefulWidget {
  final ValueChanged<int>? onNavigateToTab;

  const SellerHomeScreen({super.key, this.onNavigateToTab});

  @override
  State<SellerHomeScreen> createState() => _SellerHomeScreenState();
}

class _SellerHomeScreenState extends State<SellerHomeScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;

  final NotificationService _notificationService = NotificationService.instance;

  StreamSubscription<AppNotification>? _notificationSubscription;

  int _unreadNotificationCount = 0;

  // =============================================================
  // STORE STATUS
  // =============================================================

  bool _isStoreOpen = true;
  bool _isUpdatingStoreStatus = false;

  int? _storeSettingsId;

  // =============================================================
  // DASHBOARD STATE
  // =============================================================

  bool _isLoading = true;
  bool _isRefreshing = false;

  String _sellerName = 'Seller';

  int _pendingOrders = 0;
  int _activeOrders = 0;
  int _productCount = 0;
  int _completedOrdersToday = 0;

  double _todaySales = 0;

  List<Map<String, dynamic>> _recentOrders = [];

  // =============================================================
  // LIFECYCLE
  // =============================================================

  @override
  void initState() {
    super.initState();

    _loadDashboard();

    _loadUnreadNotificationCount();
    _listenForNotifications();
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();

    super.dispose();
  }
  // =============================================================
  // NOTIFICATIONS
  // =============================================================

  Future<void> _loadUnreadNotificationCount() async {
    try {
      final count = await _notificationService.getUnreadCount();

      if (!mounted) {
        return;
      }

      setState(() {
        _unreadNotificationCount = count;
      });
    } catch (error) {
      debugPrint('Seller notification count error: $error');
    }
  }

  void _listenForNotifications() {
    _notificationSubscription = _notificationService
        .watchNewNotifications()
        .listen(
          (_) {
            _loadUnreadNotificationCount();
          },
          onError: (Object error) {
            debugPrint('Seller notification realtime error: $error');
          },
        );
  }

  Future<void> _openNotifications() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            const NotificationsScreen(viewer: NotificationViewer.seller),
      ),
    );

    if (!mounted) {
      return;
    }

    await _loadUnreadNotificationCount();
  }
  // =============================================================
  // LOAD DASHBOARD
  // =============================================================

  Future<void> _loadDashboard({bool refresh = false}) async {
    if (refresh) {
      if (mounted) {
        setState(() {
          _isRefreshing = true;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }
    }

    try {
      final user = _supabase.auth.currentUser;

      if (user == null) {
        return;
      }

      // ==========================================================
      // STORE STATUS
      // ==========================================================

      await _loadStoreStatus();

      // ==========================================================
      // SELLER PROFILE
      // ==========================================================

      final profileResponse = await _supabase
          .from('profiles')
          .select('full_name')
          .eq('id', user.id)
          .maybeSingle();

      final String sellerName =
          profileResponse?['full_name']?.toString().trim() ?? '';

      // ==========================================================
      // PRODUCTS
      // ==========================================================

      final productResponse = await _supabase.from('products').select('id');

      final List<Map<String, dynamic>> products =
          List<Map<String, dynamic>>.from(productResponse);

      // ==========================================================
      // ORDERS
      // ==========================================================

      final ordersResponse = await _supabase
          .from('orders')
          .select('''
      id,
      status,
      order_type,
      total_price,
      created_at,
      order_status_history (
        status,
        created_at
      )
    ''')
          .order('created_at', ascending: false);

      final List<Map<String, dynamic>> orders = List<Map<String, dynamic>>.from(
        ordersResponse,
      );

      // ==========================================================
      // PENDING ORDERS
      // ==========================================================

      final int pendingOrders = orders.where((order) {
        final String status = (order['status'] ?? '').toString().toLowerCase();

        return status == 'pending';
      }).length;

      // ==========================================================
      // ACTIVE ORDERS
      //
      // Pending is included because it is still an active order.
      // ==========================================================

      const Set<String> activeStatuses = {
        'pending',
        'accepted',
        'preparing',
        'out_for_delivery',
        'ready_for_pickup',
      };

      final int activeOrders = orders.where((order) {
        final String status = (order['status'] ?? '').toString().toLowerCase();

        return activeStatuses.contains(status);
      }).length;

      // ==========================================================
      // TODAY'S SALES + COMPLETED ORDERS
      //
      // Count revenue based on when the order became completed in
      // order_status_history, not when the order was created.
      // ==========================================================

      double todaySales = 0;
      int completedOrdersToday = 0;

      for (final order in orders) {
        final String currentStatus = (order['status'] ?? '')
            .toString()
            .toLowerCase()
            .trim();

        // Only orders that are currently completed count as sales.
        if (currentStatus != 'completed') {
          continue;
        }

        // Returns a timestamp only when this order became completed today.
        final DateTime? completedAt = _completedAtToday(order);

        if (completedAt == null) {
          continue;
        }

        final double orderTotal =
            (order['total_price'] as num?)?.toDouble() ?? 0.0;

        todaySales += orderTotal;
        completedOrdersToday++;
      }

      // ==========================================================
      // RECENT ORDERS
      // ==========================================================

      final List<Map<String, dynamic>> recentOrders = orders.take(5).toList();

      // ==========================================================
      // UPDATE UI
      // ==========================================================

      if (!mounted) {
        return;
      }

      setState(() {
        _sellerName = sellerName.isEmpty ? 'Seller' : sellerName;

        _pendingOrders = pendingOrders;
        _activeOrders = activeOrders;

        _productCount = products.length;

        _todaySales = todaySales;
        _completedOrdersToday = completedOrdersToday;

        _recentOrders = recentOrders;
      });
    } on PostgrestException catch (error) {
      debugPrint(
        'Seller dashboard database error: '
        '${error.message}',
      );

      if (mounted) {
        _showErrorMessage('Unable to load seller dashboard.');
      }
    } catch (error) {
      debugPrint('Seller dashboard error: $error');

      if (mounted) {
        _showErrorMessage('Something went wrong while loading the dashboard.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
        });
      }
    }
  }

  // =============================================================
  // LOAD STORE STATUS
  // =============================================================

  Future<void> _loadStoreStatus() async {
    try {
      final response = await _supabase
          .from('store_settings')
          .select('id, is_open')
          .limit(1)
          .maybeSingle();

      if (response == null) {
        debugPrint('No store_settings row found.');

        return;
      }

      _storeSettingsId = (response['id'] as num?)?.toInt();

      _isStoreOpen = response['is_open'] as bool? ?? true;
    } catch (error) {
      debugPrint('Failed to load store status: $error');
    }
  }

  // =============================================================
  // SHOW STORE STATUS OPTIONS
  // =============================================================

  Future<void> _showStoreStatusOptions() async {
    if (_isUpdatingStoreStatus) {
      return;
    }

    final bool newStatus = !_isStoreOpen;

    final bool? confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.30),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // =================================================
                // HANDLE
                // =================================================
                Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 24),

                // =================================================
                // ICON
                // =================================================
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: newStatus
                        ? AppColors.success.withValues(alpha: 0.08)
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(19),
                    border: Border.all(
                      color: newStatus
                          ? AppColors.success.withValues(alpha: 0.10)
                          : AppColors.border.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Icon(
                    newStatus
                        ? Icons.storefront_rounded
                        : Icons.storefront_outlined,
                    size: 27,
                    color: newStatus
                        ? AppColors.success
                        : AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 17),

                // =================================================
                // TITLE
                // =================================================
                Text(
                  newStatus ? 'Open the store?' : 'Close the store?',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 21,
                    height: 1.1,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.65,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 9),

                // =================================================
                // DESCRIPTION
                // =================================================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    newStatus
                        ? 'Customers will be able to place new orders again.'
                        : 'Customers will temporarily be prevented from placing new orders.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary.withValues(alpha: 0.72),
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                // =================================================
                // CURRENT -> NEW STATUS
                // =================================================
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: AppColors.border.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CURRENT',
                              style: TextStyle(
                                fontSize: 7,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                                color: AppColors.textSecondary.withValues(
                                  alpha: 0.55,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _isStoreOpen ? 'Open' : 'Closed',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          size: 15,
                          color: AppColors.textSecondary,
                        ),
                      ),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'CHANGE TO',
                              style: TextStyle(
                                fontSize: 7,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                                color: AppColors.textSecondary.withValues(
                                  alpha: 0.55,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              newStatus ? 'Open' : 'Closed',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: newStatus
                                    ? AppColors.success
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // =================================================
                // CONFIRM
                // =================================================
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(sheetContext).pop(true);
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: AppColors.textPrimary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          newStatus
                              ? Icons.storefront_rounded
                              : Icons.power_settings_new_rounded,
                          size: 17,
                        ),

                        const SizedBox(width: 8),

                        Text(
                          newStatus ? 'Open Store' : 'Close Store',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 5),

                // =================================================
                // CANCEL
                // =================================================
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(sheetContext).pop(false);
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    await _updateStoreStatus(newStatus);
  }

  // =============================================================
  // UPDATE STORE STATUS
  // =============================================================

  Future<void> _updateStoreStatus(bool newStatus) async {
    if (_storeSettingsId == null) {
      _showErrorMessage('Store settings could not be found.');

      return;
    }

    if (_isUpdatingStoreStatus) {
      return;
    }

    setState(() {
      _isUpdatingStoreStatus = true;
    });

    try {
      await _supabase
          .from('store_settings')
          .update({
            'is_open': newStatus,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', _storeSettingsId!);

      if (!mounted) {
        return;
      }

      setState(() {
        _isStoreOpen = newStatus;
      });

      _showSuccessMessage(
        newStatus ? 'Store is now open.' : 'Store is now closed.',
        icon: newStatus
            ? Icons.check_circle_outline_rounded
            : Icons.storefront_outlined,
      );
    } on PostgrestException catch (error) {
      debugPrint(
        'Store status database error: '
        '${error.message}',
      );

      if (!mounted) {
        return;
      }

      _showErrorMessage('Unable to change store status.');
    } catch (error) {
      debugPrint('Failed to update store status: $error');

      if (!mounted) {
        return;
      }

      _showErrorMessage('Unable to change store status.');
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingStoreStatus = false;
        });
      }
    }
  }

  // =============================================================
  // REFRESH
  // =============================================================

  Future<void> _refreshDashboard() async {
    if (_isRefreshing) {
      return;
    }

    await Future.wait([
      _loadDashboard(refresh: true),
      _loadUnreadNotificationCount(),
    ]);
  }

  // =============================================================
  // ERROR MESSAGE
  // =============================================================

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.textPrimary,
          margin: const EdgeInsets.fromLTRB(18, 0, 18, 18),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: Row(
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 17,
                color: Colors.white,
              ),

              const SizedBox(width: 9),

              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  // =============================================================
  // SUCCESS MESSAGE
  // =============================================================

  void _showSuccessMessage(
    String message, {
    IconData icon = Icons.check_circle_outline_rounded,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.textPrimary,
          margin: const EdgeInsets.fromLTRB(18, 0, 18, 18),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: Row(
            children: [
              Icon(icon, size: 18, color: Colors.white),

              const SizedBox(width: 9),

              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  // =============================================================
  // NAVIGATION
  // =============================================================

  void _openOrders() {
    widget.onNavigateToTab?.call(2);
  }

  void _openProducts() {
    widget.onNavigateToTab?.call(1);
  }

  void _createPromotion() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.textPrimary,
          margin: const EdgeInsets.fromLTRB(18, 0, 18, 18),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: const Text(
            'Promotion management is coming next.',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      );
  }

  bool _isSameLocalDay(DateTime date, DateTime target) {
    return date.year == target.year &&
        date.month == target.month &&
        date.day == target.day;
  }

  DateTime? _completedAtToday(Map<String, dynamic> order) {
    final dynamic historyData = order['order_status_history'];

    if (historyData is! List) {
      return null;
    }

    final DateTime now = DateTime.now();

    DateTime? latestCompletedAt;

    for (final entry in historyData) {
      if (entry is! Map) continue;

      final String historyStatus =
          entry['status']?.toString().toLowerCase().trim() ?? '';

      if (historyStatus != 'completed') {
        continue;
      }

      final String? rawCreatedAt = entry['created_at']?.toString();

      if (rawCreatedAt == null || rawCreatedAt.isEmpty) {
        continue;
      }

      final DateTime? parsed = DateTime.tryParse(rawCreatedAt);

      if (parsed == null) {
        continue;
      }

      // Supabase timestamptz normally comes back as UTC.
      // Convert it to the device's local timezone.
      final DateTime localCompletedAt = parsed.toLocal();

      if (!_isSameLocalDay(localCompletedAt, now)) {
        continue;
      }

      if (latestCompletedAt == null ||
          localCompletedAt.isAfter(latestCompletedAt)) {
        latestCompletedAt = localCompletedAt;
      }
    }

    return latestCompletedAt;
  }

  // =============================================================
  // BUILD
  // =============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _isLoading
            ? _buildLoadingState()
            : RefreshIndicator(
                onRefresh: _refreshDashboard,
                color: AppColors.textPrimary,
                backgroundColor: AppColors.surface,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  slivers: [
                    // =============================================
                    // HEADER + STORE STATUS
                    // =============================================
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
                        child: Column(
                          children: [
                            SellerDashboardHeader(
                              sellerName: _sellerName,
                              notificationCount: _unreadNotificationCount,
                              onNotificationTap: _openNotifications,
                            ),

                            const SizedBox(height: 18),

                            SellerStoreStatusCard(
                              isOpen: _isStoreOpen,
                              isUpdating: _isUpdatingStoreStatus,
                              onTap: _showStoreStatusOptions,
                            ),

                            const SizedBox(height: 28),
                          ],
                        ),
                      ),
                    ),

                    // =============================================
                    // DASHBOARD CONTENT
                    // =============================================
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(18, 0, 18, 32),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          // =====================================
                          // STORE OVERVIEW
                          // =====================================
                          _buildOverviewHeader(),

                          const SizedBox(height: 15),

                          // =====================================
                          // SALES HERO
                          // =====================================
                          SellerSalesCard(
                            value: '₱${_todaySales.toStringAsFixed(2)}',
                            completedOrders: _completedOrdersToday,
                          ),

                          const SizedBox(height: 12),

                          // =====================================
                          // OPERATIONAL STATS
                          // =====================================
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 158,
                                  child: SellerStatCard(
                                    title: 'Pending Orders',
                                    value: '$_pendingOrders',
                                    subtitle: _pendingOrders == 0
                                        ? 'Nothing waiting'
                                        : 'Need attention',
                                    icon: Icons.schedule_rounded,
                                    isAttention: _pendingOrders > 0,
                                    onTap: _openOrders,
                                  ),
                                ),
                              ),

                              const SizedBox(width: 12),

                              Expanded(
                                child: SizedBox(
                                  height: 158,
                                  child: SellerStatCard(
                                    title: 'Active Orders',
                                    value: '$_activeOrders',
                                    subtitle: _activeOrders == 0
                                        ? 'No orders in progress'
                                        : 'Currently in progress',
                                    icon: Icons.local_fire_department_outlined,
                                    onTap: _openOrders,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // =====================================
                          // PRODUCTS
                          // =====================================
                          _buildProductSummary(),

                          const SizedBox(height: 30),

                          // =====================================
                          // QUICK ACTIONS
                          // =====================================
                          _buildSectionHeader(
                            eyebrow: 'SHORTCUTS',
                            title: 'Quick Actions',
                            subtitle: 'Jump straight into common store tasks.',
                          ),

                          const SizedBox(height: 13),

                          SellerQuickAction(
                            title: 'Manage Orders',
                            subtitle: _pendingOrders > 0
                                ? '$_pendingOrders pending ${_pendingOrders == 1 ? 'order' : 'orders'}'
                                : 'Review and update customer orders',
                            icon: Icons.receipt_long_outlined,
                            onTap: _openOrders,
                          ),

                          const SizedBox(height: 10),

                          SellerQuickAction(
                            title: 'Manage Products',
                            subtitle: '$_productCount products in your catalog',
                            icon: Icons.inventory_2_outlined,
                            onTap: _openProducts,
                          ),

                          const SizedBox(height: 10),

                          SellerQuickAction(
                            title: 'Create Promotion',
                            subtitle: 'Set up offers and customer deals',
                            icon: Icons.local_offer_outlined,
                            onTap: _createPromotion,
                          ),

                          const SizedBox(height: 30),

                          // =====================================
                          // RECENT ORDERS
                          // =====================================
                          _buildRecentOrdersHeader(),

                          const SizedBox(height: 13),

                          _buildRecentOrders(),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  // =============================================================
  // OVERVIEW HEADER
  // =============================================================

  Widget _buildOverviewHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TODAY',
                style: TextStyle(
                  fontSize: 8,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                  color: AppColors.textSecondary.withValues(alpha: 0.50),
                ),
              ),

              const SizedBox(height: 7),

              const Text(
                'Store Overview',
                style: TextStyle(
                  fontSize: 20,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.6,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'Your store performance at a glance.',
                style: TextStyle(
                  fontSize: 10.5,
                  height: 1.3,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary.withValues(alpha: 0.68),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.30)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _isStoreOpen
                      ? AppColors.success
                      : AppColors.textSecondary,
                  shape: BoxShape.circle,
                ),
              ),

              const SizedBox(width: 5),

              Text(
                _isStoreOpen ? 'LIVE' : 'PAUSED',
                style: const TextStyle(
                  fontSize: 7.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.7,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // =============================================================
  // PRODUCT SUMMARY
  // =============================================================

  Widget _buildProductSummary() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _openProducts,
        borderRadius: BorderRadius.circular(19),
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(19),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.42)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.022),
                blurRadius: 16,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                    color: AppColors.border.withValues(alpha: 0.20),
                  ),
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  size: 19,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Products',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      'Products currently in your catalog',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary.withValues(alpha: 0.65),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$_productCount',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.4,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 12,
                color: AppColors.textSecondary.withValues(alpha: 0.55),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =============================================================
  // SECTION HEADER
  // =============================================================

  Widget _buildSectionHeader({
    required String eyebrow,
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow,
          style: TextStyle(
            fontSize: 8,
            height: 1,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.1,
            color: AppColors.textSecondary.withValues(alpha: 0.50),
          ),
        ),

        const SizedBox(height: 7),

        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            height: 1,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.45,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          subtitle,
          style: TextStyle(
            fontSize: 10,
            height: 1.35,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary.withValues(alpha: 0.66),
          ),
        ),
      ],
    );
  }

  // =============================================================
  // RECENT ORDERS HEADER
  // =============================================================

  Widget _buildRecentOrdersHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: _buildSectionHeader(
            eyebrow: 'ORDERS',
            title: 'Recent Orders',
            subtitle: 'Latest customer orders from your store.',
          ),
        ),

        if (_recentOrders.isNotEmpty) ...[
          const SizedBox(width: 12),

          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _openOrders,
              borderRadius: BorderRadius.circular(30),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 7),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'View all',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(width: 4),

                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 13,
                      color: AppColors.textSecondary.withValues(alpha: 0.65),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // =============================================================
  // RECENT ORDERS
  // =============================================================

  Widget _buildRecentOrders() {
    if (_recentOrders.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.40)),
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                size: 21,
                color: AppColors.textSecondary.withValues(alpha: 0.65),
              ),
            ),

            const SizedBox(height: 13),

            const Text(
              'No orders yet',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              'New customer orders will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                height: 1.4,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary.withValues(alpha: 0.65),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        for (int index = 0; index < _recentOrders.length; index++) ...[
          SellerRecentOrderCard(order: _recentOrders[index]),

          if (index != _recentOrders.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }

  // =============================================================
  // LOADING
  // =============================================================

  Widget _buildLoadingState() {
    return const Center(
      child: SizedBox(
        width: 25,
        height: 25,
        child: CircularProgressIndicator(
          strokeWidth: 2.4,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
