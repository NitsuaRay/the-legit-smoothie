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

      Navigator.pop(context, newItem);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    // Dynamic theme colors that automatically flip based on dark/light mode
    final primaryAccent = isDarkMode ? AppColors.cream : AppColors.bobaBrown;
    final textColor = theme.textTheme.bodyLarge?.color ?? (isDarkMode ? Colors.white : AppColors.darkText);
    final subTextColor = theme.textTheme.bodyMedium?.color?.withOpacity(0.6) ?? (isDarkMode ? Colors.white70 : AppColors.greyText);
    final cardBg = theme.cardColor.withOpacity(isDarkMode ? 0.65 : 0.85);
    final borderColor = theme.dividerColor.withOpacity(isDarkMode ? 0.15 : 0.4);

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
                            color: primaryAccent.withOpacity(0.3),
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
                                      ? primaryAccent.withOpacity(0.15)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected ? primaryAccent : Colors.transparent,
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
                  cardBg: cardBg,
                  borderColor: borderColor,
                  primaryAccent: primaryAccent,
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
                  cardBg: cardBg,
                  borderColor: borderColor,
                  primaryAccent: primaryAccent,
                ),

                const SizedBox(height: 24),

                // 6. Live Availability Status Toggle Card
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

                // 7. Save Product Action Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _saveItem,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryAccent,
                      elevation: 4,
                      shadowColor: primaryAccent.withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
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