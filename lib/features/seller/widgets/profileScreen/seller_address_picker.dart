import 'package:flutter/material.dart';
import 'package:philippines_rpcmb/philippines_rpcmb.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

// ============================================================================
// SELLER ADDRESS RESULT
// ============================================================================

class SellerAddressResult {
  final dynamic region;
  final dynamic province;
  final dynamic municipality;
  final dynamic barangay;

  final String detailedAddress;
  final String fullAddress;

  const SellerAddressResult({
    required this.region,
    required this.province,
    required this.municipality,
    required this.barangay,
    required this.detailedAddress,
    required this.fullAddress,
  });
}

// ============================================================================
// SHOW SELLER ADDRESS PICKER
// ============================================================================

Future<SellerAddressResult?> showSellerAddressPicker({
  required BuildContext context,
  dynamic initialRegion,
  dynamic initialProvince,
  dynamic initialMunicipality,
  dynamic initialBarangay,
  String initialDetailedAddress = '',
}) {
  return showModalBottomSheet<SellerAddressResult>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.40),
    builder: (BuildContext context) {
      return SellerAddressPicker(
        initialRegion: initialRegion,
        initialProvince: initialProvince,
        initialMunicipality: initialMunicipality,
        initialBarangay: initialBarangay,
        initialDetailedAddress: initialDetailedAddress,
      );
    },
  );
}

// ============================================================================
// SELLER ADDRESS PICKER
// ============================================================================

class SellerAddressPicker extends StatefulWidget {
  final dynamic initialRegion;
  final dynamic initialProvince;
  final dynamic initialMunicipality;
  final dynamic initialBarangay;

  final String initialDetailedAddress;

  const SellerAddressPicker({
    super.key,
    this.initialRegion,
    this.initialProvince,
    this.initialMunicipality,
    this.initialBarangay,
    this.initialDetailedAddress = '',
  });

  @override
  State<SellerAddressPicker> createState() =>
      _SellerAddressPickerState();
}

class _SellerAddressPickerState extends State<SellerAddressPicker> {
  // ==========================================================================
  // STORE LOCATION
  //
  // The Legit Smoothie store is located in Quezon City.
  //
  // Seller/store addresses are therefore restricted to:
  //
  // NCR
  //   -> Quezon City
  //      -> Barangay
  //         -> Detailed address
  //
  // The seller cannot select another city.
  // ==========================================================================

  dynamic _region;
  dynamic _province;
  dynamic _municipality;
  dynamic _barangay;

  late final TextEditingController _detailsController;

  bool _isPreparing = true;

  // ==========================================================================
  // INIT
  // ==========================================================================

  @override
  void initState() {
    super.initState();

    _detailsController = TextEditingController(
      text: widget.initialDetailedAddress,
    );

    _prepareAddressData();
  }

  // ==========================================================================
  // DISPOSE
  // ==========================================================================

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  // ==========================================================================
  // ITEM NAME
  // ==========================================================================

  String _itemName(dynamic item) {
    if (item == null) {
      return '';
    }

    if (item is String) {
      return item.trim();
    }

    try {
      final dynamic name = item.name;

      if (name != null &&
          name.toString().trim().isNotEmpty) {
        return name.toString().trim();
      }
    } catch (_) {
      // Try regionName next.
    }

    try {
      final dynamic regionName = item.regionName;

      if (regionName != null &&
          regionName.toString().trim().isNotEmpty) {
        return regionName.toString().trim();
      }
    } catch (_) {
      // Fall through.
    }

    return item.toString().trim();
  }

  // ==========================================================================
  // NORMALIZE CITY
  // ==========================================================================

  String _normalizeCityName(String value) {
    final String name = value
        .trim()
        .toLowerCase()
        .replaceAll(
          RegExp(r'\s+'),
          ' ',
        );

    const Map<String, String> aliases = {
      'quezon city': 'quezon city',
      'city of quezon': 'quezon city',
      'city of quezon city': 'quezon city',
    };

    return aliases[name] ?? name;
  }

  // ==========================================================================
  // PREPARE ADDRESS DATA
  // ==========================================================================

