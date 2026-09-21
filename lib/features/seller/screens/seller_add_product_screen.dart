import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_colors.dart';
import '../../../main.dart';

class SellerAddProductScreen extends StatefulWidget {
  const SellerAddProductScreen({super.key});

  @override
  State<SellerAddProductScreen> createState() => _SellerAddProductScreenState();
}

class _SellerAddProductScreenState extends State<SellerAddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  bool _descriptionWasManuallyEdited = false;
  bool _isAutoUpdatingDescription = false;

  final ImagePicker _imagePicker = ImagePicker();

  XFile? _selectedImage;

  bool _isLoadingCategories = true;
  bool _isSaving = false;
  bool _isUploadingImage = false;
  bool _isAvailable = true;

  String? _selectedCategoryId;
  String? _selectedCategoryName;

  List<Map<String, dynamic>> _categories = [];

  @override
  void initState() {
    super.initState();

    _nameController.addListener(_handleProductNameChanged);

    _descriptionController.addListener(_handleDescriptionChanged);

    _loadCategories();
  }

  @override
  void dispose() {
    _nameController.removeListener(_handleProductNameChanged);

    _descriptionController.removeListener(_handleDescriptionChanged);

    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();

    super.dispose();
  }

  // ============================================================
  // LOAD CATEGORIES
  // ============================================================

  Future<void> _loadCategories() async {
    try {
      final response = await supabase
          .from('categories')
          .select('id, name, display_order, is_active')
          .eq('is_active', true)
          .order('display_order', ascending: true);

      if (!mounted) return;

      setState(() {
        _categories = List<Map<String, dynamic>>.from(response);

        _isLoadingCategories = false;
      });
    } catch (error) {
      debugPrint('Load categories error: $error');

      if (!mounted) return;

      setState(() {
        _isLoadingCategories = false;
      });

      _showError('Unable to load categories.');
    }
  }

  // ============================================================
  // CATEGORY NORMALIZATION
  // ============================================================

  String get _normalizedCategory {
    return (_selectedCategoryName ?? '').trim().toLowerCase();
  }

  bool get _isSmoothie {
    return _normalizedCategory == 'smoothies' ||
        _normalizedCategory == 'smoothie';
  }

  bool get _isMilkTea {
    return _normalizedCategory == 'milk tea' ||
        _normalizedCategory == 'milk teas';
  }

  bool get _isFruitJuices {
    return _normalizedCategory == 'fruit juices' ||
        _normalizedCategory == 'fruit juice';
  }

  bool get _isSiomai {
    return _normalizedCategory == 'siomai';
  }

  bool get _isPancitCanton {
    return _normalizedCategory == 'pancit canton';
  }

  // ============================================================
  // AUTO PRODUCT DESCRIPTION
  // ============================================================

  String _generateProductDescription() {
    final String productName = _nameController.text.trim();

    if (productName.isEmpty || _selectedCategoryName == null) {
      return '';
    }

    if (_isSmoothie) {
      return 'A refreshing $productName smoothie, '
          'blended smooth and served fresh for a creamy '
          'and satisfying drink.';
    }

    if (_isMilkTea) {
      return 'A refreshing $productName milk tea with a '
          'smooth and creamy taste, perfect for any time '
          'of the day.';
    }

    if (_isFruitJuices) {
      return 'A refreshing $productName fruit drink with '
          'a bright and fruity flavor, served fresh for '
          'a delicious and cooling treat.';
    }

    if (_isSiomai) {
      return 'Delicious $productName siomai, served hot '
          'and packed with savory flavor for a satisfying '
          'snack or meal.';
    }

    if (_isPancitCanton) {
      return 'A satisfying $productName Pancit Canton '
          'with savory noodles and bold flavor, prepared '
          'fresh and served hot.';
    }

    return 'Freshly prepared $productName from '
        'The Legit Smoothie.';
  }

  void _autoFillDescription({bool force = false}) {
    final String name = _nameController.text.trim();

    if (name.isEmpty || _selectedCategoryId == null) {
      return;
    }

    if (_descriptionWasManuallyEdited && !force) {
      return;
    }

    final String generated = _generateProductDescription();

    if (generated.isEmpty) {
      return;
    }

    _isAutoUpdatingDescription = true;

    _descriptionController.text = generated;

    _descriptionController.selection = TextSelection.collapsed(
      offset: generated.length,
    );

    _isAutoUpdatingDescription = false;

    if (force) {
      _descriptionWasManuallyEdited = false;
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _handleProductNameChanged() {
    if (_descriptionWasManuallyEdited) {
      return;
    }

    _autoFillDescription();
  }

  void _handleDescriptionChanged() {
    if (_isAutoUpdatingDescription) {
      return;
    }

    _descriptionWasManuallyEdited = _descriptionController.text
        .trim()
        .isNotEmpty;
  }
  // ============================================================
  // PRODUCT IMAGE
  // ============================================================

  Future<void> _showImageSourceSheet() async {
    if (_isSaving) return;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return SafeArea(
          child: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),

                const SizedBox(height: 18),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Product Image',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),

                const SizedBox(height: 4),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Choose where you want to get the product photo.',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                _imageSourceTile(
                  icon: Icons.photo_library_outlined,
                  title: 'Choose from Gallery',
                  subtitle: 'Select an existing product photo',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _pickImage(ImageSource.gallery);
                  },
                ),

                const SizedBox(height: 8),

                _imageSourceTile(
                  icon: Icons.camera_alt_outlined,
                  title: 'Take a Photo',
                  subtitle: 'Use your camera',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _pickImage(ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _imageSourceTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.45)),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: AppColors.primary),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 9.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1600,
        maxHeight: 1600,
      );

      if (image == null || !mounted) {
        return;
      }

      setState(() {
        _selectedImage = image;
      });
    } catch (error) {
      debugPrint('Product image picker error: $error');

      if (!mounted) return;

      _showError('Unable to select image.');
    }
  }

  void _removeSelectedImage() {
    if (_isSaving) return;

    setState(() {
      _selectedImage = null;
    });
  }

  Future<String?> _uploadProductImage(String productId) async {
    if (_selectedImage == null) {
      return null;
    }

    setState(() {
      _isUploadingImage = true;
    });

    try {
      final File file = File(_selectedImage!.path);

      final String originalName = _selectedImage!.name;

      String extension = 'jpg';

      if (originalName.contains('.')) {
        extension = originalName.split('.').last.toLowerCase();
      }

      // Prevent unsupported/random extensions.
      if (!['jpg', 'jpeg', 'png', 'webp'].contains(extension)) {
        extension = 'jpg';
      }

      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();

      final String storagePath = '$productId/product_$timestamp.$extension';

      await supabase.storage.from('product-images').upload(storagePath, file);

      final String publicUrl = supabase.storage
          .from('product-images')
          .getPublicUrl(storagePath);

      return publicUrl;
    } catch (error) {
      debugPrint('Product image upload error: $error');

      rethrow;
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingImage = false;
        });
      }
    }
  }

  // ============================================================
  // PRODUCT OPTIONS
  // ============================================================

  List<Map<String, dynamic>> _buildProductOptions() {
    // ----------------------------------------------------------
    // SMOOTHIES
    // ----------------------------------------------------------

    if (_isSmoothie) {
      return [
        {
          'option_group': 'Size',
          'option_name': 'Regular',
          'extra_price': 0,
          'is_available': true,
        },
        {
          'option_group': 'Size',
          'option_name': 'Large',
          'extra_price': 20,
          'is_available': true,
        },
        {
          'option_group': 'Toppings',
          'option_name': 'Cream Cheese',
          'extra_price': 15,
          'is_available': true,
        },
        {
          'option_group': 'Toppings',
          'option_name': 'Pearl',
          'extra_price': 15,
          'is_available': true,
        },
        {
          'option_group': 'Toppings',
          'option_name': 'Nata de Coco',
          'extra_price': 15,
          'is_available': true,
        },
      ];
    }

    // ----------------------------------------------------------
    // MILK TEA
    // ----------------------------------------------------------

    if (_isMilkTea) {
      return [
        {
          'option_group': 'Size',
          'option_name': 'Regular',
          'extra_price': 0,
          'is_available': true,
        },
        {
          'option_group': 'Size',
          'option_name': 'Large',
          'extra_price': 10,
          'is_available': true,
        },
        {
          'option_group': 'Toppings',
          'option_name': 'Cream Cheese',
          'extra_price': 15,
          'is_available': true,
        },
      ];
    }

    // ----------------------------------------------------------
    // FRUIT SERIES / JUICE
    // ----------------------------------------------------------

    if (_isFruitJuices) {
      return [
        // SIZE
        {
          'option_group': 'Size',
          'option_name': 'Regular',
          'extra_price': 0,
          'is_available': true,
        },
        {
          'option_group': 'Size',
          'option_name': 'Large',
          'extra_price': 10,
          'is_available': true,
        },

        // TOPPINGS
        {
          'option_group': 'Toppings',
          'option_name': 'Nata de Coco',
          'extra_price': 15,
          'is_available': true,
        },
      ];
    }

    // ----------------------------------------------------------
    // PANCIT CANTON
    // ----------------------------------------------------------

    if (_isPancitCanton) {
      return [
        {
          'option_group': 'Flavor',
          'option_name': 'Kalamansi',
          'extra_price': 0,
          'is_available': true,
        },
        {
          'option_group': 'Flavor',
          'option_name': 'Chilimansi',
          'extra_price': 0,
          'is_available': true,
        },
        {
          'option_group': 'Flavor',
          'option_name': 'Sweet & Spicy',
          'extra_price': 0,
          'is_available': true,
        },
      ];
    }

    // Siomai has no options.
    return [];
  }

  // ============================================================
  // SAVE PRODUCT
  // ============================================================

  Future<void> _saveProduct() async {
    if (_isSaving) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategoryId == null) {
      _showError('Please select a category.');

      return;
    }

    final double? basePrice = double.tryParse(_priceController.text.trim());

    if (basePrice == null || basePrice < 0) {
      _showError('Please enter a valid price.');

      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // ========================================================
      // 1. CREATE PRODUCT
      // ========================================================

      final product = await supabase
          .from('products')
          .insert({
            'category_id': _selectedCategoryId,
            'name': _nameController.text.trim(),
            'description': _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
            'base_price': basePrice,
            'image_url': null,
            'is_available': _isAvailable,
          })
          .select('id')
          .single();

      final String productId = product['id'].toString();

      // ========================================================
      // UPLOAD IMAGE
      // ========================================================

      if (_selectedImage != null) {
        final String? imageUrl = await _uploadProductImage(productId);

        if (imageUrl != null) {
          await supabase
              .from('products')
              .update({'image_url': imageUrl})
              .eq('id', productId);
        }
      }

      // ========================================================
      // CREATE OPTIONS
      // ========================================================

      final options = _buildProductOptions();

      if (options.isNotEmpty) {
        final rows = options.map((option) {
          return {
            'product_id': productId,
            'option_group': option['option_group'],
            'option_name': option['option_name'],
            'extra_price': option['extra_price'],
            'is_available': option['is_available'],
          };
        }).toList();

        await supabase.from('product_options').insert(rows);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_nameController.text.trim()} added successfully.'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.of(context).pop(true);
    } catch (error) {
      debugPrint('Add product error: $error');

      if (!mounted) return;

      _showError('Unable to add product. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // ============================================================
  // ERROR
  // ============================================================

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        titleSpacing: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Product',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.3,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Create a new store item',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),

      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 130),
          children: [
            // ==================================================
            // PRODUCT IMAGE
            // ==================================================
            _buildImageSection(),

            const SizedBox(height: 28),

            // ============================================================
            // PRODUCT INFORMATION
            // ============================================================
            _sectionTitle(
              'Product Information',
              'Add the essential details customers will see.',
            ),

            const SizedBox(height: 14),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.40),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.025),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ========================================================
                  // PRODUCT NAME
                  // ========================================================
                  _buildFieldLabel(label: 'Product Name', required: true),

                  const SizedBox(height: 7),

                  _buildTextField(
                    controller: _nameController,
                    hint: 'e.g. Mango Smoothie',
                    icon: Icons.local_drink_outlined,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Product name is required';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 18),

                  // ========================================================
                  // CATEGORY
                  // ========================================================
                  _buildFieldLabel(label: 'Category', required: true),

                  const SizedBox(height: 7),

                  _buildCategoryDropdown(),

                  const SizedBox(height: 18),

                  // ========================================================
                  // DESCRIPTION
                  // ========================================================
                  Row(
                    children: [
                      Expanded(
                        child: _buildFieldLabel(
                          label: 'Description',
                          helper: 'Auto-generated',
                        ),
                      ),

                      if (_nameController.text.trim().isNotEmpty &&
                          _selectedCategoryId != null)
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              _descriptionWasManuallyEdited = false;

                              _autoFillDescription(force: true);
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 5,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.auto_awesome_outlined,
                                    size: 13,
                                    color: AppColors.primary,
                                  ),

                                  const SizedBox(width: 4),

                                  const Text(
                                    'Regenerate',
                                    style: TextStyle(
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 7),

                  _buildTextField(
                    controller: _descriptionController,
                    hint: _selectedCategoryId == null
                        ? 'Select a category and enter a product name...'
                        : 'Description will be generated automatically...',
                    icon: Icons.notes_rounded,
                    maxLines: 4,
                  ),

                  const SizedBox(height: 7),

                  Row(
                    children: [
                      Icon(
                        Icons.auto_awesome_outlined,
                        size: 12,
                        color: AppColors.textSecondary.withValues(alpha: 0.60),
                      ),

                      const SizedBox(width: 5),

                      Expanded(
                        child: Text(
                          'Generated from the product name and category. You can edit it anytime.',
                          style: TextStyle(
                            fontSize: 8.5,
                            height: 1.3,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary.withValues(
                              alpha: 0.62,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // ========================================================
                  // PRICE
                  // ========================================================
                  _buildFieldLabel(
                    label: _hasSizes ? 'Regular Price' : 'Base Price',
                    required: true,
                  ),

                  const SizedBox(height: 7),

                  _buildTextField(
                    controller: _priceController,
                    hint: '0.00',
                    icon: Icons.payments_outlined,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    prefixText: '₱',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Price is required';
                      }

                      final price = double.tryParse(value.trim());

                      if (price == null || price < 0) {
                        return 'Enter a valid price';
                      }

                      return null;
                    },
                  ),
                ],
              ),
            ),

            // ==================================================
            // OPTIONS
            // ==================================================
            if (_selectedCategoryId != null) ...[
              const SizedBox(height: 30),

              _sectionTitle('Product Options', _optionsDescription),

              const SizedBox(height: 14),

              _buildOptionsPreview(),
            ],

            const SizedBox(height: 28),

            // ==================================================
            // AVAILABILITY
            // ==================================================
            _sectionTitle(
              'Availability',
              'Control whether customers can order this product.',
            ),

            const SizedBox(height: 14),

            _buildAvailabilityCard(),
          ],
        ),
      ),

      // ========================================================
      // SAVE BUTTON
      // ========================================================
      bottomNavigationBar: _buildBottomButton(),
    );
  }

  bool get _hasSizes => _isSmoothie || _isMilkTea || _isFruitJuices;

  String get _optionsDescription {
    if (_isSmoothie) {
      return 'Smoothie sizes and toppings are added automatically.';
    }

    if (_isMilkTea) {
      return 'Milk tea sizes and available topping are added automatically.';
    }

    if (_isFruitJuices) {
      return 'Fruit Juice sizes and topping are added automatically.';
    }

    if (_isPancitCanton) {
      return 'Available Pancit Canton flavors are added automatically.';
    }

    if (_isSiomai) {
      return 'Siomai does not require sizes or toppings.';
    }

    return 'Options are based on the selected category.';
  }

  // ============================================================
  // IMAGE
  // ============================================================

  Widget _buildImageSection() {
    final bool hasImage = _selectedImage != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Product Image',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.3,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: 4),

        const Text(
          'Add a clear photo that customers will see in your store.',
          style: TextStyle(
            fontSize: 10.5,
            height: 1.4,
            color: AppColors.textSecondary,
          ),
        ),

        const SizedBox(height: 14),

        GestureDetector(
          onTap: _isSaving ? null : _showImageSourceSheet,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            height: 205,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: hasImage
                    ? AppColors.primary.withValues(alpha: 0.20)
                    : AppColors.border.withValues(alpha: 0.55),
              ),
              boxShadow: [
                if (hasImage)
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.025),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
              ],
            ),
            child: hasImage
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(
                        File(_selectedImage!.path),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _imagePlaceholder();
                        },
                      ),

                      // Subtle bottom gradient
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        height: 65,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.32),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Change photo
                      Positioned(
                        left: 12,
                        bottom: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.70),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.photo_camera_outlined,
                                size: 14,
                                color: Colors.white,
                              ),
                              SizedBox(width: 5),
                              Text(
                                'Change',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Remove
                      Positioned(
                        right: 10,
                        top: 10,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _removeSelectedImage,
                            borderRadius: BorderRadius.circular(50),
                            child: Ink(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.62),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : _imagePlaceholder(),
          ),
        ),
      ],
    );
  }

  Widget _imagePlaceholder() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.add_photo_alternate_outlined,
              size: 25,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(height: 11),

          const Text(
            'Add Product Image',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 4),

          const Text(
            'Tap to choose from gallery or camera',
            style: TextStyle(fontSize: 9.5, color: AppColors.textSecondary),
          ),

          const SizedBox(height: 9),

          Text(
            'JPG, PNG or WEBP',
            style: TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }
  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _sectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.3,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 10.5,
            height: 1.4,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    String? prefixText,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final bool isMultiline = maxLines > 1;

    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(
        fontSize: 12.5,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hint,

        hintStyle: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary.withValues(alpha: 0.55),
        ),

        filled: true,
        fillColor: AppColors.background,

        // ========================================================
        // ICON
        // ========================================================
        prefixIcon: Padding(
          padding: EdgeInsets.fromLTRB(
            12,
            isMultiline ? 12 : 10,
            9,
            isMultiline ? 70 : 10,
          ),
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.45),
              ),
            ),
            child: Icon(icon, size: 17, color: AppColors.textSecondary),
          ),
        ),

        prefixIconConstraints: const BoxConstraints(minWidth: 55),

        // ========================================================
        // PRICE PREFIX
        // ========================================================
        prefixText: prefixText == null ? null : '$prefixText ',

        prefixStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w900,
          color: AppColors.textPrimary,
        ),

        contentPadding: EdgeInsets.symmetric(
          horizontal: 14,
          vertical: isMultiline ? 14 : 16,
        ),

        // ========================================================
        // BORDERS
        // ========================================================
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: AppColors.border.withValues(alpha: 0.45),
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 1.4),
        ),

        errorStyle: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600),
      ),
    );
  }
  // ============================================================
  // FIELD LABEL
  // ============================================================

  Widget _buildFieldLabel({
    required String label,
    bool required = false,
    String? helper,
  }) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.1,
                  color: AppColors.textPrimary,
                ),
              ),

              if (required) ...[
                const SizedBox(width: 3),

                const Text(
                  '*',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ],
          ),
        ),

        if (helper != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              helper.toUpperCase(),
              style: TextStyle(
                fontSize: 7,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
                color: AppColors.textSecondary.withValues(alpha: 0.70),
              ),
            ),
          ),
      ],
    );
  }

  // ============================================================
  // CATEGORY
  // ============================================================

  Widget _buildCategoryDropdown() {
    if (_isLoadingCategories) {
      return Container(
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.45)),
        ),
        child: const Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
        ),
      );
    }

    return DropdownButtonFormField<String>(
      initialValue: _selectedCategoryId,

      isExpanded: true,

      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        size: 20,
        color: AppColors.textSecondary,
      ),

      dropdownColor: AppColors.surface,

      borderRadius: BorderRadius.circular(16),

      style: const TextStyle(
        fontSize: 12.5,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),

      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.background,

        prefixIcon: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 9, 10),
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.45),
              ),
            ),
            child: const Icon(
              Icons.category_outlined,
              size: 17,
              color: AppColors.textSecondary,
            ),
          ),
        ),

        prefixIconConstraints: const BoxConstraints(minWidth: 55),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: AppColors.border.withValues(alpha: 0.45),
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 1.4),
        ),

        errorStyle: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600),
      ),

      hint: Text(
        'Select a category',
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary.withValues(alpha: 0.55),
        ),
      ),

      items: _categories.map((category) {
        return DropdownMenuItem<String>(
          value: category['id'].toString(),
          child: Text(
            category['name'].toString(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),

      onChanged: (value) {
        if (value == null) {
          return;
        }

        final category = _categories.firstWhere(
          (item) => item['id'].toString() == value,
        );

        setState(() {
          _selectedCategoryId = value;
          _selectedCategoryName = category['name'].toString();
        });

        _autoFillDescription();
      },

      validator: (value) {
        if (value == null) {
          return 'Please select a category';
        }

        return null;
      },
    );
  }

  // ============================================================
  // OPTIONS PREVIEW
  // ============================================================

  Widget _buildOptionsPreview() {
    final options = _buildProductOptions();

    if (options.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        ),
        child: const Row(
          children: [
            Icon(
              Icons.check_circle_outline_rounded,
              size: 20,
              color: AppColors.textSecondary,
            ),

            SizedBox(width: 10),

            Expanded(
              child: Text(
                'No additional options required.',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final groups = <String, List<Map<String, dynamic>>>{};

    for (final option in options) {
      final group = option['option_group'].toString();

      groups.putIfAbsent(group, () => []);

      groups[group]!.add(option);
    }

    return Column(
      children: groups.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _optionGroupCard(entry.key, entry.value),
        );
      }).toList(),
    );
  }

  Widget _optionGroupCard(String title, List<Map<String, dynamic>> options) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 11),

          ...options.map((option) {
            final double price =
                (option['extra_price'] as num?)?.toDouble() ?? 0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.07),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 13,
                      color: AppColors.primary,
                    ),
                  ),

                  const SizedBox(width: 9),

                  Expanded(
                    child: Text(
                      option['option_name'].toString(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),

                  Text(
                    price == 0 ? 'Included' : '+₱${price.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: price == 0
                          ? AppColors.textSecondary
                          : AppColors.primary,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ============================================================
  // AVAILABILITY
  // ============================================================

  Widget _buildAvailabilityCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.50)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _isAvailable
                  ? AppColors.success.withValues(alpha: 0.08)
                  : AppColors.textSecondary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _isAvailable
                  ? Icons.check_circle_outline_rounded
                  : Icons.visibility_off_outlined,
              size: 20,
              color: _isAvailable ? AppColors.success : AppColors.textSecondary,
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isAvailable ? 'Available' : 'Unavailable',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 2),

                const Text(
                  'Customers can order this product',
                  style: TextStyle(
                    fontSize: 9.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          Switch(
            value: _isAvailable,
            activeTrackColor: AppColors.primary,
            onChanged: (value) {
              setState(() {
                _isAvailable = value;
              });
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BOTTOM BUTTON
  // ============================================================

  Widget _buildBottomButton() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(color: AppColors.border.withValues(alpha: 0.45)),
          ),
        ),
        child: SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: _isSaving ? null : _saveProduct,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: _isSaving
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 9),
                      Text(
                        _isUploadingImage
                            ? 'Uploading image...'
                            : 'Adding product...',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_rounded, size: 19),
                      SizedBox(width: 7),
                      Text(
                        'Add Product',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
