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
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar
                // Inside your build column:
                SearchBarWidget(
                  controller: _searchController,
                  searchQuery: _searchQuery,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val.trim();
                      _applyFilters();
                    });
                  },
                  onClear: () {
                    setState(() {
                      _searchController.clear();
                      _searchQuery = '';
                      _applyFilters();
                    });
                  },
                ),

                // Inside your Column widgets list:
                CategorySelectorWidget(
                  categories: _categories,
                  selectedCategoryId: _selectedCategoryId,
                  getCategoryId: (category) => category
                      .id, // Replace .id if your model uses a different property name
                  getCategoryName: (category) => category
                      .name, // Replace .name if your model uses a different property name
                  onCategorySelected: (categoryId) {
                    setState(() {
                      _selectedCategoryId = categoryId;
                      _applyFilters();
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Products Grid View
                Expanded(
                  child: _filteredProducts.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off_rounded,
                                size: 64,
                                color: AppColors.textSecondary.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'No menu items found',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Try adjusting your search or category filter.',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.defaultPadding,
                            vertical: 8,
                          ),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.75,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                          itemCount: _filteredProducts.length,
                          itemBuilder: (context, index) {
                            final product = _filteredProducts[index];
                            return ProductCard(
                              product: product,
                              onTap: () =>
                                  ProductDetailModal.show(context, product),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