  void _prepareAddressData() {
    dynamic ncr;
    dynamic quezonCity;
    dynamic quezonCityProvince;

    // ------------------------------------------------------------------------
    // 1. FIND NCR
    // ------------------------------------------------------------------------

    for (final dynamic region in philippineRegions) {
      try {
        final String id =
            region.id.toString().trim().toUpperCase();

        if (id == 'NCR') {
          ncr = region;
          break;
        }
      } catch (_) {
        // Continue.
      }
    }

    // ------------------------------------------------------------------------
    // Fallback using region name.
    // ------------------------------------------------------------------------

    if (ncr == null) {
      for (final dynamic region in philippineRegions) {
        try {
          final String name = region.regionName
              .toString()
              .trim()
              .toLowerCase();

          if (name == 'ncr' ||
              name.contains(
                'national capital region',
              )) {
            ncr = region;
            break;
          }
        } catch (_) {
          // Continue.
        }
      }
    }

    // ------------------------------------------------------------------------
    // NCR NOT FOUND
    // ------------------------------------------------------------------------

    if (ncr == null) {
      if (mounted) {
        setState(() {
          _isPreparing = false;
        });
      }

      return;
    }

    _region = ncr;

    // ------------------------------------------------------------------------
    // 2. FIND QUEZON CITY
    //
    // RPCMB structure:
    //
    // NCR
    //   -> NCR District
    //      -> Municipality / City
    //         -> Barangays
    //
    // In the current RPCMB data Quezon City is located under:
    //
    // NATIONAL CAPITAL REGION - SECOND DISTRICT
    // ------------------------------------------------------------------------

    try {
      for (final dynamic province in ncr.provinces) {
        for (final dynamic municipality
            in province.municipalities) {
          final String cityName =
              _normalizeCityName(
            _itemName(municipality),
          );

          if (cityName == 'quezon city') {
            quezonCity = municipality;
            quezonCityProvince = province;
            break;
          }
        }

        if (quezonCity != null) {
          break;
        }
      }
    } catch (error) {
      debugPrint(
        'SELLER QUEZON CITY ERROR: $error',
      );
    }

    // ------------------------------------------------------------------------
    // QUEZON CITY NOT FOUND
    // ------------------------------------------------------------------------

    if (quezonCity == null) {
      if (mounted) {
        setState(() {
          _municipality = null;
          _province = null;
          _barangay = null;
          _isPreparing = false;
        });
      }

      return;
    }

    // ------------------------------------------------------------------------
    // 3. LOCK STORE CITY TO QUEZON CITY
    // ------------------------------------------------------------------------

    _municipality = quezonCity;
    _province = quezonCityProvince;

    // ------------------------------------------------------------------------
    // 4. RESTORE EXISTING BARANGAY
    //
    // We intentionally do not restore another municipality/city.
    // Even if an old seller address contains another city, the picker is
    // now permanently restricted to Quezon City.
    // ------------------------------------------------------------------------

    if (widget.initialBarangay != null) {
      final String previousBarangay =
          _itemName(
        widget.initialBarangay,
      ).trim().toLowerCase();

      for (final dynamic barangay in _barangays) {
        if (_itemName(barangay)
                .trim()
                .toLowerCase() ==
            previousBarangay) {
          _barangay = barangay;
          break;
        }
      }
    }

    // ------------------------------------------------------------------------
    // DONE
    // ------------------------------------------------------------------------

    if (mounted) {
      setState(() {
        _isPreparing = false;
      });
    }
  }

  // ==========================================================================
  // BARANGAYS
  // ==========================================================================

  List<dynamic> get _barangays {
    if (_municipality == null) {
      return <dynamic>[];
    }

    try {
      final List<dynamic> barangays =
          List<dynamic>.from(
        _municipality.barangays,
      );

      barangays.sort(
        (dynamic a, dynamic b) {
          return _itemName(a)
              .toLowerCase()
              .compareTo(
                _itemName(b).toLowerCase(),
              );
        },
      );

      return barangays;
    } catch (error) {
      debugPrint(
        'SELLER ADDRESS BARANGAY ERROR: $error',
      );

      return <dynamic>[];
    }
  }

  // ==========================================================================
  // DISPLAY HELPERS
  // ==========================================================================

