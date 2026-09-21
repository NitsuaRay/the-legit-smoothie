import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class UpdateNotesDialog extends StatefulWidget {
  final String currentNotes;
  final Future<void> Function(String) onSave;

  const UpdateNotesDialog({
    super.key,
    required this.currentNotes,
    required this.onSave,
  });

  static Future<void> show({
    required BuildContext context,
    required String currentNotes,
    required Future<void> Function(String) onSave,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.38),
      builder: (_) {
        return UpdateNotesDialog(
          currentNotes: currentNotes,
          onSave: onSave,
        );
      },
    );
  }

  @override
  State<UpdateNotesDialog> createState() =>
      _UpdateNotesDialogState();
}

class _UpdateNotesDialogState extends State<UpdateNotesDialog> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  bool _isLoading = false;
  bool _isFocused = false;

  static const int _maxNotesLength = 200;

  final List<_QuickSuggestion> _quickSuggestions = const [
    _QuickSuggestion(
      label: 'Call on arrival',
      icon: Icons.phone_outlined,
    ),
    _QuickSuggestion(
      label: 'Ring the bell',
      icon: Icons.notifications_none_rounded,
    ),
    _QuickSuggestion(
      label: 'Leave at the door',
      icon: Icons.door_front_door_outlined,
    ),
    _QuickSuggestion(
      label: 'Handle with care',
      icon: Icons.inventory_2_outlined,
    ),
  ];

  // ==============================================================
  // INIT
  // ==============================================================

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(
      text: widget.currentNotes,
    );

    _focusNode = FocusNode();

    _controller.addListener(_refresh);

    _focusNode.addListener(() {
      if (!mounted) return;

      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_refresh);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // ==============================================================
  // QUICK SUGGESTIONS
  // ==============================================================

  void _toggleSuggestion(String suggestion) {
    if (_isLoading) return;

    final List<String> currentParts = _controller.text
        .split('•')
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList();

    final int existingIndex = currentParts.indexWhere(
      (value) =>
          value.toLowerCase() == suggestion.toLowerCase(),
    );

    if (existingIndex >= 0) {
      currentParts.removeAt(existingIndex);
    } else {
      currentParts.add(suggestion);
    }

    String result = currentParts.join(' • ');

    if (result.length > _maxNotesLength) {
      result = result.substring(
        0,
        _maxNotesLength,
      );
    }

    _controller.value = TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(
        offset: result.length,
      ),
    );
  }

  bool _containsSuggestion(String suggestion) {
    return _controller.text
        .toLowerCase()
        .contains(suggestion.toLowerCase());
  }

  // ==============================================================
  // CLEAR
  // ==============================================================

  void _clearNotes() {
    if (_isLoading) return;

    _controller.clear();
  }

  // ==============================================================
  // SAVE
  // ==============================================================

  Future<void> _saveNotes() async {
    if (_isLoading) return;

    final String notes =
        _controller.text.trim();

    setState(() {
      _isLoading = true;
    });

    try {
      await widget.onSave(notes);

      if (!mounted) return;

      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            backgroundColor: AppColors.error,
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(14),
            ),
            content: const Row(
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 18,
                  color: Colors.white,
                ),
                SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'Unable to save your order instructions. Please try again.',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight:
                          FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ==============================================================
  // BUILD
  // ==============================================================

  @override
  Widget build(BuildContext context) {
    final int characterCount =
        _controller.text.length;

    final bool hasNotes =
        _controller.text.trim().isNotEmpty;

    final bool nearingLimit =
        characterCount >=
        (_maxNotesLength * 0.85);

    final double keyboardHeight =
        MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
        bottom: keyboardHeight,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight:
              MediaQuery.sizeOf(context).height *
                  0.88,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius:
              const BorderRadius.vertical(
            top: Radius.circular(28),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: 0.12,
              ),
              blurRadius: 35,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            physics:
                const BouncingScrollPhysics(),
            padding:
                const EdgeInsets.fromLTRB(
              18,
              10,
              18,
              20,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                // ==================================================
                // HANDLE
                // ==================================================

                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border
                          .withValues(alpha: 0.70),
                      borderRadius:
                          BorderRadius.circular(20),
                    ),
                  ),
                ),

                const SizedBox(height: 17),

                // ==================================================
                // HEADER
                // ==================================================

                Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color:
                            AppColors.textPrimary,
                        borderRadius:
                            BorderRadius.circular(
                          14,
                        ),
                      ),
                      child: const Icon(
                        Icons
                            .sticky_note_2_outlined,
                        size: 19,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ORDER DETAILS',
                            style: TextStyle(
                              fontSize: 7,
                              height: 1,
                              fontWeight:
                                  FontWeight.w900,
                              letterSpacing: 1.15,
                              color: AppColors
                                  .textSecondary
                                  .withValues(
                                alpha: 0.50,
                              ),
                            ),
                          ),

                          const SizedBox(height: 6),

                          const Text(
                            'Order instructions',
                            style: TextStyle(
                              fontSize: 20,
                              height: 1,
                              fontWeight:
                                  FontWeight.w900,
                              letterSpacing: -0.5,
                              color: AppColors
                                  .textPrimary,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            'Add anything we should know while preparing or handing over your order.',
                            style: TextStyle(
                              fontSize: 10,
                              height: 1.4,
                              fontWeight:
                                  FontWeight.w500,
                              color: AppColors
                                  .textSecondary
                                  .withValues(
                                alpha: 0.72,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _isLoading
                            ? null
                            : () =>
                                Navigator.of(
                                  context,
                                ).pop(),
                        borderRadius:
                            BorderRadius.circular(
                          12,
                        ),
                        child: Ink(
                          width: 36,
                          height: 36,
                          decoration:
                              BoxDecoration(
                            color: AppColors
                                .background,
                            borderRadius:
                                BorderRadius.circular(
                              12,
                            ),
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 17,
                            color: AppColors
                                .textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                // ==================================================
                // INPUT HEADER
                // ==================================================

                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'YOUR NOTE',
                        style: TextStyle(
                          fontSize: 7,
                          fontWeight:
                              FontWeight.w900,
                          letterSpacing: 1,
                          color: AppColors
                              .textSecondary,
                        ),
                      ),
                    ),

                    if (hasNotes)
                      GestureDetector(
                        onTap: _clearNotes,
                        child: Padding(
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          child: Text(
                            'CLEAR',
                            style: TextStyle(
                              fontSize: 7,
                              fontWeight:
                                  FontWeight.w900,
                              letterSpacing: 0.8,
                              color: AppColors
                                  .textSecondary
                                  .withValues(
                                alpha: 0.70,
                              ),
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(width: 7),

                    AnimatedContainer(
                      duration: const Duration(
                        milliseconds: 180,
                      ),
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: nearingLimit
                            ? AppColors.error
                                .withValues(
                                alpha: 0.07,
                              )
                            : AppColors.background,
                        borderRadius:
                            BorderRadius.circular(
                          20,
                        ),
                      ),
                      child: Text(
                        '$characterCount/$_maxNotesLength',
                        style: TextStyle(
                          fontSize: 7.5,
                          fontWeight:
                              FontWeight.w800,
                          color: nearingLimit
                              ? AppColors.error
                              : AppColors
                                  .textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // ==================================================
                // PREMIUM TEXT AREA
                // ==================================================

                AnimatedContainer(
                  duration: const Duration(
                    milliseconds: 180,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius:
                        BorderRadius.circular(18),
                    border: Border.all(
                      width: _isFocused ? 1.4 : 1,
                      color: _isFocused
                          ? AppColors.textPrimary
                          : AppColors.border
                              .withValues(
                              alpha: 0.40,
                            ),
                    ),
                    boxShadow: _isFocused
                        ? [
                            BoxShadow(
                              color: Colors.black
                                  .withValues(
                                alpha: 0.035,
                              ),
                              blurRadius: 16,
                              offset:
                                  const Offset(0, 5),
                            ),
                          ]
                        : null,
                  ),
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    enabled: !_isLoading,
                    minLines: 4,
                    maxLines: 5,
                    maxLength:
                        _maxNotesLength,
                    keyboardType:
                        TextInputType.multiline,
                    textInputAction:
                        TextInputAction.newline,
                    textAlignVertical:
                        TextAlignVertical.top,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.5,
                      fontWeight:
                          FontWeight.w600,
                      color:
                          AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      hintText:
                          'Add preparation or delivery instructions...',
                      hintStyle: TextStyle(
                        fontSize: 11,
                        height: 1.45,
                        fontWeight:
                            FontWeight.w500,
                        color: AppColors
                            .textSecondary
                            .withValues(
                          alpha: 0.48,
                        ),
                      ),
                      prefixIcon: SizedBox(
                        width: 43,
                        child: Align(
                          alignment:
                              Alignment.topCenter,
                          child: Padding(
                            padding:
                                const EdgeInsets
                                    .only(
                              top: 15,
                            ),
                            child: Icon(
                              Icons
                                  .edit_note_rounded,
                              size: 19,
                              color: _isFocused
                                  ? AppColors
                                      .textPrimary
                                  : AppColors
                                      .textSecondary
                                      .withValues(
                                      alpha:
                                          0.60,
                                    ),
                            ),
                          ),
                        ),
                      ),
                      prefixIconConstraints:
                          const BoxConstraints(
                        minWidth: 43,
                        maxWidth: 43,
                        minHeight: 43,
                      ),
                      contentPadding:
                          const EdgeInsets
                              .fromLTRB(
                        6,
                        15,
                        13,
                        15,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ==================================================
                // QUICK PICKS
                // ==================================================

                Row(
                  children: [
                    Container(
                      width: 31,
                      height: 31,
                      decoration: BoxDecoration(
                        color:
                            AppColors.background,
                        borderRadius:
                            BorderRadius.circular(
                          9,
                        ),
                      ),
                      child: const Icon(
                        Icons
                            .bolt_outlined,
                        size: 15,
                        color: AppColors
                            .textPrimary,
                      ),
                    ),

                    const SizedBox(width: 9),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quick picks',
                            style: TextStyle(
                              fontSize: 12,
                              height: 1,
                              fontWeight:
                                  FontWeight.w800,
                              color: AppColors
                                  .textPrimary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Tap to add or remove',
                            style: TextStyle(
                              fontSize: 8,
                              color: AppColors
                                  .textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 11),

                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children:
                      _quickSuggestions.map(
                    (suggestion) {
                      final bool selected =
                          _containsSuggestion(
                        suggestion.label,
                      );

                      return _SuggestionChip(
                        suggestion: suggestion,
                        selected: selected,
                        enabled: !_isLoading,
                        onTap: () =>
                            _toggleSuggestion(
                          suggestion.label,
                        ),
                      );
                    },
                  ).toList(),
                ),

                const SizedBox(height: 19),

                // ==================================================
                // INFORMATION
                // ==================================================

                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        AppColors.background,
                    borderRadius:
                        BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.border
                          .withValues(
                        alpha: 0.28,
                      ),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration:
                            BoxDecoration(
                          color:
                              AppColors.surface,
                          borderRadius:
                              BorderRadius.circular(
                            9,
                          ),
                        ),
                        child: const Icon(
                          Icons
                              .info_outline_rounded,
                          size: 14,
                          color: AppColors
                              .textPrimary,
                        ),
                      ),

                      const SizedBox(width: 9),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            const Text(
                              'GOOD TO KNOW',
                              style: TextStyle(
                                fontSize: 6.5,
                                fontWeight:
                                    FontWeight
                                        .w900,
                                letterSpacing:
                                    0.9,
                                color: AppColors
                                    .textSecondary,
                              ),
                            ),

                            const SizedBox(
                              height: 5,
                            ),

                            Text(
                              'Special requests are subject to availability and may not always be possible to fulfill.',
                              style: TextStyle(
                                fontSize: 9,
                                height: 1.4,
                                fontWeight:
                                    FontWeight
                                        .w500,
                                color: AppColors
                                    .textSecondary
                                    .withValues(
                                  alpha: 0.72,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ==================================================
                // PRIMARY CTA
                // ==================================================

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : _saveNotes,
                    style:
                        ElevatedButton.styleFrom(
                      elevation: 0,
                      shadowColor:
                          Colors.transparent,
                      backgroundColor:
                          AppColors.textPrimary,
                      disabledBackgroundColor:
                          AppColors.textPrimary
                              .withValues(
                            alpha: 0.45,
                          ),
                      foregroundColor:
                          Colors.white,
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          15,
                        ),
                      ),
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(
                        milliseconds: 180,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              key: ValueKey(
                                'loading',
                              ),
                              width: 19,
                              height: 19,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                                color:
                                    Colors.white,
                              ),
                            )
                          : Row(
                              key: const ValueKey(
                                'save',
                              ),
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .center,
                              children: [
                                Icon(
                                  hasNotes
                                      ? Icons
                                          .check_rounded
                                      : Icons
                                          .delete_outline_rounded,
                                  size: 17,
                                ),
                                const SizedBox(
                                  width: 7,
                                ),
                                Text(
                                  hasNotes
                                      ? 'Save instructions'
                                      : 'Clear instructions',
                                  style:
                                      const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight:
                                        FontWeight
                                            .w900,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),

                const SizedBox(height: 9),

                Center(
                  child: Text(
                    'You can update these instructions while your order allows changes.',
                    textAlign:
                        TextAlign.center,
                    style: TextStyle(
                      fontSize: 7.5,
                      height: 1.35,
                      color: AppColors
                          .textSecondary
                          .withValues(
                        alpha: 0.52,
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
}

// =================================================================
// QUICK SUGGESTION MODEL
// =================================================================

class _QuickSuggestion {
  final String label;
  final IconData icon;

  const _QuickSuggestion({
    required this.label,
    required this.icon,
  });
}

// =================================================================
// QUICK SUGGESTION CHIP
// =================================================================

class _SuggestionChip extends StatelessWidget {
  final _QuickSuggestion suggestion;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  const _SuggestionChip({
    required this.suggestion,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius:
            BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(
            milliseconds: 170,
          ),
          padding:
              const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.textPrimary
                : AppColors.background,
            borderRadius:
                BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? AppColors.textPrimary
                  : AppColors.border
                      .withValues(
                      alpha: 0.35,
                    ),
            ),
          ),
          child: Row(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              Icon(
                selected
                    ? Icons.check_rounded
                    : suggestion.icon,
                size: 13,
                color: selected
                    ? Colors.white
                    : AppColors
                        .textSecondary,
              ),

              const SizedBox(width: 6),

              Text(
                suggestion.label,
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight:
                      FontWeight.w700,
                  color: selected
                      ? Colors.white
                      : AppColors
                          .textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}