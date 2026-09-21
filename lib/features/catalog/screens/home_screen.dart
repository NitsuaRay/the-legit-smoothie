import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../main.dart';

import '../models/category_model.dart';
import '../models/product_model.dart';

import '../widgets/catalog_category_selector.dart';
import '../widgets/catalog_empty_state.dart';
import '../widgets/catalog_home_header.dart';
import '../widgets/catalog_product_grid.dart';
import '../widgets/catalog_search_bar.dart';
import '../widgets/catalog_section_header.dart';

import 'product_detail_modal.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

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
          .order('display_order', ascending: true);

      final List<CategoryModel> categories = (categoryRes as List)
          .map((item) => CategoryModel.fromJson(item))
          .toList();

      final productRes = await supabase
          .from('products')
          .select()
          .eq('is_available', true);

      final List<ProductModel> products = (productRes as List)
          .map((item) => ProductModel.fromJson(item))
          .toList();

      if (!mounted) return;

      setState(() {
        _categories = categories;
        _allProducts = products;
        _isLoading = false;

        _filterProducts();
      });
    } catch (error) {
      debugPrint('HOME CATALOG ERROR: $error');

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  // =============================================================
  // FILTERING
  // =============================================================

  void _applyFilters() {
    if (!mounted) return;

    setState(() {
      _filterProducts();
    });
  }

  void _filterProducts() {
    final String normalizedQuery = _searchQuery.toLowerCase();

    _filteredProducts = _allProducts.where((ProductModel product) {
      final bool matchesCategory =
          _selectedCategoryId == null ||
          product.categoryId == _selectedCategoryId;

      final bool matchesSearch =
          normalizedQuery.isEmpty ||
          product.name.toLowerCase().contains(normalizedQuery) ||
          (product.description != null &&
              product.description!.toLowerCase().contains(normalizedQuery));

      return matchesCategory && matchesSearch;
    }).toList();
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

    for (final CategoryModel category in _categories) {
      if (category.id == _selectedCategoryId) {
        return category.name;
      }
    }

    return 'Products';
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
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.textPrimary,
                ),
              )
            : RefreshIndicator(
                color: AppColors.textPrimary,
                onRefresh: _fetchCatalogData,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  slivers: [
                    // =============================================
                    // HEADER
                    // =============================================
                    const SliverToBoxAdapter(child: CatalogHomeHeader()),

                    // =============================================
                    // SEARCH
                    // =============================================
                    SliverToBoxAdapter(
                      child: CatalogSearchBar(
                        controller: _searchController,
                        searchQuery: _searchQuery,
                        onChanged: (String value) {
                          _searchQuery = value.trim();

                          _applyFilters();
                        },
                        onClear: () {
                          _searchController.clear();

                          _searchQuery = '';

                          _applyFilters();
                        },
                      ),
                    ),

                    // =============================================
                    // CATEGORIES HEADING
                    // =============================================
                    SliverToBoxAdapter(
                      child: CatalogSectionHeader(
                        eyebrow: 'Explore',
                        title: 'Browse categories',
                        meta: '${_categories.length} categories',
                      ),
                    ),

                    // =============================================
                    // CATEGORY SELECTOR
                    // =============================================
                    SliverToBoxAdapter(
                      child: CatalogCategorySelector<CategoryModel>(
                        categories: _categories,
                        selectedCategoryId: _selectedCategoryId,
                        getCategoryId: (category) => category.id,
                        getCategoryName: (category) => category.name,
                        onCategorySelected: (categoryId) {
                          _selectedCategoryId = categoryId;

                          _applyFilters();
                        },
                      ),
                    ),

                    // =============================================
                    // MENU HEADING
                    // =============================================
                    SliverToBoxAdapter(
                      child: CatalogSectionHeader(
                        eyebrow: 'Menu',
                        title: _productTitle,
                        meta:
                            '${_filteredProducts.length} '
                            '${_filteredProducts.length == 1 ? 'item' : 'items'}',
                        topSpacing: 24,
                        bottomSpacing: 13,
                      ),
                    ),

                    // =============================================
                    // PRODUCTS
                    // =============================================
                    if (_filteredProducts.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: CatalogEmptyState(searchQuery: _searchQuery),
                      )
                    else
                      CatalogProductGrid(
                        products: _filteredProducts,
                        onProductTap: (product) {
                          ProductDetailModal.show(context, product);
                        },
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}
