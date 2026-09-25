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
// DELIVERY CITY
//
// This is an internal wrapper used only by this picker.
//
// Normal city:
//   Quezon City
//       ↓
//   Barangay
//
// Special Manila structure in philippines_rpcmb:
//
//   NCR
//       ↓
//   NATIONAL CAPITAL REGION - MANILA
//       ↓
//   Sampaloc / Tondo / Ermita / etc.
//       ↓
//   Barangay
//
// The customer should still see "Manila" as one delivery city.
// ============================================================================

class _DeliveryCity {
  final String name;

  /// Normal RPCMB municipality object.
  ///
  /// Used by Quezon City, Marikina, Pasig and Mandaluyong.
  final dynamic municipality;

  /// NCR district/province containing the city.
  final dynamic province;

  /// Used by Manila.
  ///
  /// RPCMB represents Manila's areas such as Sampaloc and Tondo
  /// at the municipality level.
  final List<dynamic> areas;

  const _DeliveryCity({
    required this.name,
    this.municipality,
    this.province,
    this.areas = const [],
  });

  bool get isManila =>
      name.trim().toLowerCase() == 'manila';
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
  // DELIVERY COVERAGE
  //
  // Store:
  // Botocan, Quezon City
  //
  // Supported:
  //
  // Quezon City
  // Mandaluyong
  // Marikina
  // Pasig
  // Manila
  //
  // Manila is handled specially because RPCMB does not expose a
  // municipality called "Manila". Instead it exposes Manila areas such as
  // Sampaloc, Tondo, Ermita, etc.
  // ==========================================================================

  static const Set<String> _allowedNormalCities = {
    'quezon city',
    'mandaluyong',
    'marikina',
    'pasig',
  };

  dynamic _region;

  dynamic _province;
  dynamic _municipality;

  dynamic _barangay;


  /// Customer-facing selected city.
  _DeliveryCity? _selectedDeliveryCity;

  List<_DeliveryCity> _deliveryCities = [];

  dynamic _manilaArea;

  late final TextEditingController _detailsController;

  bool _isPreparingAddressData = true;

  @override
  void initState() {
    super.initState();

    _detailsController = TextEditingController(
      text: widget.initialDetailedAddress,
    );

    _prepareDeliveryArea();
  }

