import 'package:flutter/material.dart';
import 'package:the_legit_smoothie/core/constants/app_constants.dart';
import '../../../core/constants/app_colors.dart';

/// Modern Premium Edit Notes Sheet
class UpdateNotesDialog extends StatefulWidget {
  final String currentNotes;
  final Function(String) onSave;

  const UpdateNotesDialog({
    super.key,
    required this.currentNotes,
    required this.onSave,
  });

  static Future<void> show({
    required BuildContext context,
    required String currentNotes,
    required Function(String) onSave,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          UpdateNotesDialog(currentNotes: currentNotes, onSave: onSave),
    );
  }

  @override
  State<UpdateNotesDialog> createState() => _UpdateNotesDialogState();
}

class _UpdateNotesDialogState extends State<UpdateNotesDialog> {
  late final TextEditingController _controller;

  bool _isLoading = false;

  static const int _maxNotesLength = 200;

  final List<String> _quickSuggestions = [
    'Call on arrival',
    'Ring the bell',
    'Leave at the door',
    'Handle with care',
  ];

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(text: widget.currentNotes);

    _controller.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _insertSuggestion(String suggestion) {
    if (_isLoading) return;

    final currentText = _controller.text.trim();

    String newText;

    if (currentText.isEmpty) {
      newText = suggestion;
    } else if (currentText.toLowerCase().contains(suggestion.toLowerCase())) {
      newText = currentText;
    } else {
      newText = '$currentText • $suggestion';
    }

    if (newText.length > _maxNotesLength) {
      newText = newText.substring(0, _maxNotesLength);
    }

    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }

