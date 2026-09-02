import 'package:flutter/material.dart';
import 'package:the_legit_smoothie/features/cart/screens/cart_screen.dart';
import 'package:the_legit_smoothie/features/cart/services/cart_service.dart';
import 'package:the_legit_smoothie/features/catalog/screens/product_detail_modal.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/helpers.dart';
import '../../../main.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _selectedCategoryId; // Null means "All"
  bool _isLoading = true;

  List<CategoryModel> _categories = [];
  List<ProductModel> _products = [];

  @override
  void initState() {
    super.initState();
    _fetchCatalogData();
  }

  Future<void> _fetchCatalogData() async {
    setState(() => _isLoading = true);
    try {
      // Fetch categories
      final categoriesRes = await supabase
          .from('categories')
          .select()
          .order('display_order', ascending: true);

      // Fetch products
      final productsRes = await supabase
          .from('products')
          .select()
          .eq('is_available', true);

      setState(() {
        _categories = (categoriesRes as List)
            .map((item) => CategoryModel.fromJson(item))
            .toList();

        _products = (productsRes as List)
            .map((item) => ProductModel.fromJson(item))
            .toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading catalog: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<ProductModel> get _filteredProducts {
    if (_selectedCategoryId == null) return _products;
    return _products.where((p) => p.categoryId == _selectedCategoryId).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          // Replace the IconButton in HomeScreen's appBar:
          IconButton(
            icon: Badge(
              label: Text('${CartService().itemCount}'),
              isLabelVisible: CartService().itemCount > 0,
              backgroundColor: AppColors.secondaryDark,
              child: const Icon(Icons.shopping_bag_outlined),
            ),
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const CartScreen()));
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : RefreshIndicator(
              onRefresh: _fetchCatalogData,
              color: AppColors.primary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.defaultPadding,
                      vertical: 8.0,
                    ),
                    child: Row(
                      children: [
                        // "All" Category Chip
                        ChoiceChip(
                          label: const Text('All'),
                          selected: _selectedCategoryId == null,
                          selectedColor: AppColors.primary,
                          backgroundColor: AppColors.surface,
                          labelStyle: TextStyle(
                            color: _selectedCategoryId == null
                                ? Colors.white
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                          onSelected: (_) {
                            setState(() => _selectedCategoryId = null);
                          },
                        ),
                        const SizedBox(width: 8),

                        // Dynamic Category Chips
                        ..._categories.map((cat) {
                          final isSelected = _selectedCategoryId == cat.id;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              label: Text(cat.name),
                              selected: isSelected,
                              selectedColor: AppColors.primary,
                              backgroundColor: AppColors.surface,
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                              onSelected: (_) {
                                setState(() => _selectedCategoryId = cat.id);
                              },
                            ),
                          );
                        }),
                      ],
                    ),
                  ),

                  // Product Grid
                  Expanded(
                    child: _filteredProducts.isEmpty
                        ? const Center(
                            child: Text(
                              'No products available in this category.',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.all(
                              AppConstants.defaultPadding,
                            ),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.72,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                ),
                            itemCount: _filteredProducts.length,
                            itemBuilder: (context, index) {
                              final product = _filteredProducts[index];
                              return _ProductCard(
                                product: product,
                                onTap: () =>
                                    ProductDetailModal.show(context, product),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;

  const _ProductCard({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Placeholder/Display
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primaryAccent.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppConstants.defaultBorderRadius),
                  ),
                ),
                child: Center(
                  child:
                      product.imageUrl != null && product.imageUrl!.isNotEmpty
                      ? Image.network(product.imageUrl!, fit: BoxFit.cover)
                      : const Icon(
                          Icons.local_drink_rounded,
                          size: 48,
                          color: AppColors.secondaryDark,
                        ),
                ),
              ),
            ),

            // Details
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppHelpers.formatCurrency(product.basePrice),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.secondaryDark,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Add Button
                  SizedBox(
                    width: double.infinity,
                    height: 32,
                    child: ElevatedButton(
                      onPressed: onTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Add',
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