  @override
  void dispose() {
    _detailsController.dispose();

    super.dispose();
  }

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
      // Continue below.
    }

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

      // Mandaluyong
      'mandaluyong': 'mandaluyong',
      'city of mandaluyong': 'mandaluyong',
      'mandaluyong city': 'mandaluyong',

      // Marikina
      'marikina': 'marikina',
      'city of marikina': 'marikina',
      'marikina city': 'marikina',

      // Pasig
      'pasig': 'pasig',
      'city of pasig': 'pasig',
      'pasig city': 'pasig',

      // Manila
      'manila': 'manila',
      'city of manila': 'manila',
      'manila city': 'manila',
    };

    return aliases[name] ?? name;
  }

  // ==========================================================================
  // NORMALIZE DISTRICT NAME
  // ==========================================================================

  String _normalizeDistrictName(
    String value,
  ) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(
          RegExp(r'\s+'),
          ' ',
        );
  }

  // ==========================================================================
  // MANILA DISTRICT CHECK
  // ==========================================================================

  bool _isManilaProvince(
    dynamic province,
  ) {
    final String name =
        _normalizeDistrictName(
      _itemName(province),
    );

    return name.contains(
      'national capital region - manila',
    );
  }

  // ==========================================================================
  // NORMAL DELIVERY CITY CHECK
  // ==========================================================================

  bool _isAllowedNormalCity(
    String cityName,
  ) {
    return _allowedNormalCities.contains(
      _normalizeCityName(
        cityName,
      ),
    );
  }

  // ==========================================================================
  // PREPARE DELIVERY AREA
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
    // Fallback using region name.
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
    // NCR NOT FOUND
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

    _region = ncr;

    final List<_DeliveryCity> cities = [];

    try {
      for (final dynamic province in ncr.provinces) {

        if (_isManilaProvince(province)) {
          final List<dynamic> manilaAreas =
              List<dynamic>.from(
            province.municipalities,
          );

          manilaAreas.sort(
            (dynamic a, dynamic b) {
              return _itemName(a)
                  .toLowerCase()
                  .compareTo(
                    _itemName(b)
                        .toLowerCase(),
                  );
            },
          );

          if (manilaAreas.isNotEmpty) {
            cities.add(
              _DeliveryCity(
                name: 'Manila',
                province: province,
                areas: manilaAreas,
              ),
            );
          }

          continue;
        }

        for (final dynamic municipality
            in province.municipalities) {
          final String cityName =
              _itemName(municipality);

          if (!_isAllowedNormalCity(
            cityName,
          )) {
            continue;
          }

          final String displayName =
              _displayCityName(
            cityName,
          );

          final bool alreadyAdded =
              cities.any(
            (_DeliveryCity existing) =>
                existing.name
                    .toLowerCase() ==
                displayName
                    .toLowerCase(),
          );

          if (!alreadyAdded) {
            cities.add(
              _DeliveryCity(
                name: displayName,
                municipality:
                    municipality,
                province: province,
              ),
            );
          }
        }
      }
    } catch (error) {
      debugPrint(
        'Error preparing NCR delivery cities: $error',
      );
    }

    cities.sort(
      (_DeliveryCity a, _DeliveryCity b) {
        if (a.name == 'Quezon City' &&
            b.name != 'Quezon City') {
          return -1;
        }

        if (b.name == 'Quezon City' &&
            a.name != 'Quezon City') {
          return 1;
        }

        return a.name.compareTo(
          b.name,
        );
      },
    );

    _deliveryCities = cities;

    if (widget.initialMunicipality != null) {
      final dynamic initialMunicipality =
          widget.initialMunicipality;

      final String initialName =
          _normalizeCityName(
        _itemName(
          initialMunicipality,
        ),
      );

      for (final _DeliveryCity city
          in _deliveryCities) {
        if (city.isManila ||
            city.municipality == null) {
          continue;
        }

        final String cityName =
            _normalizeCityName(
          _itemName(
            city.municipality,
          ),
        );

        if (cityName == initialName) {
          _selectedDeliveryCity = city;
          _municipality =
              city.municipality;
          _province = city.province;

          break;
        }
      }


      if (_selectedDeliveryCity == null) {
        for (final _DeliveryCity city
            in _deliveryCities) {
          if (!city.isManila) {
            continue;
          }

          for (final dynamic area
              in city.areas) {
            if (_itemName(area)
                    .trim()
                    .toLowerCase() ==
                _itemName(
                  initialMunicipality,
                )
                    .trim()
                    .toLowerCase()) {
              _selectedDeliveryCity =
                  city;

              _manilaArea = area;
              _municipality = area;
              _province = city.province;

              break;
            }
          }

          if (_selectedDeliveryCity !=
              null) {
            break;
          }
        }
      }
    }

    // ------------------------------------------------------------------------
    // 5. DEFAULT TO QUEZON CITY
    // ------------------------------------------------------------------------

    if (_selectedDeliveryCity == null) {
      for (final _DeliveryCity city
          in _deliveryCities) {
        if (city.name ==
            'Quezon City') {
          _selectedDeliveryCity = city;

          _municipality =
              city.municipality;

          _province =
              city.province;

          break;
        }
      }
    }

    // ------------------------------------------------------------------------
    // 6. RESTORE BARANGAY
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
  // SELECT DELIVERY CITY
  // ==========================================================================

  void _selectDeliveryCity(
    _DeliveryCity? city,
  ) {
    if (city == null) {
      return;
    }

    setState(() {
      _selectedDeliveryCity = city;

      _barangay = null;
      _manilaArea = null;

      if (city.isManila) {
        // Manila needs area selection first.
        _province = city.province;
        _municipality = null;
      } else {
        // Normal city.
        _province = city.province;
        _municipality =
            city.municipality;
      }
    });
  }

  // ==========================================================================
  // SELECT MANILA AREA
  // ==========================================================================

  void _selectManilaArea(
    dynamic area,
  ) {
    setState(() {
      _manilaArea = area;

      // Keep municipality compatible with existing app.
      //
      // RPCMB itself considers Sampaloc/Tondo/etc. municipality-level
      // objects, so we return that actual object.
      _municipality = area;

      _barangay = null;
    });
  }

  // ==========================================================================
  // MANILA AREAS
  // ==========================================================================

  List<dynamic> get _manilaAreas {
    final _DeliveryCity? city =
        _selectedDeliveryCity;

    if (city == null ||
        !city.isManila) {
      return <dynamic>[];
    }

    return city.areas;
  }

  // ==========================================================================
  // BARANGAYS
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
  // Normal:
  //
  // 172 Area 4, Botocan, Quezon City, Metro Manila
  //
  // Manila:
  //
  // 123 Street, Barangay ..., Sampaloc, Manila, Metro Manila
  // ==========================================================================

  String _buildAddress() {
    final List<String> parts = [
      _detailsController.text.trim(),

      _formatBarangayName(
        _itemName(_barangay),
      ),

      if (_selectedDeliveryCity?.isManila ==
          true) ...[
        _formatManilaAreaName(
          _itemName(
            _manilaArea,
          ),
        ),
        'Manila',
      ] else
        _selectedDeliveryCity?.name ?? '',

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
  // ==========================================================================

  String _displayCityName(
    String rawName,
  ) {
    switch (_normalizeCityName(rawName)) {
      case 'quezon city':
        return 'Quezon City';

      case 'mandaluyong':
        return 'Mandaluyong';

      case 'marikina':
        return 'Marikina';

      case 'pasig':
        return 'Pasig';

      case 'manila':
        return 'Manila';

      default:
        return _toTitleCase(
          rawName,
        );
    }
  }

  // ==========================================================================
  // FORMAT MANILA AREA
  // ==========================================================================

  String _formatManilaAreaName(
    String value,
  ) {
    return _toTitleCase(
      value,
    );
  }

  // ==========================================================================
  // FORMAT BARANGAY
  // ==========================================================================

  String _formatBarangayName(
    String value,
  ) {
    return _toTitleCase(
      value,
    );
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
        .split(
          RegExp(r'\s+'),
        )
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
    // DELIVERY CITY
    // ------------------------------------------------------------------------

    if (_selectedDeliveryCity == null) {
      _showValidation(
        'Please select a delivery city.',
      );

      return;
    }

    // ------------------------------------------------------------------------
    // MANILA AREA
    // ------------------------------------------------------------------------

    if (_selectedDeliveryCity!.isManila &&
        _manilaArea == null) {
      _showValidation(
        'Please select your Manila area.',
      );

      return;
    }

    // ------------------------------------------------------------------------
    // RPCMB MUNICIPALITY
    // ------------------------------------------------------------------------

    if (_municipality == null) {
      _showValidation(
        'Please select your delivery area.',
      );

      return;
    }

    // ------------------------------------------------------------------------
    // BARANGAY
    // ------------------------------------------------------------------------

    if (_barangay == null) {
      _showValidation(
        'Please select your barangay.',
      );

      return;
    }

    // ------------------------------------------------------------------------
    // DETAILED ADDRESS
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
    // RETURN RESULT
    // ------------------------------------------------------------------------

    Navigator.of(context).pop(
      PhilippineAddressResult(
        region: _region,
        province: _province,
        municipality:
            _municipality,
        barangay: _barangay,
        detailedAddress:
            _detailsController.text
                .trim(),
        fullAddress:
            _buildAddress(),
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
                          // SERVICE AREA
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
                                        'Serving Quezon City, Manila, Mandaluyong, Marikina and Pasig.',
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
                          // NO CITIES
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
                              child:
                                  const Row(
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
                              _DeliveryCity>(
                            key: ValueKey(
                              'city_${_selectedDeliveryCity?.name ?? ''}',
                            ),
                            label:
                                'DELIVERY CITY',
                            icon: Icons
                                .location_city_outlined,
                            value:
                                _selectedDeliveryCity,
                            items:
                                _deliveryCities,
                            itemName:
                                (_DeliveryCity item) =>
                                    item.name,
                            hint:
                                'Select delivery city',
                            enabled:
                                _deliveryCities
                                    .isNotEmpty,
                            onChanged:
                                _selectDeliveryCity,
                          ),

                          // ================================================
                          // MANILA AREA
                          // ================================================

                          if (_selectedDeliveryCity
                                  ?.isManila ==
                              true) ...[
                            const SizedBox(
                              height: 12,
                            ),

                            _AddressDropdown<
                                dynamic>(
                              key: ValueKey(
                                'manila_area_${_itemName(_manilaArea)}',
                              ),
                              label:
                                  'MANILA AREA',
                              icon: Icons
                                  .map_outlined,
                              value:
                                  _manilaArea,
                              items:
                                  _manilaAreas,
                              itemName:
                                  (dynamic item) =>
                                      _formatManilaAreaName(
                                _itemName(
                                  item,
                                ),
                              ),
                              hint:
                                  'Select Manila area',
                              enabled:
                                  _manilaAreas
                                      .isNotEmpty,
                              onChanged:
                                  (dynamic value) {
                                if (value !=
                                    null) {
                                  _selectManilaArea(
                                    value,
                                  );
                                }
                              },
                            ),
                          ],

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
                            hint:
                                _selectedDeliveryCity ==
                                        null
                                    ? 'Select a city first'
                                    : _selectedDeliveryCity!
                                            .isManila &&
                                        _manilaArea ==
                                            null
                                    ? 'Select Manila area first'
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

                          if (_selectedDeliveryCity !=
                                  null &&
                              _municipality !=
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
                          // SAVE
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