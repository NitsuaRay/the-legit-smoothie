import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';

import '../widgets/addPromoScreen/promo_applies_to_section.dart';
import '../widgets/addPromoScreen/promo_banner_section.dart';
import '../widgets/addPromoScreen/promo_details_section.dart';
import '../widgets/addPromoScreen/promo_discount_section.dart';
import '../widgets/addPromoScreen/promo_mix_match_section.dart';
import '../widgets/addPromoScreen/promo_schedule_section.dart';
import '../widgets/addPromoScreen/promo_status_section.dart';
import '../widgets/addPromoScreen/promo_type_selector.dart';

class SellerAddPromotionScreen extends StatefulWidget {
  const SellerAddPromotionScreen({
    super.key,
  });

  @override
  State<SellerAddPromotionScreen> createState() =>
      _SellerAddPromotionScreenState();
}

class _SellerAddPromotionScreenState
    extends State<SellerAddPromotionScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;

  final ImagePicker _imagePicker = ImagePicker();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController =
      TextEditingController();

  final TextEditingController _descriptionController =
      TextEditingController();

  final TextEditingController _tagController =
      TextEditingController();

  final TextEditingController _discountValueController =
      TextEditingController();

  final TextEditingController _bundlePriceController =
      TextEditingController();

  // =============================================================
  // BANNER
  // =============================================================

  Uint8List? _bannerBytes;
  String? _bannerExtension;

  bool _isPickingBanner = false;

  // =============================================================
  // GENERAL STATE
  // =============================================================

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isActive = true;
  bool _discountOptions = false;

  String _promotionType = 'simple_discount';
  String _discountType = 'percentage';
  String _appliesTo = 'store';

  late DateTime _startsAt;
  late DateTime _validUntil;

  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _products = [];

  final Set<String> _selectedCategoryIds = {};
  final Set<String> _selectedProductIds = {};

  final List<Map<String, dynamic>> _groups = [];

  int _groupCounter = 0;

  // =============================================================
  // INIT
  // =============================================================

  @override
  void initState() {
    super.initState();

    final DateTime now = DateTime.now();

    _startsAt = now;
    _validUntil = now.add(
      const Duration(days: 7),
    );

    _addInitialGroups();
    _loadData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagController.dispose();
    _discountValueController.dispose();
    _bundlePriceController.dispose();

    super.dispose();
  }

  // =============================================================
  // INITIAL MIX & MATCH GROUPS
  // =============================================================

  void _addInitialGroups() {
    _groups.add(
      _newGroup('Drink'),
    );

    _groups.add(
      _newGroup('Snack'),
    );
  }

  Map<String, dynamic> _newGroup(
    String name,
  ) {
    _groupCounter++;

    return {
      'localId': _groupCounter,
      'name': name,
      'requiredQuantity': 1,
      'categoryIds': <String>{},
      'productIds': <String>{},
    };
  }

  // =============================================================
  // LOAD PRODUCTS / CATEGORIES
  // =============================================================

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        _supabase
            .from('categories')
            .select(
              'id, name, display_order, is_active',
            )
            .eq(
              'is_active',
              true,
            )
            .order(
              'display_order',
            ),

        _supabase
            .from('products')
            .select(
              '''
              id,
              category_id,
              name,
              base_price,
              image_url,
              is_available
              ''',
            )
            .order(
              'name',
            ),
      ]);

      if (!mounted) return;

      setState(() {
        _categories =
            List<Map<String, dynamic>>.from(
          results[0],
        );

        _products =
            List<Map<String, dynamic>>.from(
          results[1],
        );

        _isLoading = false;
      });
    } catch (error) {
      debugPrint(
        'Load promotion data error: $error',
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage(
        'Unable to load promotion data.',
        isError: true,
      );
    }
  }

  // =============================================================
  // MESSAGE
  // =============================================================

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Colors.red.shade700
            : AppColors.textPrimary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // =============================================================
  // PROMOTION TYPE
  // =============================================================

  void _changePromotionType(
    String value,
  ) {
    setState(() {
      _promotionType = value;
    });
  }

  // =============================================================
  // APPLIES TO
  // =============================================================

  void _changeAppliesTo(
    String value,
  ) {
    setState(() {
      _appliesTo = value;

      if (value == 'store') {
        _selectedCategoryIds.clear();
        _selectedProductIds.clear();
      }
    });
  }

  void _toggleCategory(
    String id,
  ) {
    setState(() {
      if (!_selectedCategoryIds.add(id)) {
        _selectedCategoryIds.remove(id);
      }
    });
  }

  void _toggleProduct(
    String id,
  ) {
    setState(() {
      if (!_selectedProductIds.add(id)) {
        _selectedProductIds.remove(id);
      }
    });
  }

  // =============================================================
  // MIX & MATCH GROUPS
  // =============================================================

  void _addGroup() {
    setState(() {
      _groups.add(
        _newGroup(
          'Group ${_groups.length + 1}',
        ),
      );
    });
  }

  void _removeGroup(
    int index,
  ) {
    if (_groups.length <= 2) {
      return;
    }

    setState(() {
      _groups.removeAt(index);
    });
  }

  void _changeGroupName(
    int index,
    String value,
  ) {
    _groups[index]['name'] = value;
  }

  void _changeGroupQuantity(
    int index,
    int value,
  ) {
    setState(() {
      _groups[index]['requiredQuantity'] =
          value < 1 ? 1 : value;
    });
  }

  void _toggleGroupCategory(
    int index,
    String id,
  ) {
    setState(() {
      final Set<String> ids =
          _groups[index]['categoryIds']
              as Set<String>;

      if (!ids.add(id)) {
        ids.remove(id);
      }
    });
  }

  void _toggleGroupProduct(
    int index,
    String id,
  ) {
    setState(() {
      final Set<String> ids =
          _groups[index]['productIds']
              as Set<String>;

      if (!ids.add(id)) {
        ids.remove(id);
      }
    });
  }

  // =============================================================
  // DATE / TIME
  // =============================================================

  Future<DateTime?> _pickDateTime(
    DateTime initial,
  ) async {
    final DateTime? date =
        await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(
        const Duration(days: 365),
      ),
      lastDate: DateTime(
        DateTime.now().year + 5,
      ),
    );

    if (date == null || !mounted) {
      return null;
    }

    final TimeOfDay? time =
        await showTimePicker(
      context: context,
      initialTime:
          TimeOfDay.fromDateTime(
        initial,
      ),
    );

    if (time == null) {
      return null;
    }

    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }

  Future<void> _pickStart() async {
    final DateTime? result =
        await _pickDateTime(
      _startsAt,
    );

    if (result == null) {
      return;
    }

    setState(() {
      _startsAt = result;

      if (!_validUntil.isAfter(
        _startsAt,
      )) {
        _validUntil = _startsAt.add(
          const Duration(days: 7),
        );
      }
    });
  }

  Future<void> _pickEnd() async {
    final DateTime? result =
        await _pickDateTime(
      _validUntil,
    );

    if (result == null) {
      return;
    }

    if (!result.isAfter(
      _startsAt,
    )) {
      _showMessage(
        'End date must be after the start date.',
        isError: true,
      );

      return;
    }

    setState(() {
      _validUntil = result;
    });
  }

  // =============================================================
  // BANNER PICKER
  // =============================================================

  Future<void> _pickBanner() async {
    if (_isPickingBanner) {
      return;
    }

    setState(() {
      _isPickingBanner = true;
    });

    try {
      final XFile? image =
          await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 88,
        maxWidth: 1920,
      );

      if (image == null) {
        return;
      }

      final Uint8List bytes =
          await image.readAsBytes();

      if (bytes.isEmpty) {
        _showMessage(
          'Unable to read the selected image.',
          isError: true,
        );

        return;
      }

      // Maximum banner size: 5 MB.
      if (bytes.length >
          5 * 1024 * 1024) {
        _showMessage(
          'Banner image must be smaller than 5 MB.',
          isError: true,
        );

        return;
      }

      final String fileName =
          image.name.toLowerCase();

      final int dotIndex =
          fileName.lastIndexOf('.');

      if (dotIndex == -1) {
        _showMessage(
          'The selected image has an unsupported file type.',
          isError: true,
        );

        return;
      }

      String extension =
          fileName.substring(
        dotIndex + 1,
      );

      const Set<String>
          allowedExtensions = {
        'jpg',
        'jpeg',
        'png',
        'webp',
      };

      if (!allowedExtensions.contains(
        extension,
      )) {
        _showMessage(
          'Please select a JPG, PNG, or WebP image.',
          isError: true,
        );

        return;
      }

      if (extension == 'jpeg') {
        extension = 'jpg';
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _bannerBytes = bytes;
        _bannerExtension = extension;
      });
    } catch (error) {
      debugPrint(
        'PICK PROMOTION BANNER ERROR: $error',
      );

      _showMessage(
        'Unable to select banner image.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isPickingBanner = false;
        });
      }
    }
  }

  void _removeBanner() {
    setState(() {
      _bannerBytes = null;
      _bannerExtension = null;
    });
  }

  // =============================================================
  // VALIDATION
  // =============================================================

  bool _validateBusinessRules() {
    if (!_validUntil.isAfter(
      _startsAt,
    )) {
      _showMessage(
        'End date must be after the start date.',
        isError: true,
      );

      return false;
    }

    if (_promotionType ==
            'simple_discount' &&
        _appliesTo == 'selection' &&
        _selectedCategoryIds.isEmpty &&
        _selectedProductIds.isEmpty) {
      _showMessage(
        'Select at least one category or product.',
        isError: true,
      );

      return false;
    }

    if (_promotionType ==
        'mix_and_match') {
      if (_groups.length < 2) {
        _showMessage(
          'Mix & Match requires at least two groups.',
          isError: true,
        );

        return false;
      }

      for (
        int i = 0;
        i < _groups.length;
        i++
      ) {
        final Map<String, dynamic> group =
            _groups[i];

        final String name =
            group['name']
                    ?.toString()
                    .trim() ??
                '';

        final Set<String> categoryIds =
            group['categoryIds']
                as Set<String>;

        final Set<String> productIds =
            group['productIds']
                as Set<String>;

        if (name.isEmpty) {
          _showMessage(
            'Group ${i + 1} needs a name.',
            isError: true,
          );

          return false;
        }

        if (categoryIds.isEmpty &&
            productIds.isEmpty) {
          _showMessage(
            'Select eligible items for ${group['name']}.',
            isError: true,
          );

          return false;
        }
      }
    }

    return true;
  }

  // =============================================================
  // CREATE PROMOTION
  // =============================================================

  Future<void> _createPromotion() async {
    if (_isSaving) {
      return;
    }

    if (!(_formKey.currentState
            ?.validate() ??
        false)) {
      return;
    }

    if (!_validateBusinessRules()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    String? promotionId;
    String? uploadedBannerPath;

    try {
      // ---------------------------------------------------------
      // PROMOTION VALUE
      // ---------------------------------------------------------

      final double value =
          _promotionType ==
                  'mix_and_match'
              ? double.parse(
                  _bundlePriceController
                      .text
                      .trim(),
                )
              : double.parse(
                  _discountValueController
                      .text
                      .trim(),
                );

      // ---------------------------------------------------------
      // UPLOAD BANNER
      // ---------------------------------------------------------

      String? bannerUrl;

      if (_bannerBytes != null) {
        final String extension =
            _bannerExtension ?? 'jpg';

        final String? userId =
            _supabase
                .auth
                .currentUser
                ?.id;

        if (userId == null) {
          throw Exception(
            'Seller is not authenticated.',
          );
        }

        final String fileName =
            '${DateTime.now().microsecondsSinceEpoch}.$extension';

        uploadedBannerPath =
            '$userId/$fileName';

        final String contentType =
            switch (extension) {
          'png' => 'image/png',
          'webp' => 'image/webp',
          _ => 'image/jpeg',
        };

        await _supabase.storage
            .from(
              'promotion-banners',
            )
            .uploadBinary(
              uploadedBannerPath,
              _bannerBytes!,
              fileOptions:
                  FileOptions(
                contentType:
                    contentType,
                upsert: false,
              ),
            );

        bannerUrl = _supabase.storage
            .from(
              'promotion-banners',
            )
            .getPublicUrl(
              uploadedBannerPath,
            );
      }

      // ---------------------------------------------------------
      // CREATE PROMOTION
      // ---------------------------------------------------------

      final Map<String, dynamic>
          promotionResponse =
          await _supabase
              .from('promotions')
              .insert({
                'title':
                    _titleController
                        .text
                        .trim(),

                'description':
                    _descriptionController
                            .text
                            .trim()
                            .isEmpty
                        ? null
                        : _descriptionController
                            .text
                            .trim(),

                'discount_tag':
                    _tagController
                            .text
                            .trim()
                            .isEmpty
                        ? null
                        : _tagController
                            .text
                            .trim(),

                'banner_url':
                    bannerUrl,

                'promotion_type':
                    _promotionType,

                'discount_type':
                    _promotionType ==
                            'mix_and_match'
                        ? 'fixed_price'
                        : _discountType,

                'discount_value':
                    value,

                'applies_to':
                    _promotionType ==
                            'mix_and_match'
                        ? 'selection'
                        : _appliesTo,

                'discount_options':
                    _promotionType ==
                            'simple_discount'
                        ? _discountOptions
                        : false,

                'starts_at':
                    _startsAt
                        .toUtc()
                        .toIso8601String(),

                'valid_until':
                    _validUntil
                        .toUtc()
                        .toIso8601String(),

                'is_active':
                    _isActive,
              })
              .select('id')
              .single();

      promotionId =
          promotionResponse['id']
              .toString();

      // ---------------------------------------------------------
      // SAVE TARGETS
      // ---------------------------------------------------------

      if (_promotionType ==
          'simple_discount') {
        await _saveSimpleTargets(
          promotionId,
        );
      } else {
        await _saveMixMatchGroups(
          promotionId,
        );
      }

      if (!mounted) {
        return;
      }

      _showMessage(
        'Promotion created successfully.',
      );

      Navigator.of(context).pop(
        true,
      );
    } on PostgrestException catch (error) {
      debugPrint(
        'CREATE PROMOTION POSTGREST ERROR',
      );
      debugPrint(
        'Code: ${error.code}',
      );
      debugPrint(
        'Message: ${error.message}',
      );
      debugPrint(
        'Details: ${error.details}',
      );
      debugPrint(
        'Hint: ${error.hint}',
      );

      await _cleanupFailedPromotion(
        promotionId:
            promotionId,
        bannerPath:
            uploadedBannerPath,
      );

      _showMessage(
        'Unable to create promotion: ${error.message}',
        isError: true,
      );
    } on StorageException catch (error) {
      debugPrint(
        'CREATE PROMOTION STORAGE ERROR',
      );
      debugPrint(
        'Message: ${error.message}',
      );
      debugPrint(
        'Status: ${error.statusCode}',
      );

      await _cleanupFailedPromotion(
        promotionId:
            promotionId,
        bannerPath:
            uploadedBannerPath,
      );

      _showMessage(
        'Unable to upload promotion banner: ${error.message}',
        isError: true,
      );
    } catch (error) {
      debugPrint(
        'CREATE PROMOTION ERROR: $error',
      );

      await _cleanupFailedPromotion(
        promotionId:
            promotionId,
        bannerPath:
            uploadedBannerPath,
      );

      _showMessage(
        'Unable to create promotion.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // =============================================================
  // CLEANUP FAILED CREATE
  // =============================================================

  Future<void>
      _cleanupFailedPromotion({
    String? promotionId,
    String? bannerPath,
  }) async {
    if (promotionId != null) {
      try {
        await _supabase
            .from('promotions')
            .delete()
            .eq(
              'id',
              promotionId,
            );
      } catch (error) {
        debugPrint(
          'FAILED PROMOTION CLEANUP ERROR: $error',
        );
      }
    }

    if (bannerPath != null) {
      try {
        await _supabase.storage
            .from(
              'promotion-banners',
            )
            .remove([
          bannerPath,
        ]);
      } catch (error) {
        debugPrint(
          'FAILED BANNER CLEANUP ERROR: $error',
        );
      }
    }
  }

  // =============================================================
  // SAVE SIMPLE TARGETS
  // =============================================================

  Future<void> _saveSimpleTargets(
    String promotionId,
  ) async {
    if (_appliesTo == 'store') {
      return;
    }

    if (_selectedCategoryIds
        .isNotEmpty) {
      await _supabase
          .from(
            'promotion_categories',
          )
          .insert(
            _selectedCategoryIds
                .map(
                  (String id) => {
                    'promotion_id':
                        promotionId,
                    'category_id':
                        id,
                  },
                )
                .toList(),
          );
    }

    if (_selectedProductIds
        .isNotEmpty) {
      await _supabase
          .from(
            'promotion_products',
          )
          .insert(
            _selectedProductIds
                .map(
                  (String id) => {
                    'promotion_id':
                        promotionId,
                    'product_id':
                        id,
                  },
                )
                .toList(),
          );
    }
  }

  // =============================================================
  // SAVE MIX & MATCH
  // =============================================================

  Future<void>
      _saveMixMatchGroups(
    String promotionId,
  ) async {
    for (
      int i = 0;
      i < _groups.length;
      i++
    ) {
      final Map<String, dynamic> group =
          _groups[i];

      final Map<String, dynamic>
          groupResponse =
          await _supabase
              .from(
                'promotion_groups',
              )
              .insert({
                'promotion_id':
                    promotionId,
                'name':
                    group['name']
                        .toString()
                        .trim(),
                'required_quantity':
                    group[
                        'requiredQuantity'],
                'sort_order': i,
              })
              .select('id')
              .single();

      final String groupId =
          groupResponse['id']
              .toString();

      final Set<String> categoryIds =
          group['categoryIds']
              as Set<String>;

      final Set<String> productIds =
          group['productIds']
              as Set<String>;

      if (categoryIds.isNotEmpty) {
        await _supabase
            .from(
              'promotion_group_categories',
            )
            .insert(
              categoryIds
                  .map(
                    (String id) => {
                      'group_id':
                          groupId,
                      'category_id':
                          id,
                    },
                  )
                  .toList(),
            );
      }

      if (productIds.isNotEmpty) {
        await _supabase
            .from(
              'promotion_group_products',
            )
            .insert(
              productIds
                  .map(
                    (String id) => {
                      'group_id':
                          groupId,
                      'product_id':
                          id,
                    },
                  )
                  .toList(),
            );
      }
    }
  }

  // =============================================================
  // BUILD
  // =============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          AppColors.background,

      // =========================================================
      // APP BAR
      // =========================================================

      appBar: AppBar(
        backgroundColor:
            AppColors.background,
        surfaceTintColor:
            Colors.transparent,
        elevation: 0,
        titleSpacing: 0,
        title: const Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              'CREATE',
              style: TextStyle(
                fontSize: 8,
                fontWeight:
                    FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
            Text(
              'New Promotion',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.w900,
                letterSpacing: -0.4,
              ),
            ),
          ],
        ),
      ),

      // =========================================================
      // BODY
      // =========================================================

      body: _isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(
                color:
                    AppColors.textPrimary,
              ),
            )
          : Form(
              key: _formKey,
              child: ListView(
                padding:
                    const EdgeInsets
                        .fromLTRB(
                  AppConstants
                      .defaultPadding,
                  12,
                  AppConstants
                      .defaultPadding,
                  120,
                ),
                children: [
                  // =================================================
                  // DETAILS
                  // =================================================

                  PromoDetailsSection(
                    titleController:
                        _titleController,
                    descriptionController:
                        _descriptionController,
                    tagController:
                        _tagController,
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  // =================================================
                  // BANNER
                  // =================================================

                  PromoBannerSection(
                    imageBytes:
                        _bannerBytes,
                    isPicking:
                        _isPickingBanner,
                    onPick:
                        _pickBanner,
                    onRemove:
                        _removeBanner,
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  // =================================================
                  // TYPE
                  // =================================================

                  PromoTypeSelector(
                    value:
                        _promotionType,
                    onChanged:
                        _changePromotionType,
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  // =================================================
                  // SIMPLE DISCOUNT
                  // =================================================

                  if (_promotionType ==
                      'simple_discount') ...[
                    PromoDiscountSection(
                      discountType:
                          _discountType,
                      valueController:
                          _discountValueController,
                      discountOptions:
                          _discountOptions,
                      onTypeChanged:
                          (String value) {
                        setState(() {
                          _discountType =
                              value;
                        });
                      },
                      onDiscountOptionsChanged:
                          (bool value) {
                        setState(() {
                          _discountOptions =
                              value;
                        });
                      },
                    ),

                    const SizedBox(
                      height: 14,
                    ),

                    PromoAppliesToSection(
                      appliesTo:
                          _appliesTo,
                      categories:
                          _categories,
                      products:
                          _products,
                      selectedCategoryIds:
                          _selectedCategoryIds,
                      selectedProductIds:
                          _selectedProductIds,
                      onAppliesToChanged:
                          _changeAppliesTo,
                      onCategoryToggle:
                          _toggleCategory,
                      onProductToggle:
                          _toggleProduct,
                    ),
                  ]

                  // =================================================
                  // MIX & MATCH
                  // =================================================

                  else ...[
                    PromoMixMatchSection(
                      bundlePriceController:
                          _bundlePriceController,
                      groups:
                          _groups,
                      categories:
                          _categories,
                      products:
                          _products,
                      onAddGroup:
                          _addGroup,
                      onRemoveGroup:
                          _removeGroup,
                      onNameChanged:
                          _changeGroupName,
                      onQuantityChanged:
                          _changeGroupQuantity,
                      onCategoryToggle:
                          _toggleGroupCategory,
                      onProductToggle:
                          _toggleGroupProduct,
                    ),
                  ],

                  const SizedBox(
                    height: 14,
                  ),

                  // =================================================
                  // SCHEDULE
                  // =================================================

                  PromoScheduleSection(
                    startsAt:
                        _startsAt,
                    validUntil:
                        _validUntil,
                    onStartTap:
                        _pickStart,
                    onEndTap:
                        _pickEnd,
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  // =================================================
                  // STATUS
                  // =================================================

                  PromoStatusSection(
                    isActive:
                        _isActive,
                    onChanged:
                        (bool value) {
                      setState(() {
                        _isActive =
                            value;
                      });
                    },
                  ),
                ],
              ),
            ),

      // =========================================================
      // CREATE BUTTON
      // =========================================================

      bottomNavigationBar:
          _isLoading
              ? null
              : SafeArea(
                  minimum:
                      const EdgeInsets
                          .fromLTRB(
                    AppConstants
                        .defaultPadding,
                    8,
                    AppConstants
                        .defaultPadding,
                    12,
                  ),
                  child: SizedBox(
                    height: 54,
                    child:
                        FilledButton(
                      onPressed:
                          _isSaving
                              ? null
                              : _createPromotion,
                      style:
                          FilledButton
                              .styleFrom(
                        backgroundColor:
                            AppColors
                                .textPrimary,
                        disabledBackgroundColor:
                            AppColors
                                .textPrimary
                                .withValues(
                                  alpha:
                                      0.45,
                                ),
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
                          _isSaving
                              ? const SizedBox(
                                  width:
                                      21,
                                  height:
                                      21,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth:
                                        2,
                                    color:
                                        Colors.white,
                                  ),
                                )
                              : const Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment
                                          .center,
                                  children: [
                                    Icon(
                                      Icons
                                          .add_rounded,
                                    ),
                                    SizedBox(
                                      width:
                                          7,
                                    ),
                                    Text(
                                      'Create Promotion',
                                      style:
                                          TextStyle(
                                        fontSize:
                                            12,
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
    );
  }
}