import 'package:flutter/material.dart';
import 'package:the_legit_smoothie/features/cart/models/cart_item_model.dart';
import 'package:the_legit_smoothie/features/cart/services/cart_service.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/helpers.dart';
import '../../../main.dart';
import '../models/product_model.dart';
import '../models/product_option_model.dart';

class ProductDetailModal extends StatefulWidget {
  final ProductModel product;
  final CartItemModel? cartItem; // If provided, we are editing an existing item

  const ProductDetailModal({
    super.key,
    required this.product,
    this.cartItem,
  });

  static Future<void> show(
    BuildContext context,
    ProductModel product, {
    CartItemModel? cartItem,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (_) => ProductDetailModal(
        product: product,
        cartItem: cartItem,
      ),
    );
  }

  @override
  State<ProductDetailModal> createState() => _ProductDetailModalState();
}

class _ProductDetailModalState extends State<ProductDetailModal> {
  bool _isLoading = true;
  late int _quantity;

  // Options grouped by category
  Map<String, List<ProductOptionModel>> _groupedOptions = {};

  // User Selections
  final Map<String, ProductOptionModel> _singleSelections = {};
  final List<ProductOptionModel> _multiSelections = [];

  bool get _isEditing => widget.cartItem != null;

  @override
  void initState() {
    super.initState();
    _quantity = widget.cartItem?.quantity ?? 1;
    _fetchOptions();
  }

