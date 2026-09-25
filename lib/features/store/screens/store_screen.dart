import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';

import '../../promotions/screens/promotion_detail_screen.dart';

import '../widgets/store_benefits.dart';
import '../widgets/store_featured_deals.dart';
import '../widgets/store_header.dart';
import '../widgets/store_hero.dart';
import '../widgets/store_information_card.dart';
import '../widgets/store_section_header.dart';

class StoreScreen extends StatefulWidget {
  final VoidCallback onBrowseMenu;

  const StoreScreen({super.key, required this.onBrowseMenu});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;

  // =============================================================
  // STORE STATUS
  // =============================================================

  bool _isStoreOpen = false;
  bool _isLoadingStoreStatus = true;

  RealtimeChannel? _storeStatusChannel;

  // =============================================================
  // STORE INFORMATION
  // =============================================================

  String? _storeAddress;

  // =============================================================
  // PROMOTIONS
  // =============================================================

  bool _isLoadingPromotions = true;

  List<Map<String, dynamic>> _promotions = [];

  // =============================================================
  // LIFECYCLE
  // =============================================================

  @override
  void initState() {
    super.initState();

    _loadInitialData();
    _subscribeToStoreStatus();
  }

  @override
  void dispose() {
    if (_storeStatusChannel != null) {
      _supabase.removeChannel(_storeStatusChannel!);
    }

    super.dispose();
  }

  // =============================================================
  // INITIAL DATA
  // =============================================================

  Future<void> _loadInitialData() async {
    await Future.wait([
      _loadStoreStatus(),
      _loadStoreAddress(),
      _loadPromotions(),
    ]);
  }

  // =============================================================
  // REFRESH`
  // =============================================================
  Future<void> _refresh() async {
    await Future.wait([
      _loadStoreStatus(showLoading: false),
      _loadStoreAddress(),
      _loadPromotions(showLoading: false),
    ]);
  }
  // =============================================================
  // STORE STATUS
  // =============================================================

  Future<void> _loadStoreStatus({bool showLoading = true}) async {
    if (showLoading && mounted) {
      setState(() {
        _isLoadingStoreStatus = true;
      });
    }

    try {
      final Map<String, dynamic>? data = await _supabase
          .from('store_settings')
          .select('is_open')
          .eq('id', 1)
          .maybeSingle();

      if (!mounted) {
        return;
      }

      setState(() {
        _isStoreOpen = data?['is_open'] == true;

        _isLoadingStoreStatus = false;
      });
    } catch (error) {
      debugPrint('Unable to load store status: $error');

      if (!mounted) {
        return;
      }

      setState(() {
        _isStoreOpen = false;
        _isLoadingStoreStatus = false;
      });
    }
  }

  // =============================================================
  // STORE ADDRESS
  // =============================================================

