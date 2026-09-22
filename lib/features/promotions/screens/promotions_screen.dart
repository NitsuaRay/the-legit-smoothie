import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:the_legit_smoothie/features/promotions/screens/promotion_detail_screen.dart';

import '../../../core/constants/app_colors.dart';

import '../widgets/promoScreen/customer_promo_card.dart';
import '../widgets/promoScreen/customer_promo_empty_state.dart';
import '../widgets/promoScreen/customer_promo_filters.dart';
import '../widgets/promoScreen/customer_promo_header.dart';
import '../widgets/promoScreen/customer_promo_hero.dart';
import '../widgets/promoScreen/customer_promo_loading.dart';
import '../widgets/promoScreen/customer_promo_search.dart';

class PromotionsScreen extends StatefulWidget {
  const PromotionsScreen({super.key});

  @override
  State<PromotionsScreen> createState() => _PromotionsScreenState();
}

class _PromotionsScreenState extends State<PromotionsScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;

  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  bool _isRefreshing = false;

  String _searchQuery = '';
  String _selectedFilter = 'all';

  List<Map<String, dynamic>> _promotions = [];

  // ==============================================================
  // INIT
  // ==============================================================

  @override
  void initState() {
    super.initState();

    _loadPromotions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ==============================================================
  // LOAD PROMOTIONS
  // ==============================================================

  Future<void> _loadPromotions({bool refresh = false}) async {
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
      final dynamic response = await _supabase
          .from('promotions')
          .select('''
            *,
            promotion_categories (
              category_id,
              categories (
                id,
                name
              )
            ),
            promotion_products (
              product_id,
              products (
                id,
                name,
                image_url,
                base_price
              )
            ),
            promotion_groups (
              id,
              name,
              required_quantity,
              sort_order,
              promotion_group_categories (
                category_id,
                categories (
                  id,
                  name
                )
              ),
              promotion_group_products (
                product_id,
                products (
                  id,
                  name,
                  image_url,
                  base_price
                )
              )
            )
          ''')
          .eq('is_active', true)
          .order('created_at', ascending: false);

      final List<Map<String, dynamic>> loaded = List<Map<String, dynamic>>.from(
        response as List,
      );

      if (!mounted) return;

      setState(() {
        _promotions = loaded;
      });
    } on PostgrestException {

      if (!mounted) return;

      _showMessage('Unable to load promotions right now.', error: true);
    } catch (error) {

      if (!mounted) return;

      _showMessage('Unable to load promotions right now.', error: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
        });
      }
    }
  }

  // ==============================================================
  // ACTIVE / UPCOMING
  // ==============================================================

  bool _isCurrentlyActive(Map<String, dynamic> promotion) {
    if (promotion['is_active'] != true) {
      return false;
    }

    final DateTime now = DateTime.now().toUtc();

    final DateTime? startsAt = DateTime.tryParse(
      promotion['starts_at']?.toString() ?? '',
    )?.toUtc();

    final DateTime? validUntil = DateTime.tryParse(
      promotion['valid_until']?.toString() ?? '',
    )?.toUtc();

    if (startsAt != null && now.isBefore(startsAt)) {
      return false;
    }

    if (validUntil != null && now.isAfter(validUntil)) {
      return false;
    }

    return true;
  }

  bool _isUpcoming(Map<String, dynamic> promotion) {
    if (promotion['is_active'] != true) {
      return false;
    }

    final DateTime? startsAt = DateTime.tryParse(
      promotion['starts_at']?.toString() ?? '',
    )?.toUtc();

    if (startsAt == null) {
      return false;
    }

    return DateTime.now().toUtc().isBefore(startsAt);
  }

  // ==============================================================
  // SEARCH TEXT
  // ==============================================================

  String _promotionSearchText(Map<String, dynamic> promotion) {
    final List<String> values = [
      promotion['title']?.toString() ?? '',
      promotion['description']?.toString() ?? '',
      promotion['discount_tag']?.toString() ?? '',
      promotion['promotion_type']?.toString() ?? '',
      promotion['discount_type']?.toString() ?? '',
      promotion['applies_to']?.toString() ?? '',
    ];

    final dynamic categories = promotion['promotion_categories'];

    if (categories is List) {
      for (final dynamic row in categories) {
        if (row is Map) {
          final dynamic category = row['categories'];

          if (category is Map) {
            values.add(category['name']?.toString() ?? '');
          }
        }
      }
    }

    final dynamic products = promotion['promotion_products'];

    if (products is List) {
      for (final dynamic row in products) {
        if (row is Map) {
          final dynamic product = row['products'];

          if (product is Map) {
            values.add(product['name']?.toString() ?? '');
          }
        }
      }
    }

    final dynamic groups = promotion['promotion_groups'];

    if (groups is List) {
      for (final dynamic rawGroup in groups) {
        if (rawGroup is! Map) continue;

        values.add(rawGroup['name']?.toString() ?? '');

        final dynamic groupCategories = rawGroup['promotion_group_categories'];

        if (groupCategories is List) {
          for (final dynamic row in groupCategories) {
            if (row is Map) {
              final dynamic category = row['categories'];

              if (category is Map) {
                values.add(category['name']?.toString() ?? '');
              }
            }
          }
        }

        final dynamic groupProducts = rawGroup['promotion_group_products'];

        if (groupProducts is List) {
          for (final dynamic row in groupProducts) {
            if (row is Map) {
              final dynamic product = row['products'];

              if (product is Map) {
                values.add(product['name']?.toString() ?? '');
              }
            }
          }
        }
      }
    }

    return values.join(' ').toLowerCase();
  }

  // ==============================================================
  // FILTER
  // ==============================================================

  List<Map<String, dynamic>> get _filteredPromotions {
    Iterable<Map<String, dynamic>> results = _promotions;

    if (_selectedFilter == 'active') {
      results = results.where(_isCurrentlyActive);
    } else if (_selectedFilter == 'upcoming') {
      results = results.where(_isUpcoming);
    }

    final String query = _searchQuery.trim().toLowerCase();

    if (query.isNotEmpty) {
      results = results.where(
        (promotion) => _promotionSearchText(promotion).contains(query),
      );
    }

    return results.toList();
  }

  List<Map<String, dynamic>> get _featuredPromotions {
    return _promotions.where(_isCurrentlyActive).take(5).toList();
  }

  // ==============================================================
  // SEARCH
  // ==============================================================

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
    });
  }

  void _clearSearch() {
    _searchController.clear();

    setState(() {
      _searchQuery = '';
    });
  }

  // ==============================================================
  // FILTER
  // ==============================================================

  void _selectFilter(String filter) {
    if (_selectedFilter == filter) {
      return;
    }

    setState(() {
      _selectedFilter = filter;
    });
  }

  // ==============================================================
  // MESSAGE
  // ==============================================================

  void _showMessage(String message, {bool error = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          backgroundColor: error ? AppColors.error : AppColors.textPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
  }

  // ==============================================================
  // BUILD
  // ==============================================================

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> filtered = _filteredPromotions;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.textPrimary,
          backgroundColor: AppColors.surface,
          onRefresh: () => _loadPromotions(refresh: true),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              // ====================================================
              // HEADER
              // ====================================================
              const SliverToBoxAdapter(child: CustomerPromoHeader()),

              // ====================================================
              // FEATURED
              // ====================================================
              if (!_isLoading && _featuredPromotions.isNotEmpty)
                SliverToBoxAdapter(
                  child: CustomerPromoHero(promotions: _featuredPromotions),
                ),

              // ====================================================
              // SEARCH
              // ====================================================
              SliverToBoxAdapter(
                child: CustomerPromoSearch(
                  controller: _searchController,
                  searchQuery: _searchQuery,
                  onChanged: _onSearchChanged,
                  onClear: _clearSearch,
                ),
              ),

              // ====================================================
              // FILTERS
              // ====================================================
              SliverToBoxAdapter(
                child: CustomerPromoFilters(
                  selectedFilter: _selectedFilter,
                  onSelected: _selectFilter,
                ),
              ),

              // ====================================================
              // SECTION TITLE
              // ====================================================
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 19, 18, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedFilter == 'upcoming'
                                  ? 'COMING SOON'
                                  : 'AVAILABLE DEALS',
                              style: TextStyle(
                                fontSize: 7,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.1,
                                color: AppColors.textSecondary.withValues(
                                  alpha: 0.50,
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              _selectedFilter == 'upcoming'
                                  ? 'Upcoming offers'
                                  : 'Deals for you',
                              style: const TextStyle(
                                fontSize: 18,
                                height: 1,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.4,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (!_isLoading)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: AppColors.border.withValues(alpha: 0.30),
                            ),
                          ),
                          child: Text(
                            '${filtered.length}',
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // ====================================================
              // CONTENT
              // ====================================================
              if (_isLoading)
                const SliverToBoxAdapter(child: CustomerPromoLoading())
              else if (filtered.isEmpty)
                SliverToBoxAdapter(
                  child: CustomerPromoEmptyState(
                    hasSearch: _searchQuery.trim().isNotEmpty,
                    onClearSearch: _clearSearch,
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 32),
                  sliver: SliverList.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 13),
                    itemBuilder: (context, index) {
                      final Map<String, dynamic> promotion = filtered[index];

                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  PromotionDetailScreen(promotion: promotion),
                            ),
                          );
                        },
                        child: CustomerPromoCard(promotion: promotion),
                      );
                    },
                  ),
                ),

              if (_isRefreshing)
                const SliverToBoxAdapter(child: SizedBox.shrink()),
            ],
          ),
        ),
      ),
    );
  }
}
