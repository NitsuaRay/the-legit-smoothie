import 'package:flutter/material.dart';
import 'package:the_legit_smoothie/features/seller/screens/seller_order_detail_screen.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../main.dart';

import '../widgets/seller_order_card.dart';

class SellerOrdersScreen extends StatefulWidget {
  const SellerOrdersScreen({super.key});

  @override
  State<SellerOrdersScreen> createState() =>
      _SellerOrdersScreenState();
}

class _SellerOrdersScreenState
    extends State<SellerOrdersScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  List<Map<String, dynamic>> _allOrders = [];
  List<Map<String, dynamic>> _filteredOrders = [];

  bool _isLoading = true;
  String? _errorMessage;

  String _searchQuery = '';

  // Active is the default because these are the orders
  // that currently require the seller's attention.
  String _selectedFilter = 'active';

  // ============================================================
  // FILTERS
  // ============================================================

  static const List<_OrderFilter> _filters = [
    _OrderFilter(
      id: 'active',
      label: 'Active',
    ),
    _OrderFilter(
      id: 'past',
      label: 'Past',
    ),
    _OrderFilter(
      id: 'all',
      label: 'All',
    ),
  ];

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

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOAD ORDERS
  // ============================================================

  Future<void> _loadOrders() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final response = await supabase
          .from('orders')
          .select('''
            id,
            user_id,
            status,
            order_type,
            total_amount,
            delivery_address,
            contact_number,
            notes,
            created_at,
            updated_at,
            delivery_fee,
            subtotal,
            total_price,
            cancel_reason,

            customer:profiles!orders_user_id_fkey (
              id,
              full_name,
              phone_number,
              avatar_url
            ),

            order_items (
              id,
              quantity
            )
          ''')
          .order(
            'created_at',
            ascending: false,
          );

      final orders = (response as List)
          .map(
            (item) => Map<String, dynamic>.from(
              item as Map,
            ),
          )
          .toList();

      if (!mounted) return;

      setState(() {
        _allOrders = orders;
        _isLoading = false;
      });

      _applyFilters();
    } catch (error) {
      debugPrint(
        'Seller orders load error: $error',
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage =
            'Unable to load orders right now.';
      });
    }
  }

  // ============================================================
  // FILTER ORDERS
  // ============================================================

  void _applyFilters() {
    final String query =
        _searchQuery.trim().toLowerCase();

    final List<Map<String, dynamic>> filtered =
        _allOrders.where((order) {
      final String status =
          order['status']
                  ?.toString()
                  .toLowerCase() ??
              '';

      final String orderType =
          order['order_type']
                  ?.toString()
                  .toLowerCase() ??
              '';

      final String orderId =
          order['id']
                  ?.toString()
                  .toLowerCase() ??
              '';

      final customer = order['customer'];

      String customerName = '';

      if (customer is Map) {
        customerName =
            customer['full_name']
                    ?.toString()
                    .trim()
                    .toLowerCase() ??
                '';
      }

      // ========================================================
      // STATUS FILTER
      // ========================================================

      bool matchesStatus;

      switch (_selectedFilter) {
        case 'active':
          matchesStatus =
              _activeStatuses.contains(status);
          break;

        case 'past':
          matchesStatus =
              _pastStatuses.contains(status);
          break;

        case 'all':
        default:
          matchesStatus = true;
          break;
      }

      // ========================================================
      // SEARCH
      // ========================================================

      final bool matchesSearch =
          query.isEmpty ||
          customerName.contains(query) ||
          orderId.contains(query) ||
          orderType.contains(query) ||
          status.contains(query);

      return matchesStatus && matchesSearch;
    }).toList();

    // ==========================================================
    // ACTIVE PRIORITY
    //
    // Pending orders appear first because they have not yet
    // been acknowledged by the seller.
    //
    // Everything else stays newest-first.
    // ==========================================================

    if (_selectedFilter == 'active') {
      filtered.sort(_compareActiveOrders);
    }

    if (!mounted) return;

    setState(() {
      _filteredOrders = filtered;
    });
  }

  // ============================================================
  // ACTIVE ORDER SORTING
  // ============================================================

  int _compareActiveOrders(
    Map<String, dynamic> a,
    Map<String, dynamic> b,
  ) {
    final String statusA =
        a['status']
                ?.toString()
                .toLowerCase() ??
            '';

    final String statusB =
        b['status']
                ?.toString()
                .toLowerCase() ??
            '';

    final int priorityA =
        _activePriority(statusA);

    final int priorityB =
        _activePriority(statusB);

    // Priority first.
    if (priorityA != priorityB) {
      return priorityA.compareTo(priorityB);
    }

    // Then newest first within the same priority.
    final DateTime? dateA =
        DateTime.tryParse(
      a['created_at']?.toString() ?? '',
    );

    final DateTime? dateB =
        DateTime.tryParse(
      b['created_at']?.toString() ?? '',
    );

    if (dateA == null && dateB == null) {
      return 0;
    }

    if (dateA == null) {
      return 1;
    }

    if (dateB == null) {
      return -1;
    }

    return dateB.compareTo(dateA);
  }

  int _activePriority(String status) {
    switch (status) {
      case 'pending':
        return 0;

      case 'accepted':
        return 1;

      case 'preparing':
        return 2;

      case 'ready_for_pickup':
      case 'out_for_delivery':
        return 3;

      default:
        return 4;
    }
  }

  // ============================================================
  // COUNTS
  // ============================================================

  int _countForFilter(String filter) {
    switch (filter) {
      case 'active':
        return _allOrders.where((order) {
          final String status =
              order['status']
                      ?.toString()
                      .toLowerCase() ??
                  '';

          return _activeStatuses.contains(
            status,
          );
        }).length;

      case 'past':
        return _allOrders.where((order) {
          final String status =
              order['status']
                      ?.toString()
                      .toLowerCase() ??
                  '';

          return _pastStatuses.contains(
            status,
          );
        }).length;

      case 'all':
      default:
        return _allOrders.length;
    }
  }

  int get _pendingOrderCount {
    return _allOrders.where((order) {
      final String status =
          order['status']
                  ?.toString()
                  .toLowerCase() ??
              '';

      return status == 'pending';
    }).length;
  }

  // ============================================================
  // ORDER DETAILS
  // ============================================================

  Future<void> _openOrder(
    Map<String, dynamic> order,
  ) async {
    final String? orderId =
        order['id']?.toString();

    if (orderId == null ||
        orderId.isEmpty) {
      return;
    }

    final bool? updated =
        await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) =>
            SellerOrderDetailScreen(
          orderId: orderId,
        ),
      ),
    );

    if (updated == true) {
      await _loadOrders();
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _loadOrders,
          child: CustomScrollView(
            physics:
                const AlwaysScrollableScrollPhysics(
              parent:
                  BouncingScrollPhysics(),
            ),
            slivers: [
              // ==================================================
              // HEADER
              // ==================================================
              SliverToBoxAdapter(
                child: _buildHeader(),
              ),

              // ==================================================
              // SEARCH
              // ==================================================
              SliverToBoxAdapter(
                child: _buildSearch(),
              ),

              // ==================================================
              // FILTERS
              // ==================================================
              SliverToBoxAdapter(
                child: _buildFilters(),
              ),

              // ==================================================
              // RESULT HEADER
              // ==================================================
              if (!_isLoading &&
                  _errorMessage == null)
                SliverToBoxAdapter(
                  child: _buildResultHeader(),
                ),

              // ==================================================
              // CONTENT
              // ==================================================
              if (_isLoading)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildLoadingState(),
                )
              else if (_errorMessage != null)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildErrorState(),
                )
              else if (_filteredOrders.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptyState(),
                )
              else
                SliverPadding(
                  padding:
                      const EdgeInsets.fromLTRB(
                    AppConstants
                        .defaultPadding,
                    0,
                    AppConstants
                        .defaultPadding,
                    30,
                  ),
                  sliver:
                      SliverList.separated(
                    itemCount:
                        _filteredOrders.length,
                    separatorBuilder:
                        (context, index) =>
                            const SizedBox(
                      height: 12,
                    ),
                    itemBuilder:
                        (context, index) {
                      final order =
                          _filteredOrders[
                              index];

                      return SellerOrderCard(
                        order: order,
                        onTap: () =>
                            _openOrder(
                          order,
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.defaultPadding,
        18,
        AppConstants.defaultPadding,
        18,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Orders',
                  style: TextStyle(
                    fontSize: 25,
                    height: 1.05,
                    fontWeight:
                        FontWeight.w900,
                    letterSpacing: -0.7,
                    color:
                        AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  'Manage and fulfill customer orders.',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight:
                        FontWeight.w500,
                    color: AppColors
                        .textSecondary
                        .withValues(
                      alpha: 0.75,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ====================================================
          // ORDER INDICATOR
          //
          // Badge only represents NEW pending orders.
          // ====================================================
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius:
                  BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.border
                    .withValues(
                  alpha: 0.42,
                ),
              ),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Center(
                  child: Icon(
                    Icons
                        .receipt_long_outlined,
                    size: 20,
                    color:
                        AppColors.textPrimary,
                  ),
                ),

                if (_pendingOrderCount > 0)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      constraints:
                          const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 4,
                      ),
                      decoration:
                          BoxDecoration(
                        color:
                            AppColors.primary,
                        borderRadius:
                            BorderRadius
                                .circular(
                          10,
                        ),
                        border: Border.all(
                          color: AppColors
                              .background,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _pendingOrderCount >
                                  99
                              ? '99+'
                              : '$_pendingOrderCount',
                          style:
                              const TextStyle(
                            fontSize: 7.5,
                            height: 1,
                            fontWeight:
                                FontWeight
                                    .w900,
                            color:
                                Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SEARCH
  // ============================================================

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.defaultPadding,
        0,
        AppConstants.defaultPadding,
        14,
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          _searchQuery = value;
          _applyFilters();
        },
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText:
              'Search customer or order...',
          hintStyle: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary
                .withValues(
              alpha: 0.55,
            ),
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            size: 20,
            color: AppColors.textSecondary,
          ),
          suffixIcon:
              _searchQuery.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchController
                            .clear();

                        _searchQuery = '';

                        _applyFilters();
                      },
                      icon: const Icon(
                        Icons.close_rounded,
                        size: 18,
                      ),
                    )
                  : null,
          filled: true,
          fillColor: AppColors.surface,
          contentPadding:
              const EdgeInsets.symmetric(
            vertical: 15,
          ),
          enabledBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(16),
            borderSide: BorderSide(
              color: AppColors.border
                  .withValues(
                alpha: 0.42,
              ),
            ),
          ),
          focusedBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(16),
            borderSide:
                const BorderSide(
              color: AppColors.primary,
              width: 1.3,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // FILTERS
  // ============================================================

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal:
            AppConstants.defaultPadding,
      ),
      child: Row(
        children: _filters.map((filter) {
          final bool selected =
              _selectedFilter ==
                  filter.id;

          final int count =
              _countForFilter(
            filter.id,
          );

          return Expanded(
            child: Padding(
              padding:
                  EdgeInsets.only(
                right:
                    filter != _filters.last
                        ? 8
                        : 0,
              ),
              child: GestureDetector(
                behavior:
                    HitTestBehavior.opaque,
                onTap: () {
                  setState(() {
                    _selectedFilter =
                        filter.id;
                  });

                  _applyFilters();
                },
                child:
                    AnimatedContainer(
                  duration:
                      const Duration(
                    milliseconds: 180,
                  ),
                  height: 42,
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 10,
                  ),
                  decoration:
                      BoxDecoration(
                    color: selected
                        ? AppColors.primary
                        : AppColors.surface,
                    borderRadius:
                        BorderRadius
                            .circular(
                      14,
                    ),
                    border: Border.all(
                      color: selected
                          ? AppColors
                              .primary
                          : AppColors
                              .border
                              .withValues(
                              alpha:
                                  0.45,
                            ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .center,
                    children: [
                      Flexible(
                        child: Text(
                          filter.label,
                          overflow:
                              TextOverflow
                                  .ellipsis,
                          style:
                              TextStyle(
                            fontSize: 10.5,
                            fontWeight:
                                FontWeight
                                    .w800,
                            color: selected
                                ? Colors
                                    .white
                                : AppColors
                                    .textSecondary,
                          ),
                        ),
                      ),

                      const SizedBox(
                        width: 6,
                      ),

                      Container(
                        constraints:
                            const BoxConstraints(
                          minWidth: 20,
                        ),
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 5,
                          vertical: 3,
                        ),
                        decoration:
                            BoxDecoration(
                          color: selected
                              ? Colors.white
                                  .withValues(
                                  alpha:
                                      0.16,
                                )
                              : AppColors
                                  .background,
                          borderRadius:
                              BorderRadius
                                  .circular(
                            20,
                          ),
                        ),
                        child: Text(
                          '$count',
                          textAlign:
                              TextAlign.center,
                          style:
                              TextStyle(
                            fontSize: 8,
                            fontWeight:
                                FontWeight
                                    .w900,
                            color: selected
                                ? Colors
                                    .white
                                : AppColors
                                    .textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ============================================================
  // RESULT HEADER
  // ============================================================

  Widget _buildResultHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.defaultPadding,
        22,
        AppConstants.defaultPadding,
        12,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  _filterTitle(),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight:
                        FontWeight.w900,
                    letterSpacing: -0.25,
                    color:
                        AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  _filterSubtitle(),
                  style: TextStyle(
                    fontSize: 9.5,
                    height: 1.35,
                    fontWeight:
                        FontWeight.w500,
                    color: AppColors
                        .textSecondary
                        .withValues(
                      alpha: 0.70,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          Text(
            '${_filteredOrders.length} '
            '${_filteredOrders.length == 1 ? 'order' : 'orders'}',
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              color: AppColors
                  .textSecondary
                  .withValues(
                alpha: 0.68,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _filterTitle() {
    switch (_selectedFilter) {
      case 'active':
        return 'Active Orders';

      case 'past':
        return 'Past Orders';

      case 'all':
      default:
        return 'All Orders';
    }
  }

  String _filterSubtitle() {
    switch (_selectedFilter) {
      case 'active':
        return 'Orders that still need your attention.';

      case 'past':
        return 'Completed and cancelled orders.';

      case 'all':
      default:
        return 'Every customer order.';
    }
  }

  // ============================================================
  // LOADING
  // ============================================================

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        color: AppColors.primary,
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.all(
        AppConstants.defaultPadding,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: AppColors.error
                    .withValues(
                  alpha: 0.07,
                ),
                borderRadius:
                    BorderRadius.circular(
                  18,
                ),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: AppColors.error,
                size: 27,
              ),
            ),

            const SizedBox(height: 14),

            const Text(
              'Couldn\'t load orders',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              _errorMessage ??
                  'Something went wrong.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10.5,
                color:
                    AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 16),

            OutlinedButton.icon(
              onPressed: _loadOrders,
              icon: const Icon(
                Icons.refresh_rounded,
                size: 17,
              ),
              label: const Text(
                'Try Again',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _buildEmptyState() {
    final bool hasSearch =
        _searchQuery.trim().isNotEmpty;

    late String title;
    late String subtitle;
    late IconData icon;

    if (hasSearch) {
      title = 'No matching orders';
      subtitle =
          'Try another customer name or order number.';
      icon = Icons.search_off_rounded;
    } else {
      switch (_selectedFilter) {
        case 'active':
          title = 'No active orders';
          subtitle =
              'New and ongoing customer orders will appear here.';
          icon = Icons.inbox_outlined;
          break;

        case 'past':
          title = 'No past orders';
          subtitle =
              'Completed and cancelled orders will appear here.';
          icon = Icons.history_rounded;
          break;

        case 'all':
        default:
          title = 'No orders yet';
          subtitle =
              'Customer orders will appear here once they are placed.';
          icon =
              Icons.receipt_long_outlined;
          break;
      }
    }

    return Padding(
      padding: const EdgeInsets.all(
        AppConstants.defaultPadding,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius:
                    BorderRadius.circular(
                  20,
                ),
                border: Border.all(
                  color: AppColors.border
                      .withValues(
                    alpha: 0.40,
                  ),
                ),
              ),
              child: Icon(
                icon,
                size: 28,
                color:
                    AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 15),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight:
                    FontWeight.w900,
                color:
                    AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10.5,
                height: 1.45,
                color: AppColors
                    .textSecondary
                    .withValues(
                  alpha: 0.75,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===================================================================
// FILTER MODEL
// ===================================================================

class _OrderFilter {
  final String id;
  final String label;

  const _OrderFilter({
    required this.id,
    required this.label,
  });
}