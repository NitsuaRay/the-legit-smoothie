import 'package:flutter/material.dart';
import 'package:the_legit_smoothie/features/cart/services/cart_service.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/helpers.dart';
import '../../../main.dart';
import '../models/product_model.dart';
import '../models/product_option_model.dart';

class ProductDetailModal extends StatefulWidget {
  final ProductModel product;

  const ProductDetailModal({super.key, required this.product});

  static Future<void> show(BuildContext context, ProductModel product) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProductDetailModal(product: product),
    );
  }

  @override
  State<ProductDetailModal> createState() => _ProductDetailModalState();
}

class _ProductDetailModalState extends State<ProductDetailModal> {
  bool _isLoading = true;
  int _quantity = 1;

  // Options grouped by category (e.g., {"Size": [...], "Toppings": [...]})
  Map<String, List<ProductOptionModel>> _groupedOptions = {};

  // User Selections
  // Single choice options (Size, Sugar Level, Flavor) -> GroupName: Option
  final Map<String, ProductOptionModel> _singleSelections = {};

  // Multiple choice options (Toppings, Add-ons) -> List<Option>
  final List<ProductOptionModel> _multiSelections = [];

  @override
  void initState() {
    super.initState();
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

        // Auto-select first item in single-choice groups (e.g. Size, Sugar)
        grouped.forEach((group, opts) {
          if (group != 'Toppings' && group != 'Add-ons' && opts.isNotEmpty) {
            _singleSelections[group] = opts.first;
          }
        });

        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Price Calculation: (Base + Options) * Quantity
  double get _calculatedTotalPrice {
    double total = widget.product.basePrice;

    // Add single selection prices
    for (var opt in _singleSelections.values) {
      total += opt.extraPrice;
    }

    // Add multi selection prices
    for (var opt in _multiSelections) {
      total += opt.extraPrice;
    }

    return total * _quantity;
  }

  void _handleAddToCart() {
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

    // Calculate unit price for 1 item
    double singleUnitPrice = widget.product.basePrice;
    for (var opt in _singleSelections.values) {
      singleUnitPrice += opt.extraPrice;
    }
    for (var opt in _multiSelections) {
      singleUnitPrice += opt.extraPrice;
    }

    // Add to global cart state
    CartService().addItem(
      product: widget.product,
      selectedOptions: selectedOptionsJson,
      unitPrice: singleUnitPrice,
      quantity: _quantity,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${_quantity}x ${widget.product.name} to Cart!'),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      height: MediaQuery.of(context).size.height * 0.85,
      child: Column(
        children: [
          // Drag handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 12),

          // Modal Header & Item Info
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.defaultPadding,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: AppColors.primaryAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.local_drink_rounded,
                    size: 40,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (widget.product.description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.product.description!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 6),
                      Text(
                        AppHelpers.formatCurrency(widget.product.basePrice),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 24),

          // Dynamic Customization Options
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.defaultPadding,
                    ),
                    children: [
                      ..._groupedOptions.entries.map((entry) {
                        final groupName = entry.key;
                        final options = entry.value;
                        final isMultiSelect =
                            groupName == 'Toppings' || groupName == 'Add-ons';

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              groupName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Single Choice Radio Tiles or Multi Choice Checkboxes
                            ...options.map((opt) {
                              if (isMultiSelect) {
                                final isSelected = _multiSelections.contains(
                                  opt,
                                );
                                return CheckboxListTile(
                                  value: isSelected,
                                  activeColor: AppColors.primary,
                                  title: Text(opt.optionName),
                                  subtitle: opt.extraPrice > 0
                                      ? Text(
                                          '+ ${AppHelpers.formatCurrency(opt.extraPrice)}',
                                        )
                                      : null,
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
                              } else {
                                // Wrap your tiles collection with a RadioGroup
                                return RadioGroup<ProductOptionModel>(
                                  groupValue: _singleSelections[groupName],
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() {
                                        _singleSelections[groupName] = val;
                                      });
                                    }
                                  },
                                  child: Builder(
                                    builder: (context) {
                                      // Look up individual items. Note that 'isSelected' is deleted
                                      // since RadioGroup handles the active/selected UI states natively.
                                      return RadioListTile<ProductOptionModel>(
                                        value: opt,
                                        activeColor: AppColors.primary,
                                        title: Text(opt.optionName),
                                        subtitle: opt.extraPrice > 0
                                            ? Text(
                                                '+ ${AppHelpers.formatCurrency(opt.extraPrice)}',
                                              )
                                            : null,
                                      );
                                    },
                                  ),
                                );
                              }
                            }),
                            const SizedBox(height: 16),
                          ],
                        );
                      }),
                    ],
                  ),
          ),

          // Bottom Bar (Quantity Selector & Add to Cart)
          Container(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                // Quantity Counter
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, size: 18),
                        onPressed: _quantity > 1
                            ? () => setState(() => _quantity--)
                            : null,
                      ),
                      Text(
                        '$_quantity',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, size: 18),
                        onPressed: () => setState(() => _quantity++),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),

                // Add to Cart Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleAddToCart,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      'Add to Cart - ${AppHelpers.formatCurrency(_calculatedTotalPrice)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.white,
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
}
