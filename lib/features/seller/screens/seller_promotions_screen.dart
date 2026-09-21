import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:the_legit_smoothie/features/seller/screens/seller_edit_promotion_screen.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';

import 'seller_add_promotion_screen.dart';

import '../widgets/promoScreen/seller_promo_card.dart';
import '../widgets/promoScreen/seller_promo_empty_state.dart';
import '../widgets/promoScreen/seller_promo_filters.dart';
import '../widgets/promoScreen/seller_promo_header.dart';
import '../widgets/promoScreen/seller_promo_search.dart';

class SellerPromotionsScreen extends StatefulWidget {
  const SellerPromotionsScreen({super.key});

  @override
  State<SellerPromotionsScreen> createState() => _SellerPromotionsScreenState();
}

class _SellerPromotionsScreenState extends State<SellerPromotionsScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;

  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  bool _isRefreshing = false;

  String _searchQuery = '';
  String _selectedFilter = 'active';

  List<Map<String, dynamic>> _promotions = [];
  List<Map<String, dynamic>> _filteredPromotions = [];

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

  Future<void> _loadPromotions({bool refresh = false}) async {
    if (mounted) {
      setState(() {
        if (refresh) {
          _isRefreshing = true;
        } else {
          _isLoading = true;
        }
      });
    }

    try {
      final response = await _supabase
          .from('promotions')
          .select('''
            id,
            title,
            description,
            discount_tag,
            banner_url,
            promotion_type,
            discount_type,
            discount_value,
            applies_to,
            discount_options,
            minimum_order_amount,
            minimum_quantity,
            starts_at,
            valid_until,
            is_active,
            created_at,
            updated_at,

            promotion_categories (
              category_id,
              category:categories (
                id,
                name
              )
            ),

            promotion_products (
              product_id,
              product:products (
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
                category:categories (
                  id,
                  name
                )
              ),

              promotion_group_products (
                product_id,
                product:products (
                  id,
                  name,
                  image_url,
                  base_price
                )
              )
            )
          ''')
          .order('created_at', ascending: false);

      final promotions = List<Map<String, dynamic>>.from(response);

      /*
       * Supabase does not guarantee the nested
       * promotion_groups relation uses sort_order
       * unless explicitly requested on that relation,
       * so sort it locally.
       */
      for (final promotion in promotions) {
        final dynamic rawGroups = promotion['promotion_groups'];

        if (rawGroups is List) {
          rawGroups.sort((a, b) {
            if (a is! Map || b is! Map) {
              return 0;
            }

            final int aOrder = (a['sort_order'] as num?)?.toInt() ?? 0;

            final int bOrder = (b['sort_order'] as num?)?.toInt() ?? 0;

            return aOrder.compareTo(bOrder);
          });
        }
      }

      if (!mounted) return;

      setState(() {
        _promotions = promotions;
      });

      _applyFilters();
    } on PostgrestException catch (error) {
      debugPrint('LOAD PROMOTIONS POSTGREST ERROR');
      debugPrint('Code: ${error.code}');
      debugPrint('Message: ${error.message}');
      debugPrint('Details: ${error.details}');
      debugPrint('Hint: ${error.hint}');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to load promotions: ${error.message}'),
          backgroundColor: AppColors.error,
        ),
      );
    } catch (error) {
      debugPrint('Load promotions error: $error');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to load promotions.'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
        });
      }
    }
  }

  String _promotionStatus(Map<String, dynamic> promotion) {
    if (promotion['is_active'] != true) {
      return 'disabled';
    }

    final DateTime now = DateTime.now();

    final DateTime? startsAt = DateTime.tryParse(
      promotion['starts_at']?.toString() ?? '',
    )?.toLocal();

    final DateTime? validUntil = DateTime.tryParse(
      promotion['valid_until']?.toString() ?? '',
    )?.toLocal();

    if (startsAt != null && now.isBefore(startsAt)) {
      return 'upcoming';
    }

    if (validUntil != null && now.isAfter(validUntil)) {
      return 'expired';
    }

    return 'active';
  }

  void _applyFilters() {
    List<Map<String, dynamic>> results = List<Map<String, dynamic>>.from(
      _promotions,
    );

    if (_selectedFilter != 'all') {
      results = results.where((promotion) {
        return _promotionStatus(promotion) == _selectedFilter;
      }).toList();
    }

    final String query = _searchQuery.trim().toLowerCase();

    if (query.isNotEmpty) {
      results = results.where((promotion) {
        return _searchableText(promotion).contains(query);
      }).toList();
    }

    if (!mounted) return;

    setState(() {
      _filteredPromotions = results;
    });
  }

  String _searchableText(Map<String, dynamic> promotion) {
    final buffer = StringBuffer();

    buffer.write('${promotion['title'] ?? ''} ');

    buffer.write('${promotion['description'] ?? ''} ');

    buffer.write('${promotion['discount_tag'] ?? ''} ');

    buffer.write('${promotion['promotion_type'] ?? ''} ');

    final dynamic categories = promotion['promotion_categories'];

    if (categories is List) {
      for (final item in categories) {
        if (item is Map) {
          final dynamic category = item['category'];

          if (category is Map) {
            buffer.write('${category['name'] ?? ''} ');
          }
        }
      }
    }

    final dynamic products = promotion['promotion_products'];

    if (products is List) {
      for (final item in products) {
        if (item is Map) {
          final dynamic product = item['product'];

          if (product is Map) {
            buffer.write('${product['name'] ?? ''} ');
          }
        }
      }
    }

    final dynamic groups = promotion['promotion_groups'];

    if (groups is List) {
      for (final group in groups) {
        if (group is! Map) continue;

        buffer.write('${group['name'] ?? ''} ');

        final dynamic groupCategories = group['promotion_group_categories'];

        if (groupCategories is List) {
          for (final item in groupCategories) {
            if (item is Map && item['category'] is Map) {
              buffer.write('${item['category']['name'] ?? ''} ');
            }
          }
        }

        final dynamic groupProducts = group['promotion_group_products'];

        if (groupProducts is List) {
          for (final item in groupProducts) {
            if (item is Map && item['product'] is Map) {
              buffer.write('${item['product']['name'] ?? ''} ');
            }
          }
        }
      }
    }

    return buffer.toString().toLowerCase();
  }

  int _countStatus(String status) {
    return _promotions.where((promotion) {
      return _promotionStatus(promotion) == status;
    }).length;
  }

  int get _activeCount => _countStatus('active');

  int get _upcomingCount => _countStatus('upcoming');

  int get _expiredCount => _countStatus('expired');

  void _handleSearch(String value) {
    _searchQuery = value;
    _applyFilters();
  }

  void _clearSearch() {
    _searchController.clear();
    _searchQuery = '';
    _applyFilters();
  }

  void _changeFilter(String filter) {
    if (_selectedFilter == filter) {
      return;
    }

    _selectedFilter = filter;
    _applyFilters();
  }

  Future<void> _openAddPromotion() async {
    final bool? created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const SellerAddPromotionScreen()),
    );

    if (created == true && mounted) {
      await _loadPromotions(refresh: true);
    }
  }

  Future<void> _refresh() {
    return _loadPromotions(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          color: AppColors.textPrimary,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppConstants.defaultPadding,
                    18,
                    AppConstants.defaultPadding,
                    0,
                  ),
                  child: SellerPromoHeader(
                    isRefreshing: _isRefreshing,
                    onRefresh: _refresh,
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppConstants.defaultPadding,
                    24,
                    AppConstants.defaultPadding,
                    0,
                  ),
                  child: SellerPromoSearch(
                    controller: _searchController,
                    query: _searchQuery,
                    onChanged: _handleSearch,
                    onClear: _clearSearch,
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppConstants.defaultPadding,
                    14,
                    0,
                    0,
                  ),
                  child: SellerPromoFilters(
                    selected: _selectedFilter,
                    allCount: _promotions.length,
                    activeCount: _activeCount,
                    upcomingCount: _upcomingCount,
                    expiredCount: _expiredCount,
                    onChanged: _changeFilter,
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppConstants.defaultPadding,
                    25,
                    AppConstants.defaultPadding,
                    12,
                  ),
                  child: _buildResultHeader(),
                ),
              ),

              if (_isLoading)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.textPrimary,
                    ),
                  ),
                )
              else if (_filteredPromotions.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: SellerPromoEmptyState(
                    searching:
                        _searchQuery.isNotEmpty || _selectedFilter != 'all',
                    onCreate: _openAddPromotion,
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppConstants.defaultPadding,
                    0,
                    AppConstants.defaultPadding,
                    120,
                  ),
                  sliver: SliverList.separated(
                    itemCount: _filteredPromotions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final promotion = _filteredPromotions[index];

                      return SellerPromoCard(
                        promotion: promotion,
                        status: _promotionStatus(promotion),
                        onTap: () {
                          _openPromotion(promotion);
                        },
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

  Widget _buildResultHeader() {
    final String label = switch (_selectedFilter) {
      'active' => 'ACTIVE PROMOTIONS',
      'upcoming' => 'UPCOMING PROMOTIONS',
      'expired' => 'EXPIRED PROMOTIONS',
      _ => 'ALL PROMOTIONS',
    };

    return Row(
      children: [
        Expanded(
          child: Text(
            '${_filteredPromotions.length} $label',
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
              color: AppColors.textSecondary.withValues(alpha: 0.65),
            ),
          ),
        ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _openAddPromotion,
            borderRadius: BorderRadius.circular(12),
            child: Ink(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.textPrimary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.add_rounded, size: 15, color: Colors.white),
                  SizedBox(width: 4),
                  Text(
                    'Add',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openPromotion(Map<String, dynamic> promotion) async {
    final String? promotionId = promotion['id']?.toString();

    if (promotionId == null || promotionId.isEmpty) {
      return;
    }

    final bool? changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => SellerEditPromotionScreen(promotionId: promotionId),
      ),
    );

    if (changed == true && mounted) {
      await _loadPromotions(refresh: true);
    }
  }
}
