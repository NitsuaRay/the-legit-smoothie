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

class SellerEditPromotionScreen extends StatefulWidget {
  final String promotionId;

  const SellerEditPromotionScreen({
    super.key,
    required this.promotionId,
  });

  @override
  State<SellerEditPromotionScreen> createState() =>
      _SellerEditPromotionScreenState();
}

class _SellerEditPromotionScreenState
    extends State<SellerEditPromotionScreen> {
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

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isDeleting = false;
  bool _isPickingBanner = false;

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

  // Existing banner stored in Supabase.
  String? _existingBannerUrl;

  // Existing banner's Storage object path.
  String? _existingBannerPath;

  // Newly selected replacement banner.
  Uint8List? _bannerBytes;
  String? _bannerExtension;

  // True when seller explicitly removes the current banner.
  bool _removeExistingBanner = false;

  @override
  void initState() {
    super.initState();

    final DateTime now = DateTime.now();

    _startsAt = now;
    _validUntil = now.add(
      const Duration(days: 7),
    );

    _loadPromotion();
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
  // LOAD
  // =============================================================

  Future<void> _loadPromotion() async {
    try {
      final List<dynamic> results = await Future.wait([
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

        _supabase
            .from('promotions')
            .select('''
              id,
              title,
              description,
              discount_tag,
              banner_url,
              promotion_type,
              discount_type,
              discount_value,
              applies_to,
              discount_options,
              starts_at,
              valid_until,
              is_active
            ''')
            .eq(
              'id',
              widget.promotionId,
            )
            .single(),

        _supabase
            .from('promotion_categories')
            .select('category_id')
            .eq(
              'promotion_id',
              widget.promotionId,
            ),

        _supabase
            .from('promotion_products')
            .select('product_id')
            .eq(
              'promotion_id',
              widget.promotionId,
            ),

        _supabase
            .from('promotion_groups')
            .select('''
              id,
              name,
              required_quantity,
              sort_order,
              promotion_group_categories (
                category_id
              ),
              promotion_group_products (
                product_id
              )
            ''')
            .eq(
              'promotion_id',
              widget.promotionId,
            )
            .order(
              'sort_order',
            ),
      ]);

      if (!mounted) return;

      final List<Map<String, dynamic>> categories =
          List<Map<String, dynamic>>.from(
        results[0],
      );

      final List<Map<String, dynamic>> products =
          List<Map<String, dynamic>>.from(
        results[1],
      );

      final Map<String, dynamic> promotion =
          Map<String, dynamic>.from(
        results[2],
      );

      final List<Map<String, dynamic>> promotionCategories =
          List<Map<String, dynamic>>.from(
        results[3],
      );

      final List<Map<String, dynamic>> promotionProducts =
          List<Map<String, dynamic>>.from(
        results[4],
      );

      final List<Map<String, dynamic>> promotionGroups =
          List<Map<String, dynamic>>.from(
        results[5],
      );

      _titleController.text =
          promotion['title']?.toString() ?? '';

      _descriptionController.text =
          promotion['description']?.toString() ?? '';

      _tagController.text =
          promotion['discount_tag']?.toString() ?? '';

      _promotionType =
          promotion['promotion_type']?.toString() ??
              'simple_discount';

      _discountType =
          promotion['discount_type']?.toString() ??
              'percentage';

      _appliesTo =
          promotion['applies_to']?.toString() ??
              'store';

      _discountOptions =
          promotion['discount_options'] == true;

      _isActive =
          promotion['is_active'] == true;

      _existingBannerUrl =
          promotion['banner_url']?.toString();

      if (_existingBannerUrl?.trim().isEmpty == true) {
        _existingBannerUrl = null;
      }

      _existingBannerPath =
          _storagePathFromPublicUrl(
        _existingBannerUrl,
      );

      final num? discountValue =
          promotion['discount_value'] as num?;

      if (discountValue != null) {
        if (_promotionType == 'mix_and_match') {
          _bundlePriceController.text =
              _formatNumber(
            discountValue,
          );
        } else {
          _discountValueController.text =
              _formatNumber(
            discountValue,
          );
        }
      }

      _startsAt = DateTime.parse(
        promotion['starts_at'].toString(),
      ).toLocal();

      _validUntil = DateTime.parse(
        promotion['valid_until'].toString(),
      ).toLocal();

      _selectedCategoryIds
        ..clear()
        ..addAll(
          promotionCategories.map(
            (Map<String, dynamic> item) =>
                item['category_id'].toString(),
          ),
        );

      _selectedProductIds
        ..clear()
        ..addAll(
          promotionProducts.map(
            (Map<String, dynamic> item) =>
                item['product_id'].toString(),
          ),
        );

      _groups.clear();

      for (final Map<String, dynamic> group
          in promotionGroups) {
        _groupCounter++;

        final Set<String> categoryIds = {};

        final dynamic rawCategories =
            group['promotion_group_categories'];

        if (rawCategories is List) {
          for (final dynamic item in rawCategories) {
            if (item is Map &&
                item['category_id'] != null) {
              categoryIds.add(
                item['category_id'].toString(),
              );
            }
          }
        }

        final Set<String> productIds = {};

        final dynamic rawProducts =
            group['promotion_group_products'];

        if (rawProducts is List) {
          for (final dynamic item in rawProducts) {
            if (item is Map &&
                item['product_id'] != null) {
              productIds.add(
                item['product_id'].toString(),
              );
            }
          }
        }

        _groups.add({
          'localId': _groupCounter,
          'name':
              group['name']?.toString() ??
                  'Group $_groupCounter',
          'requiredQuantity':
              (group['required_quantity'] as num?)
                      ?.toInt() ??
                  1,
          'categoryIds': categoryIds,
          'productIds': productIds,
        });
      }

      // A Mix & Match promotion should normally already
      // have groups. This gives the UI something usable
      // if old/incomplete data does not.
      if (_promotionType == 'mix_and_match' &&
          _groups.isEmpty) {
        _groups.add(
          _newGroup('Drink'),
        );

        _groups.add(
          _newGroup('Snack'),
        );
      }

      setState(() {
        _categories = categories;
        _products = products;
        _isLoading = false;
      });
    } on PostgrestException catch (error) {
      debugPrint(
        'LOAD EDIT PROMOTION POSTGREST ERROR',
      );
      debugPrint('Code: ${error.code}');
      debugPrint('Message: ${error.message}');
      debugPrint('Details: ${error.details}');
      debugPrint('Hint: ${error.hint}');

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage(
        'Unable to load promotion: ${error.message}',
        isError: true,
      );
    } catch (error) {
      debugPrint(
        'LOAD EDIT PROMOTION ERROR: $error',
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage(
        'Unable to load promotion.',
        isError: true,
      );
    }
  }

  // =============================================================
  // HELPERS
  // =============================================================

  String _formatNumber(num value) {
    if (value % 1 == 0) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(2);
  }

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
  // FORM CHANGES
  // =============================================================

  void _changePromotionType(
    String value,
  ) {
    setState(() {
      _promotionType = value;

      if (value == 'mix_and_match' &&
          _groups.isEmpty) {
        _groups.add(
          _newGroup('Drink'),
        );

        _groups.add(
          _newGroup('Snack'),
        );
      }
    });
  }

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
  // SCHEDULE
  // =============================================================

  Future<DateTime?> _pickDateTime(
    DateTime initial,
  ) async {
    final DateTime? date =
        await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(
        const Duration(days: 3650),
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

    if (result == null) return;

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

    if (result == null) return;

    if (!result.isAfter(_startsAt)) {
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
  // BANNER
  // =============================================================

  Future<void> _pickBanner() async {
    if (_isPickingBanner) return;

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

      if (bytes.length >
          5 * 1024 * 1024) {
        _showMessage(
          'Banner image must be smaller than 5 MB.',
          isError: true,
        );

        return;
      }

      final String lowerName =
          image.name.toLowerCase();

      final int dotIndex =
          lowerName.lastIndexOf('.');

      if (dotIndex == -1) {
        _showMessage(
          'The selected image has an unsupported file type.',
          isError: true,
        );

        return;
      }

      String extension =
          lowerName.substring(
        dotIndex + 1,
      );

      const Set<String> allowed = {
        'jpg',
        'jpeg',
        'png',
        'webp',
      };

      if (!allowed.contains(extension)) {
        _showMessage(
          'Please select a JPG, PNG, or WebP image.',
          isError: true,
        );

        return;
      }

      if (extension == 'jpeg') {
        extension = 'jpg';
      }

      if (!mounted) return;

      setState(() {
        _bannerBytes = bytes;
        _bannerExtension = extension;
        _removeExistingBanner = false;
      });
    } catch (error) {
      debugPrint(
        'EDIT PROMOTION PICK BANNER ERROR: $error',
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

      _existingBannerUrl = null;
      _removeExistingBanner = true;
    });
  }

  String? _storagePathFromPublicUrl(
    String? url,
  ) {
    if (url == null || url.trim().isEmpty) {
      return null;
    }

    const String marker =
        '/storage/v1/object/public/promotion-banners/';

    final int index = url.indexOf(marker);

    if (index == -1) {
      return null;
    }

    return Uri.decodeFull(
      url.substring(
        index + marker.length,
      ),
    );
  }

  // =============================================================
  // VALIDATION
  // =============================================================

  bool _validateBusinessRules() {
    if (!_validUntil.isAfter(_startsAt)) {
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

      for (int i = 0;
          i < _groups.length;
          i++) {
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
  // UPDATE
  // =============================================================

  Future<void> _updatePromotion() async {
    if (_isSaving) return;

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

    String? newlyUploadedPath;

    try {
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

      String? finalBannerUrl =
          _existingBannerUrl;

      // ---------------------------------------------------------
      // Upload replacement banner first.
      // ---------------------------------------------------------

      if (_bannerBytes != null) {
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

        final String extension =
            _bannerExtension ?? 'jpg';

        final String fileName =
            '${DateTime.now().microsecondsSinceEpoch}.$extension';

        newlyUploadedPath =
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
              newlyUploadedPath,
              _bannerBytes!,
              fileOptions:
                  FileOptions(
                contentType:
                    contentType,
                upsert: false,
              ),
            );

        finalBannerUrl =
            _supabase.storage
                .from(
                  'promotion-banners',
                )
                .getPublicUrl(
                  newlyUploadedPath,
                );
      }

      if (_removeExistingBanner &&
          _bannerBytes == null) {
        finalBannerUrl = null;
      }

      // ---------------------------------------------------------
      // Update parent promotion.
      // ---------------------------------------------------------

      await _supabase
          .from('promotions')
          .update({
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
                finalBannerUrl,

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
          .eq(
            'id',
            widget.promotionId,
          );

      // ---------------------------------------------------------
      // Clear old targeting.
      //
      // Deleting promotion_groups cascades to its group
      // category/product junction rows.
      // ---------------------------------------------------------

      await _supabase
          .from('promotion_categories')
          .delete()
          .eq(
            'promotion_id',
            widget.promotionId,
          );

      await _supabase
          .from('promotion_products')
          .delete()
          .eq(
            'promotion_id',
            widget.promotionId,
          );

      await _supabase
          .from('promotion_groups')
          .delete()
          .eq(
            'promotion_id',
            widget.promotionId,
          );

      // ---------------------------------------------------------
      // Recreate current targeting.
      // ---------------------------------------------------------

      if (_promotionType ==
          'simple_discount') {
        await _saveSimpleTargets();
      } else {
        await _saveMixMatchGroups();
      }

      // ---------------------------------------------------------
      // Database update succeeded.
      // We can now delete the OLD banner if necessary.
      // ---------------------------------------------------------

      if ((_bannerBytes != null ||
              _removeExistingBanner) &&
          _existingBannerPath != null) {
        try {
          await _supabase.storage
              .from(
                'promotion-banners',
              )
              .remove([
            _existingBannerPath!,
          ]);
        } catch (error) {
          // Promotion is already updated.
          // Do not fail the entire edit because old-file
          // cleanup failed.
          debugPrint(
            'OLD PROMOTION BANNER CLEANUP ERROR: $error',
          );
        }
      }

      if (!mounted) return;

      _showMessage(
        'Promotion updated successfully.',
      );

      Navigator.of(context).pop(
        true,
      );
    } on PostgrestException catch (error) {
      debugPrint(
        'UPDATE PROMOTION POSTGREST ERROR',
      );
      debugPrint('Code: ${error.code}');
      debugPrint('Message: ${error.message}');
      debugPrint('Details: ${error.details}');
      debugPrint('Hint: ${error.hint}');

      // If the new image uploaded but the update failed,
      // remove that newly uploaded image.
      if (newlyUploadedPath != null) {
        try {
          await _supabase.storage
              .from(
                'promotion-banners',
              )
              .remove([
            newlyUploadedPath,
          ]);
        } catch (_) {}
      }

      _showMessage(
        'Unable to update promotion: ${error.message}',
        isError: true,
      );
    } on StorageException catch (error) {
      debugPrint(
        'UPDATE PROMOTION STORAGE ERROR',
      );
      debugPrint(
        'Message: ${error.message}',
      );

      if (newlyUploadedPath != null) {
        try {
          await _supabase.storage
              .from(
                'promotion-banners',
              )
              .remove([
            newlyUploadedPath,
          ]);
        } catch (_) {}
      }

      _showMessage(
        'Unable to update promotion banner: ${error.message}',
        isError: true,
      );
    } catch (error) {
      debugPrint(
        'UPDATE PROMOTION ERROR: $error',
      );

      if (newlyUploadedPath != null) {
        try {
          await _supabase.storage
              .from(
                'promotion-banners',
              )
              .remove([
            newlyUploadedPath,
          ]);
        } catch (_) {}
      }

      _showMessage(
        'Unable to update promotion.',
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
  // SIMPLE TARGETS
  // =============================================================

  Future<void>
      _saveSimpleTargets() async {
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
                        widget.promotionId,
                    'category_id': id,
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
                        widget.promotionId,
                    'product_id': id,
                  },
                )
                .toList(),
          );
    }
  }

  // =============================================================
  // MIX & MATCH TARGETS
  // =============================================================

  Future<void>
      _saveMixMatchGroups() async {
    for (int i = 0;
        i < _groups.length;
        i++) {
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
                    widget.promotionId,
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
  // DELETE PROMOTION
  // =============================================================

  Future<void> _confirmDelete() async {
    if (_isSaving || _isDeleting) {
      return;
    }

    final bool? confirmed =
        await showDialog<bool>(
      context: context,
      builder: (
        BuildContext dialogContext,
      ) {
        return AlertDialog(
          title: const Text(
            'Delete promotion?',
            style: TextStyle(
              fontWeight: FontWeight.w900,
            ),
          ),
          content: const Text(
            'This promotion and all of its targeting rules will be permanently deleted.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(false);
              },
              child: const Text(
                'Cancel',
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(true);
              },
              style:
                  FilledButton.styleFrom(
                backgroundColor:
                    Colors.red.shade700,
              ),
              child: const Text(
                'Delete',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    await _deletePromotion();
  }

  Future<void> _deletePromotion() async {
    setState(() {
      _isDeleting = true;
    });

    try {
      // Cascades should remove:
      // promotion_categories
      // promotion_products
      // promotion_groups
      // promotion_group_categories
      // promotion_group_products

      await _supabase
          .from('promotions')
          .delete()
          .eq(
            'id',
            widget.promotionId,
          );

      if (_existingBannerPath != null) {
        try {
          await _supabase.storage
              .from(
                'promotion-banners',
              )
              .remove([
            _existingBannerPath!,
          ]);
        } catch (error) {
          debugPrint(
            'DELETE PROMOTION BANNER ERROR: $error',
          );
        }
      }

      if (!mounted) return;

      Navigator.of(context).pop(
        true,
      );
    } on PostgrestException catch (error) {
      debugPrint(
        'DELETE PROMOTION ERROR: ${error.message}',
      );

      _showMessage(
        'Unable to delete promotion: ${error.message}',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
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
              'MANAGE',
              style: TextStyle(
                fontSize: 8,
                fontWeight:
                    FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
            Text(
              'Edit Promotion',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.w900,
                letterSpacing: -0.4,
              ),
            ),
          ],
        ),
        actions: [
          if (!_isLoading)
            IconButton(
              onPressed:
                  _isDeleting
                      ? null
                      : _confirmDelete,
              tooltip:
                  'Delete promotion',
              icon: _isDeleting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(
                      Icons
                          .delete_outline_rounded,
                    ),
            ),
          const SizedBox(
            width: 5,
          ),
        ],
      ),
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

                  // See note below about existing network image.
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

                  if (_existingBannerUrl != null &&
                      _bannerBytes == null) ...[
                    const SizedBox(
                      height: 10,
                    ),
                    _buildExistingBanner(),
                  ],

                  const SizedBox(
                    height: 14,
                  ),

                  PromoTypeSelector(
                    value:
                        _promotionType,
                    onChanged:
                        _changePromotionType,
                  ),

                  const SizedBox(
                    height: 14,
                  ),

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
                  ] else ...[
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
                          _isSaving ||
                                  _isDeleting
                              ? null
                              : _updatePromotion,
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
                      child: _isSaving
                          ? const SizedBox(
                              width: 21,
                              height: 21,
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
                                      .check_rounded,
                                ),
                                SizedBox(
                                  width: 7,
                                ),
                                Text(
                                  'Save Changes',
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

  // =============================================================
  // EXISTING BANNER
  // =============================================================

  Widget _buildExistingBanner() {
    return Container(
      padding: const EdgeInsets.all(
        10,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius:
            BorderRadius.circular(
          18,
        ),
        border: Border.all(
          color: AppColors.border
              .withValues(
            alpha: 0.25,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius:
                BorderRadius.circular(
              14,
            ),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                _existingBannerUrl!,
                fit: BoxFit.cover,
                errorBuilder: (
                  context,
                  error,
                  stackTrace,
                ) {
                  return Container(
                    color:
                        AppColors.background,
                    alignment:
                        Alignment.center,
                    child: const Icon(
                      Icons
                          .broken_image_outlined,
                      size: 28,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(
            height: 9,
          ),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Current banner',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed:
                    _pickBanner,
                icon: const Icon(
                  Icons
                      .photo_library_outlined,
                  size: 16,
                ),
                label: const Text(
                  'Replace',
                ),
              ),
              IconButton(
                onPressed:
                    _removeBanner,
                icon: const Icon(
                  Icons
                      .delete_outline_rounded,
                  size: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}