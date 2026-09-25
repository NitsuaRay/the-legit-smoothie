import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/app_colors.dart';

import '../widgets/salesScreen/seller_sales_empty_state.dart';
import '../widgets/salesScreen/seller_sales_hero.dart';
import '../widgets/salesScreen/seller_sales_history_card.dart';
import '../widgets/salesScreen/seller_sales_history_header.dart';
import '../widgets/salesScreen/seller_sales_summary_card.dart';
import '../widgets/salesScreen/seller_sales_view_selector.dart';

class SellerSalesScreen extends StatefulWidget {
  const SellerSalesScreen({
    super.key,
  });

  @override
  State<SellerSalesScreen> createState() =>
      _SellerSalesScreenState();
}

class _SellerSalesScreenState
    extends State<SellerSalesScreen> {
  final SupabaseClient _supabase =
      Supabase.instance.client;

  bool _isLoading = true;
  bool _isRefreshing = false;

  String? _errorMessage;

  _SalesView _selectedView =
      _SalesView.daily;

  List<_CompletedSale> _sales = [];

  // =============================================================
  // LIFECYCLE
  // =============================================================

  @override
  void initState() {
    super.initState();
    _loadSales();
  }

  // =============================================================
  // LOAD SALES
  // =============================================================

  Future<void> _loadSales({
    bool refresh = false,
  }) async {
    if (refresh) {
      if (mounted) {
        setState(() {
          _isRefreshing = true;
          _errorMessage = null;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _errorMessage = null;
        });
      }
    }

    try {
      final List<dynamic> response =
          await _supabase
              .from('orders')
              .select(
                '''
                id,
                status,
                total_price,
                created_at,
                order_status_history (
                  status,
                  created_at
                )
                ''',
              )
              .eq(
                'status',
                'completed',
              )
              .order(
                'created_at',
                ascending: false,
              );

      final List<Map<String, dynamic>>
          orders =
          List<Map<String, dynamic>>.from(
        response,
      );

      final List<_CompletedSale>
          completedSales = [];

      for (final Map<String, dynamic>
          order in orders) {
        final DateTime? completedAt =
            _getCompletedAt(order);

        if (completedAt == null) {
          continue;
        }

        final double total =
            (order['total_price'] as num?)
                    ?.toDouble() ??
                0.0;

        completedSales.add(
          _CompletedSale(
            orderId:
                order['id']?.toString() ??
                    '',
            total: total,
            completedAt: completedAt,
          ),
        );
      }

      completedSales.sort(
        (
          _CompletedSale a,
          _CompletedSale b,
        ) {
          return b.completedAt.compareTo(
            a.completedAt,
          );
        },
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _sales = completedSales;
      });
    } on PostgrestException catch (error) {
      debugPrint(
        'Seller sales database error: '
        '${error.message}',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage =
            'Unable to load sales right now.';
      });
    } catch (error, stackTrace) {
      debugPrint(
        'Seller sales error: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage =
            'Something went wrong while '
            'loading sales.';
      });
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
  // COMPLETED DATE
  // =============================================================

  DateTime? _getCompletedAt(
    Map<String, dynamic> order,
  ) {
    final dynamic historyData =
        order['order_status_history'];

    if (historyData is! List) {
      return null;
    }

    DateTime? latestCompletedAt;

    for (final dynamic entry
        in historyData) {
      if (entry is! Map) {
        continue;
      }

      final String status =
          entry['status']
                  ?.toString()
                  .trim()
                  .toLowerCase() ??
              '';

      if (status != 'completed') {
        continue;
      }

      final String? rawDate =
          entry['created_at']?.toString();

      if (rawDate == null ||
          rawDate.isEmpty) {
        continue;
      }

      final DateTime? parsed =
          DateTime.tryParse(rawDate);

      if (parsed == null) {
        continue;
      }

      final DateTime localDate =
          parsed.toLocal();

      if (latestCompletedAt == null ||
          localDate.isAfter(
            latestCompletedAt,
          )) {
        latestCompletedAt = localDate;
      }
    }

    return latestCompletedAt;
  }

  // =============================================================
  // SUMMARY VALUES
  // =============================================================

  double get _todaySales {
    final DateTime now =
        DateTime.now();

    return _sales
        .where(
          (_CompletedSale sale) =>
              _isSameDay(
            sale.completedAt,
            now,
          ),
        )
        .fold<double>(
          0,
          (
            double total,
            _CompletedSale sale,
          ) =>
              total + sale.total,
        );
  }

  int get _todayOrderCount {
    final DateTime now =
        DateTime.now();

    return _sales.where(
      (_CompletedSale sale) {
        return _isSameDay(
          sale.completedAt,
          now,
        );
      },
    ).length;
  }

  double get _monthSales {
    final DateTime now =
        DateTime.now();

    return _sales
        .where(
          (_CompletedSale sale) =>
              sale.completedAt.year ==
                  now.year &&
              sale.completedAt.month ==
                  now.month,
        )
        .fold<double>(
          0,
          (
            double total,
            _CompletedSale sale,
          ) =>
              total + sale.total,
        );
  }

  int get _monthOrderCount {
    final DateTime now =
        DateTime.now();

    return _sales.where(
      (_CompletedSale sale) {
        return sale.completedAt.year ==
                now.year &&
            sale.completedAt.month ==
                now.month;
      },
    ).length;
  }

  double get _allTimeSales {
    return _sales.fold<double>(
      0,
      (
        double total,
        _CompletedSale sale,
      ) =>
          total + sale.total,
    );
  }

  int get _allTimeOrderCount {
    return _sales.length;
  }

  // =============================================================
  // DAILY GROUPS
  // =============================================================

  List<_SalesGroup> get _dailyGroups {
    final Map<String, _MutableSalesGroup>
        groups = {};

    for (final _CompletedSale sale
        in _sales) {
      final DateTime date =
          sale.completedAt;

      final String key =
          '${date.year}-'
          '${date.month.toString().padLeft(2, '0')}-'
          '${date.day.toString().padLeft(2, '0')}';

      final _MutableSalesGroup group =
          groups.putIfAbsent(
        key,
        () => _MutableSalesGroup(
          date: DateTime(
            date.year,
            date.month,
            date.day,
          ),
        ),
      );

      group.total += sale.total;
      group.orderCount++;
    }

    final List<_SalesGroup> result =
        groups.values
            .map(
              (_MutableSalesGroup group) =>
                  _SalesGroup(
                date: group.date,
                total: group.total,
                orderCount:
                    group.orderCount,
              ),
            )
            .toList();

    result.sort(
      (
        _SalesGroup a,
        _SalesGroup b,
      ) =>
          b.date.compareTo(a.date),
    );

    return result;
  }

  // =============================================================
  // MONTHLY GROUPS
  // =============================================================

  List<_SalesGroup> get _monthlyGroups {
    final Map<String, _MutableSalesGroup>
        groups = {};

    for (final _CompletedSale sale
        in _sales) {
      final DateTime date =
          sale.completedAt;

      final String key =
          '${date.year}-'
          '${date.month.toString().padLeft(2, '0')}';

      final _MutableSalesGroup group =
          groups.putIfAbsent(
        key,
        () => _MutableSalesGroup(
          date: DateTime(
            date.year,
            date.month,
          ),
        ),
      );

      group.total += sale.total;
      group.orderCount++;
    }

    final List<_SalesGroup> result =
        groups.values
            .map(
              (_MutableSalesGroup group) =>
                  _SalesGroup(
                date: group.date,
                total: group.total,
                orderCount:
                    group.orderCount,
              ),
            )
            .toList();

    result.sort(
      (
        _SalesGroup a,
        _SalesGroup b,
      ) =>
          b.date.compareTo(a.date),
    );

    return result;
  }

  List<_SalesGroup> get _visibleGroups {
    switch (_selectedView) {
      case _SalesView.daily:
        return _dailyGroups;

      case _SalesView.monthly:
        return _monthlyGroups;
    }
  }

  // =============================================================
  // HELPERS
  // =============================================================

  bool _isSameDay(
    DateTime a,
    DateTime b,
  ) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day;
  }

  String _formatCurrency(
    double amount,
  ) {
    final String fixed =
        amount.toStringAsFixed(2);

    final List<String> parts =
        fixed.split('.');

    final String whole = parts[0];

    final StringBuffer buffer =
        StringBuffer();

    for (
      int i = 0;
      i < whole.length;
      i++
    ) {
      final int remaining =
          whole.length - i;

      buffer.write(whole[i]);

      if (remaining > 1 &&
          remaining % 3 == 1) {
        buffer.write(',');
      }
    }

    return '₱${buffer.toString()}.${parts[1]}';
  }

  String _monthName(int month) {
    const List<String> months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    if (month < 1 ||
        month > 12) {
      return '';
    }

    return months[month - 1];
  }

  String _shortMonthName(
    int month,
  ) {
    const List<String> months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    if (month < 1 ||
        month > 12) {
      return '';
    }

    return months[month - 1];
  }

  String _formatGroupDate(
    DateTime date,
  ) {
    if (_selectedView ==
        _SalesView.monthly) {
      return '${_monthName(date.month)} '
          '${date.year}';
    }

    final DateTime now =
        DateTime.now();

    final DateTime yesterday =
        now.subtract(
      const Duration(days: 1),
    );

    if (_isSameDay(date, now)) {
      return 'Today';
    }

    if (_isSameDay(
      date,
      yesterday,
    )) {
      return 'Yesterday';
    }

    return '${_shortMonthName(date.month)} '
        '${date.day}, ${date.year}';
  }

  // =============================================================
  // BUILD
  // =============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppColors.background,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor:
            AppColors.background,
        surfaceTintColor:
            Colors.transparent,
        leading: Padding(
          padding:
              const EdgeInsets.only(
            left: 12,
          ),
          child: IconButton(
            tooltip: 'Back',
            onPressed: () {
              Navigator.of(context)
                  .pop();
            },
            icon: const Icon(
              Icons
                  .arrow_back_ios_new_rounded,
              size: 18,
              color:
                  AppColors.textPrimary,
            ),
          ),
        ),
        titleSpacing: 8,
        title: const Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Text(
              'Sales',
              style: TextStyle(
                fontSize: 17,
                fontWeight:
                    FontWeight.w900,
                letterSpacing: -0.35,
                color:
                    AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 1),
            Text(
              'Revenue overview',
              style: TextStyle(
                fontSize: 9,
                fontWeight:
                    FontWeight.w600,
                color:
                    AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? _buildLoading()
          : _errorMessage != null
              ? _buildError()
              : _buildContent(),
    );
  }

  // =============================================================
  // CONTENT
  // =============================================================

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: () =>
          _loadSales(refresh: true),
      color: AppColors.textPrimary,
      backgroundColor:
          AppColors.surface,
      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(
          parent:
              BouncingScrollPhysics(),
        ),
        padding:
            const EdgeInsets.fromLTRB(
          18,
          8,
          18,
          35,
        ),
        children: [
          SellerSalesHero(
            salesValue:
                _formatCurrency(
              _todaySales,
            ),
            completedOrders:
                _todayOrderCount,
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child:
                    SellerSalesSummaryCard(
                  eyebrow: 'THIS MONTH',
                  value: _formatCurrency(
                    _monthSales,
                  ),
                  subtitle:
                      '$_monthOrderCount '
                      '${_monthOrderCount == 1 ? 'order' : 'orders'}',
                  icon: Icons
                      .calendar_month_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child:
                    SellerSalesSummaryCard(
                  eyebrow: 'ALL TIME',
                  value: _formatCurrency(
                    _allTimeSales,
                  ),
                  subtitle:
                      '$_allTimeOrderCount '
                      '${_allTimeOrderCount == 1 ? 'order' : 'orders'}',
                  icon: Icons
                      .insights_outlined,
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          SellerSalesHistoryHeader(
            isMonthly:
                _selectedView ==
                    _SalesView.monthly,
          ),

          const SizedBox(height: 14),

          SellerSalesViewSelector(
            isMonthly:
                _selectedView ==
                    _SalesView.monthly,
            onDailyPressed: () {
              setState(() {
                _selectedView =
                    _SalesView.daily;
              });
            },
            onMonthlyPressed: () {
              setState(() {
                _selectedView =
                    _SalesView.monthly;
              });
            },
          ),

          const SizedBox(height: 15),

          if (_visibleGroups.isEmpty)
            const SellerSalesEmptyState()
          else
            ..._visibleGroups.map(
              (_SalesGroup group) =>
                  Padding(
                padding:
                    const EdgeInsets.only(
                  bottom: 10,
                ),
                child:
                    SellerSalesHistoryCard(
                  title:
                      _formatGroupDate(
                    group.date,
                  ),
                  orderCount:
                      group.orderCount,
                  total:
                      _formatCurrency(
                    group.total,
                  ),
                ),
              ),
            ),

          if (_isRefreshing) ...[
            const SizedBox(height: 10),
            const Center(
              child: SizedBox(
                width: 17,
                height: 17,
                child:
                    CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors
                      .textPrimary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // =============================================================
  // LOADING
  // =============================================================

  Widget _buildLoading() {
    return const Center(
      child: SizedBox(
        width: 25,
        height: 25,
        child:
            CircularProgressIndicator(
          strokeWidth: 2.4,
          color:
              AppColors.textPrimary,
        ),
      ),
    );
  }

  // =============================================================
  // ERROR
  // =============================================================

  Widget _buildError() {
    return RefreshIndicator(
      onRefresh: () =>
          _loadSales(refresh: true),
      color: AppColors.textPrimary,
      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding:
            const EdgeInsets.all(30),
        children: [
          const SizedBox(height: 100),

          const Icon(
            Icons
                .error_outline_rounded,
            size: 42,
            color: AppColors.error,
          ),

          const SizedBox(height: 14),

          const Text(
            'Couldn\'t load sales',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight:
                  FontWeight.w900,
              color:
                  AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            _errorMessage ??
                'Something went wrong.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10.5,
              height: 1.4,
              color:
                  AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 18),

          Center(
            child:
                OutlinedButton.icon(
              onPressed: _loadSales,
              icon: const Icon(
                Icons.refresh_rounded,
                size: 17,
              ),
              label: const Text(
                'Try Again',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================
// MODELS
// =============================================================

enum _SalesView {
  daily,
  monthly,
}

class _CompletedSale {
  final String orderId;
  final double total;
  final DateTime completedAt;

  const _CompletedSale({
    required this.orderId,
    required this.total,
    required this.completedAt,
  });
}

class _SalesGroup {
  final DateTime date;
  final double total;
  final int orderCount;

  const _SalesGroup({
    required this.date,
    required this.total,
    required this.orderCount,
  });
}

class _MutableSalesGroup {
  final DateTime date;

  double total = 0;
  int orderCount = 0;

  _MutableSalesGroup({
    required this.date,
  });
}