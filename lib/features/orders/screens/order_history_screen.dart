import 'package:flutter/material.dart';
import 'package:the_legit_smoothie/core/utils/helpers.dart';
import 'package:the_legit_smoothie/features/orders/widgets/order_search_filter_bar.dart';
import 'package:the_legit_smoothie/features/orders/widgets/order_widgets.dart';
import 'package:the_legit_smoothie/main.dart';
import 'package:the_legit_smoothie/shared/widgets/custom_app_bar.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import 'order_tracking_screen.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  late Stream<List<Map<String, dynamic>>> _ordersStream;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  /// Active is the default because this is the user's most likely task:
  /// finding and tracking an order that is currently in progress.
  String _selectedFilter = 'active';

  static const Set<String> _activeStatuses = {
    'pending',
    'accepted',
    'preparing',
    'out_for_delivery',
    'ready_for_pickup',
  };

  static const Set<String> _pastStatuses = {'completed', 'cancelled'};

  final List<Map<String, dynamic>> _filterOptions = const [
    {
      'key': 'active',
      'label': 'Active Orders',
      'icon': Icons.pending_actions_rounded,
    },
    {'key': 'past', 'label': 'Past Orders', 'icon': Icons.history_rounded},
    {'key': 'all', 'label': 'All Orders', 'icon': Icons.grid_view_rounded},
  ];

  bool _matchesFilter(String status) {
    switch (_selectedFilter) {
      case 'active':
        return _activeStatuses.contains(status);

      case 'past':
        return _pastStatuses.contains(status);

      case 'all':
      default:
        return true;
    }
  }

  @override
  void initState() {
    super.initState();
    _initStream();

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  void _initStream() {
    final user = supabase.auth.currentUser;
    if (user != null) {
      // Include order_items relational query to fetch nested item data
      _ordersStream = supabase
          .from('orders')
          .stream(primaryKey: ['id'])
          .eq('user_id', user.id)
          .order('created_at', ascending: false);
    } else {
      _ordersStream = const Stream.empty();
    }
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _initStream();
    });
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.amber.shade800;
      case 'accepted':
        return Colors.orange.shade800;
      case 'preparing':
        return AppColors.primary;
      case 'out_for_delivery':
      case 'ready_for_pickup':
        return Colors.blue.shade600;
      case 'completed':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  String get _emptyTitle {
    if (_searchQuery.isNotEmpty) {
      return 'No matching orders found';
    }

    switch (_selectedFilter) {
      case 'active':
        return 'No active orders';

      case 'past':
        return 'No past orders';

      case 'all':
      default:
        return 'No orders placed yet';
    }
  }

  String get _emptyMessage {
    if (_searchQuery.isNotEmpty) {
      return 'Try searching for order ID, items, or notes.';
    }

    switch (_selectedFilter) {
      case 'active':
        return 'Your current orders will appear here while they are being processed.';

      case 'past':
        return 'Completed and cancelled orders will appear here.';

      case 'all':
      default:
        return 'Your active and past orders will appear here.';
    }
  }

  String _formatStatusLabel(String status) {
    return status.toUpperCase().replaceAll('_', ' ');
  }

  Future<void> _cancelOrder(String orderId) async {
    final confirmed = await CancelOrderDialog.show(context);

    if (!mounted || confirmed != true) return;

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
    );

    try {
      await supabase
          .from('orders')
          .update({'status': 'cancelled'})
          .eq('id', orderId);

      if (!mounted) return;
      navigator.pop();

      messenger.showSnackBar(
        const SnackBar(
          content: Text('Order cancelled successfully.'),
          backgroundColor: AppColors.error,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      navigator.pop();

      messenger.showSnackBar(
        SnackBar(
          content: Text('Failed to cancel order: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _updateNotes(String orderId, String currentNotes) async {
    UpdateNotesDialog.show(
      context: context,
      currentNotes: currentNotes,
      onSave: (newNotes) async {
        try {
          await supabase
              .from('orders')
              .update({'notes': newNotes})
              .eq('id', orderId);

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Order notes updated!'),
              backgroundColor: AppColors.success,
            ),
          );
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update notes: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: MainAppBar(
        showLogo: false,
        showBackButton: false,
        titleWidget: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.15),
                    AppColors.primary.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.receipt_long_rounded,
                size: 18,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [AppColors.textPrimary, AppColors.primary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    child: const Text(
                      'Order History',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        color: AppColors.surface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Review your past and active orders',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                      color: AppColors.textSecondary.withValues(alpha: 0.8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          OrderSearchFilterBar(
            searchController: _searchController,
            searchQuery: _searchQuery,
            selectedFilter: _selectedFilter,
            filterOptions: _filterOptions,
            onFilterSelected: (filterKey) {
              setState(() {
                _selectedFilter = filterKey;
              });
            },
            onClearSearch: () => _searchController.clear(),
          ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _ordersStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading orders: ${snapshot.error}',
                      style: const TextStyle(color: AppColors.error),
                    ),
                  );
                }

                final rawOrders = snapshot.data ?? [];

                final orders = rawOrders.where((order) {
                  final String orderId = (order['id'] ?? '')
                      .toString()
                      .toLowerCase();
                  final String notes = (order['notes'] ?? '')
                      .toString()
                      .toLowerCase();
                  final String status = (order['status'] ?? 'pending')
                      .toString()
                      .toLowerCase();

                  // Extract item names safely from order_items or items array
                  final List dynamicItems =
                      order['order_items'] ?? order['items'] ?? [];
                  final bool matchesItems = dynamicItems.any((item) {
                    final Map<String, dynamic> itemMap =
                        Map<String, dynamic>.from(item as Map);
                    final String itemName =
                        (itemMap['name'] ??
                                itemMap['product_name'] ??
                                itemMap['title'] ??
                                '')
                            .toString()
                            .toLowerCase();
                    return itemName.contains(_searchQuery);
                  });

                  final matchesSearch =
                      _searchQuery.isEmpty ||
                      orderId.contains(_searchQuery) ||
                      notes.contains(_searchQuery) ||
                      matchesItems;

                  final matchesFilter = _matchesFilter(status);

                  return matchesSearch && matchesFilter;
                }).toList();

                if (orders.isEmpty) {
                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: _handleRefresh,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.5,
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _searchQuery.isNotEmpty
                                    ? Icons.search_off_rounded
                                    : Icons.receipt_long_outlined,
                                size: 60,
                                color: AppColors.primary.withValues(alpha: 0.8),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              _emptyTitle,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _emptyMessage,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.textSecondary.withValues(
                                  alpha: 0.8,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  color: AppColors.primary,
                  backgroundColor: AppColors.surface,
                  onRefresh: _handleRefresh,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    itemCount: orders.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return _OrderCard(
                        order: order,
                        statusColor: _getStatusColor(order['status'] ?? ''),
                        statusLabel: _formatStatusLabel(
                          order['status'] ?? 'pending',
                        ),
                        onUpdateNotes: () => _updateNotes(
                          order['id'],
                          (order['notes'] ?? '').toString(),
                        ),
                        onCancelOrder: () => _cancelOrder(order['id']),
                      );
                    },
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

class _OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final Color statusColor;
  final String statusLabel;
  final VoidCallback onUpdateNotes;
  final VoidCallback onCancelOrder;

  const _OrderCard({
    required this.order,
    required this.statusColor,
    required this.statusLabel,
    required this.onUpdateNotes,
    required this.onCancelOrder,
  });

  @override
  Widget build(BuildContext context) {
    final String orderId = order['id'];
    final String status = (order['status'] ?? 'pending').toString();
    final String orderType = (order['order_type'] ?? 'delivery').toString();
    final String notes = (order['notes'] ?? '').toString();
    final double totalPrice = (order['total_price'] as num?)?.toDouble() ?? 0.0;
    final DateTime createdAt = DateTime.parse(order['created_at']).toLocal();

    final isPending = status == 'pending';
    final isPreparing = status == 'preparing';
    final isCancelled = status == 'cancelled';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => OrderTrackingScreen(orderId: orderId),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          orderType == 'delivery'
                              ? Icons.delivery_dining_rounded
                              : Icons.storefront_rounded,
                          size: 18,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order #${orderId.substring(0, orderId.length > 8 ? 8 : orderId.length).toUpperCase()}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            (AppHelpers.formatDate(createdAt)),
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary.withValues(
                                alpha: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: statusColor,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
              if (notes.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.sticky_note_2_outlined,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          notes,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Price',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary.withValues(alpha: 0.8),
                        ),
                      ),
                      Text(
                        AppHelpers.formatCurrency(totalPrice),
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      if (isPending || isPreparing)
                        IconButton(
                          onPressed: onUpdateNotes,
                          icon: const Icon(Icons.edit_note_rounded),
                          color: AppColors.primary,
                          tooltip: 'Update Instructions',
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.primary.withValues(
                              alpha: 0.08,
                            ),
                          ),
                        ),

                      const SizedBox(width: 8),
                      if (!isCancelled)
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    OrderTrackingScreen(orderId: orderId),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.near_me_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Track',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
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
            ],
          ),
        ),
      ),
    );
  }
}
