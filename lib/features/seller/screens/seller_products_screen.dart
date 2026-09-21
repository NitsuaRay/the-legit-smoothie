import 'package:flutter/material.dart';
import 'package:the_legit_smoothie/features/seller/screens/seller_add_product_screen.dart';
import 'package:the_legit_smoothie/features/seller/screens/seller_edit_product_screen.dart';

import '../../../core/constants/app_colors.dart';
import '../../../main.dart';
import '../widgets/productScreen/seller_product_card.dart';

class SellerProductsScreen extends StatefulWidget {
  const SellerProductsScreen({super.key});

  @override
  State<SellerProductsScreen> createState() => _SellerProductsScreenState();
}

class _SellerProductsScreenState extends State<SellerProductsScreen> {
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;

  String? _errorMessage;

  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _categories = [];

  String? _selectedCategoryId;

  final Set<String> _updatingProducts = {};

  @override
  void initState() {
    super.initState();

    _searchController.addListener(_onSearchChanged);

    _loadData();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);

    _searchController.dispose();

    super.dispose();
  }

  // ============================================================
  // SEARCH
  // ============================================================

  void _onSearchChanged() {
    setState(() {});
  }

  // ============================================================
  // LOAD DATA
  // ============================================================

  Future<void> _loadData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final results = await Future.wait([
        supabase
            .from('categories')
            .select('id, name, display_order')
            .order('display_order', ascending: true),

        supabase
            .from('products')
            .select('''
              id,
              category_id,
              name,
              description,
              base_price,
              image_url,
              is_available,
              created_at,
              categories (
                id,
                name
              )
              ''')
            .order('created_at', ascending: false),
      ]);

      if (!mounted) return;

      setState(() {
        _categories = List<Map<String, dynamic>>.from(results[0]);

        _products = List<Map<String, dynamic>>.from(results[1]);

        _isLoading = false;
      });
    } catch (error) {
      debugPrint('Seller products load error: $error');

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = 'Unable to load your products.';
      });
    }
  }

  // ============================================================
  // FILTERED PRODUCTS
  // ============================================================

  List<Map<String, dynamic>> get _filteredProducts {
    final String query = _searchController.text.trim().toLowerCase();

    return _products.where((product) {
      final String name = (product['name'] ?? '').toString().toLowerCase();

      final String description = (product['description'] ?? '')
          .toString()
          .toLowerCase();

      final String categoryId = (product['category_id'] ?? '').toString();

      final bool matchesSearch =
          query.isEmpty || name.contains(query) || description.contains(query);

      final bool matchesCategory =
          _selectedCategoryId == null || categoryId == _selectedCategoryId;

      return matchesSearch && matchesCategory;
    }).toList();
  }

  // ============================================================
  // AVAILABILITY
  // ============================================================

  Future<void> _updateAvailability(
    Map<String, dynamic> product,
    bool value,
  ) async {
    final String productId = product['id'].toString();

    if (_updatingProducts.contains(productId)) {
      return;
    }

    setState(() {
      _updatingProducts.add(productId);
    });

    try {
      await supabase
          .from('products')
          .update({'is_available': value})
          .eq('id', productId);

      if (!mounted) return;

      setState(() {
        product['is_available'] = value;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value
                ? '${product['name']} is now available.'
                : '${product['name']} is now unavailable.',
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (error) {
      debugPrint('Availability update error: $error');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to update product availability.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _updatingProducts.remove(productId);
        });
      }
    }
  }

  // ============================================================
  // ADD PRODUCT
  // ============================================================

  Future<void> _addProduct() async {
    final bool? added = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const SellerAddProductScreen()),
    );

    if (added == true) {
      await _loadData();
    }
  }

  // ============================================================
  // EDIT PRODUCT
  // ============================================================

  Future<void> _editProduct(Map<String, dynamic> product) async {
    final bool? updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => SellerEditProductScreen(product: product),
      ),
    );

    if (updated == true) {
      await _loadData();
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final products = _filteredProducts;

    return Scaffold(
      backgroundColor: AppColors.background,

      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _loadData,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ==================================================
              // HEADER
              // ==================================================
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: _buildHeader(),
                ),
              ),

              // ==================================================
              // SEARCH
              // ==================================================
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
                  child: _buildSearchBar(),
                ),
              ),

              // ==================================================
              // CATEGORY FILTERS
              // ==================================================
              if (!_isLoading && _categories.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: _buildCategoryFilters(),
                  ),
                ),

              // ==================================================
              // SUMMARY
              // ==================================================
              if (!_isLoading && _errorMessage == null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                    child: _buildProductSummary(products.length),
                  ),
                ),

              // ==================================================
              // BODY
              // ==================================================
              if (_isLoading)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.primary,
                    ),
                  ),
                )
              else if (_errorMessage != null)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildErrorState(),
                )
              else if (products.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptyState(),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                  sliver: SliverList.separated(
                    itemCount: products.length,
                    separatorBuilder: (context, index) {
                      return const SizedBox(height: 12);
                    },
                    itemBuilder: (context, index) {
                      final product = products[index];

                      final String id = product['id'].toString();

                      return SellerProductCard(
                        product: product,
                        isUpdatingAvailability: _updatingProducts.contains(id),
                        onAvailabilityChanged: (value) {
                          _updateAvailability(product, value);
                        },
                        onEdit: () {
                          _editProduct(product);
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),

      // ==========================================================
      // ADD PRODUCT
      // ==========================================================
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addProduct,
        elevation: 2,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded, size: 21),
        label: const Text(
          'Add Product',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // =========================================================
        // PRODUCTS ICON
        // =========================================================
        Container(
          width: 50,
          height: 50,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.45)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.035),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.20),
              ),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              size: 21,
              color: AppColors.textPrimary,
            ),
          ),
        ),

        const SizedBox(width: 13),

        // =========================================================
        // TITLE
        // =========================================================
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CATALOG',
                style: TextStyle(
                  fontSize: 7.5,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.15,
                  color: AppColors.textSecondary.withValues(alpha: 0.55),
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                'Products',
                style: TextStyle(
                  fontSize: 23,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.65,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                'Manage your store catalog',
                style: TextStyle(
                  fontSize: 10.5,
                  height: 1.2,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary.withValues(alpha: 0.72),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        // =========================================================
        // REFRESH
        // =========================================================
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _loadData,
            borderRadius: BorderRadius.circular(14),
            child: Ink(
              width: 43,
              height: 43,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.45),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.025),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.refresh_rounded,
                  size: 19,
                  color: AppColors.textSecondary.withValues(alpha: 0.85),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SEARCH BAR
  // ============================================================

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.55)),
      ),
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search products...',
          hintStyle: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary.withValues(alpha: 0.65),
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            size: 20,
            color: AppColors.textSecondary,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                  },
                  icon: const Icon(Icons.close_rounded, size: 18),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  // ============================================================
  // CATEGORY FILTER
  // ============================================================

  Widget _buildCategoryFilters() {
    return SizedBox(
      height: 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _categoryChip(
            label: 'All',
            categoryId: null,
            icon: Icons.grid_view_rounded,
          ),

          const SizedBox(width: 8),

          ..._categories.map((category) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _categoryChip(
                label: category['name'].toString(),
                categoryId: category['id'].toString(),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ============================================================
  // CATEGORY CHIP
  // ============================================================

  Widget _categoryChip({
    required String label,
    required String? categoryId,
    IconData? icon,
  }) {
    final bool selected = _selectedCategoryId == categoryId;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (selected) {
            return;
          }

          setState(() {
            _selectedCategoryId = categoryId;
          });
        },
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(
            horizontal: selected ? 14 : 13,
            vertical: 9,
          ),
          decoration: BoxDecoration(
            color: selected ? AppColors.textPrimary : AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? AppColors.textPrimary
                  : AppColors.border.withValues(alpha: 0.42),
            ),
            boxShadow: [
              if (selected)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.10),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              else
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.018),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // =================================================
              // OPTIONAL ICON
              // =================================================
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 13,
                  color: selected ? Colors.white : AppColors.textSecondary,
                ),

                const SizedBox(width: 6),
              ],

              // =================================================
              // LABEL
              // =================================================
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  height: 1,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  letterSpacing: selected ? 0.05 : 0,
                  color: selected ? Colors.white : AppColors.textSecondary,
                ),
              ),

              // =================================================
              // SELECTED INDICATOR
              // =================================================
              AnimatedSize(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                child: selected
                    ? Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: Container(
                          width: 15,
                          height: 15,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.14),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            size: 10,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SUMMARY
  // ============================================================

  Widget _buildProductSummary(int visibleCount) {
    final int availableCount = _products.where((product) {
      return product['is_available'] == true;
    }).length;

    return Row(
      children: [
        Expanded(
          child: Text(
            '$visibleCount '
            '${visibleCount == 1 ? 'product' : 'products'}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
              ),

              const SizedBox(width: 5),

              Text(
                '$availableCount available',
                style: const TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _buildEmptyState() {
    final bool filtering =
        _searchController.text.trim().isNotEmpty || _selectedCategoryId != null;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
              child: Icon(
                filtering
                    ? Icons.search_off_rounded
                    : Icons.inventory_2_outlined,
                size: 30,
                color: AppColors.textSecondary.withValues(alpha: 0.45),
              ),
            ),

            const SizedBox(height: 16),

            Text(
              filtering ? 'No products found' : 'No products yet',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              filtering
                  ? 'Try changing your search or category.'
                  : 'Add your first product to start building your catalog.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11.5,
                height: 1.4,
                color: AppColors.textSecondary,
              ),
            ),

            if (!filtering) ...[
              const SizedBox(height: 18),

              ElevatedButton.icon(
                onPressed: _addProduct,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add Product'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.07),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: AppColors.error,
                size: 29,
              ),
            ),

            const SizedBox(height: 15),

            Text(
              _errorMessage ?? 'Something went wrong.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 14),

            OutlinedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh_rounded, size: 17),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