  Future<void> _fetchOptions() async {
    try {
      final res = await supabase
          .from('product_options')
          .select()
          .eq('product_id', widget.product.id)
          .eq('is_available', true);

      final options = (res as List)
          .map((item) => ProductOptionModel.fromJson(item))
          .toList();

      final Map<String, List<ProductOptionModel>> grouped = {};
      for (var opt in options) {
        grouped.putIfAbsent(opt.optionGroup, () => []).add(opt);
      }

      setState(() {
        _groupedOptions = grouped;

        if (_isEditing) {
          // Pre-select existing options from cart item
          final selectedOptionNames = widget.cartItem!.selectedOptions
              .map((o) => o['name'] as String)
              .toSet();

          for (var opt in options) {
            if (selectedOptionNames.contains(opt.optionName)) {
              if (opt.optionGroup == 'Toppings' || opt.optionGroup == 'Add-ons') {
                _multiSelections.add(opt);
              } else {
                _singleSelections[opt.optionGroup] = opt;
              }
            }
          }
        } else {
          // Default selection for non-editing mode
          grouped.forEach((group, opts) {
            if (group != 'Toppings' && group != 'Add-ons' && opts.isNotEmpty) {
              _singleSelections[group] = opts.first;
            }
          });
        }

        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  double get _calculatedTotalPrice {
    double total = widget.product.basePrice;

    for (var opt in _singleSelections.values) {
      total += opt.extraPrice;
    }

    for (var opt in _multiSelections) {
      total += opt.extraPrice;
    }

    return total * _quantity;
  }

  void _handleSaveCart() {
    final selectedOptionsJson = [
      ..._singleSelections.values.map(
        (opt) => {
          'group': opt.optionGroup,
          'name': opt.optionName,
          'extra_price': opt.extraPrice,
        },
      ),
      ..._multiSelections.map(
        (opt) => {
          'group': opt.optionGroup,
          'name': opt.optionName,
          'extra_price': opt.extraPrice,
        },
      ),
    ];

    double singleUnitPrice = widget.product.basePrice;
    for (var opt in _singleSelections.values) {
      singleUnitPrice += opt.extraPrice;
    }
    for (var opt in _multiSelections) {
      singleUnitPrice += opt.extraPrice;
    }

    if (_isEditing) {
      CartService().removeItem(widget.cartItem!.id);
    }

    CartService().addItem(
      product: widget.product,
      selectedOptions: selectedOptionsJson,
      unitPrice: singleUnitPrice,
      quantity: _quantity,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _isEditing
                    ? 'Updated ${widget.product.name} in Cart!'
                    : 'Added ${_quantity}x ${widget.product.name} to Cart!',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 25,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      height: MediaQuery.of(context).size.height * 0.88,
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 38,
            height: 4.5,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.defaultPadding,
              12,
              AppConstants.defaultPadding,
              16,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.border.withValues(alpha: 0.6),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: widget.product.imageUrl != null &&
                            widget.product.imageUrl!.isNotEmpty
                        ? Image.network(
                            widget.product.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildPlaceholder(),
                          )
                        : _buildPlaceholder(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              widget.product.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.4,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () => Navigator.of(context).pop(),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.border.withValues(alpha: 0.6),
                                ),
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                size: 18,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (widget.product.description != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          widget.product.description!,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.3,
                            color: AppColors.textSecondary.withValues(alpha: 0.9),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          AppHelpers.formatCurrency(widget.product.basePrice),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.border.withValues(alpha: 0.5)),

          // Body
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2.5,
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      ..._groupedOptions.entries.map((entry) {
                        final groupName = entry.key;
                        final options = entry.value;
                        final isMultiSelect =
                            groupName == 'Toppings' || groupName == 'Add-ons';

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  groupName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                Text(
                                  isMultiSelect ? 'Optional' : 'Required',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isMultiSelect
                                        ? AppColors.textSecondary
                                        : AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (isMultiSelect)
                              ...options.map((opt) {
                                final isSelected =
                                    _multiSelections.contains(opt);
                                return _buildMultiSelectTile(
                                  option: opt,
                                  isSelected: isSelected,
                                  onChanged: (selected) {
                                    setState(() {
                                      if (selected == true) {
                                        _multiSelections.add(opt);
                                      } else {
                                        _multiSelections.remove(opt);
                                      }
                                    });
                                  },
                                );
                              })
                            else
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: options.map((opt) {
                                  final isSelected =
                                      _singleSelections[groupName] == opt;
                                  return _buildSingleSelectChip(
                                    option: opt,
                                    isSelected: isSelected,
                                    onTap: () {
                                      setState(() {
                                        _singleSelections[groupName] = opt;
                                      });
                                    },
                                  );
                                }).toList(),
                              ),
                            const SizedBox(height: 24),
                          ],
                        );
                      }),
                    ],
                  ),
          ),

          // Bottom Action Bar
          Container(
            padding: EdgeInsets.fromLTRB(
              AppConstants.defaultPadding,
              14,
              AppConstants.defaultPadding,
              14 + MediaQuery.of(context).padding.bottom,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Stepper
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.border.withValues(alpha: 0.8),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_rounded, size: 18),
                        splashRadius: 20,
                        color: _quantity > 1
                            ? AppColors.textPrimary
                            : AppColors.border,
                        onPressed: _quantity > 1
                            ? () => setState(() => _quantity--)
                            : null,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          '$_quantity',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_rounded, size: 18),
                        splashRadius: 20,
                        color: AppColors.textPrimary,
                        onPressed: () => setState(() => _quantity++),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),

                // Primary Button
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSaveCart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _isEditing ? 'Update Cart' : 'Add to Cart',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              AppHelpers.formatCurrency(_calculatedTotalPrice),
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSingleSelectChip({
    required ProductOptionModel option,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.border.withValues(alpha: 0.8),
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              option.optionName,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
            if (option.extraPrice > 0) ...[
              const SizedBox(width: 6),
              Text(
                '+${AppHelpers.formatCurrency(option.extraPrice)}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.85)
                      : AppColors.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMultiSelectTile({
    required ProductOptionModel option,
    required bool isSelected,
    required ValueChanged<bool?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: isSelected
            ? AppColors.primary.withValues(alpha: 0.05)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => onChanged(!isSelected),
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.6)
                    : AppColors.border.withValues(alpha: 0.6),
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary.withValues(alpha: 0.4),
                      width: 1.8,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check_rounded,
                          size: 16,
                          color: Colors.white,
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    option.optionName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                if (option.extraPrice > 0)
                  Text(
                    '+${AppHelpers.formatCurrency(option.extraPrice)}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.primaryAccent.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.local_drink_rounded,
          size: 32,
          color: AppColors.primary,
        ),
      ),
    );
  }
}