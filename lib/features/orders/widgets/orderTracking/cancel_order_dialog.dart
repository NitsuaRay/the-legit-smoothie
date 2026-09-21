import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class CancelOrderDialog extends StatefulWidget {
  const CancelOrderDialog({
    super.key,
  });

  @override
  State<CancelOrderDialog> createState() =>
      _CancelOrderDialogState();
}

class _CancelOrderDialogState
    extends State<CancelOrderDialog> {
  final TextEditingController _reasonController =
      TextEditingController();

  String? _selectedReason;

  static const List<String> _reasons = [
    'Changed my mind',
    'Ordered by mistake',
    'Delivery time takes too long',
    'Need to modify items in order',
    'Other',
  ];

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  bool get _isOther =>
      _selectedReason == 'Other';

  bool get _canConfirm {
    if (_selectedReason == null) {
      return false;
    }

    if (_isOther) {
      return _reasonController.text
          .trim()
          .isNotEmpty;
    }

    return true;
  }

  void _confirm() {
    if (!_canConfirm) return;

    final String reason = _isOther
        ? _reasonController.text.trim()
        : _selectedReason!;

    Navigator.of(context).pop(reason);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding:
          const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: Container(
        constraints:
            const BoxConstraints(
          maxWidth: 430,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius:
              BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.border
                .withValues(alpha: 0.32),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: 0.12,
              ),
              blurRadius: 35,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 43,
                    height: 43,
                    decoration: BoxDecoration(
                      color: AppColors.error
                          .withValues(
                        alpha: 0.08,
                      ),
                      borderRadius:
                          BorderRadius.circular(
                        13,
                      ),
                    ),
                    child: const Icon(
                      Icons
                          .warning_amber_rounded,
                      size: 20,
                      color: AppColors.error,
                    ),
                  ),

                  const SizedBox(width: 12),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CANCEL ORDER',
                          style: TextStyle(
                            fontSize: 6.5,
                            fontWeight:
                                FontWeight.w900,
                            letterSpacing: 1,
                            color:
                                AppColors.error,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Why are you cancelling?',
                          style: TextStyle(
                            fontSize: 17,
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
                ],
              ),

              const SizedBox(height: 9),

              Text(
                'Select the reason that best describes why you want to cancel this order.',
                style: TextStyle(
                  fontSize: 10,
                  height: 1.45,
                  color: AppColors.textSecondary
                      .withValues(alpha: 0.75),
                ),
              ),

              const SizedBox(height: 17),

              ..._reasons.map(
                (reason) {
                  final bool selected =
                      _selectedReason ==
                          reason;

                  return Padding(
                    padding:
                        const EdgeInsets.only(
                      bottom: 8,
                    ),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedReason =
                              reason;
                        });
                      },
                      borderRadius:
                          BorderRadius.circular(
                        13,
                      ),
                      child:
                          AnimatedContainer(
                        duration: const Duration(
                          milliseconds: 160,
                        ),
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 12,
                          vertical: 11,
                        ),
                        decoration:
                            BoxDecoration(
                          color: selected
                              ? AppColors
                                  .textPrimary
                              : AppColors
                                  .background,
                          borderRadius:
                              BorderRadius
                                  .circular(
                            13,
                          ),
                          border: Border.all(
                            color: selected
                                ? AppColors
                                    .textPrimary
                                : AppColors
                                    .border
                                    .withValues(
                                    alpha:
                                        0.25,
                                  ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 18,
                              height: 18,
                              decoration:
                                  BoxDecoration(
                                shape:
                                    BoxShape.circle,
                                border:
                                    Border.all(
                                  width: 1.5,
                                  color: selected
                                      ? Colors
                                          .white
                                      : AppColors
                                          .textSecondary,
                                ),
                              ),
                              child: selected
                                  ? Center(
                                      child:
                                          Container(
                                        width: 8,
                                        height: 8,
                                        decoration:
                                            const BoxDecoration(
                                          color:
                                              Colors.white,
                                          shape:
                                              BoxShape.circle,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),

                            const SizedBox(
                              width: 10,
                            ),

                            Expanded(
                              child: Text(
                                reason,
                                style:
                                    TextStyle(
                                  fontSize: 10.5,
                                  fontWeight:
                                      FontWeight
                                          .w700,
                                  color: selected
                                      ? Colors
                                          .white
                                      : AppColors
                                          .textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              if (_isOther) ...[
                const SizedBox(height: 3),

                TextField(
                  controller:
                      _reasonController,
                  minLines: 2,
                  maxLines: 4,
                  onChanged: (_) =>
                      setState(() {}),
                  style: const TextStyle(
                    fontSize: 11,
                    color:
                        AppColors.textPrimary,
                  ),
                  decoration:
                      InputDecoration(
                    hintText:
                        'Tell us your reason...',
                    hintStyle: TextStyle(
                      fontSize: 10,
                      color: AppColors
                          .textSecondary
                          .withValues(
                        alpha: 0.55,
                      ),
                    ),
                    filled: true,
                    fillColor:
                        AppColors.background,
                    contentPadding:
                        const EdgeInsets.all(
                      13,
                    ),
                    border:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius
                              .circular(13),
                      borderSide:
                          BorderSide.none,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 14),

              Container(
                padding:
                    const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error
                      .withValues(alpha: 0.05),
                  borderRadius:
                      BorderRadius.circular(13),
                ),
                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      size: 15,
                      color: AppColors.error,
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: Text(
                        'Once cancelled, this action cannot be undone.',
                        style: TextStyle(
                          fontSize: 9,
                          height: 1.35,
                          color: AppColors
                              .textSecondary
                              .withValues(
                            alpha: 0.78,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 17),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          Navigator.of(
                        context,
                      ).pop(),
                      style: OutlinedButton
                          .styleFrom(
                        minimumSize:
                            const Size(
                          0,
                          45,
                        ),
                        side: BorderSide(
                          color: AppColors
                              .border
                              .withValues(
                            alpha: 0.50,
                          ),
                        ),
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            13,
                          ),
                        ),
                      ),
                      child: const Text(
                        'Keep order',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight:
                              FontWeight.w800,
                          color: AppColors
                              .textPrimary,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 9),

                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          _canConfirm
                              ? _confirm
                              : null,
                      style:
                          ElevatedButton
                              .styleFrom(
                        elevation: 0,
                        minimumSize:
                            const Size(
                          0,
                          45,
                        ),
                        backgroundColor:
                            AppColors.error,
                        disabledBackgroundColor:
                            AppColors.error
                                .withValues(
                          alpha: 0.28,
                        ),
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            13,
                          ),
                        ),
                      ),
                      child: const Text(
                        'Cancel order',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight:
                              FontWeight.w900,
                          color: Colors.white,
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
    );
  }
}