  Future<void> _saveNotes() async {
    if (_isLoading) return;

    final notes = _controller.text.trim();

    setState(() {
      _isLoading = true;
    });

    try {
      await widget.onSave(notes);

      // Guard the State after the async gap
      if (!mounted) return;

      Navigator.of(context).pop();
    } catch (e) {
      // Guard the State before using context
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to save your order instructions. Please try again.',
          ),
          backgroundColor: AppColors.error,
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

  @override
  Widget build(BuildContext context) {
    final int characterCount = _controller.text.length;
    final bool hasNotes = _controller.text.trim().isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 30,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==================================================
                // HANDLE
                // ==================================================
                Center(
                  child: Container(
                    width: 42,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.border.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ==================================================
                // HEADER
                // ==================================================
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withValues(alpha: 0.14),
                            AppColors.primary.withValues(alpha: 0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.10),
                        ),
                      ),
                      child: const Icon(
                        Icons.edit_note_rounded,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),

                    const SizedBox(width: 12),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order Instructions',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.4,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Add a note to help us prepare your order just the way you like it.',
                            style: TextStyle(
                              fontSize: 12.5,
                              height: 1.4,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                // ==================================================
                // TEXT FIELD LABEL
                // ==================================================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Your Note',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '$characterCount/$_maxNotesLength',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: characterCount > _maxNotesLength * 0.9
                            ? AppColors.error
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // ==================================================
                // PREMIUM TEXT FIELD
                // ==================================================
                AnimatedContainer(
                  width: double.infinity,
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: AppColors.background.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: _controller.text.isNotEmpty
                          ? AppColors.primary.withValues(alpha: 0.35)
                          : AppColors.border.withValues(alpha: 0.65),
                    ),
                    boxShadow: _controller.text.isNotEmpty
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.05),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: TextField(
                    controller: _controller,
                    enabled: !_isLoading,

                    maxLines: 4,
                    minLines: 4,
                    maxLength: _maxNotesLength,

                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    textAlignVertical: TextAlignVertical.top,

                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.45,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),

                    decoration: InputDecoration(
                      counterText: '',

                      hintText:
                          'e.g. Please add extra ice, call when you arrive...',

                      hintStyle: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary.withValues(alpha: 0.65),
                      ),

                      // IMPORTANT: constrain the icon's width.
                      prefixIcon: const SizedBox(
                        width: 44,
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: EdgeInsets.only(top: 14),
                            child: Icon(
                              Icons.sticky_note_2_outlined,
                              size: 20,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),

                      prefixIconConstraints: const BoxConstraints(
                        minWidth: 44,
                        maxWidth: 44,
                        minHeight: 44,
                      ),

                      contentPadding: const EdgeInsets.fromLTRB(8, 16, 14, 16),

                      border: InputBorder.none,

                      // Useful for multiline fields.
                      alignLabelWithHint: true,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ==================================================
                // QUICK SUGGESTIONS
                // ==================================================
                const Text(
                  'Quick Suggestions',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 10),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _quickSuggestions.map((suggestion) {
                    final bool isSelected = _controller.text
                        .toLowerCase()
                        .contains(suggestion.toLowerCase());

                    return InkWell(
                      borderRadius: BorderRadius.circular(30),
                      onTap: _isLoading
                          ? null
                          : () => _insertSuggestion(suggestion),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.10)
                              : AppColors.background,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary.withValues(alpha: 0.25)
                                : AppColors.border.withValues(alpha: 0.65),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isSelected
                                  ? Icons.check_rounded
                                  : Icons.add_rounded,
                              size: 14,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              suggestion,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 22),

                // ==================================================
                // INFO MESSAGE
                // ==================================================
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.045),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.info_outline_rounded,
                          size: 16,
                          color: AppColors.primary,
                        ),
                      ),

                      const SizedBox(width: 9),

                      const Expanded(
                        child: Text(
                          'Special requests are subject to availability and may not always be possible to fulfill.',
                          style: TextStyle(
                            fontSize: 11.5,
                            height: 1.4,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // ==================================================
                // ACTION BUTTONS
                // ==================================================
                Row(
                  children: [
                    // CANCEL
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: OutlinedButton(
                          onPressed: _isLoading
                              ? null
                              : () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textPrimary,
                            side: BorderSide(
                              color: AppColors.border.withValues(alpha: 0.8),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // SAVE
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveNotes,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            disabledBackgroundColor: AppColors.primary
                                .withValues(alpha: 0.55),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 180),
                            child: _isLoading
                                ? const SizedBox(
                                    key: ValueKey('saving'),
                                    width: 21,
                                    height: 21,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.3,
                                      color: Colors.white,
                                    ),
                                  )
                                : Row(
                                    key: const ValueKey('save'),
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.check_rounded, size: 19),
                                      const SizedBox(width: 7),
                                      Text(
                                        hasNotes
                                            ? 'Save Instructions'
                                            : 'Clear Instructions',
                                        style: const TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CancelledOrderCard extends StatelessWidget {
  final String? cancelReason;

  const CancelledOrderCard({super.key, required this.cancelReason});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.cancel_outlined, color: AppColors.error),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'This order has been cancelled.',
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          if (cancelReason != null && cancelReason!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Reason: $cancelReason',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.error.withValues(alpha: 0.9),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class CancelOrderDialog extends StatefulWidget {
  const CancelOrderDialog({super.key});

  @override
  State<CancelOrderDialog> createState() => _CancelOrderDialogState();
}

class _CancelOrderDialogState extends State<CancelOrderDialog> {
  final TextEditingController reasonController = TextEditingController();

  String? selectedPresetReason;

  final List<String> presetReasons = const [
    'Changed my mind',
    'Ordered by mistake',
    'Delivery time takes too long',
    'Need to modify items in order',
    'Other',
  ];

  @override
  void dispose() {
    reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isOtherSelected = selectedPresetReason == 'Other';

    final customReason = reasonController.text.trim();

    final bool canConfirm =
        selectedPresetReason != null &&
        (!isOtherSelected || customReason.isNotEmpty);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.45)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.14),
              blurRadius: 32,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.10),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        color: AppColors.error,
                        size: 32,
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Center(
                    child: Text(
                      'Cancel Order?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Center(
                    child: Text(
                      'Tell us why you want to cancel this order.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.45,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  RadioGroup<String>(
                    groupValue: selectedPresetReason,
                    onChanged: (value) {
                      setState(() {
                        selectedPresetReason = value;
                      });
                    },
                    child: Column(
                      children: presetReasons.map((reason) {
                        final bool isSelected = selectedPresetReason == reason;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              setState(() {
                                selectedPresetReason = reason;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              curve: Curves.easeOut,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary.withValues(alpha: 0.08)
                                    : AppColors.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.border.withValues(alpha: 0.7),
                                  width: isSelected ? 1.4 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Radio<String>(
                                    value: reason,
                                    activeColor: AppColors.primary,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      reason,
                                      style: TextStyle(
                                        fontSize: 14.5,
                                        height: 1.25,
                                        color: AppColors.textPrimary,
                                        fontWeight: isSelected
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    child: isOtherSelected
                        ? Padding(
                            key: const ValueKey('other_reason_field'),
                            padding: const EdgeInsets.only(top: 4),
                            child: TextField(
                              controller: reasonController,
                              maxLines: 3,
                              minLines: 2,
                              onChanged: (_) => setState(() {}),
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Type your reason here...',
                                hintStyle: const TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                                filled: true,
                                fillColor: AppColors.border.withValues(
                                  alpha: 0.12,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 14,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: AppColors.border.withValues(
                                      alpha: 0.8,
                                    ),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: AppColors.border.withValues(
                                      alpha: 0.8,
                                    ),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: AppColors.primary,
                                    width: 1.4,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),

                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 18,
                          color: AppColors.error,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Once cancelled, this action cannot be undone.',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12.5,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(
                              color: AppColors.border.withValues(alpha: 0.9),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            'Keep Order',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: AppColors.error,
                            disabledBackgroundColor: AppColors.error.withValues(
                              alpha: 0.35,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: canConfirm
                              ? () {
                                  final reason = selectedPresetReason == 'Other'
                                      ? reasonController.text.trim()
                                      : selectedPresetReason!;

                                  Navigator.of(context).pop(reason);
                                }
                              : null,
                          child: const Text(
                            'Cancel Order',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
