import 'package:flutter/material.dart';

import 'package:the_legit_smoothie/widgets/category_selector_widget.dart';
import 'package:the_legit_smoothie/widgets/search_bar_widget.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../main.dart';

import '../models/category_model.dart';
import '../models/product_model.dart';
import '../widgets/product_card.dart';
import 'product_detail_modal.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  List<CategoryModel> _categories = [];
  List<ProductModel> _allProducts = [];
  List<ProductModel> _filteredProducts = [];

  String? _selectedCategoryId;
  String _searchQuery = '';

  bool _isLoading = true;

  // =============================================================
  // LIFECYCLE
  // =============================================================

  @override
  void initState() {
    super.initState();
    _fetchCatalogData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // =============================================================
  // FETCH CATALOG
  // =============================================================

  Future<void> _fetchCatalogData() async {
    try {
      final categoryRes = await supabase
          .from('categories')
          .select()
          .order(
            'display_order',
            ascending: true,
          );

      final categories = (categoryRes as List)
          .map(
            (item) =>
                CategoryModel.fromJson(item),
          )
          .toList();

      final productRes = await supabase
          .from('products')
          .select()
          .eq('is_available', true);

      final products = (productRes as List)
          .map(
            (item) =>
                ProductModel.fromJson(item),
          )
          .toList();

      if (!mounted) return;

      setState(() {
        _categories = categories;
        _allProducts = products;
        _isLoading = false;
      });

      _applyFilters();
    } catch (error) {
      debugPrint(
        'HOME CATALOG ERROR: $error',
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  // =============================================================
  // FILTER
  // =============================================================

  void _applyFilters() {
    if (!mounted) return;

    setState(() {
      _filteredProducts =
          _allProducts.where((product) {
        final bool matchesCategory =
            _selectedCategoryId == null ||
                product.categoryId ==
                    _selectedCategoryId;

        final bool matchesSearch =
            _searchQuery.isEmpty ||
                product.name
                    .toLowerCase()
                    .contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                (product.description != null &&
                    product.description!
                        .toLowerCase()
                        .contains(
                          _searchQuery
                              .toLowerCase(),
                        ));

        return matchesCategory &&
            matchesSearch;
      }).toList();
    });
  }

  // =============================================================
  // BUILD
  // =============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: _isLoading
            ? const Center(
                child:
                    CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color:
                      AppColors.textPrimary,
                ),
              )
            : RefreshIndicator(
                color:
                    AppColors.textPrimary,
                onRefresh:
                    _fetchCatalogData,
                child: CustomScrollView(
                  physics:
                      const AlwaysScrollableScrollPhysics(
                    parent:
                        BouncingScrollPhysics(),
                  ),
                  slivers: [
                    // =============================================
                    // CUSTOMER HOME HEADER
                    // =============================================

                    SliverToBoxAdapter(
                      child: _buildHeader(),
                    ),

                    // =============================================
                    // SEARCH
                    // =============================================

                    SliverToBoxAdapter(
                      child: Padding(
                        padding:
                            const EdgeInsets.only(
                          top: 4,
                        ),
                        child: SearchBarWidget(
                          controller:
                              _searchController,
                          searchQuery:
                              _searchQuery,
                          onChanged: (value) {
                            _searchQuery =
                                value.trim();

                            _applyFilters();
                          },
                          onClear: () {
                            _searchController
                                .clear();

                            _searchQuery = '';

                            _applyFilters();
                          },
                        ),
                      ),
                    ),

                    // =============================================
                    // CATEGORY HEADING
                    // =============================================

                    SliverToBoxAdapter(
                      child: Padding(
                        padding:
                            const EdgeInsets.fromLTRB(
                          AppConstants
                              .defaultPadding,
                          22,
                          AppConstants
                              .defaultPadding,
                          10,
                        ),
                        child: Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Text(
                                    'EXPLORE',
                                    style:
                                        TextStyle(
                                      fontSize: 7,
                                      fontWeight:
                                          FontWeight
                                              .w900,
                                      letterSpacing:
                                          1.1,
                                      color: AppColors
                                          .textSecondary
                                          .withValues(
                                        alpha:
                                            0.58,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(
                                    height: 4,
                                  ),

                                  const Text(
                                    'Browse categories',
                                    style:
                                        TextStyle(
                                      fontSize: 18,
                                      fontWeight:
                                          FontWeight
                                              .w900,
                                      letterSpacing:
                                          -0.4,
                                      color: AppColors
                                          .textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Text(
                              '${_categories.length} categories',
                              style: TextStyle(
                                fontSize: 8.5,
                                fontWeight:
                                    FontWeight.w600,
                                color: AppColors
                                    .textSecondary
                                    .withValues(
                                  alpha: 0.65,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // =============================================
                    // CATEGORIES
                    // =============================================

                    SliverToBoxAdapter(
                      child:
                          CategorySelectorWidget(
                        categories:
                            _categories,
                        selectedCategoryId:
                            _selectedCategoryId,
                        getCategoryId:
                            (category) =>
                                category.id,
                        getCategoryName:
                            (category) =>
                                category.name,
                        onCategorySelected:
                            (categoryId) {
                          _selectedCategoryId =
                              categoryId;

                          _applyFilters();
                        },
                      ),
                    ),

                    // =============================================
                    // PRODUCTS HEADER
                    // =============================================

                    SliverToBoxAdapter(
                      child: Padding(
                        padding:
                            const EdgeInsets.fromLTRB(
                          AppConstants
                              .defaultPadding,
                          24,
                          AppConstants
                              .defaultPadding,
                          13,
                        ),
                        child: Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Text(
                                    'MENU',
                                    style:
                                        TextStyle(
                                      fontSize: 7,
                                      fontWeight:
                                          FontWeight
                                              .w900,
                                      letterSpacing:
                                          1.1,
                                      color: AppColors
                                          .textSecondary
                                          .withValues(
                                        alpha:
                                            0.58,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(
                                    height: 4,
                                  ),

                                  Text(
                                    _productTitle,
                                    style:
                                        const TextStyle(
                                      fontSize: 18,
                                      fontWeight:
                                          FontWeight
                                              .w900,
                                      letterSpacing:
                                          -0.4,
                                      color: AppColors
                                          .textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Container(
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration:
                                  BoxDecoration(
                                color: AppColors
                                    .surface,
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  20,
                                ),
                                border:
                                    Border.all(
                                  color: AppColors
                                      .border
                                      .withValues(
                                    alpha:
                                        0.30,
                                  ),
                                ),
                              ),
                              child: Text(
                                '${_filteredProducts.length} '
                                '${_filteredProducts.length == 1 ? 'item' : 'items'}',
                                style:
                                    const TextStyle(
                                  fontSize: 8,
                                  fontWeight:
                                      FontWeight
                                          .w800,
                                  color: AppColors
                                      .textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // =============================================
                    // EMPTY STATE
                    // =============================================

                    if (_filteredProducts
                        .isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child:
                            _buildEmptyState(),
                      )
                    else

                      // ===========================================
                      // PRODUCT GRID
                      // ===========================================

                      SliverPadding(
                        padding:
                            const EdgeInsets.fromLTRB(
                          AppConstants
                              .defaultPadding,
                          0,
                          AppConstants
                              .defaultPadding,
                          110,
                        ),
                        sliver: SliverGrid(
                          delegate:
                              SliverChildBuilderDelegate(
                            (
                              BuildContext context,
                              int index,
                            ) {
                              final product =
                                  _filteredProducts[
                                      index];

                              return ProductCard(
                                product:
                                    product,
                                onTap: () {
                                  ProductDetailModal
                                      .show(
                                    context,
                                    product,
                                  );
                                },
                              );
                            },
                            childCount:
                                _filteredProducts
                                    .length,
                          ),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio:
                                0.70,
                            crossAxisSpacing:
                                12,
                            mainAxisSpacing: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }

  // =============================================================
  // HOME HEADER
  // =============================================================

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.defaultPadding,
        18,
        AppConstants.defaultPadding,
        20,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          // =====================================================
          // BRAND ROW
          // =====================================================

          Row(
            children: [
              // =================================================
              // LOGO
              // =================================================

              SizedBox(
                width: 38,
                height: 38,
                child: Image.asset(
                  'assets/logoSmoothie.png',
                  fit: BoxFit.contain,
                  errorBuilder: (
                    context,
                    error,
                    stackTrace,
                  ) {
                    return Container(
                      decoration:
                          BoxDecoration(
                        color:
                            AppColors.surface,
                        shape:
                            BoxShape.circle,
                        border: Border.all(
                          color: AppColors
                              .border
                              .withValues(
                            alpha: 0.35,
                          ),
                        ),
                      ),
                      child: const Icon(
                        Icons
                            .local_drink_outlined,
                        size: 18,
                        color: AppColors
                            .textPrimary,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(width: 10),

              // =================================================
              // BRAND
              // =================================================

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    const Text(
                      'THE LEGIT SMOOTHIE',
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1,
                        fontWeight:
                            FontWeight.w900,
                        letterSpacing: 0.2,
                        color: AppColors
                            .textPrimary,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      'Freshly made. Made for you.',
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 8.5,
                        height: 1,
                        fontWeight:
                            FontWeight.w500,
                        color: AppColors
                            .textSecondary
                            .withValues(
                          alpha: 0.68,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // =================================================
              // STATUS
              // =================================================

              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),
                  border: Border.all(
                    color: AppColors.border
                        .withValues(
                      alpha: 0.30,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration:
                          BoxDecoration(
                        color:
                            Colors.green.shade600,
                        shape:
                            BoxShape.circle,
                      ),
                    ),

                    const SizedBox(width: 6),

                    const Text(
                      'OPEN',
                      style: TextStyle(
                        fontSize: 7,
                        fontWeight:
                            FontWeight.w900,
                        letterSpacing: 0.5,
                        color: AppColors
                            .textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // =====================================================
          // GREETING
          // =====================================================

          Text(
            _greeting.toUpperCase(),
            style: TextStyle(
              fontSize: 7,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
              color: AppColors.textSecondary
                  .withValues(
                alpha: 0.58,
              ),
            ),
          ),

          const SizedBox(height: 7),

          const Text(
            'What are you\ncraving today?',
            style: TextStyle(
              fontSize: 31,
              height: 1.02,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.15,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 11),

          ConstrainedBox(
            constraints:
                const BoxConstraints(
              maxWidth: 300,
            ),
            child: Text(
              'Explore fresh smoothies, milk tea, '
              'fruit juice and your favorite snacks.',
              style: TextStyle(
                fontSize: 10,
                height: 1.5,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary
                    .withValues(
                  alpha: 0.72,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =============================================================
  // PRODUCT TITLE
  // =============================================================

  String get _productTitle {
    if (_searchQuery.isNotEmpty) {
      return 'Search results';
    }

    if (_selectedCategoryId == null) {
      return 'All products';
    }

    for (final category in _categories) {
      if (category.id ==
          _selectedCategoryId) {
        return category.name;
      }
    }

    return 'Products';
  }

  // =============================================================
  // GREETING
  // =============================================================

  String get _greeting {
    final int hour =
        DateTime.now().hour;

    if (hour < 12) {
      return 'Good morning';
    }

    if (hour < 18) {
      return 'Good afternoon';
    }

    return 'Good evening';
  }

  // =============================================================
  // EMPTY STATE
  // =============================================================

  Widget _buildEmptyState() {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 40,
      ),
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius:
                  BorderRadius.circular(22),
              border: Border.all(
                color: AppColors.border
                    .withValues(
                  alpha: 0.35,
                ),
              ),
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 29,
              color: AppColors
                  .textSecondary
                  .withValues(
                alpha: 0.42,
              ),
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            'Nothing here yet',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight:
                  FontWeight.w900,
              letterSpacing: -0.2,
              color:
                  AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            _searchQuery.isNotEmpty
                ? 'We couldn’t find anything matching '
                    '“$_searchQuery”. Try another search.'
                : 'There are no available products '
                    'in this category right now.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              height: 1.5,
              color:
                  AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}