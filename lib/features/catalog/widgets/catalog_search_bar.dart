import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';

class CatalogSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final String searchQuery;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final String hintText;

  const CatalogSearchBar({
    super.key,
    required this.controller,
    required this.searchQuery,
    required this.onChanged,
    required this.onClear,
    this.hintText = 'Search drinks or snacks',
  });

  @override
  State<CatalogSearchBar> createState() =>
      _CatalogSearchBarState();
}

class _CatalogSearchBarState
    extends State<CatalogSearchBar> {
  late final FocusNode _focusNode;

  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();

    _focusNode = FocusNode();

    _focusNode.addListener(() {
      if (!mounted) return;

      setState(() {
        _hasFocus = _focusNode.hasFocus;
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
    final bool active =
        _hasFocus || widget.searchQuery.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
      ),
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 180,
        ),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: active
                ? AppColors.textPrimary.withValues(
                    alpha: 0.55,
                  )
                : AppColors.border.withValues(
                    alpha: 0.35,
                  ),
            width: active ? 1.15 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: active ? 0.045 : 0.025,
              ),
              blurRadius: active ? 16 : 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            // =================================================
            // SEARCH ICON
            // =================================================

            Padding(
              padding: const EdgeInsets.only(
                left: 15,
              ),
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius:
                      BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.search_rounded,
                  size: 18,
                  color: AppColors.textPrimary,
                ),
              ),
            ),

            // =================================================
            // INPUT
            // =================================================

            Expanded(
              child: TextField(
                controller: widget.controller,
                focusNode: _focusNode,
                onChanged: widget.onChanged,
                cursorColor: AppColors.textPrimary,
                textInputAction:
                    TextInputAction.search,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary
                        .withValues(
                      alpha: 0.55,
                    ),
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 17,
                  ),
                ),
              ),
            ),

            // =================================================
            // CLEAR
            // =================================================

            if (widget.searchQuery.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(
                  right: 9,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.onClear,
                    customBorder:
                        const CircleBorder(),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.border
                              .withValues(
                            alpha: 0.25,
                          ),
                        ),
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 16,
                        color:
                            AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}