  Future<void> _loadStoreAddress() async {
    try {
      final Map<String, dynamic>? seller = await _supabase
          .from('profiles')
          .select('id, full_name, default_address')
          .eq('role', 'seller')
          .limit(1)
          .maybeSingle();

      if (!mounted) {
        return;
      }

      final String address =
          seller?['default_address']?.toString().trim() ?? '';

      debugPrint('STORE SELLER: $seller');

      debugPrint('STORE ADDRESS: $address');

      setState(() {
        _storeAddress = address.isEmpty ? null : address;
      });
    } on PostgrestException catch (error) {
      debugPrint(
        'Unable to load store address: '
        '${error.message}',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _storeAddress = null;
      });
    } catch (error) {
      debugPrint('Unable to load store address: $error');

      if (!mounted) {
        return;
      }

      setState(() {
        _storeAddress = null;
      });
    }
  }
  // =============================================================
  // OPEN STORE MAP
  // =============================================================

  // =============================================================
  // OPEN STORE MAP
  // =============================================================

  Future<void> _openStoreMap() async {
    final String address = _storeAddress?.trim() ?? '';

    if (address.isEmpty) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Store location is not available yet.')),
        );

      return;
    }

    final String encodedAddress = Uri.encodeComponent(address);

    final Uri mapUri = Uri.parse(
      'https://www.google.com/maps/search/?api=1'
      '&query=$encodedAddress',
    );

    try {
      final bool launched = await launchUrl(
        mapUri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && mounted) {
        _showMapError();
      }
    } catch (error) {
      debugPrint('Unable to open store map: $error');

      if (mounted) {
        _showMapError();
      }
    }
  }

  void _showMapError() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Unable to open the store location.')),
      );
  }
  // =============================================================
  // REALTIME STORE STATUS
  // =============================================================

  void _subscribeToStoreStatus() {
    _storeStatusChannel = _supabase
        .channel('customer-store-screen-status')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'store_settings',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: 1,
          ),
          callback: (payload) {
            final Map<String, dynamic> newRecord = payload.newRecord;

            final bool newStatus = newRecord['is_open'] == true;

            if (!mounted) {
              return;
            }

            setState(() {
              _isStoreOpen = newStatus;
              _isLoadingStoreStatus = false;
            });
          },
        )
        .subscribe();
  }

  // =============================================================
  // LOAD PROMOTIONS
  // =============================================================

  Future<void> _loadPromotions({bool showLoading = true}) async {
    if (showLoading && mounted) {
      setState(() {
        _isLoadingPromotions = true;
      });
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

      if (!mounted) {
        return;
      }

      setState(() {
        _promotions = loaded;
        _isLoadingPromotions = false;
      });
    } on PostgrestException catch (error) {
      debugPrint(
        'Unable to load promotions: '
        '${error.message}',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _promotions = [];
        _isLoadingPromotions = false;
      });
    } catch (error) {
      debugPrint('Unable to load promotions: $error');

      if (!mounted) {
        return;
      }

      setState(() {
        _promotions = [];
        _isLoadingPromotions = false;
      });
    }
  }

  // =============================================================
  // ACTIVE PROMOTION
  // =============================================================

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

  // =============================================================
  // FEATURED PROMOTIONS
  // =============================================================

  List<Map<String, dynamic>> get _featuredPromotions {
    return _promotions.where(_isCurrentlyActive).take(3).toList();
  }

  // =============================================================
  // OPEN PROMOTION
  // =============================================================

  void _openPromotion(Map<String, dynamic> promotion) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PromotionDetailScreen(promotion: promotion),
      ),
    );
  }

  // =============================================================
  // BUILD
  // =============================================================

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> featuredPromotions = _featuredPromotions;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.textPrimary,
          backgroundColor: AppColors.surface,
          onRefresh: _refresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              // =================================================
              // HEADER
              // =================================================
              SliverToBoxAdapter(
                child: StoreHeader(
                  isStoreOpen: _isStoreOpen,
                  isLoading: _isLoadingStoreStatus,
                ),
              ),

              // =================================================
              // HERO
              // =================================================
              SliverToBoxAdapter(
                child: StoreHero(
                  isStoreOpen: _isStoreOpen,
                  isLoading: _isLoadingStoreStatus,
                  onBrowseMenu: widget.onBrowseMenu,
                ),
              ),

              // =================================================
              // FEATURED DEALS
              // =================================================
              const SliverToBoxAdapter(
                child: StoreSectionHeader(
                  eyebrow: 'SPECIAL OFFERS',
                  title: 'Featured Deals',
                  description:
                      'Fresh offers and exclusive deals selected for you.',
                ),
              ),

              SliverToBoxAdapter(
                child: StoreFeaturedDeals(
                  promotions: featuredPromotions,
                  isLoading: _isLoadingPromotions,
                  onPromotionTap: _openPromotion,
                ),
              ),

              // =================================================
              // BENEFITS
              // =================================================
              const SliverToBoxAdapter(
                child: StoreSectionHeader(
                  eyebrow: 'THE LEGIT EXPERIENCE',
                  title: 'Why choose us?',
                  description: 'Made fresh, made simple, and made for you.',
                ),
              ),

              const SliverToBoxAdapter(
                child: IntrinsicHeight(child: StoreBenefits()),
              ),

              // =================================================
              // STORE INFORMATION
              // =================================================
              const SliverToBoxAdapter(
                child: StoreSectionHeader(
                  eyebrow: 'VISIT US',
                  title: 'Store Information',
                  description:
                      'Everything you need to know before placing your order.',
                ),
              ),

              SliverToBoxAdapter(
                child: StoreInformationCard(
                  storeAddress: _storeAddress,
                  onViewMap: _openStoreMap,
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 34)),
            ],
          ),
        ),
      ),
    );
  }
}
