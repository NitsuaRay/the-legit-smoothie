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
  final CartItemModel? cartItem;

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
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (_) => ProductDetailModal(
        product: product,
        cartItem: cartItem,
      ),
    );
  }

  @override
  State<ProductDetailModal> createState() =>
      _ProductDetailModalState();
}

class _ProductDetailModalState
    extends State<ProductDetailModal> {
  bool _isLoading = true;

  late int _quantity;

  Map<String, List<ProductOptionModel>>
      _groupedOptions = {};

  final Map<String, ProductOptionModel>
      _singleSelections = {};

  final List<ProductOptionModel>
      _multiSelections = [];

  bool get _isEditing => widget.cartItem != null;

  bool get _hasOptions => _groupedOptions.isNotEmpty;

  @override
  void initState() {
    super.initState();

    _quantity = widget.cartItem?.quantity ?? 1;

    _fetchOptions();
  }

  // ================================================================
  // FETCH OPTIONS
  // ================================================================

  Future<void> _fetchOptions() async {
    try {
      final res = await supabase
          .from('product_options')
          .select()
          .eq(
            'product_id',
            widget.product.id,
          )
          .eq(
            'is_available',
            true,
          );

      final options = (res as List)
          .map(
            (item) =>
                ProductOptionModel.fromJson(item),
          )
          .toList();

      final Map<String, List<ProductOptionModel>>
          grouped = {};

      for (final option in options) {
        grouped
            .putIfAbsent(
              option.optionGroup,
              () => [],
            )
            .add(option);
      }

      if (!mounted) return;

      setState(() {
        _groupedOptions = grouped;

        if (_isEditing) {
          final selectedOptionNames = widget
              .cartItem!.selectedOptions
              .map(
                (option) =>
                    option['name'] as String,
              )
              .toSet();

          for (final option in options) {
            if (!selectedOptionNames.contains(
              option.optionName,
            )) {
              continue;
            }

            if (_isMultiSelectGroup(
              option.optionGroup,
            )) {
              _multiSelections.add(option);
            } else {
              _singleSelections[
                      option.optionGroup] =
                  option;
            }
          }
        } else {
          grouped.forEach(
            (group, options) {
              if (!_isMultiSelectGroup(group) &&
                  options.isNotEmpty) {
                _singleSelections[group] =
                    options.first;
              }
            },
          );
        }

        _isLoading = false;
      });
    } catch (error) {

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _isMultiSelectGroup(String group) {
    final normalized =
        group.trim().toLowerCase();

    return normalized == 'toppings' ||
        normalized == 'add-ons' ||
        normalized == 'addons';
  }

  // ================================================================
  // PRICE
  // ================================================================

  double get _unitPrice {
    double total =
        widget.product.basePrice;

    for (final option
        in _singleSelections.values) {
      total += option.extraPrice;
    }

    for (final option
        in _multiSelections) {
      total += option.extraPrice;
    }

    return total;
  }

  double get _calculatedTotalPrice {
    return _unitPrice * _quantity;
  }

  // ================================================================
  // SAVE CART
  // ================================================================

  void _handleSaveCart() {
    final selectedOptionsJson = [
      ..._singleSelections.values.map(
        (option) => {
          'group': option.optionGroup,
          'name': option.optionName,
          'extra_price':
              option.extraPrice,
        },
      ),
      ..._multiSelections.map(
        (option) => {
          'group': option.optionGroup,
          'name': option.optionName,
          'extra_price':
              option.extraPrice,
        },
      ),
    ];

    if (_isEditing) {
      CartService().removeItem(
        widget.cartItem!.id,
      );
    }

    CartService().addItem(
      product: widget.product,
      selectedOptions:
          selectedOptionsJson,
      unitPrice: _unitPrice,
      quantity: _quantity,
    );

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: Colors.white,
              size: 20,
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Text(
                _isEditing
                    ? 'Updated ${widget.product.name} in Cart!'
                    : 'Added ${_quantity}x ${widget.product.name} to Cart!',
                style: const TextStyle(
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        backgroundColor:
            AppColors.primary,
        behavior:
            SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(14),
        ),
        margin:
            const EdgeInsets.all(16),
        duration:
            const Duration(seconds: 2),
      ),
    );

    Navigator.of(context).pop();
  }

  // ================================================================
  // BUILD
  // ================================================================

  @override
  Widget build(BuildContext context) {
    final double screenHeight =
        MediaQuery.sizeOf(context).height;

    return ConstrainedBox(
      constraints: BoxConstraints(
        // IMPORTANT:
        // The modal can be compact for products
        // like Siomai, but never exceed 90%.
        maxHeight: screenHeight * 0.90,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius:
              BorderRadius.vertical(
            top: Radius.circular(30),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ======================================================
            // DRAG HANDLE
            // ======================================================

            const SizedBox(height: 10),

            Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius:
                    BorderRadius.circular(100),
              ),
            ),

            const SizedBox(height: 4),

            // ======================================================
            // SCROLLABLE CONTENT
            // ======================================================

            Flexible(
              child: SingleChildScrollView(
                physics:
                    const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.fromLTRB(
                  AppConstants.defaultPadding,
                  12,
                  AppConstants.defaultPadding,
                  20,
                ),
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    _buildProductHero(),

                    if (_isLoading) ...[
                      const SizedBox(
                        height: 90,
                      ),

                      const Center(
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color:
                              AppColors.primary,
                        ),
                      ),

                      const SizedBox(
                        height: 90,
                      ),
                    ] else if (_hasOptions) ...[
                      const SizedBox(
                        height: 24,
                      ),

                      _buildCustomizationHeader(),

                      const SizedBox(
                        height: 14,
                      ),

                      ..._groupedOptions.entries
                          .map(
                        (entry) =>
                            _buildOptionSection(
                          groupName:
                              entry.key,
                          options:
                              entry.value,
                        ),
                      ),
                    ] else ...[
                      const SizedBox(
                        height: 18,
                      ),

                      _buildReadyToOrderCard(),
                    ],
                  ],
                ),
              ),
            ),

            // ======================================================
            // BOTTOM CART BAR
            // ======================================================

            _buildBottomActionBar(),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // PRODUCT HERO
  // ================================================================

  Widget _buildProductHero() {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding:
              const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius:
                BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.border
                  .withValues(
                alpha: 0.42,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black
                    .withValues(
                  alpha: 0.025,
                ),
                blurRadius: 18,
                offset:
                    const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.center,
            children: [
              // PRODUCT IMAGE
              Container(
                width: 112,
                height: 112,
                padding:
                    const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),
                  border: Border.all(
                    color: AppColors.border
                        .withValues(
                      alpha: 0.35,
                    ),
                  ),
                ),
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(
                    16,
                  ),
                  child:
                      _buildProductImage(),
                ),
              ),

              const SizedBox(width: 15),

              // PRODUCT INFO
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.only(
                    right: 28,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Text(
                        widget.product.name,
                        maxLines: 2,
                        overflow:
                            TextOverflow
                                .ellipsis,
                        style:
                            const TextStyle(
                          fontSize: 19,
                          height: 1.12,
                          fontWeight:
                              FontWeight.w900,
                          letterSpacing:
                              -0.5,
                          color: AppColors
                              .textPrimary,
                        ),
                      ),

                      if (widget.product
                                  .description !=
                              null &&
                          widget
                              .product
                              .description!
                              .trim()
                              .isNotEmpty) ...[
                        const SizedBox(
                          height: 7,
                        ),

                        Text(
                          widget.product
                              .description!,
                          maxLines: 3,
                          overflow:
                              TextOverflow
                                  .ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            height: 1.45,
                            color: AppColors
                                .textSecondary
                                .withValues(
                              alpha: 0.82,
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(
                        height: 12,
                      ),

                      Text(
                        'STARTS AT',
                        style: TextStyle(
                          fontSize: 7.5,
                          fontWeight:
                              FontWeight.w800,
                          letterSpacing: 0.8,
                          color: AppColors
                              .textSecondary
                              .withValues(
                            alpha: 0.55,
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 3,
                      ),

                      Text(
                        AppHelpers
                            .formatCurrency(
                          widget.product
                              .basePrice,
                        ),
                        style:
                            const TextStyle(
                          fontSize: 18,
                          height: 1,
                          fontWeight:
                              FontWeight.w900,
                          letterSpacing:
                              -0.4,
                          color: AppColors
                              .textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // CLOSE BUTTON
        Positioned(
          top: 9,
          right: 9,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () =>
                  Navigator.of(context)
                      .pop(),
              borderRadius:
                  BorderRadius.circular(50),
              child: Ink(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color:
                      AppColors.background,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.border
                        .withValues(
                      alpha: 0.50,
                    ),
                  ),
                ),
                child: const Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: AppColors
                      .textSecondary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ================================================================
  // IMAGE
  // ================================================================

  Widget _buildProductImage() {
    final String? imageUrl =
        widget.product.imageUrl;

    if (imageUrl == null ||
        imageUrl.trim().isEmpty) {
      return _buildPlaceholder();
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.contain,
      alignment: Alignment.center,
      loadingBuilder: (
        context,
        child,
        progress,
      ) {
        if (progress == null) {
          return child;
        }

        return const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child:
                CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
        );
      },
      errorBuilder: (
        context,
        error,
        stackTrace,
      ) {
        return _buildPlaceholder();
      },
    );
  }

  // ================================================================
  // CUSTOMIZATION HEADER
  // ================================================================

  Widget _buildCustomizationHeader() {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'Customize your order',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight:
                      FontWeight.w900,
                  letterSpacing: -0.3,
                  color:
                      AppColors.textPrimary,
                ),
              ),

              SizedBox(height: 3),

              Text(
                'Make it exactly how you like it.',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors
                      .textSecondary,
                ),
              ),
            ],
          ),
        ),

        Container(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 9,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius:
                BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.border
                  .withValues(
                alpha: 0.45,
              ),
            ),
          ),
          child: Text(
            '${_groupedOptions.length} ${_groupedOptions.length == 1 ? 'option' : 'options'}',
            style: const TextStyle(
              fontSize: 8,
              fontWeight:
                  FontWeight.w800,
              color:
                  AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  // ================================================================
  // OPTION SECTION
  // ================================================================

  Widget _buildOptionSection({
    required String groupName,
    required List<ProductOptionModel>
        options,
  }) {
    final bool isMultiSelect =
        _isMultiSelectGroup(groupName);

    return Container(
      width: double.infinity,
      margin:
          const EdgeInsets.only(
        bottom: 12,
      ),
      padding:
          const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border
              .withValues(
            alpha: 0.42,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  groupName,
                  style:
                      const TextStyle(
                    fontSize: 14,
                    fontWeight:
                        FontWeight.w900,
                    letterSpacing: -0.2,
                    color: AppColors
                        .textPrimary,
                  ),
                ),
              ),

              Container(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 8,
                  vertical: 5,
                ),
                decoration:
                    BoxDecoration(
                  color: isMultiSelect
                      ? AppColors
                          .background
                      : AppColors.primary
                          .withValues(
                          alpha: 0.07,
                        ),
                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),
                ),
                child: Text(
                  isMultiSelect
                      ? 'OPTIONAL'
                      : 'REQUIRED',
                  style: TextStyle(
                    fontSize: 7.5,
                    fontWeight:
                        FontWeight.w900,
                    letterSpacing: 0.4,
                    color: isMultiSelect
                        ? AppColors
                            .textSecondary
                        : AppColors
                            .primary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          if (isMultiSelect)
            ...options.map(
              (option) {
                final bool isSelected =
                    _multiSelections
                        .contains(option);

                return _buildMultiSelectTile(
                  option: option,
                  isSelected:
                      isSelected,
                  onChanged: (selected) {
                    setState(() {
                      if (selected ==
                          true) {
                        _multiSelections
                            .add(option);
                      } else {
                        _multiSelections
                            .remove(option);
                      }
                    });
                  },
                );
              },
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: options.map(
                (option) {
                  final bool isSelected =
                      _singleSelections[
                              groupName] ==
                          option;

                  return _buildSingleSelectChip(
                    option: option,
                    isSelected:
                        isSelected,
                    onTap: () {
                      setState(() {
                        _singleSelections[
                                groupName] =
                            option;
                      });
                    },
                  );
                },
              ).toList(),
            ),
        ],
      ),
    );
  }

  // ================================================================
  // SINGLE SELECT
  // ================================================================

  Widget _buildSingleSelectChip({
    required ProductOptionModel option,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(13),
        child: AnimatedContainer(
          duration:
              const Duration(
            milliseconds: 180,
          ),
          padding:
              const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 11,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary
                : AppColors.background,
            borderRadius:
                BorderRadius.circular(13),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : AppColors.border
                      .withValues(
                      alpha: 0.55,
                    ),
            ),
          ),
          child: Row(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              if (isSelected) ...[
                const Icon(
                  Icons.check_rounded,
                  size: 14,
                  color: Colors.white,
                ),
                const SizedBox(
                  width: 5,
                ),
              ],

              Text(
                option.optionName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight:
                      FontWeight.w800,
                  color: isSelected
                      ? Colors.white
                      : AppColors
                          .textPrimary,
                ),
              ),

              if (option.extraPrice >
                  0) ...[
                const SizedBox(
                  width: 6,
                ),

                Text(
                  '+${AppHelpers.formatCurrency(option.extraPrice)}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight:
                        FontWeight.w700,
                    color: isSelected
                        ? Colors.white
                            .withValues(
                            alpha: 0.78,
                          )
                        : AppColors
                            .textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ================================================================
  // MULTI SELECT
  // ================================================================

  Widget _buildMultiSelectTile({
    required ProductOptionModel option,
    required bool isSelected,
    required ValueChanged<bool?>
        onChanged,
  }) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 8,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () =>
              onChanged(!isSelected),
          borderRadius:
              BorderRadius.circular(14),
          child: AnimatedContainer(
            duration:
                const Duration(
              milliseconds: 180,
            ),
            padding:
                const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 11,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary
                      .withValues(
                      alpha: 0.055,
                    )
                  : AppColors.background,
              borderRadius:
                  BorderRadius.circular(14),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                        .withValues(
                        alpha: 0.35,
                      )
                    : AppColors.border
                        .withValues(
                        alpha: 0.45,
                      ),
              ),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration:
                      const Duration(
                    milliseconds: 180,
                  ),
                  width: 21,
                  height: 21,
                  decoration:
                      BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.surface,
                    borderRadius:
                        BorderRadius.circular(
                      6,
                    ),
                    border: Border.all(
                      color: isSelected
                          ? AppColors
                              .primary
                          : AppColors
                              .border,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons
                              .check_rounded,
                          size: 14,
                          color:
                              Colors.white,
                        )
                      : null,
                ),

                const SizedBox(
                  width: 11,
                ),

                Expanded(
                  child: Text(
                    option.optionName,
                    style:
                        const TextStyle(
                      fontSize: 12,
                      fontWeight:
                          FontWeight.w700,
                      color: AppColors
                          .textPrimary,
                    ),
                  ),
                ),

                if (option.extraPrice >
                    0)
                  Text(
                    '+${AppHelpers.formatCurrency(option.extraPrice)}',
                    style:
                        const TextStyle(
                      fontSize: 11,
                      fontWeight:
                          FontWeight.w800,
                      color: AppColors
                          .textPrimary,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================================================================
  // NO OPTIONS
  // ================================================================

  Widget _buildReadyToOrderCard() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 13,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.border
              .withValues(
            alpha: 0.42,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.success
                  .withValues(
                alpha: 0.08,
              ),
              borderRadius:
                  BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons
                  .check_circle_outline_rounded,
              size: 19,
              color: AppColors.success,
            ),
          ),

          const SizedBox(width: 11),

          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Ready to order',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                        FontWeight.w800,
                    color: AppColors
                        .textPrimary,
                  ),
                ),

                SizedBox(height: 2),

                Text(
                  'No customization needed for this item.',
                  style: TextStyle(
                    fontSize: 9.5,
                    color: AppColors
                        .textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // BOTTOM ACTION BAR
  // ================================================================

  Widget _buildBottomActionBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppConstants.defaultPadding,
        12,
        AppConstants.defaultPadding,
        12 +
            MediaQuery.paddingOf(context)
                .bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.border
                .withValues(
              alpha: 0.35,
            ),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withValues(
              alpha: 0.035,
            ),
            blurRadius: 16,
            offset:
                const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // QUANTITY
          Container(
            height: 50,
            padding:
                const EdgeInsets.symmetric(
              horizontal: 4,
            ),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius:
                  BorderRadius.circular(15),
              border: Border.all(
                color: AppColors.border
                    .withValues(
                  alpha: 0.50,
                ),
              ),
            ),
            child: Row(
              children: [
                _buildQuantityButton(
                  icon:
                      Icons.remove_rounded,
                  enabled: _quantity > 1,
                  onTap: () {
                    if (_quantity > 1) {
                      setState(() {
                        _quantity--;
                      });
                    }
                  },
                ),

                SizedBox(
                  width: 30,
                  child: Text(
                    '$_quantity',
                    textAlign:
                        TextAlign.center,
                    style:
                        const TextStyle(
                      fontSize: 14,
                      fontWeight:
                          FontWeight.w900,
                      color: AppColors
                          .textPrimary,
                    ),
                  ),
                ),

                _buildQuantityButton(
                  icon:
                      Icons.add_rounded,
                  onTap: () {
                    setState(() {
                      _quantity++;
                    });
                  },
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // ADD TO CART
          Expanded(
            child: SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : _handleSaveCart,
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      AppColors.primary,
                  foregroundColor:
                      Colors.white,
                  disabledBackgroundColor:
                      AppColors.primary
                          .withValues(
                    alpha: 0.45,
                  ),
                  elevation: 0,
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 15,
                  ),
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      15,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _isEditing
                            ? 'Update Cart'
                            : 'Add to Cart',
                        style:
                            const TextStyle(
                          fontSize: 13,
                          fontWeight:
                              FontWeight.w800,
                        ),
                      ),
                    ),

                    Container(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration:
                          BoxDecoration(
                        color: Colors.white
                            .withValues(
                          alpha: 0.13,
                        ),
                        borderRadius:
                            BorderRadius
                                .circular(
                          10,
                        ),
                      ),
                      child: Text(
                        AppHelpers
                            .formatCurrency(
                          _calculatedTotalPrice,
                        ),
                        style:
                            const TextStyle(
                          fontSize: 11,
                          fontWeight:
                              FontWeight.w900,
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
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled
            ? onTap
            : null,
        borderRadius:
            BorderRadius.circular(10),
        child: SizedBox(
          width: 34,
          height: 40,
          child: Icon(
            icon,
            size: 17,
            color: enabled
                ? AppColors.textPrimary
                : AppColors.textSecondary
                    .withValues(
                    alpha: 0.25,
                  ),
          ),
        ),
      ),
    );
  }

  // ================================================================
  // PLACEHOLDER
  // ================================================================

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.background,
      child: Center(
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.primary
                .withValues(
              alpha: 0.06,
            ),
            borderRadius:
                BorderRadius.circular(15),
          ),
          child: const Icon(
            Icons.local_drink_outlined,
            size: 25,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}