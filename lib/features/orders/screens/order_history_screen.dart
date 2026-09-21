import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../main.dart';

import '../widgets/orderHistory/update_notes_dialog.dart';

import '../widgets/orderHistory/order_history_card.dart';
import '../widgets/orderHistory/order_history_empty_state.dart';
import '../widgets/orderHistory/order_history_error_state.dart';
import '../widgets/orderHistory/order_history_header.dart';
import '../widgets/orderHistory/order_search_filter_bar.dart';

import 'order_tracking_screen.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({
    super.key,
  });

  @override
  State<OrderHistoryScreen> createState() =>
      _OrderHistoryScreenState();
}

class _OrderHistoryScreenState
    extends State<OrderHistoryScreen> {
  late Stream<List<Map<String, dynamic>>>
      _ordersStream;

  final TextEditingController _searchController =
      TextEditingController();

  String _searchQuery = '';
  String _selectedFilter = 'active';

  bool _isRefreshing = false;

  // ==============================================================
  // STATUS GROUPS
  // ==============================================================

  static const Set<String> _activeStatuses = {
    'pending',
    'accepted',
    'preparing',
    'out_for_delivery',
    'ready_for_pickup',
  };

  static const Set<String> _pastStatuses = {
    'completed',
    'cancelled',
  };

  // ==============================================================
  // FILTER OPTIONS
  // ==============================================================

  final List<Map<String, dynamic>>
      _filterOptions = const [
    {
      'key': 'active',
      'label': 'Active Orders',
      'icon': Icons.pending_actions_outlined,
    },
    {
      'key': 'past',
      'label': 'Past Orders',
      'icon': Icons.history_rounded,
    },
    {
      'key': 'all',
      'label': 'All Orders',
      'icon': Icons.grid_view_outlined,
    },
  ];

  // ==============================================================
  // INIT
  // ==============================================================

  @override
  void initState() {
    super.initState();

    _initStream();

    _searchController.addListener(
      _handleSearchChanged,
    );
  }

  void _handleSearchChanged() {
    if (!mounted) return;

    final String query =
        _searchController.text
            .trim()
            .toLowerCase();

    if (_searchQuery == query) {
      return;
    }

    setState(() {
      _searchQuery = query;
    });
  }

  // ==============================================================
  // ORDER STREAM
  // ==============================================================

  void _initStream() {
    final user =
        supabase.auth.currentUser;

    if (user != null) {
      _ordersStream = supabase
          .from('orders')
          .stream(
            primaryKey: ['id'],
          )
          .eq(
            'user_id',
            user.id,
          )
          .order(
            'created_at',
            ascending: false,
          );
    } else {
      _ordersStream =
          const Stream.empty();
    }
  }

  // ==============================================================
  // REFRESH
  // ==============================================================

  Future<void> _handleRefresh() async {
    if (_isRefreshing) {
      return;
    }

    setState(() {
      _isRefreshing = true;

      _initStream();
    });

    await Future.delayed(
      const Duration(milliseconds: 500),
    );

    if (!mounted) return;

    setState(() {
      _isRefreshing = false;
    });
  }

  // ==============================================================
  // DISPOSE
  // ==============================================================

  @override
  void dispose() {
    _searchController.removeListener(
      _handleSearchChanged,
    );

    _searchController.dispose();

    super.dispose();
  }

  // ==============================================================
  // FILTER
  // ==============================================================

  bool _matchesFilter(String status) {
    switch (_selectedFilter) {
      case 'active':
        return _activeStatuses.contains(
          status,
        );

      case 'past':
        return _pastStatuses.contains(
          status,
        );

      case 'all':
      default:
        return true;
    }
  }

  // ==============================================================
  // STATUS COLOR
  // ==============================================================

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

  // ==============================================================
  // STATUS LABEL
  // ==============================================================

  String _formatStatusLabel(
    String status,
  ) {
    return status
        .toUpperCase()
        .replaceAll('_', ' ');
  }

  // ==============================================================
  // EMPTY STATE TEXT
  // ==============================================================

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
      return 'Try searching for an order ID, item, or order instructions.';
    }

    switch (_selectedFilter) {
      case 'active':
        return 'Your current orders will appear here while they are being prepared.';

      case 'past':
        return 'Your completed and cancelled orders will appear here.';

      case 'all':
      default:
        return 'Your active and previous orders will appear here.';
    }
  }

  // ==============================================================
  // UPDATE NOTES
  // ==============================================================

  Future<void> _updateNotes(
    String orderId,
    String currentNotes,
  ) async {
    await UpdateNotesDialog.show(
      context: context,
      currentNotes: currentNotes,
      onSave: (newNotes) async {
        try {
          await supabase
              .from('orders')
              .update({
                'notes': newNotes,
              })
              .eq(
                'id',
                orderId,
              );

          if (!mounted) return;

          ScaffoldMessenger.of(context)
              .showSnackBar(
            SnackBar(
              behavior:
                  SnackBarBehavior.floating,
              margin:
                  const EdgeInsets.all(16),
              backgroundColor:
                  AppColors.textPrimary,
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(
                  14,
                ),
              ),
              content: const Row(
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                  SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      'Order instructions updated.',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        } catch (e) {
          if (!mounted) return;

          ScaffoldMessenger.of(context)
              .showSnackBar(
            SnackBar(
              behavior:
                  SnackBarBehavior.floating,
              margin:
                  const EdgeInsets.all(16),
              backgroundColor:
                  AppColors.error,
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(
                  14,
                ),
              ),
              content: const Row(
                children: [
                  Icon(
                    Icons
                        .error_outline_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                  SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      'Unable to update order instructions.',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );

          rethrow;
        }
      },
    );
  }

  // ==============================================================
  // OPEN TRACKING
  // ==============================================================

  void _openTracking(
    BuildContext context,
    String orderId,
  ) {
    if (orderId.isEmpty) {
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            OrderTrackingScreen(
          orderId: orderId,
        ),
      ),
    );
  }

  // ==============================================================
  // SEARCH / FILTER ORDERS
  // ==============================================================

  List<Map<String, dynamic>>
      _filterOrders(
    List<Map<String, dynamic>>
        rawOrders,
  ) {
    return rawOrders.where((order) {
      final String orderId =
          (order['id'] ?? '')
              .toString()
              .toLowerCase();

      final String notes =
          (order['notes'] ?? '')
              .toString()
              .toLowerCase();

      final String status =
          (order['status'] ?? 'pending')
              .toString()
              .trim()
              .toLowerCase();

      // ----------------------------------------------------------
      // Search order items if they are available in the map.
      // ----------------------------------------------------------

      final dynamic rawItems =
          order['order_items'] ??
              order['items'];

      final List<dynamic> dynamicItems =
          rawItems is List
              ? rawItems
              : const [];

      final bool matchesItems =
          dynamicItems.any(
        (dynamic item) {
          if (item is! Map) {
            return false;
          }

          final Map<String, dynamic>
              itemMap =
              Map<String, dynamic>.from(
            item,
          );

          final String itemName =
              (itemMap['name'] ??
                      itemMap[
                          'product_name'] ??
                      itemMap['title'] ??
                      '')
                  .toString()
                  .toLowerCase();

          return itemName.contains(
            _searchQuery,
          );
        },
      );

      final bool matchesSearch =
          _searchQuery.isEmpty ||
          orderId.contains(
            _searchQuery,
          ) ||
          notes.contains(
            _searchQuery,
          ) ||
          matchesItems;

      final bool matchesFilter =
          _matchesFilter(status);

      return matchesSearch &&
          matchesFilter;
    }).toList();
  }

  // ==============================================================
  // BUILD
  // ==============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // =====================================================
            // HEADER
            // =====================================================

            OrderHistoryHeader(
              isRefreshing:
                  _isRefreshing,
              onRefresh:
                  _handleRefresh,
            ),

            // =====================================================
            // SEARCH + FILTER
            // =====================================================

            OrderSearchFilterBar(
              searchController:
                  _searchController,
              searchQuery:
                  _searchQuery,
              selectedFilter:
                  _selectedFilter,
              filterOptions:
                  _filterOptions,
              onFilterSelected:
                  (filterKey) {
                if (_selectedFilter ==
                    filterKey) {
                  return;
                }

                setState(() {
                  _selectedFilter =
                      filterKey;
                });
              },
              onClearSearch: () {
                _searchController.clear();
              },
            ),

            // =====================================================
            // ORDERS
            // =====================================================

            Expanded(
              child: _buildOrders(),
            ),
          ],
        ),
      ),
    );
  }

  // ==============================================================
  // ORDERS CONTENT
  // ==============================================================

  Widget _buildOrders() {
    return StreamBuilder<
        List<Map<String, dynamic>>>(
      stream: _ordersStream,
      builder: (
        context,
        snapshot,
      ) {
        // =========================================================
        // INITIAL LOADING
        // =========================================================

        if (snapshot.connectionState ==
                ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child:
                  CircularProgressIndicator(
                strokeWidth: 2,
                color:
                    AppColors.textPrimary,
              ),
            ),
          );
        }

        // =========================================================
        // ERROR
        // =========================================================

        if (snapshot.hasError) {
          debugPrint(
            'Orders stream error: '
            '${snapshot.error}',
          );

          return RefreshIndicator(
            color:
                AppColors.textPrimary,
            backgroundColor:
                AppColors.surface,
            onRefresh:
                _handleRefresh,
            child:
                OrderHistoryErrorState(
              onRetry:
                  _handleRefresh,
            ),
          );
        }

        // =========================================================
        // FILTER
        // =========================================================

        final List<
                Map<String, dynamic>>
            rawOrders =
            snapshot.data ?? [];

        final List<
                Map<String, dynamic>>
            orders =
            _filterOrders(
          rawOrders,
        );

        // =========================================================
        // EMPTY
        // =========================================================

        if (orders.isEmpty) {
          return RefreshIndicator(
            color:
                AppColors.textPrimary,
            backgroundColor:
                AppColors.surface,
            onRefresh:
                _handleRefresh,
            child:
                OrderHistoryEmptyState(
              title:
                  _emptyTitle,
              message:
                  _emptyMessage,
              isSearching:
                  _searchQuery.isNotEmpty,
            ),
          );
        }

        // =========================================================
        // ORDER LIST
        // =========================================================

        return RefreshIndicator(
          color:
              AppColors.textPrimary,
          backgroundColor:
              AppColors.surface,
          onRefresh:
              _handleRefresh,
          child: ListView.separated(
            physics:
                const AlwaysScrollableScrollPhysics(),
            padding:
                const EdgeInsets.fromLTRB(
              18,
              6,
              18,
              30,
            ),
            itemCount:
                orders.length,
            separatorBuilder:
                (_, __) =>
                    const SizedBox(
              height: 12,
            ),
            itemBuilder:
                (context, index) {
              final Map<String, dynamic>
                  order =
                  orders[index];

              final String orderId =
                  order['id']
                          ?.toString() ??
                      '';

              final String status =
                  (order['status'] ??
                          'pending')
                      .toString();

              return OrderHistoryCard(
                order:
                    order,
                statusColor:
                    _getStatusColor(
                  status,
                ),
                statusLabel:
                    _formatStatusLabel(
                  status,
                ),
                onUpdateNotes: () {
                  _updateNotes(
                    orderId,
                    (order['notes'] ??
                            '')
                        .toString(),
                  );
                },
                onOpenOrder: () {
                  _openTracking(
                    context,
                    orderId,
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}