import 'package:flutter/material.dart';
import 'package:the_legit_smoothie/core/constants/app_colors.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedCategory = 'Smoothies';
  String _selectedIcon = '🥭';
  bool _isAvailable = true;

  final List<String> _categories = [
    'Smoothies',
    'Milk Tea',
    'Snacks',
    'Add-ons',
  ];

  final List<String> _emojiPicker = [
    '🥭', '🧋', '🥟', '🥑', '🍓', '🍌', '🧆', '🧇', '🍵', '🧃'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveItem() {
    if (_formKey.currentState!.validate()) {
      final newItem = {
        'name': _nameController.text.trim(),
        'category': _selectedCategory,
        'price': '₱${_priceController.text.trim()}',
        'icon': _selectedIcon,
        'isAvailable': _isAvailable,
        'description': _descriptionController.text.trim(),
      };

      // Return the new item back to the calling screen
      Navigator.pop(context, newItem);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final textColor = theme.textTheme.bodyLarge?.color ?? AppColors.darkText;
    final subTextColor = theme.textTheme.bodyMedium?.color?.withOpacity(0.6) ?? AppColors.greyText;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Custom Header replacing AppBar
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
                    // Invisible placeholder to keep title centered
                    const SizedBox(width: 20),
                  ],
                ),

                const SizedBox(height: 24),

                // 1. Icon / Graphic Preview Card
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? Colors.white.withOpacity(0.06)
                              : AppColors.cream.withOpacity(0.6),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.bobaBrown.withOpacity(0.2),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _selectedIcon,
                            style: const TextStyle(fontSize: 44),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Select Icon Preview',
                        style: TextStyle(fontSize: 12, color: subTextColor, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 10),
                      // Emoji Selector Row
                      SizedBox(
                        height: 44,
                        child: ListView.separated(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: _emojiPicker.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final emoji = _emojiPicker[index];
                            final isSelected = emoji == _selectedIcon;
                            return InkWell(
                              onTap: () => setState(() => _selectedIcon = emoji),
                              borderRadius: BorderRadius.circular(12),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.bobaBrown.withOpacity(0.15)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected ? AppColors.bobaBrown : Colors.transparent,
                                  ),
                                ),
                                child: Center(
                                  child: Text(emoji, style: const TextStyle(fontSize: 22)),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
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
                      final isSelected = category == _selectedCategory;

                      return ChoiceChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) setState(() => _selectedCategory = category);
                        },
                        selectedColor: AppColors.bobaBrown,
                        backgroundColor: theme.cardColor,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        labelStyle: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : (isDarkMode ? Colors.white70 : AppColors.darkText),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected ? AppColors.bobaBrown : theme.dividerColor,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // 3. Item Name Input
                _buildLabel('Item Name', textColor),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _nameController,
                  hintText: 'e.g. Mango Graham Crunch',
                  theme: theme,
                  isDarkMode: isDarkMode,
                  textColor: textColor,
                  subTextColor: subTextColor,
                  validator: (val) => val == null || val.isEmpty ? 'Please enter item name' : null,
                ),

                const SizedBox(height: 20),

                // 4. Price Input
                _buildLabel('Price (PHP)', textColor),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _priceController,
                  hintText: 'e.g. 120',
                  keyboardType: TextInputType.number,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(left: 14, right: 8, top: 14, bottom: 14),
                    child: Text('₱', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.bobaBrown)),
                  ),
                  theme: theme,
                  isDarkMode: isDarkMode,
                  textColor: textColor,
                  subTextColor: subTextColor,
                  validator: (val) => val == null || val.isEmpty ? 'Please enter price' : null,
                ),

                const SizedBox(height: 20),

                // 5. Description Input (Optional)
                _buildLabel('Description (Optional)', textColor),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _descriptionController,
                  hintText: 'Short description or ingredients...',
                  maxLines: 3,
                  theme: theme,
                  isDarkMode: isDarkMode,
                  textColor: textColor,
                  subTextColor: subTextColor,
                ),

                const SizedBox(height: 24),

                // 6. Live Availability Status Toggle Card
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDarkMode ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.04),
                    ),
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
                        activeColor: AppColors.bobaBrown,
                        onChanged: (val) => setState(() => _isAvailable = val),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 36),

                // 7. Save Product Action Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _saveItem,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.bobaBrown,
                      elevation: 4,
                      shadowColor: AppColors.bobaBrown.withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Save Product',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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
        fillColor: theme.cardColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDarkMode ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.bobaBrown, width: 1.5),
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