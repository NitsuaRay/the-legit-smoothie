import 'package:flutter/material.dart';

import 'package:the_legit_smoothie/features/seller/screens/seller_order_detail_screen.dart';
import 'package:the_legit_smoothie/features/seller/widgets/orderDetailScreen/seller_order_card.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../main.dart';


import '../widgets/orderScreen/seller_orders_filter_bar.dart';
import '../widgets/orderScreen/seller_orders_header.dart';
import '../widgets/orderScreen/seller_orders_result_header.dart';
import '../widgets/orderScreen/seller_orders_search.dart';
import '../widgets/orderScreen/seller_orders_state.dart';

class SellerOrdersScreen extends StatefulWidget {
  const SellerOrdersScreen({
    super.key,
  });

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

  String _selectedFilter = 'active';

  // ============================================================
  // FILTERS
  // ============================================================

  static const List<SellerOrderFilter> _filters = [
    SellerOrderFilter(
      id: 'active',
      label: 'Active',
    ),
    SellerOrderFilter(
      id: 'past',
      label: 'Past',
    ),
    SellerOrderFilter(
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

  // ============================================================
  // LIFECYCLE
  // ============================================================

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

      if (!mounted) {
        return;
      }

      setState(() {
        _allOrders = orders;
        _isLoading = false;
      });

      _applyFilters();
    } catch (error) {
      debugPrint(
        'Seller orders load error: $error',
      );

      if (!mounted) {
        return;
      }

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

      final bool matchesSearch =
          query.isEmpty ||
          customerName.contains(query) ||
          orderId.contains(query) ||
          orderType.contains(query) ||
          status.contains(query);

      return matchesStatus &&
          matchesSearch;
    }).toList();

    // Active orders are operationally sorted:
    // pending -> accepted -> preparing ->
    // ready / delivery.
    if (_selectedFilter == 'active') {
      filtered.sort(
        _compareActiveOrders,
      );
    }

    if (!mounted) {
      return;
    }

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

    if (priorityA != priorityB) {
      return priorityA.compareTo(
        priorityB,
      );
    }

    final DateTime? dateA =
        DateTime.tryParse(
      a['created_at']?.toString() ?? '',
    );

    final DateTime? dateB =
        DateTime.tryParse(
      b['created_at']?.toString() ?? '',
    );

    if (dateA == null &&
        dateB == null) {
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

  int _activePriority(
    String status,
  ) {
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

  int _countForFilter(
    String filter,
  ) {
    switch (filter) {
      case 'active':
        return _allOrders.where(
          (order) {
            final String status =
                order['status']
                        ?.toString()
                        .toLowerCase() ??
                    '';

            return _activeStatuses.contains(
              status,
            );
          },
        ).length;

      case 'past':
        return _allOrders.where(
          (order) {
            final String status =
                order['status']
                        ?.toString()
                        .toLowerCase() ??
                    '';

            return _pastStatuses.contains(
              status,
            );
          },
        ).length;

      case 'all':
      default:
        return _allOrders.length;
    }
  }

  int get _pendingOrderCount {
    return _allOrders.where(
      (order) {
        final String status =
            order['status']
                    ?.toString()
                    .toLowerCase() ??
                '';

        return status == 'pending';
      },
    ).length;
  }

  // ============================================================
  // FILTER LABELS
  // ============================================================

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
  // SEARCH
  // ============================================================

  void _handleSearchChanged(
    String value,
  ) {
    _searchQuery = value;

    _applyFilters();
  }

  void _clearSearch() {
    _searchController.clear();

    _searchQuery = '';

    _applyFilters();
  }

  // ============================================================
  // FILTER CHANGE
  // ============================================================

  void _changeFilter(
    String filterId,
  ) {
    if (_selectedFilter == filterId) {
      return;
    }

    setState(() {
      _selectedFilter = filterId;
    });

    _applyFilters();
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
      backgroundColor:
          AppColors.background,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.textPrimary,
          onRefresh: _loadOrders,
          child: CustomScrollView(
            physics:
                const AlwaysScrollableScrollPhysics(
              parent:
                  BouncingScrollPhysics(),
            ),
            slivers: [
              // =================================================
              // HEADER
              // =================================================

              SliverToBoxAdapter(
                child: SellerOrdersHeader(
                  pendingOrderCount:
                      _pendingOrderCount,
                ),
              ),

              // =================================================
              // SEARCH
              // =================================================

              SliverToBoxAdapter(
                child: SellerOrdersSearch(
                  controller:
                      _searchController,
                  searchQuery:
                      _searchQuery,
                  onChanged:
                      _handleSearchChanged,
                  onClear:
                      _clearSearch,
                ),
              ),

              // =================================================
              // FILTERS
              // =================================================

              SliverToBoxAdapter(
                child:
                    SellerOrdersFilterBar(
                  filters: _filters,
                  selectedFilter:
                      _selectedFilter,
                  countForFilter:
                      _countForFilter,
                  onChanged:
                      _changeFilter,
                ),
              ),

              // =================================================
              // RESULT HEADER
              // =================================================

              if (!_isLoading &&
                  _errorMessage == null)
                SliverToBoxAdapter(
                  child:
                      SellerOrdersResultHeader(
                    title:
                        _filterTitle(),
                    subtitle:
                        _filterSubtitle(),
                    orderCount:
                        _filteredOrders
                            .length,
                  ),
                ),

              // =================================================
              // CONTENT
              // =================================================

              if (_isLoading)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child:
                      SellerOrdersLoadingState(),
                )
              else if (_errorMessage != null)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child:
                      SellerOrdersErrorState(
                    message:
                        _errorMessage!,
                    onRetry:
                        _loadOrders,
                  ),
                )
              else if (_filteredOrders.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child:
                      SellerOrdersEmptyState(
                    hasSearch:
                        _searchQuery
                            .trim()
                            .isNotEmpty,
                    selectedFilter:
                        _selectedFilter,
                  ),
                )
              else
                SliverPadding(
                  padding:
                      const EdgeInsets
                          .fromLTRB(
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
                        _filteredOrders
                            .length,
                    separatorBuilder:
                        (
                      context,
                      index,
                    ) =>
                            const SizedBox(
                      height: 12,
                    ),
                    itemBuilder:
                        (
                      context,
                      index,
                    ) {
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
}