import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:the_legit_smoothie/core/constants/app_colors.dart';
import 'package:the_legit_smoothie/features/store/models/add_on_model.dart';
import 'package:the_legit_smoothie/features/store/models/category_model.dart';
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

  // Data
  List<CategoryModel> _categories = [];
  List<SizeModel> _allSizes = [];
  List<AddOnModel> _allAddOns = [];

  CategoryModel? _selectedCategory;
  final Set<int> _selectedSizeIds = {};
  final Set<int> _selectedAddOnIds = {};

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final categories = await _databaseService.getCategories();
      final sizes = await _databaseService.getSizes();
      final addOns = await _databaseService.getAddOns();

      if (mounted) {
        setState(() {
          _categories = categories;
          _allSizes = sizes;
          _allAddOns = addOns;

          if (_categories.isNotEmpty) {
            _selectedCategory = _categories.firstWhere(
              (c) => c.name.toLowerCase().contains('smoothie'),
              orElse: () => _categories.first,
            );
            _applyCategoryRules(_selectedCategory!);
          }

          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load menu metadata: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  void _applyCategoryRules(CategoryModel category) {
    _selectedSizeIds.clear();
    _selectedAddOnIds.clear();

    final catName = category.name.toLowerCase();

    if (catName.contains('smoothie')) {
      _selectedSizeIds.addAll(_allSizes.map((s) => s.id));
      _selectedAddOnIds.addAll(_allAddOns.map((a) => a.id));
    } else if (catName.contains('juice')) {
      _selectedSizeIds.addAll(_allSizes.map((s) => s.id));
      final nata = _allAddOns.where((a) => a.name.toLowerCase().contains('nata'));
      _selectedAddOnIds.addAll(nata.map((a) => a.id));
    } else if (catName.contains('tea')) {
      _selectedSizeIds.addAll(_allSizes.map((s) => s.id));
      final creamCheese = _allAddOns.where((a) => a.name.toLowerCase().contains('cream cheese'));
      _selectedAddOnIds.addAll(creamCheese.map((a) => a.id));
    }
  }

  /// Pick image from gallery or camera
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  void _showImageSourceBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Pick from Gallery'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
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
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      String? imageUrl;

      // Upload image to Supabase Storage if an image was picked
      if (_selectedImageFile != null) {
        imageUrl = await _databaseService.uploadMenuItemImage(_selectedImageFile!);
      }

      final double price = double.parse(_priceController.text.trim());

      await _databaseService.createMenuItem(
        categoryId: _selectedCategory!.id,
        name: _nameController.text.trim(),
        price: price,
        imagePath: imageUrl,
        sizeIds: _selectedSizeIds.toList(),
        addOnIds: _selectedAddOnIds.toList(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product added successfully!')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving product: $e')),
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

    final primaryAccent = isDarkMode ? AppColors.cream : AppColors.bobaBrown;
    final textColor = theme.textTheme.bodyLarge?.color ?? (isDarkMode ? Colors.white : AppColors.darkText);
    final subTextColor = theme.textTheme.bodyMedium?.color?.withOpacity(0.6) ?? (isDarkMode ? Colors.white70 : AppColors.greyText);
    final cardBg = theme.cardColor.withOpacity(isDarkMode ? 0.65 : 0.85);
    final borderColor = theme.dividerColor.withOpacity(isDarkMode ? 0.15 : 0.4);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: primaryAccent))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: textColor,
                              size: 20,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                          Text(
                            'Add New Menu Item',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 20),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // 1. Item Image Upload Card
                      GestureDetector(
                        onTap: _showImageSourceBottomSheet,
                        child: Center(
                          child: Stack(
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: cardBg,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: primaryAccent.withOpacity(0.4),
                                    width: 1.5,
                                  ),
                                  image: _selectedImageFile != null
                                      ? DecorationImage(
                                          image: FileImage(_selectedImageFile!),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: _selectedImageFile == null
                                    ? Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.add_a_photo_rounded,
                                            size: 32,
                                            color: primaryAccent,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Upload Photo',
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
                              if (_selectedImageFile != null)
                                Positioned(
                                  right: 4,
                                  top: 4,
                                  child: GestureDetector(
                                    onTap: () => setState(() => _selectedImageFile = null),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close_rounded,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // 2. Category Selection
                      _buildLabel('Category', textColor),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 40,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _categories.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final category = _categories[index];
                            final isSelected = category.id == _selectedCategory?.id;

                            return ChoiceChip(
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
                              selectedColor: primaryAccent,
                              backgroundColor: cardBg,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              labelStyle: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected
                                    ? (isDarkMode ? AppColors.darkText : Colors.white)
                                    : textColor,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                  color: isSelected ? primaryAccent : borderColor,
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 24),

                      // 3. Item Name
                      _buildLabel('Item Name', textColor),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _nameController,
                        hintText: 'e.g. Mango Bliss Smoothie',
                        theme: theme,
                        isDarkMode: isDarkMode,
                        textColor: textColor,
                        subTextColor: subTextColor,
                        cardBg: cardBg,
                        borderColor: borderColor,
                        primaryAccent: primaryAccent,
                        validator: (val) => val == null || val.trim().isEmpty ? 'Please enter item name' : null,
                      ),

                      const SizedBox(height: 20),

                      // 4. Base Price Input
                      _buildLabel('Base Price (PHP)', textColor),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _priceController,
                        hintText: 'e.g. 120',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(left: 14, right: 8, top: 14, bottom: 14),
                          child: Text('₱', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryAccent)),
                        ),
                        theme: theme,
                        isDarkMode: isDarkMode,
                        textColor: textColor,
                        subTextColor: subTextColor,
                        cardBg: cardBg,
                        borderColor: borderColor,
                        primaryAccent: primaryAccent,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Please enter price';
                          if (double.tryParse(val.trim()) == null) return 'Enter a valid number';
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      // 5. Sizes Selection
                      _buildLabel('Available Sizes', textColor),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: _allSizes.map((size) {
                          final isSelected = _selectedSizeIds.contains(size.id);
                          return FilterChip(
                            label: Text(size.name),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedSizeIds.add(size.id);
                                } else {
                                  _selectedSizeIds.remove(size.id);
                                }
                              });
                            },
                            selectedColor: primaryAccent.withOpacity(0.2),
                            checkmarkColor: primaryAccent,
                            backgroundColor: cardBg,
                            side: BorderSide(color: isSelected ? primaryAccent : borderColor),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 24),

                      // 6. Add-ons Selection
                      _buildLabel('Available Add-ons (₱15.00 each)', textColor),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: _allAddOns.map((addOn) {
                          final isSelected = _selectedAddOnIds.contains(addOn.id);
                          return FilterChip(
                            label: Text(addOn.name),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedAddOnIds.add(addOn.id);
                                } else {
                                  _selectedAddOnIds.remove(addOn.id);
                                }
                              });
                            },
                            selectedColor: primaryAccent.withOpacity(0.2),
                            checkmarkColor: primaryAccent,
                            backgroundColor: cardBg,
                            side: BorderSide(color: isSelected ? primaryAccent : borderColor),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 24),

                      // 7. Initial Status Toggle Card
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderColor),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Initial Status',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _isAvailable ? 'Item will be listed as Available' : 'Item will be listed as Sold Out',
                                  style: TextStyle(fontSize: 12, color: subTextColor),
                                ),
                              ],
                            ),
                            Switch.adaptive(
                              value: _isAvailable,
                              activeColor: primaryAccent,
                              onChanged: (val) => setState(() => _isAvailable = val),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 36),

                      // 8. Save Button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveItem,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryAccent,
                            elevation: 4,
                            shadowColor: primaryAccent.withOpacity(0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : Text(
                                  'Save Product',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode ? AppColors.darkText : Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildLabel(String label, Color textColor) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required ThemeData theme,
    required bool isDarkMode,
    required Color textColor,
    required Color subTextColor,
    required Color cardBg,
    required Color borderColor,
    required Color primaryAccent,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    Widget? prefixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: TextStyle(color: textColor, fontSize: 14),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: subTextColor, fontSize: 14),
        prefixIcon: prefixIcon,
        filled: true,
        fillColor: cardBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primaryAccent, width: 1.5),
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