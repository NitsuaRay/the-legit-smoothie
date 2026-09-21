import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';

// ============================================================================
// ADDRESS RESULT
// ============================================================================

class PhilippineAddressResult {
  final dynamic region;
  final dynamic province;
  final dynamic municipality;
  final dynamic barangay;

  final String detailedAddress;
  final String fullAddress;

  const PhilippineAddressResult({
    required this.region,
    required this.province,
    required this.municipality,
    required this.barangay,
    required this.detailedAddress,
    required this.fullAddress,
  });
}

// ============================================================================
// SHOW ADDRESS PICKER
// ============================================================================

Future<PhilippineAddressResult?> showPhilippineAddressPicker({
  required BuildContext context,
  required List<dynamic> regions,
  dynamic initialRegion,
  dynamic initialProvince,
  dynamic initialMunicipality,
  dynamic initialBarangay,
  String initialDetailedAddress = '',
}) {
  return showModalBottomSheet<PhilippineAddressResult>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(
      alpha: 0.40,
    ),
    builder: (BuildContext context) {
      return PhilippineAddressPicker(
        regions: regions,
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
// PHILIPPINE ADDRESS PICKER
// ============================================================================

class PhilippineAddressPicker extends StatefulWidget {
  final List<dynamic> regions;

  final dynamic initialRegion;
  final dynamic initialProvince;
  final dynamic initialMunicipality;
  final dynamic initialBarangay;

  final String initialDetailedAddress;

  const PhilippineAddressPicker({
    super.key,
    required this.regions,
    this.initialRegion,
    this.initialProvince,
    this.initialMunicipality,
    this.initialBarangay,
    this.initialDetailedAddress = '',
  });

  @override
  State<PhilippineAddressPicker> createState() =>
      _PhilippineAddressPickerState();
}

class _PhilippineAddressPickerState
    extends State<PhilippineAddressPicker> {
  // ==========================================================================
  // CURRENT DELIVERY AREA
  //
  // Store:
  // Botocan, Quezon City
  //
  // For now we only allow selected nearby Metro Manila cities.
  //
  // To add another city later, simply add its normalized name here.
  // ==========================================================================

  static const Set<String> _allowedCities = {
    'quezon city',
    'manila',
    'san juan',
    'mandaluyong',
    'marikina',
    'caloocan',
  };

  // ==========================================================================
  // STATE
  // ==========================================================================

  dynamic _region;
  dynamic _province;
  dynamic _municipality;
  dynamic _barangay;

  dynamic _metroManilaRegion;

  List<dynamic> _deliveryCities = [];

  late final TextEditingController _detailsController;

  bool _isPreparingAddressData = true;

  // ==========================================================================
  // INIT
  // ==========================================================================

  @override
  void initState() {
    super.initState();

    _detailsController = TextEditingController(
      text: widget.initialDetailedAddress,
    );

    _prepareDeliveryArea();
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
  //
  // philippines_rpcmb uses typed objects for:
  // Region
  // Province
  // Municipality
  //
  // Barangays are strings in the data shown by your debug output.
  // ==========================================================================

  String _itemName(dynamic item) {
    if (item == null) {
      return '';
    }

    // Barangays
    if (item is String) {
      return item.trim();
    }

    // Province / Municipality
    try {
      final dynamic name = item.name;

      if (name != null &&
          name.toString().trim().isNotEmpty) {
        return name.toString().trim();
      }
    } catch (_) {
      // Continue below.
    }

    // Region
    try {
      final dynamic regionName = item.regionName;

      if (regionName != null &&
          regionName.toString().trim().isNotEmpty) {
        return regionName.toString().trim();
      }
    } catch (_) {
      // Continue below.
    }

    return item.toString().trim();
  }

  // ==========================================================================
  // NORMALIZE CITY NAME
  //
  // Different Philippine datasets sometimes use:
  //
  // QUEZON CITY
  // CITY OF QUEZON
  //
  // CITY OF MANILA
  // MANILA
  //
  // etc.
  //
  // We normalize those variations so filtering still works.
  // ==========================================================================

  String _normalizeCityName(String value) {
    String name = value
        .trim()
        .toLowerCase()
        .replaceAll(
          RegExp(r'\s+'),
          ' ',
        );

    const Map<String, String> aliases = {
      // Quezon City
      'quezon city': 'quezon city',
      'city of quezon': 'quezon city',
      'city of quezon city': 'quezon city',

      // Manila
      'manila': 'manila',
      'city of manila': 'manila',

      // San Juan
      'san juan': 'san juan',
      'city of san juan': 'san juan',

      // Mandaluyong
      'mandaluyong': 'mandaluyong',
      'city of mandaluyong': 'mandaluyong',

      // Marikina
      'marikina': 'marikina',
      'city of marikina': 'marikina',

      // Caloocan
      'caloocan': 'caloocan',
      'city of caloocan': 'caloocan',
    };

    return aliases[name] ?? name;
  }

  // ==========================================================================
  // ALLOWED CITY CHECK
  // ==========================================================================

  bool _isAllowedCity(String cityName) {
    final String normalized =
        _normalizeCityName(cityName);

    return _allowedCities.contains(
      normalized,
    );
  }

  // ==========================================================================
  // PREPARE DELIVERY AREA
  //
  // Actual philippines_rpcmb hierarchy from your debug output:
  //
  // Region NCR
  //    ↓
  // Province / NCR District
  //    ↓
  // Municipality / City
  //    ↓
  // Barangays
  // ==========================================================================

  void _prepareDeliveryArea() {
    dynamic ncr;

    // ------------------------------------------------------------------------
    // 1. FIND NCR
    // ------------------------------------------------------------------------

    for (final dynamic region in widget.regions) {
      try {
        final String id =
            region.id.toString().trim().toUpperCase();

        if (id == 'NCR') {
          ncr = region;
          break;
        }
      } catch (_) {
        // Continue searching.
      }
    }

    // ------------------------------------------------------------------------
    // Fallback: search using regionName.
    // ------------------------------------------------------------------------

    if (ncr == null) {
      for (final dynamic region in widget.regions) {
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
    // NCR still not found.
    // ------------------------------------------------------------------------

    if (ncr == null) {
      if (mounted) {
        setState(() {
          _deliveryCities = [];
          _isPreparingAddressData = false;
        });
      }

      return;
    }

    _metroManilaRegion = ncr;
    _region = ncr;

    // ------------------------------------------------------------------------
    // 2. READ ALL NCR CITIES
    // ------------------------------------------------------------------------

    final List<dynamic> allowedCities = [];

    try {
      for (final dynamic province in ncr.provinces) {
        for (final dynamic municipality
            in province.municipalities) {
          final String cityName =
              _itemName(municipality);

          if (_isAllowedCity(cityName)) {
            final bool alreadyAdded =
                allowedCities.any(
              (dynamic existing) =>
                  _normalizeCityName(
                    _itemName(existing),
                  ) ==
                  _normalizeCityName(
                    cityName,
                  ),
            );

            if (!alreadyAdded) {
              allowedCities.add(
                municipality,
              );
            }
          }
        }
      }
    } catch (error) {
      debugPrint(
        'Error reading NCR cities: $error',
      );
    }

    // ------------------------------------------------------------------------
    // 3. SORT
    //
    // Quezon City should appear first because the store is in Botocan.
    // ------------------------------------------------------------------------

    allowedCities.sort(
      (dynamic a, dynamic b) {
        final String aName =
            _normalizeCityName(
          _itemName(a),
        );

        final String bName =
            _normalizeCityName(
          _itemName(b),
        );

        if (aName == 'quezon city' &&
            bName != 'quezon city') {
          return -1;
        }

        if (bName == 'quezon city' &&
            aName != 'quezon city') {
          return 1;
        }

        return aName.compareTo(
          bName,
        );
      },
    );

    _deliveryCities = allowedCities;

    // ------------------------------------------------------------------------
    // 4. RESTORE EXISTING CITY
    //
    // If customer already selected an allowed city, restore it.
    // ------------------------------------------------------------------------

    if (widget.initialMunicipality != null) {
      final String previousCity =
          _normalizeCityName(
        _itemName(
          widget.initialMunicipality,
        ),
      );

      for (final dynamic city
          in _deliveryCities) {
        final String currentCity =
            _normalizeCityName(
          _itemName(city),
        );

        if (currentCity == previousCity) {
          _municipality = city;
          break;
        }
      }
    }

    // ------------------------------------------------------------------------
    // 5. DEFAULT TO QUEZON CITY
    // ------------------------------------------------------------------------

    if (_municipality == null) {
      for (final dynamic city
          in _deliveryCities) {
        if (_normalizeCityName(
              _itemName(city),
            ) ==
            'quezon city') {
          _municipality = city;
          break;
        }
      }
    }

    // ------------------------------------------------------------------------
    // 6. FIND NCR DISTRICT FOR CITY
    // ------------------------------------------------------------------------

    if (_municipality != null) {
      _findProvinceForCity(
        _municipality,
      );
    }

    // ------------------------------------------------------------------------
    // 7. RESTORE EXISTING BARANGAY
    // ------------------------------------------------------------------------

    if (_municipality != null &&
        widget.initialBarangay != null) {
      final String previousBarangay =
          _itemName(
        widget.initialBarangay,
      ).toLowerCase();

      for (final dynamic barangay
          in _barangays) {
        if (_itemName(barangay)
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
        _isPreparingAddressData = false;
      });
    }
  }

  // ==========================================================================
  // FIND NCR DISTRICT / PROVINCE FOR SELECTED CITY
  //
  // This is kept internally.
  //
  // The customer does NOT manually select the NCR district.
  // ==========================================================================

  void _findProvinceForCity(
    dynamic selectedCity,
  ) {
    _province = null;

    if (_metroManilaRegion == null ||
        selectedCity == null) {
      return;
    }

    final String selectedCityName =
        _normalizeCityName(
      _itemName(selectedCity),
    );

    try {
      for (final dynamic province
          in _metroManilaRegion.provinces) {
        for (final dynamic municipality
            in province.municipalities) {
          final String municipalityName =
              _normalizeCityName(
            _itemName(municipality),
          );

          if (municipalityName ==
              selectedCityName) {
            _province = province;
            return;
          }
        }
      }
    } catch (error) {
      debugPrint(
        'Error finding NCR district: $error',
      );
    }
  }

  // ==========================================================================
  // BARANGAYS
  //
  // Your debug output showed:
  //
  // Municipality(
  //   ...,
  //   barangays: [...]
  // )
  //
  // Therefore we can access .barangays directly.
  // ==========================================================================

  List<dynamic> get _barangays {
    if (_municipality == null) {
      return <dynamic>[];
    }

    try {
      return List<dynamic>.from(
        _municipality.barangays,
      );
    } catch (error) {
      debugPrint(
        'Error reading barangays: $error',
      );

      return <dynamic>[];
    }
  }

  // ==========================================================================
  // BUILD FULL ADDRESS
  //
  // Example:
  //
  // 172 Area 4, Botocan, Quezon City, Metro Manila
  // ==========================================================================

  String _buildAddress() {
    final List<String> parts = [
      _detailsController.text.trim(),
      _formatBarangayName(
        _itemName(_barangay),
      ),
      _displayCityName(
        _itemName(_municipality),
      ),
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
  // DISPLAY CITY NAME
  //
  // Converts package names like:
  //
  // CITY OF QUEZON
  //
  // into:
  //
  // Quezon City
  // ==========================================================================

  String _displayCityName(
    String rawName,
  ) {
    switch (_normalizeCityName(rawName)) {
      case 'quezon city':
        return 'Quezon City';

      case 'manila':
        return 'Manila';

      case 'san juan':
        return 'San Juan';

      case 'mandaluyong':
        return 'Mandaluyong';

      case 'marikina':
        return 'Marikina';

      case 'caloocan':
        return 'Caloocan';

      default:
        return _toTitleCase(rawName);
    }
  }

  // ==========================================================================
  // FORMAT BARANGAY
  // ==========================================================================

  String _formatBarangayName(
    String value,
  ) {
    return _toTitleCase(value);
  }

  // ==========================================================================
  // TITLE CASE
  // ==========================================================================

  String _toTitleCase(
    String value,
  ) {
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
  // SAVE ADDRESS
  // ==========================================================================

  void _saveAddress() {
    // ------------------------------------------------------------------------
    // City
    // ------------------------------------------------------------------------

    if (_municipality == null) {
      _showValidation(
        'Please select a delivery city.',
      );

      return;
    }

    // ------------------------------------------------------------------------
    // Allowed delivery city
    // ------------------------------------------------------------------------

    if (!_isAllowedCity(
      _itemName(_municipality),
    )) {
      _showValidation(
        'Sorry, we do not deliver to this city yet.',
      );

      return;
    }

    // ------------------------------------------------------------------------
    // Barangay
    // ------------------------------------------------------------------------

    if (_barangay == null) {
      _showValidation(
        'Please select your barangay.',
      );

      return;
    }

    // ------------------------------------------------------------------------
    // Detailed address
    // ------------------------------------------------------------------------

    if (_detailsController.text
        .trim()
        .isEmpty) {
      _showValidation(
        'Please enter your house number, street or building.',
      );

      return;
    }

    // ------------------------------------------------------------------------
    // Return result
    // ------------------------------------------------------------------------

    Navigator.of(context).pop(
      PhilippineAddressResult(
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
  // VALIDATION MESSAGE
  // ==========================================================================

  void _showValidation(
    String message,
  ) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(
              fontWeight:
                  FontWeight.w600,
            ),
          ),
          backgroundColor:
              AppColors.textPrimary,
          behavior:
              SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              14,
            ),
          ),
          margin:
              const EdgeInsets.all(
            16,
          ),
        ),
      );
  }

  // ==========================================================================
  // BUILD
  // ==========================================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final double keyboard =
        MediaQuery.of(context)
            .viewInsets
            .bottom;

    return AnimatedPadding(
      duration:
          const Duration(
        milliseconds: 180,
      ),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(
        bottom: keyboard,
      ),
      child: Container(
        constraints:
            BoxConstraints(
          maxHeight:
              MediaQuery.of(context)
                      .size
                      .height *
                  0.90,
        ),
        decoration:
            BoxDecoration(
          color: AppColors.surface,
          borderRadius:
              const BorderRadius
                  .vertical(
            top: Radius.circular(
              30,
            ),
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
                  const Offset(
                0,
                -6,
              ),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child:
              _isPreparingAddressData
                  ? const SizedBox(
                      height: 300,
                      child: Center(
                        child:
                            CircularProgressIndicator(
                          color:
                              AppColors
                                  .textPrimary,
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      padding:
                          const EdgeInsets
                              .fromLTRB(
                        AppConstants
                            .defaultPadding,
                        10,
                        AppConstants
                            .defaultPadding,
                        24,
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          // ================================================
                          // HANDLE
                          // ================================================

                          Center(
                            child:
                                Container(
                              width: 38,
                              height: 4,
                              decoration:
                                  BoxDecoration(
                                color:
                                    AppColors
                                        .border,
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  20,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(
                            height: 22,
                          ),

                          // ================================================
                          // HEADER
                          // ================================================

                          Row(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
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
                                          .circular(
                                    15,
                                  ),
                                ),
                                child:
                                    const Icon(
                                  Icons
                                      .location_on_outlined,
                                  color:
                                      Colors.white,
                                  size: 21,
                                ),
                              ),

                              const SizedBox(
                                width: 13,
                              ),

                              Expanded(
                                child:
                                    Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                  children: [
                                    Text(
                                      'DELIVERY',
                                      style:
                                          TextStyle(
                                        fontSize:
                                            7,
                                        fontWeight:
                                            FontWeight
                                                .w900,
                                        letterSpacing:
                                            1.1,
                                        color: AppColors
                                            .textSecondary
                                            .withValues(
                                          alpha:
                                              0.62,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height:
                                          4,
                                    ),
                                    const Text(
                                      'Delivery address',
                                      style:
                                          TextStyle(
                                        fontSize:
                                            20,
                                        height:
                                            1,
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
                                      height:
                                          7,
                                    ),
                                    Text(
                                      'Available in Quezon City and selected nearby Metro Manila cities.',
                                      style:
                                          TextStyle(
                                        fontSize:
                                            9,
                                        height:
                                            1.4,
                                        color: AppColors
                                            .textSecondary
                                            .withValues(
                                          alpha:
                                              0.70,
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
                                color: Colors
                                    .transparent,
                                child:
                                    InkWell(
                                  onTap:
                                      () {
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
                                          BoxShape
                                              .circle,
                                      border:
                                          Border
                                              .all(
                                        color: AppColors
                                            .border
                                            .withValues(
                                          alpha:
                                              0.25,
                                        ),
                                      ),
                                    ),
                                    child:
                                        const Icon(
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

                          // ================================================
                          // SERVICE AREA CARD
                          // ================================================

                          Container(
                            width:
                                double.infinity,
                            padding:
                                const EdgeInsets
                                    .all(
                              14,
                            ),
                            decoration:
                                BoxDecoration(
                              color: AppColors
                                  .background,
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                16,
                              ),
                              border:
                                  Border.all(
                                color: AppColors
                                    .border
                                    .withValues(
                                  alpha:
                                      0.25,
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
                                    color: AppColors
                                        .surface,
                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                      11,
                                    ),
                                  ),
                                  child:
                                      const Icon(
                                    Icons
                                        .storefront_outlined,
                                    size: 17,
                                    color: AppColors
                                        .textPrimary,
                                  ),
                                ),

                                const SizedBox(
                                  width: 11,
                                ),

                                Expanded(
                                  child:
                                      Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                    children: [
                                      const Text(
                                        'BOTOCAN, QUEZON CITY',
                                        style:
                                            TextStyle(
                                          fontSize:
                                              7,
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
                                        height:
                                            5,
                                      ),
                                      Text(
                                        'The store currently serves selected cities near Quezon City.',
                                        style:
                                            TextStyle(
                                          fontSize:
                                              8.5,
                                          height:
                                              1.4,
                                          color: AppColors
                                              .textSecondary
                                              .withValues(
                                            alpha:
                                                0.70,
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

                          // ================================================
                          // NO CITIES ERROR
                          // ================================================

                          if (_deliveryCities
                              .isEmpty) ...[
                            Container(
                              width:
                                  double.infinity,
                              padding:
                                  const EdgeInsets
                                      .all(
                                14,
                              ),
                              decoration:
                                  BoxDecoration(
                                color: Colors
                                    .red
                                    .withValues(
                                  alpha:
                                      0.05,
                                ),
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  15,
                                ),
                                border:
                                    Border.all(
                                  color: Colors
                                      .red
                                      .withValues(
                                    alpha:
                                        0.15,
                                  ),
                                ),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons
                                        .error_outline_rounded,
                                    size: 18,
                                    color:
                                        Colors.red,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child:
                                        Text(
                                      'Metro Manila delivery cities could not be loaded.',
                                      style:
                                          TextStyle(
                                        fontSize:
                                            9,
                                        height:
                                            1.4,
                                        fontWeight:
                                            FontWeight
                                                .w700,
                                        color:
                                            Colors.red,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                          ],

                          // ================================================
                          // DELIVERY CITY
                          // ================================================

                          _AddressDropdown<
                              dynamic>(
                            key: ValueKey(
                              'city_${_itemName(_municipality)}',
                            ),
                            label:
                                'DELIVERY CITY',
                            icon: Icons
                                .location_city_outlined,
                            value:
                                _municipality,
                            items:
                                _deliveryCities,
                            itemName:
                                (dynamic item) =>
                                    _displayCityName(
                              _itemName(
                                item,
                              ),
                            ),
                            hint:
                                'Select delivery city',
                            enabled:
                                _deliveryCities
                                    .isNotEmpty,
                            onChanged:
                                (dynamic value) {
                              setState(() {
                                _municipality =
                                    value;

                                _barangay =
                                    null;

                                _findProvinceForCity(
                                  value,
                                );
                              });
                            },
                          ),

                          const SizedBox(
                            height: 12,
                          ),

                          // ================================================
                          // BARANGAY
                          // ================================================

                          _AddressDropdown<
                              dynamic>(
                            key: ValueKey(
                              'barangay_${_itemName(_municipality)}',
                            ),
                            label:
                                'BARANGAY',
                            icon: Icons
                                .home_work_outlined,
                            value:
                                _barangay,
                            items:
                                _barangays,
                            itemName:
                                (dynamic item) =>
                                    _formatBarangayName(
                              _itemName(
                                item,
                              ),
                            ),
                            hint: _municipality ==
                                    null
                                ? 'Select a city first'
                                : 'Select barangay',
                            enabled:
                                _municipality !=
                                        null &&
                                    _barangays
                                        .isNotEmpty,
                            onChanged:
                                (dynamic value) {
                              setState(() {
                                _barangay =
                                    value;
                              });
                            },
                          ),

                          const SizedBox(
                            height: 12,
                          ),

                          // ================================================
                          // HOUSE / STREET
                          // ================================================

                          _AddressTextField(
                            controller:
                                _detailsController,
                            label:
                                'HOUSE / STREET / BUILDING',
                            hint:
                                'House no., street, subdivision, building...',
                            icon: Icons
                                .home_outlined,
                            onChanged:
                                (_) {
                              setState(
                                () {},
                              );
                            },
                          ),

                          const SizedBox(
                            height: 18,
                          ),

                          // ================================================
                          // ADDRESS PREVIEW
                          // ================================================

                          if (_municipality !=
                                  null &&
                              _barangay !=
                                  null)
                            _AddressPreview(
                              address:
                                  _buildAddress(),
                            ),

                          const SizedBox(
                            height: 20,
                          ),

                          // ================================================
                          // SAVE BUTTON
                          // ================================================

                          SizedBox(
                            width:
                                double.infinity,
                            height: 54,
                            child:
                                FilledButton(
                              onPressed:
                                  _deliveryCities
                                          .isEmpty
                                      ? null
                                      : _saveAddress,
                              style:
                                  FilledButton
                                      .styleFrom(
                                backgroundColor:
                                    AppColors
                                        .textPrimary,
                                foregroundColor:
                                    Colors.white,
                                disabledBackgroundColor:
                                    AppColors
                                        .textSecondary
                                        .withValues(
                                  alpha:
                                      0.25,
                                ),
                                elevation: 0,
                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    17,
                                  ),
                                ),
                              ),
                              child:
                                  const Row(
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
                                    'Use this address',
                                    style:
                                        TextStyle(
                                      fontSize:
                                          11,
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
// ADDRESS DROPDOWN
// ============================================================================

class _AddressDropdown<T>
    extends StatelessWidget {
  final String label;
  final IconData icon;

  final T? value;

  final List<T> items;

  final String Function(T) itemName;

  final String hint;

  final bool enabled;

  final ValueChanged<T?> onChanged;

  const _AddressDropdown({
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
  Widget build(
    BuildContext context,
  ) {
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
                  itemName(
                    item,
                  ),
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
// ADDRESS DETAILS FIELD
// ============================================================================

class _AddressTextField
    extends StatelessWidget {
  final TextEditingController controller;

  final String label;
  final String hint;
  final IconData icon;

  final ValueChanged<String>?
      onChanged;

  const _AddressTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.onChanged,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
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

class _AddressPreview
    extends StatelessWidget {
  final String address;

  const _AddressPreview({
    required this.address,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(
        14,
      ),
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
            alpha: 0.24,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration:
                BoxDecoration(
              color:
                  AppColors.surface,
              borderRadius:
                  BorderRadius.circular(
                10,
              ),
            ),
            child: const Icon(
              Icons
                  .pin_drop_outlined,
              size: 17,
              color: AppColors
                  .textPrimary,
            ),
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
                  'ADDRESS PREVIEW',
                  style:
                      TextStyle(
                    fontSize: 6.5,
                    fontWeight:
                        FontWeight
                            .w900,
                    letterSpacing:
                        0.9,
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
                        FontWeight
                            .w700,
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