import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class CustomerPromoSearch
    extends StatefulWidget {
  final TextEditingController controller;
  final String searchQuery;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const CustomerPromoSearch({
    super.key,
    required this.controller,
    required this.searchQuery,
    required this.onChanged,
    required this.onClear,
  });

  @override
  State<CustomerPromoSearch> createState() =>
      _CustomerPromoSearchState();
}

class _CustomerPromoSearchState
    extends State<CustomerPromoSearch> {
  final FocusNode _focusNode =
      FocusNode();

  bool _focused = false;

  @override
  void initState() {
    super.initState();

    _focusNode.addListener(() {
      if (!mounted) return;

      setState(() {
        _focused =
            _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 18,
      ),
      child: AnimatedContainer(
        duration:
            const Duration(
          milliseconds: 180,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius:
              BorderRadius.circular(17),
          border: Border.all(
            width: _focused ? 1.3 : 1,
            color: _focused
                ? AppColors.textPrimary
                : AppColors.border
                    .withValues(
                    alpha: 0.35,
                  ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black
                  .withValues(
                alpha:
                    _focused ? 0.035 : 0.018,
              ),
              blurRadius:
                  _focused ? 16 : 10,
              offset:
                  const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller:
              widget.controller,
          focusNode: _focusNode,
          onChanged:
              widget.onChanged,
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight:
                FontWeight.w600,
            color:
                AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText:
                'Search deals, drinks or products...',
            hintStyle: TextStyle(
              fontSize: 10.5,
              color: AppColors
                  .textSecondary
                  .withValues(
                alpha: 0.52,
              ),
            ),
            prefixIcon: Padding(
              padding:
                  const EdgeInsets.all(
                8,
              ),
              child: Container(
                width: 34,
                height: 34,
                decoration:
                    BoxDecoration(
                  color: AppColors
                      .background,
                  borderRadius:
                      BorderRadius
                          .circular(
                    10,
                  ),
                ),
                child: const Icon(
                  Icons.search_rounded,
                  size: 16,
                  color: AppColors
                      .textPrimary,
                ),
              ),
            ),
            suffixIcon: widget
                    .searchQuery
                    .isNotEmpty
                ? IconButton(
                    onPressed:
                        widget.onClear,
                    icon: Container(
                      width: 27,
                      height: 27,
                      decoration:
                          BoxDecoration(
                        color: AppColors
                            .background,
                        shape:
                            BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 13,
                        color: AppColors
                            .textPrimary,
                      ),
                    ),
                  )
                : null,
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(
              vertical: 15,
            ),
          ),
        ),
      ),
    );
  }
}