  String _toTitleCase(String value) {
    if (value.trim().isEmpty) {
      return '';
    }

    return value
        .trim()
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .map(
          (String word) {
            if (word.isEmpty) {
              return word;
            }

            return '${word[0].toUpperCase()}'
                '${word.substring(1)}';
          },
        )
        .join(' ');
  }

  // ==========================================================================
  // BUILD ADDRESS
  // ==========================================================================

  String _buildAddress() {
    final List<String> parts = [
      _detailsController.text.trim(),
      _toTitleCase(
        _itemName(_barangay),
      ),
      'Quezon City',
      'Metro Manila',
    ]
        .where(
          (String value) =>
              value.trim().isNotEmpty,
        )
        .toList();

    return parts.join(', ');
  }

  // ==========================================================================
  // SAVE
  // ==========================================================================

  void _saveAddress() {
    // ------------------------------------------------------------------------
    // QUEZON CITY MUST BE AVAILABLE
    // ------------------------------------------------------------------------

    if (_municipality == null ||
        _normalizeCityName(
              _itemName(_municipality),
            ) !=
            'quezon city') {
      _showMessage(
        'Quezon City address data could not be loaded.',
      );

      return;
    }

    // ------------------------------------------------------------------------
    // BARANGAY
    // ------------------------------------------------------------------------

    if (_barangay == null) {
      _showMessage(
        'Please select the store barangay.',
      );

      return;
    }

    // ------------------------------------------------------------------------
    // DETAILED ADDRESS
    // ------------------------------------------------------------------------

    if (_detailsController.text
        .trim()
        .isEmpty) {
      _showMessage(
        'Please enter the house number, street or building.',
      );

      return;
    }

    // ------------------------------------------------------------------------
    // RETURN RESULT
    // ------------------------------------------------------------------------

    Navigator.of(context).pop(
      SellerAddressResult(
        region: _region,
        province: _province,
        municipality: _municipality,
        barangay: _barangay,
        detailedAddress:
            _detailsController.text.trim(),
        fullAddress: _buildAddress(),
      ),
    );
  }

