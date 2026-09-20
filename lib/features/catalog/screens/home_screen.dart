import 'package:flutter/material.dart';
import 'package:the_legit_smoothie/shared/widgets/category_selector_widget.dart';
import 'package:the_legit_smoothie/shared/widgets/custom_app_bar.dart';
import 'package:the_legit_smoothie/shared/widgets/search_bar_widget.dart';
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
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<CategoryModel> _categories = [];
  List<ProductModel> _allProducts = [];
  List<ProductModel> _filteredProducts = [];

  String? _selectedCategoryId; // null = 'All'
  String _searchQuery = '';
  bool _isLoading = true;

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

  Future<void> _fetchCatalogData() async {
    try {
      final categoryRes = await supabase
          .from('categories')
          .select()
          .order('display_order', ascending: true);

      final categories = (categoryRes as List)
          .map((item) => CategoryModel.fromJson(item))
          .toList();

      final productRes = await supabase
          .from('products')
          .select()
          .eq('is_available', true);

      final products = (productRes as List)
          .map((item) => ProductModel.fromJson(item))
          .toList();

      setState(() {
        _categories = categories;
        _allProducts = products;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredProducts = _allProducts.where((product) {
        final matchesCategory =
            _selectedCategoryId == null ||
            product.categoryId == _selectedCategoryId;

        final matchesSearch =
            _searchQuery.isEmpty ||
            product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (product.description != null &&
                product.description!.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ));

        return matchesCategory && matchesSearch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const MainAppBar(),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.primary,
              ),
            )
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _fetchCatalogData,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  // ====================================================
                  // SEARCH
                  // ====================================================
                  SliverToBoxAdapter(
                    child: SearchBarWidget(
                      controller: _searchController,
                      searchQuery: _searchQuery,
                      onChanged: (value) {
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

                  // ====================================================
                  // CATEGORIES
                  // ====================================================
                  SliverToBoxAdapter(
                    child: CategorySelectorWidget(
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

                  // ====================================================
                  // PRODUCT COUNT
                  // ====================================================
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppConstants.defaultPadding,
                        18,
                        AppConstants.defaultPadding,
                        12,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _selectedCategoryId == null
                                  ? 'All Products'
                                  : 'Products',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.3,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),

                          Text(
                            '${_filteredProducts.length} items',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary.withValues(
                                alpha: 0.70,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ====================================================
                  // EMPTY STATE
                  // ====================================================
                  if (_filteredProducts.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _buildEmptyState(),
                    )
                  else
                    // ==================================================
                    // PRODUCTS
                    // ==================================================
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        AppConstants.defaultPadding,
                        0,
                        AppConstants.defaultPadding,
                        110,
                      ),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final product = _filteredProducts[index];

                          return ProductCard(
                            product: product,
                            onTap: () {
                              ProductDetailModal.show(context, product);
                            },
                          );
                        }, childCount: _filteredProducts.length),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,

                              // More room for image + description +
                              // price without making cards too tall.
                              childAspectRatio: 0.70,

                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.45),
              ),
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 30,
              color: AppColors.textSecondary.withValues(alpha: 0.45),
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            'Nothing here yet',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Try another search or browse a different category.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
