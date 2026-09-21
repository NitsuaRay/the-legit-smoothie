import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_colors.dart';
import '../../../main.dart';

class SellerEditProductScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const SellerEditProductScreen({super.key, required this.product});

  @override
  State<SellerEditProductScreen> createState() =>
      _SellerEditProductScreenState();
}

class _SellerEditProductScreenState extends State<SellerEditProductScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();

  List<Map<String, dynamic>> _categories = [];

  String? _selectedCategoryId;
  String? _selectedCategoryName;

  XFile? _selectedImage;

  String? _currentImageUrl;

  bool _isAvailable = true;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isUploadingImage = false;

  bool _isLoadingCategories = true;
  bool _descriptionWasManuallyEdited = true;
  bool _isAutoUpdatingDescription = false;

  String get _productId => widget.product['id'].toString();

  @override
  void initState() {
    super.initState();

    _nameController.addListener(_handleProductNameChanged);

    _descriptionController.addListener(_handleDescriptionChanged);

    _initializeProduct();
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
  // INITIALIZE
  // ============================================================

  Future<void> _initializeProduct() async {
    _nameController.text = (widget.product['name'] ?? '').toString();

    _descriptionController.text = (widget.product['description'] ?? '')
        .toString();

    _descriptionWasManuallyEdited = _descriptionController.text
        .trim()
        .isNotEmpty;

    final double price =
        (widget.product['base_price'] as num?)?.toDouble() ?? 0;

    _priceController.text = price.toStringAsFixed(2);

    _selectedCategoryId = widget.product['category_id']?.toString();

    _currentImageUrl = (widget.product['image_url'] ?? '').toString().trim();

    _isAvailable = widget.product['is_available'] == true;

    try {
      final response = await supabase
          .from('categories')
          .select('id, name, display_order, is_active')
          .eq('is_active', true)
          .order('display_order', ascending: true);

      final categories = List<Map<String, dynamic>>.from(response);

      String? categoryName;

      if (_selectedCategoryId != null) {
        for (final category in categories) {
          if (category['id'].toString() == _selectedCategoryId) {
            categoryName = category['name'].toString();

            break;
          }
        }
      }

      if (!mounted) return;

      setState(() {
        _categories = categories;
        _selectedCategoryName = categoryName;

        _isLoading = false;
      });
    } catch (error) {
      debugPrint('Edit product initialization error: $error');

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showError('Unable to load product information.');
    }
  }

  // ============================================================
  // CATEGORY HELPERS
  // ============================================================

  String get _normalizedCategory =>
      (_selectedCategoryName ?? '').trim().toLowerCase();

  bool get _isSmoothie =>
      _normalizedCategory == 'smoothies' || _normalizedCategory == 'smoothie';

  bool get _isMilkTea =>
      _normalizedCategory == 'milk tea' || _normalizedCategory == 'milk teas';

  bool get _isFruitSeries =>
      _normalizedCategory == 'fruit series' ||
      _normalizedCategory == 'fruit juices' ||
      _normalizedCategory == 'fruit juice' ||
      _normalizedCategory == 'juice' ||
      _normalizedCategory == 'fruit series or juice';

  bool get _isPancitCanton => _normalizedCategory == 'pancit canton';

  bool get _hasSizes => _isSmoothie || _isMilkTea || _isFruitSeries;

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

    if (_isFruitSeries) {
      return 'A refreshing $productName fruit drink with '
          'a bright and fruity flavor, served fresh for '
          'a delicious and cooling treat.';
    }

    if (_isPancitCanton) {
      return 'A satisfying $productName Pancit Canton '
          'with savory noodles and bold flavor, prepared '
          'fresh and served hot.';
    }

    // Siomai / categories without special rules
    if (_normalizedCategory == 'siomai') {
      return 'Delicious $productName siomai, served hot '
          'and packed with savory flavor for a satisfying '
          'snack or meal.';
    }

    return 'Freshly prepared $productName from '
        'The Legit Smoothie.';
  }

  void _autoFillDescription({bool force = false}) {
    final String name = _nameController.text.trim();

    if (name.isEmpty || _selectedCategoryId == null) {
      return;
    }

    // Protect an existing/custom description.
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
  // OPTIONS
  // ============================================================

  List<Map<String, dynamic>> _buildProductOptions() {
    if (_isSmoothie) {
      return [
        _option('Size', 'Regular', 0),
        _option('Size', 'Large', 20),
        _option('Toppings', 'Cream Cheese', 15),
        _option('Toppings', 'Pearl', 15),
        _option('Toppings', 'Nata de Coco', 15),
      ];
    }

    if (_isMilkTea) {
      return [
        _option('Size', 'Regular', 0),
        _option('Size', 'Large', 10),
        _option('Toppings', 'Cream Cheese', 15),
      ];
    }

    if (_isFruitSeries) {
      return [
        _option('Size', 'Regular', 0),
        _option('Size', 'Large', 10),
        _option('Toppings', 'Nata de Coco', 15),
      ];
    }

    if (_isPancitCanton) {
      return [
        _option('Flavor', 'Kalamansi', 0),
        _option('Flavor', 'Chilimansi', 0),
        _option('Flavor', 'Sweet & Spicy', 0),
      ];
    }

    // Siomai
    return [];
  }

  Map<String, dynamic> _option(String group, String name, num extraPrice) {
    return {
      'option_group': group,
      'option_name': name,
      'extra_price': extraPrice,
      'is_available': true,
    };
  }

  // ============================================================
  // IMAGE PICKER
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
                    'Change Product Image',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),

                const SizedBox(height: 5),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Choose a new photo for this product.',
                    style: TextStyle(
                      fontSize: 10.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                _imageSourceTile(
                  icon: Icons.photo_library_outlined,
                  title: 'Choose from Gallery',
                  subtitle: 'Select an existing photo',
                  onTap: () {
                    Navigator.pop(sheetContext);

                    _pickImage(ImageSource.gallery);
                  },
                ),

                const SizedBox(height: 8),

                _imageSourceTile(
                  icon: Icons.camera_alt_outlined,
                  title: 'Take a Photo',
                  subtitle: 'Use your device camera',
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
      final image = await _imagePicker.pickImage(
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
      debugPrint('Edit product image picker error: $error');

      _showError('Unable to select image.');
    }
  }

  // ============================================================
  // UPLOAD NEW IMAGE
  // ============================================================

  Future<String> _uploadNewImage() async {
    final image = _selectedImage;

    if (image == null) {
      throw Exception('No image selected.');
    }

    setState(() {
      _isUploadingImage = true;
    });

    try {
      String extension = 'jpg';

      if (image.name.contains('.')) {
        extension = image.name.split('.').last.toLowerCase();
      }

      if (!['jpg', 'jpeg', 'png', 'webp'].contains(extension)) {
        extension = 'jpg';
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;

      final path = '$_productId/product_$timestamp.$extension';

      await supabase.storage
          .from('product-images')
          .upload(path, File(image.path));

      return supabase.storage.from('product-images').getPublicUrl(path);
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingImage = false;
        });
      }
    }
  }

  // ============================================================
  // GET STORAGE PATH FROM OLD PUBLIC URL
  // ============================================================

  String? _storagePathFromPublicUrl(String? url) {
    if (url == null || url.trim().isEmpty) {
      return null;
    }

    const marker = '/storage/v1/object/public/product-images/';

    final index = url.indexOf(marker);

    if (index == -1) {
      return null;
    }

    return Uri.decodeFull(url.substring(index + marker.length));
  }

  // ============================================================
  // SAVE CHANGES
  // ============================================================

  Future<void> _saveChanges() async {
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

    String? newImageUrl;

    try {
      // ========================================================
      // 1. UPLOAD NEW IMAGE FIRST
      // ========================================================

      if (_selectedImage != null) {
        newImageUrl = await _uploadNewImage();
      }

      // ========================================================
      // 2. UPDATE PRODUCT
      // ========================================================

      await supabase
          .from('products')
          .update({
            'category_id': _selectedCategoryId,
            'name': _nameController.text.trim(),
            'description': _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
            'base_price': basePrice,
            'is_available': _isAvailable,

            'image_url': ?newImageUrl,

            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', _productId);

      // ========================================================
      // 3. REBUILD OPTIONS
      //
      // Delete old options, then recreate options based on
      // the currently selected category.
      // ========================================================

      await supabase
          .from('product_options')
          .delete()
          .eq('product_id', _productId);

      final options = _buildProductOptions();

      if (options.isNotEmpty) {
        final rows = options.map((option) {
          return {
            'product_id': _productId,
            'option_group': option['option_group'],
            'option_name': option['option_name'],
            'extra_price': option['extra_price'],
            'is_available': option['is_available'],
          };
        }).toList();

        await supabase.from('product_options').insert(rows);
      }

      // ========================================================
      // 4. DELETE OLD IMAGE
      //
      // Only after DB successfully points to the new image.
      // ========================================================

      if (newImageUrl != null &&
          _currentImageUrl != null &&
          _currentImageUrl!.isNotEmpty) {
        final oldPath = _storagePathFromPublicUrl(_currentImageUrl);

        if (oldPath != null) {
          try {
            await supabase.storage.from('product-images').remove([oldPath]);
          } catch (error) {
            // Do not fail the whole edit because
            // old-image cleanup failed.
            debugPrint('Old product image cleanup error: $error');
          }
        }
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_nameController.text.trim()} updated successfully.'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.of(context).pop(true);
    } catch (error) {
      debugPrint('Edit product error: $error');

      // If the new image uploaded but updating
      // the product failed, clean up the unused
      // newly uploaded file.
      if (newImageUrl != null) {
        final newPath = _storagePathFromPublicUrl(newImageUrl);

        if (newPath != null) {
          try {
            await supabase.storage.from('product-images').remove([newPath]);
          } catch (_) {}
        }
      }

      if (!mounted) return;

      _showError('Unable to update product. Please try again.');
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
              'Edit Product',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.3,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Update product information',
              style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),

      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.primary,
              ),
            )
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 130),
                children: [
                  _buildImageSection(),

                  const SizedBox(height: 28),

                  // ============================================================
                  // PRODUCT INFORMATION
                  // ============================================================
                  _sectionTitle(
                    'Product Information',
                    'Update the essential details customers will see.',
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
                                  onTap: _isSaving
                                      ? null
                                      : () {
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 1),
                              child: Icon(
                                Icons.auto_awesome_outlined,
                                size: 12,
                                color: AppColors.textSecondary.withValues(
                                  alpha: 0.60,
                                ),
                              ),
                            ),

                            const SizedBox(width: 5),

                            Expanded(
                              child: Text(
                                'Regenerate from the current product name and category, or edit the description yourself.',
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
                          prefixText: '₱',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
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

                  if (_selectedCategoryId != null) ...[
                    const SizedBox(height: 30),

                    _sectionTitle('Product Options', _optionsDescription),

                    const SizedBox(height: 14),

                    _buildOptionsPreview(),
                  ],

                  const SizedBox(height: 28),

                  _sectionTitle(
                    'Availability',
                    'Control whether customers can order this product.',
                  ),

                  const SizedBox(height: 14),

                  _buildAvailabilityCard(),
                ],
              ),
            ),

      bottomNavigationBar: _isLoading ? null : _buildBottomButton(),
    );
  }

  // ============================================================
  // IMAGE UI
  // ============================================================

  Widget _buildImageSection() {
    final bool hasNewImage = _selectedImage != null;

    final bool hasCurrentImage =
        _currentImageUrl != null && _currentImageUrl!.isNotEmpty;

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
          'Tap the image to replace the current product photo.',
          style: TextStyle(fontSize: 10.5, color: AppColors.textSecondary),
        ),

        const SizedBox(height: 14),

        GestureDetector(
          onTap: _isSaving ? null : _showImageSourceSheet,
          child: Container(
            width: double.infinity,
            height: 220,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.50),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(17),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: Colors.white,
                    child: hasNewImage
                        ? Image.file(
                            File(_selectedImage!.path),
                            fit: BoxFit.contain,
                          )
                        : hasCurrentImage
                        ? Image.network(
                            _currentImageUrl!,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return _imagePlaceholder();
                            },
                          )
                        : _imagePlaceholder(),
                  ),

                  Positioned(
                    left: 12,
                    bottom: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.72),
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
                            'Change Photo',
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

                  if (hasNewImage)
                    Positioned(
                      right: 10,
                      top: 10,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedImage = null;
                            });
                          },
                          borderRadius: BorderRadius.circular(50),
                          child: Ink(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.65),
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
              ),
            ),
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
              color: AppColors.primary,
              size: 25,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            'Add Product Image',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION
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
  // OPTIONS UI
  // ============================================================

  String get _optionsDescription {
    if (_isSmoothie) {
      return 'Regular, Large (+₱20), Cream Cheese, Pearl and Nata de Coco.';
    }

    if (_isMilkTea) {
      return 'Regular, Large (+₱10) and Cream Cheese.';
    }

    if (_isFruitSeries) {
      return 'Regular, Large (+₱10) and Nata de Coco.';
    }

    if (_isPancitCanton) {
      return 'Kalamansi, Chilimansi and Sweet & Spicy flavors.';
    }

    return 'No additional options are required.';
  }

  Widget _buildOptionsPreview() {
    final options = _buildProductOptions();

    if (options.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.50)),
        ),
        child: const Row(
          children: [
            Icon(
              Icons.check_circle_outline_rounded,
              size: 19,
              color: AppColors.textSecondary,
            ),
            SizedBox(width: 10),
            Text(
              'No additional options required.',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
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

                Text(
                  _isAvailable
                      ? 'Customers can order this product.'
                      : 'This product is hidden from ordering.',
                  style: const TextStyle(
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
            onChanged: _isSaving
                ? null
                : (value) {
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
  // BOTTOM SAVE
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
            onPressed: _isSaving ? null : _saveChanges,
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
                            : 'Saving changes...',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_rounded, size: 19),
                      SizedBox(width: 7),
                      Text(
                        'Save Changes',
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