  // ==========================================================================
  // MESSAGE
  // ==========================================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor:
              AppColors.textPrimary,
          behavior:
              SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(14),
          ),
          margin:
              const EdgeInsets.all(16),
        ),
      );
  }

  // ==========================================================================
  // BUILD
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    final double keyboard =
        MediaQuery.of(context)
            .viewInsets
            .bottom;

    return AnimatedPadding(
      duration:
          const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(
        bottom: keyboard,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight:
              MediaQuery.of(context)
                      .size
                      .height *
                  0.90,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius:
              const BorderRadius.vertical(
            top: Radius.circular(30),
          ),
          border: Border(
            top: BorderSide(
              color: AppColors.border
                  .withValues(
                alpha: 0.30,
              ),
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black
                  .withValues(
                alpha: 0.08,
              ),
              blurRadius: 30,
              offset:
                  const Offset(0, -6),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: _isPreparing
              ? const SizedBox(
                  height: 300,
                  child: Center(
                    child:
                        CircularProgressIndicator(
                      color:
                          AppColors.textPrimary,
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding:
                      const EdgeInsets.fromLTRB(
                    AppConstants.defaultPadding,
                    10,
                    AppConstants.defaultPadding,
                    24,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      // ======================================================
                      // HANDLE
                      // ======================================================

                      Center(
                        child: Container(
                          width: 38,
                          height: 4,
                          decoration:
                              BoxDecoration(
                            color:
                                AppColors.border,
                            borderRadius:
                                BorderRadius
                                    .circular(20),
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 22,
                      ),

                      // ======================================================
                      // HEADER
                      // ======================================================

                      Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration:
                                BoxDecoration(
                              color: AppColors
                                  .textPrimary,
                              borderRadius:
                                  BorderRadius
                                      .circular(15),
                            ),
                            child: const Icon(
                              Icons
                                  .storefront_outlined,
                              color: Colors.white,
                              size: 21,
                            ),
                          ),

                          const SizedBox(
                            width: 13,
                          ),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [
                                Text(
                                  'STORE LOCATION',
                                  style: TextStyle(
                                    fontSize: 7,
                                    fontWeight:
                                        FontWeight
                                            .w900,
                                    letterSpacing:
                                        1.1,
                                    color: AppColors
                                        .textSecondary
                                        .withValues(
                                      alpha: 0.62,
                                    ),
                                  ),
                                ),

                                const SizedBox(
                                  height: 4,
                                ),

                                const Text(
                                  'Store address',
                                  style: TextStyle(
                                    fontSize: 20,
                                    height: 1,
                                    fontWeight:
                                        FontWeight
                                            .w900,
                                    letterSpacing:
                                        -0.4,
                                    color: AppColors
                                        .textPrimary,
                                  ),
                                ),

                                const SizedBox(
                                  height: 7,
                                ),

                                Text(
                                  'Set the physical location of The Legit Smoothie in Quezon City.',
                                  style: TextStyle(
                                    fontSize: 9,
                                    height: 1.4,
                                    color: AppColors
                                        .textSecondary
                                        .withValues(
                                      alpha: 0.70,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(
                            width: 8,
                          ),

                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                Navigator.of(
                                  context,
                                ).pop();
                              },
                              customBorder:
                                  const CircleBorder(),
                              child: Ink(
                                width: 38,
                                height: 38,
                                decoration:
                                    BoxDecoration(
                                  color: AppColors
                                      .background,
                                  shape:
                                      BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors
                                        .border
                                        .withValues(
                                      alpha: 0.25,
                                    ),
                                  ),
                                ),
                                child: const Icon(
                                  Icons
                                      .close_rounded,
                                  size: 18,
                                  color: AppColors
                                      .textPrimary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 22,
                      ),

                      // ======================================================
                      // STORE INFO
                      // ======================================================

                      Container(
                        width: double.infinity,
                        padding:
                            const EdgeInsets.all(14),
                        decoration:
                            BoxDecoration(
                          color:
                              AppColors.background,
                          borderRadius:
                              BorderRadius.circular(
                            16,
                          ),
                          border: Border.all(
                            color: AppColors.border
                                .withValues(
                              alpha: 0.25,
                            ),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration:
                                  BoxDecoration(
                                color:
                                    AppColors.surface,
                                borderRadius:
                                    BorderRadius
                                        .circular(11),
                              ),
                              child: const Icon(
                                Icons
                                    .location_on_outlined,
                                size: 17,
                                color: AppColors
                                    .textPrimary,
                              ),
                            ),

                            const SizedBox(
                              width: 11,
                            ),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  const Text(
                                    'QUEZON CITY ONLY',
                                    style: TextStyle(
                                      fontSize: 7,
                                      fontWeight:
                                          FontWeight
                                              .w900,
                                      letterSpacing:
                                          0.8,
                                      color: AppColors
                                          .textPrimary,
                                    ),
                                  ),

                                  const SizedBox(
                                    height: 5,
                                  ),

                                  Text(
                                    'The store location is restricted to Quezon City. Select the barangay and enter the exact street or building address.',
                                    style: TextStyle(
                                      fontSize: 8.5,
                                      height: 1.4,
                                      color: AppColors
                                          .textSecondary
                                          .withValues(
                                        alpha: 0.70,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      // ======================================================
                      // CITY - LOCKED TO QUEZON CITY
                      // ======================================================

                      Text(
                        'CITY',
                        style: TextStyle(
                          fontSize: 6.5,
                          fontWeight:
                              FontWeight.w900,
                          letterSpacing: 0.9,
                          color: AppColors
                              .textSecondary
                              .withValues(
                            alpha: 0.60,
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 7,
                      ),

                      Container(
                        width: double.infinity,
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        decoration:
                            BoxDecoration(
                          color:
                              AppColors.background,
                          borderRadius:
                              BorderRadius.circular(
                            14,
                          ),
                          border: Border.all(
                            color: AppColors.border
                                .withValues(
                              alpha: 0.28,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons
                                  .location_city_outlined,
                              size: 18,
                              color: AppColors
                                  .textSecondary,
                            ),

                            const SizedBox(
                              width: 12,
                            ),

                            const Expanded(
                              child: Text(
                                'Quezon City',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight:
                                      FontWeight
                                          .w700,
                                  color: AppColors
                                      .textPrimary,
                                ),
                              ),
                            ),

                            Container(
                              width: 30,
                              height: 30,
                              decoration:
                                  BoxDecoration(
                                color: AppColors
                                    .surface,
                                shape:
                                    BoxShape.circle,
                              ),
                              child: Icon(
                                Icons
                                    .lock_outline_rounded,
                                size: 14,
                                color: AppColors
                                    .textSecondary
                                    .withValues(
                                  alpha: 0.65,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      // ======================================================
                      // BARANGAY
                      // ======================================================

                      _SellerAddressDropdown<dynamic>(
                        key: ValueKey(
                          'seller_barangay_${_itemName(_municipality)}',
                        ),
                        label: 'BARANGAY',
                        icon: Icons
                            .home_work_outlined,
                        value: _barangay,
                        items: _barangays,
                        itemName:
                            (dynamic item) {
                          return _toTitleCase(
                            _itemName(item),
                          );
                        },
                        hint: _municipality == null
                            ? 'Quezon City data unavailable'
                            : 'Select barangay',
                        enabled:
                            _municipality != null &&
                                _barangays
                                    .isNotEmpty,
                        onChanged:
                            (dynamic value) {
                          setState(() {
                            _barangay = value;
                          });
                        },
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      // ======================================================
                      // DETAILS
                      // ======================================================

                      _SellerAddressTextField(
                        controller:
                            _detailsController,
                        label:
                            'HOUSE / STREET / BUILDING',
                        hint:
                            'House no., street, subdivision, building...',
                        icon:
                            Icons.home_outlined,
                        onChanged: (_) {
                          setState(() {});
                        },
                      ),

                      const SizedBox(
                        height: 18,
                      ),

                      // ======================================================
                      // PREVIEW
                      // ======================================================

                      if (_municipality != null &&
                          _barangay != null)
                        _SellerAddressPreview(
                          address:
                              _buildAddress(),
                        ),

                      const SizedBox(
                        height: 20,
                      ),

                      // ======================================================
                      // SAVE
                      // ======================================================

                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: FilledButton(
                          onPressed:
                              _municipality == null
                                  ? null
                                  : _saveAddress,
                          style:
                              FilledButton.styleFrom(
                            backgroundColor:
                                AppColors
                                    .textPrimary,
                            foregroundColor:
                                Colors.white,
                            disabledBackgroundColor:
                                AppColors
                                    .textSecondary
                                    .withValues(
                              alpha: 0.25,
                            ),
                            elevation: 0,
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius
                                      .circular(17),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .center,
                            children: [
                              Icon(
                                Icons
                                    .check_rounded,
                                size: 18,
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              Text(
                                'Use this store address',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight:
                                      FontWeight
                                          .w900,
                                ),
                              ),
                            ],
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

// ============================================================================
// DROPDOWN
// ============================================================================

class _SellerAddressDropdown<T>
    extends StatelessWidget {
  final String label;
  final IconData icon;
  final T? value;
  final List<T> items;
  final String Function(T) itemName;
  final String hint;
  final bool enabled;
  final ValueChanged<T?> onChanged;

  const _SellerAddressDropdown({
    super.key,
    required this.label,
    required this.icon,
    required this.value,
    required this.items,
    required this.itemName,
    required this.hint,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final T? validValue =
        value != null &&
                items.contains(value)
            ? value
            : null;

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.only(
            left: 2,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 6.5,
              fontWeight:
                  FontWeight.w900,
              letterSpacing: 0.9,
              color: AppColors
                  .textSecondary
                  .withValues(
                alpha: 0.60,
              ),
            ),
          ),
        ),

        const SizedBox(
          height: 7,
        ),

        DropdownButtonFormField<T>(
          initialValue: validValue,
          isExpanded: true,
          icon: const Icon(
            Icons
                .keyboard_arrow_down_rounded,
          ),
          decoration:
              InputDecoration(
            prefixIcon: Icon(
              icon,
              size: 18,
              color:
                  AppColors.textSecondary,
            ),
            filled: true,
            fillColor:
                AppColors.background,
            contentPadding:
                const EdgeInsets
                    .symmetric(
              horizontal: 13,
              vertical: 15,
            ),
            border:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(
                14,
              ),
              borderSide:
                  BorderSide(
                color: AppColors.border
                    .withValues(
                  alpha: 0.28,
                ),
              ),
            ),
            enabledBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(
                14,
              ),
              borderSide:
                  BorderSide(
                color: AppColors.border
                    .withValues(
                  alpha: 0.28,
                ),
              ),
            ),
            disabledBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(
                14,
              ),
              borderSide:
                  BorderSide(
                color: AppColors.border
                    .withValues(
                  alpha: 0.18,
                ),
              ),
            ),
            focusedBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(
                14,
              ),
              borderSide:
                  const BorderSide(
                color:
                    AppColors.textPrimary,
                width: 1.2,
              ),
            ),
          ),
          hint: Text(
            hint,
            style: TextStyle(
              fontSize: 10,
              color: AppColors
                  .textSecondary
                  .withValues(
                alpha: 0.55,
              ),
            ),
          ),
          items: items.map(
            (T item) {
              return DropdownMenuItem<T>(
                value: item,
                child: Text(
                  itemName(item),
                  maxLines: 1,
                  overflow:
                      TextOverflow
                          .ellipsis,
                  style:
                      const TextStyle(
                    fontSize: 10.5,
                    fontWeight:
                        FontWeight
                            .w600,
                    color: AppColors
                        .textPrimary,
                  ),
                ),
              );
            },
          ).toList(),
          onChanged:
              enabled
                  ? onChanged
                  : null,
        ),
      ],
    );
  }
}

// ============================================================================
// DETAILS FIELD
// ============================================================================

class _SellerAddressTextField
    extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final ValueChanged<String>? onChanged;

  const _SellerAddressTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.only(
            left: 2,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 6.5,
              fontWeight:
                  FontWeight.w900,
              letterSpacing: 0.9,
              color: AppColors
                  .textSecondary
                  .withValues(
                alpha: 0.60,
              ),
            ),
          ),
        ),

        const SizedBox(
          height: 7,
        ),

        TextFormField(
          controller: controller,
          onChanged: onChanged,
          textCapitalization:
              TextCapitalization.words,
          minLines: 2,
          maxLines: 4,
          style: const TextStyle(
            fontSize: 11,
            fontWeight:
                FontWeight.w700,
            color:
                AppColors.textPrimary,
          ),
          decoration:
              InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 10,
              color: AppColors
                  .textSecondary
                  .withValues(
                alpha: 0.45,
              ),
            ),
            prefixIcon: Icon(
              icon,
              size: 18,
              color:
                  AppColors.textSecondary,
            ),
            filled: true,
            fillColor:
                AppColors.background,
            contentPadding:
                const EdgeInsets
                    .symmetric(
              horizontal: 14,
              vertical: 15,
            ),
            border:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(
                14,
              ),
              borderSide:
                  BorderSide(
                color: AppColors.border
                    .withValues(
                  alpha: 0.30,
                ),
              ),
            ),
            enabledBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(
                14,
              ),
              borderSide:
                  BorderSide(
                color: AppColors.border
                    .withValues(
                  alpha: 0.30,
                ),
              ),
            ),
            focusedBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(
                14,
              ),
              borderSide:
                  const BorderSide(
                color:
                    AppColors.textPrimary,
                width: 1.2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// ADDRESS PREVIEW
// ============================================================================

class _SellerAddressPreview
    extends StatelessWidget {
  final String address;

  const _SellerAddressPreview({
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(14),
      decoration:
          BoxDecoration(
        color: AppColors.background,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border
              .withValues(
            alpha: 0.24,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.pin_drop_outlined,
            size: 18,
            color:
                AppColors.textPrimary,
          ),

          const SizedBox(
            width: 10,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  'STORE ADDRESS PREVIEW',
                  style:
                      TextStyle(
                    fontSize: 6.5,
                    fontWeight:
                        FontWeight.w900,
                    letterSpacing: 0.9,
                    color: AppColors
                        .textSecondary
                        .withValues(
                      alpha: 0.60,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 5,
                ),

                Text(
                  address,
                  style:
                      const TextStyle(
                    fontSize: 10,
                    height: 1.45,
                    fontWeight:
                        FontWeight.w700,
                    color: AppColors
                        .textPrimary,
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