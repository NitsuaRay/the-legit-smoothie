import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:the_legit_smoothie/core/constants/app_colors.dart';
import 'package:the_legit_smoothie/features/store/models/add_on_model.dart';
import 'package:the_legit_smoothie/features/store/models/category_model.dart';
import 'package:the_legit_smoothie/features/store/models/flavor_model.dart';
import 'package:the_legit_smoothie/features/store/models/size_model.dart';
import 'package:the_legit_smoothie/features/store/services/menu_database_service.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _databaseService = MenuDatabaseService();
  final ImagePicker _picker = ImagePicker();

  final _nameController = TextEditingController();
  final _priceController = TextEditingController();

  // State
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isAvailable = true;
  File? _selectedImageFile;

  // Master Data
  List<CategoryModel> _categories = [];
  List<SizeModel> _allSizes = [];
  List<AddOnModel> _allAddOns = [];
  List<FlavorModel> _allFlavors = [];

  // Selected State & Rules
  CategoryModel? _selectedCategory;
  final Set<int> _selectedSizeIds = {};
  final Set<int> _selectedAddOnIds = {};
  final Set<int> _selectedFlavorIds = {};

  bool _isSizesEnabled = true;
  bool _isAddOnsEnabled = true;
  bool _isFlavorsEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final results = await Future.wait([
        _databaseService.getCategories(),
        _databaseService.getSizes(),
        _databaseService.getAddOns(),
        _databaseService.getFlavors(),
      ]);

      if (!mounted) return;

      final categories = results[0] as List<CategoryModel>;
      final sizes = results[1] as List<SizeModel>;
      final addOns = results[2] as List<AddOnModel>;
      final flavors = results[3] as List<FlavorModel>;

      setState(() {
        _categories = categories;
        _allSizes = sizes;
        _allAddOns = addOns;
        _allFlavors = flavors;

        if (_categories.isNotEmpty) {
          _selectedCategory = _categories.firstWhere(
            (c) => c.name.toLowerCase().contains('smoothie'),
            orElse: () => _categories.first,
          );
          _applyCategoryRules(_selectedCategory!);
        }

        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load menu metadata: $e'),
          backgroundColor: AppColors.error,
        ),
      );
      setState(() => _isLoading = false);
    }
  }

  void _applyCategoryRules(CategoryModel category) {
    _selectedSizeIds.clear();
    _selectedAddOnIds.clear();
    _selectedFlavorIds.clear();

    final catName = category.name.toLowerCase();

    if (catName.contains('canton')) {
      _isSizesEnabled = false;
      _isAddOnsEnabled = false;
      _isFlavorsEnabled = true;

      _selectedFlavorIds.addAll(_allFlavors.map((f) => f.id));
    } else if (catName.contains('smoothie')) {
      _isSizesEnabled = true;
      _isAddOnsEnabled = true;
      _isFlavorsEnabled = false;

      _selectedSizeIds.addAll(_allSizes.map((s) => s.id));
      _selectedAddOnIds.addAll(_allAddOns.map((a) => a.id));
    } else if (catName.contains('siomai')) {
      _isSizesEnabled = false;
      _isAddOnsEnabled = false;
      _isFlavorsEnabled = false;
    } else if (catName.contains('juice')) {
      _isSizesEnabled = true;
      _isAddOnsEnabled = true;
      _isFlavorsEnabled = false;

      _selectedSizeIds.addAll(_allSizes.map((s) => s.id));
      final nata = _allAddOns.where(
        (a) => a.name.toLowerCase().contains('nata'),
      );
      _selectedAddOnIds.addAll(nata.map((a) => a.id));
    } else if (catName.contains('tea')) {
      _isSizesEnabled = true;
      _isAddOnsEnabled = true;
      _isFlavorsEnabled = false;

      _selectedSizeIds.addAll(_allSizes.map((s) => s.id));
      final creamCheese = _allAddOns.where(
        (a) => a.name.toLowerCase().contains('cream cheese'),
      );
      _selectedAddOnIds.addAll(creamCheese.map((a) => a.id));
    } else {
      _isSizesEnabled = true;
      _isAddOnsEnabled = true;
      _isFlavorsEnabled = false;
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null && mounted) {
        setState(() {
          _selectedImageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showImageSourceBottomSheet(bool isDarkMode) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDarkMode ? AppColors.darkText : AppColors.cardWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Wrap(
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.photo_library_rounded,
                    color: isDarkMode ? AppColors.cream : AppColors.secondary,
                  ),
                ),
                title: Text(
                  'Pick from Gallery',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? AppColors.cream : AppColors.darkText,
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.camera_alt_rounded,
                    color: isDarkMode ? AppColors.cream : AppColors.secondary,
                  ),
                ),
                title: Text(
                  'Take a Photo',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? AppColors.cream : AppColors.darkText,
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      String? imageUrl;

      if (_selectedImageFile != null) {
        imageUrl = await _databaseService.uploadMenuItemImage(
          _selectedImageFile!,
        );
      }

      final double price = double.parse(_priceController.text.trim());

      await _databaseService.createMenuItem(
        categoryId: _selectedCategory!.id,
        name: _nameController.text.trim(),
        price: price,
        imagePath: imageUrl,
        isAvailable: _isAvailable,
        sizeIds: _isSizesEnabled ? _selectedSizeIds.toList() : [],
        addOnIds: _isAddOnsEnabled ? _selectedAddOnIds.toList() : [],
        flavorIds: _isFlavorsEnabled ? _selectedFlavorIds.toList() : [],
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product added successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving product: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // --- Color Theme Mapping using AppColors ---
    final baseBgColor = isDarkMode ? AppColors.darkText : AppColors.background;
    final bgAsset = isDarkMode ? 'assets/bgBrown.png' : 'assets/bgWhite.png';

    final primaryAccent = isDarkMode ? AppColors.cream : AppColors.bobaBrown;
    final secondaryAccent = AppColors.secondary;

    final textColor = isDarkMode ? AppColors.cream : AppColors.darkText;
    final subTextColor = isDarkMode
        ? AppColors.cream.withValues(alpha: 0.65)
        : AppColors.greyText;

    final cardBg = isDarkMode
        ? AppColors.darkText.withValues(alpha: 0.75)
        : AppColors.cardWhite.withValues(alpha: 0.92);

    final borderColor = isDarkMode
        ? AppColors.cream.withValues(alpha: 0.18)
        : AppColors.greyBorder;

    return Scaffold(
      backgroundColor: baseBgColor,
      // SafeArea wraps the body to ensure status bar cutouts are respected
      body: SafeArea(
        child: Stack(
          children: [
            // 1. Background Image Overlay (0.5 opacity)
            Positioned.fill(
              child: Opacity(
                opacity: 0.5,
                child: Image.asset(
                  bgAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(color: baseBgColor),
                ),
              ),
            ),

            // 2. Main Content
            _isLoading
                ? Center(child: CircularProgressIndicator(color: primaryAccent))
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 16.0,
                    ),

                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: MediaQuery.paddingOf(context).top + 24,
                          ),
                          // App Bar Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: cardBg,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: borderColor),
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    color: textColor,
                                    size: 18,
                                  ),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ),
                              Text(
                                'Add New Menu Item',
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(width: 44), // Alignment spacing
                            ],
                          ),

                          const SizedBox(height: 24),

                          // 1. Image Picker Hero Section
                          Center(
                            child: Stack(
                              children: [
                                GestureDetector(
                                  onTap: () =>
                                      _showImageSourceBottomSheet(isDarkMode),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    width: 130,
                                    height: 130,
                                    decoration: BoxDecoration(
                                      color: cardBg,
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(
                                        color: _selectedImageFile != null
                                            ? secondaryAccent
                                            : primaryAccent.withValues(
                                                alpha: 0.5,
                                              ),
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: isDarkMode ? 0.3 : 0.06,
                                          ),
                                          blurRadius: 16,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                      image: _selectedImageFile != null
                                          ? DecorationImage(
                                              image: FileImage(
                                                _selectedImageFile!,
                                              ),
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                    ),
                                    child: _selectedImageFile == null
                                        ? Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(
                                                  12,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: secondaryAccent
                                                      .withValues(alpha: 0.15),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(
                                                  Icons.add_a_photo_rounded,
                                                  size: 28,
                                                  color: primaryAccent,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                'Upload Image',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: subTextColor,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          )
                                        : null,
                                  ),
                                ),
                                if (_selectedImageFile != null)
                                  Positioned(
                                    right: -4,
                                    top: -4,
                                    child: GestureDetector(
                                      onTap: () => setState(
                                        () => _selectedImageFile = null,
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: AppColors.error,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: cardBg,
                                            width: 2,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.close_rounded,
                                          size: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 28),

                          // 2. Categories Selection
                          _buildSectionTitle('Category', textColor),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 42,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: _categories.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 10),
                              itemBuilder: (context, index) {
                                final category = _categories[index];
                                final isSelected =
                                    category.id == _selectedCategory?.id;

                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  child: ChoiceChip(
                                    label: Text(category.name),
                                    selected: isSelected,
                                    onSelected: (selected) {
                                      if (selected) {
                                        setState(() {
                                          _selectedCategory = category;
                                          _applyCategoryRules(category);
                                        });
                                      }
                                    },
                                    selectedColor: secondaryAccent,
                                    backgroundColor: cardBg,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),
                                    labelStyle: TextStyle(
                                      fontSize: 13,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? Colors.white
                                          : textColor,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      side: BorderSide(
                                        color: isSelected
                                            ? secondaryAccent
                                            : borderColor,
                                        width: isSelected ? 1.5 : 1.0,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Form Details Card
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: borderColor),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(
                                    alpha: isDarkMode ? 0.2 : 0.04,
                                  ),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 3. Item Name Input
                                _buildInputLabel('Item Name', textColor),
                                const SizedBox(height: 8),
                                _buildTextField(
                                  controller: _nameController,
                                  hintText: 'e.g. Classic Pancit Canton',
                                  textColor: textColor,
                                  subTextColor: subTextColor,
                                  fillColor: isDarkMode
                                      ? Colors.black26
                                      : AppColors.background,
                                  borderColor: borderColor,
                                  focusColor: secondaryAccent,
                                  validator: (val) =>
                                      val == null || val.trim().isEmpty
                                      ? 'Please enter item name'
                                      : null,
                                ),

                                const SizedBox(height: 18),

                                // 4. Base Price Input
                                _buildInputLabel('Base Price (PHP)', textColor),
                                const SizedBox(height: 8),
                                _buildTextField(
                                  controller: _priceController,
                                  hintText: 'e.g. 35.00',
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 12,
                                    ),
                                    child: Text(
                                      '₱',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: secondaryAccent,
                                      ),
                                    ),
                                  ),
                                  textColor: textColor,
                                  subTextColor: subTextColor,
                                  fillColor: isDarkMode
                                      ? Colors.black26
                                      : AppColors.background,
                                  borderColor: borderColor,
                                  focusColor: secondaryAccent,
                                  validator: (val) {
                                    if (val == null || val.trim().isEmpty)
                                      return 'Please enter price';
                                    if (double.tryParse(val.trim()) == null)
                                      return 'Enter a valid number';
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // 5. Sizes Section
                          _buildOptionGroupCard(
                            title: 'Available Sizes',
                            isEnabled: _isSizesEnabled,
                            textColor: textColor,
                            subTextColor: subTextColor,
                            cardBg: cardBg,
                            borderColor: borderColor,
                            children: _allSizes.map((size) {
                              final isSelected = _selectedSizeIds.contains(
                                size.id,
                              );
                              return _buildFilterChip(
                                label: size.name,
                                isSelected: isSelected,
                                isEnabled: _isSizesEnabled,
                                isDarkMode: isDarkMode,
                                primaryAccent: primaryAccent,
                                secondaryAccent: secondaryAccent,
                                borderColor: borderColor,
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      _selectedSizeIds.add(size.id);
                                    } else {
                                      _selectedSizeIds.remove(size.id);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 20),

                          // 6. Add-ons Section
                          _buildOptionGroupCard(
                            title: 'Available Add-ons (₱15.00 each)',
                            isEnabled: _isAddOnsEnabled,
                            textColor: textColor,
                            subTextColor: subTextColor,
                            cardBg: cardBg,
                            borderColor: borderColor,
                            children: _allAddOns.map((addOn) {
                              final isSelected = _selectedAddOnIds.contains(
                                addOn.id,
                              );
                              return _buildFilterChip(
                                label: addOn.name,
                                isSelected: isSelected,
                                isEnabled: _isAddOnsEnabled,
                                isDarkMode: isDarkMode,
                                primaryAccent: primaryAccent,
                                secondaryAccent: secondaryAccent,
                                borderColor: borderColor,
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      _selectedAddOnIds.add(addOn.id);
                                    } else {
                                      _selectedAddOnIds.remove(addOn.id);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 20),

                          // 7. Flavors Section (Canton Only)
                          _buildOptionGroupCard(
                            title: 'Available Flavors',
                            isEnabled: _isFlavorsEnabled,
                            textColor: textColor,
                            subTextColor: subTextColor,
                            cardBg: cardBg,
                            borderColor: borderColor,
                            children: _allFlavors.map((flavor) {
                              final isSelected = _selectedFlavorIds.contains(
                                flavor.id,
                              );
                              return _buildFilterChip(
                                label: flavor.name,
                                isSelected: isSelected,
                                isEnabled: _isFlavorsEnabled,
                                isDarkMode: isDarkMode,
                                primaryAccent: primaryAccent,
                                secondaryAccent: secondaryAccent,
                                borderColor: borderColor,
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      _selectedFlavorIds.add(flavor.id);
                                    } else {
                                      _selectedFlavorIds.remove(flavor.id);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 20),

                          // 8. Availability Card
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: borderColor),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Item Status',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _isAvailable
                                          ? 'Listed as Available'
                                          : 'Listed as Sold Out',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: _isAvailable
                                            ? AppColors.success
                                            : AppColors.error,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                Switch.adaptive(
                                  value: _isAvailable,
                                  activeColor: secondaryAccent,
                                  onChanged: (val) =>
                                      setState(() => _isAvailable = val),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),

                          // 9. Primary Save Action Button
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: _isSaving ? null : _saveItem,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: secondaryAccent,
                                foregroundColor: Colors.white,
                                elevation: 4,
                                shadowColor: secondaryAccent.withValues(
                                  alpha: 0.4,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: _isSaving
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : const Text(
                                      'Save Product',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  // Helper Widgets
  Widget _buildSectionTitle(String title, Color textColor) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: textColor,
        letterSpacing: 0.2,
      ),
    );
  }

  Widget _buildInputLabel(String label, Color textColor) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
    );
  }

  Widget _buildOptionGroupCard({
    required String title,
    required bool isEnabled,
    required Color textColor,
    required Color subTextColor,
    required Color cardBg,
    required Color borderColor,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isEnabled ? borderColor : borderColor.withValues(alpha: 0.8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isEnabled
                      ? textColor
                      : textColor.withValues(alpha: 0.6),
                ),
              ),
              if (!isEnabled)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.greyText.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Disabled for category',
                    style: TextStyle(
                      fontSize: 10,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
                      color: subTextColor.withValues(alpha: 0.7),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: children),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required bool isEnabled,
    required bool isDarkMode,
    required Color primaryAccent,
    required Color secondaryAccent,
    required Color borderColor,
    required Function(bool) onSelected,
  }) {
    final chipSelectedBg = secondaryAccent.withValues(alpha: 0.2);
    final chipUnselectedBg = isDarkMode ? Colors.black26 : AppColors.background;

    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isSelected && isEnabled
              ? FontWeight.bold
              : FontWeight.w500,
          color: isEnabled
              ? (isSelected
                    ? (isDarkMode ? AppColors.cream : AppColors.bobaBrown)
                    : (isDarkMode ? AppColors.cream : AppColors.darkText))
              : (isDarkMode
                    ? AppColors.cream.withValues(alpha: 0.3)
                    : AppColors.greyText.withValues(alpha: 0.5)),
        ),
      ),
      selected: isEnabled && isSelected,
      onSelected: isEnabled ? (val) => onSelected(val) : null,
      disabledColor: Colors.transparent,
      selectedColor: chipSelectedBg,
      checkmarkColor: secondaryAccent,
      backgroundColor: chipUnselectedBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isEnabled
              ? (isSelected ? secondaryAccent : borderColor)
              : borderColor.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required Color textColor,
    required Color subTextColor,
    required Color fillColor,
    required Color borderColor,
    required Color focusColor,
    TextInputType keyboardType = TextInputType.text,
    Widget? prefixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(
        color: textColor,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: subTextColor.withValues(alpha: 0.6),
          fontSize: 13,
        ),
        prefixIcon: prefixIcon,
        filled: true,
        fillColor: fillColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: focusColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
    );
  }
}
