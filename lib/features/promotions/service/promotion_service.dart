import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../cart/models/cart_item_model.dart';
import '../models/applied_promotion.dart';

class PromotionService {
  PromotionService({
    SupabaseClient? supabase,
  }) : _supabase =
            supabase ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  // =============================================================
  // BEST PROMOTION
  // =============================================================

  Future<AppliedPromotion?>
      calculateBestPromotion(
    List<CartItemModel> items,
  ) async {
    if (items.isEmpty) {
      return null;
    }

    try {
      final List<Map<String, dynamic>>
          cartPayload =
          buildCartPayload(items);

      final dynamic response =
          await _supabase.rpc(
        'calculate_best_promotion',
        params: {
          'p_cart': cartPayload,
        },
      );

      final Map<String, dynamic>?
          promotion =
          _extractSingleResult(response);

      if (promotion == null) {
        return null;
      }

      final AppliedPromotion result =
          AppliedPromotion.fromMap(
        promotion,
      );

      if (!result.hasDiscount) {
        return null;
      }

      return result;
    } on PostgrestException catch (error) {
      debugPrint(
        'Promotion RPC error: '
        '${error.message}',
      );

      rethrow;
    } catch (error) {
      debugPrint(
        'Promotion calculation error: $error',
      );

      rethrow;
    }
  }

  // =============================================================
  // CART -> DATABASE PAYLOAD
  // =============================================================

  List<Map<String, dynamic>>
      buildCartPayload(
    List<CartItemModel> items,
  ) {
    return items.map((item) {
      return {
        'product_id':
            item.product.id,
        'quantity':
            item.quantity,
        'selected_option_ids':
            _extractOptionIds(
          item.selectedOptions,
        ),
      };
    }).toList();
  }

  // =============================================================
  // OPTION IDS
  // =============================================================

  List<String> _extractOptionIds(
    List<Map<String, dynamic>>
        selectedOptions,
  ) {
    final List<String> ids = [];

    for (final option
        in selectedOptions) {
      final dynamic rawId =
          option['id'] ??
          option['option_id'];

      if (rawId == null) {
        continue;
      }

      final String id =
          rawId.toString().trim();

      if (id.isNotEmpty) {
        ids.add(id);
      }
    }

    return ids;
  }

  // =============================================================
  // RPC RESPONSE
  // =============================================================

  Map<String, dynamic>?
      _extractSingleResult(
    dynamic response,
  ) {
    if (response == null) {
      return null;
    }

    if (response is List) {
      if (response.isEmpty) {
        return null;
      }

      final dynamic first =
          response.first;

      if (first is Map) {
        return Map<String, dynamic>.from(
          first,
        );
      }

      return null;
    }

    if (response is Map) {
      return Map<String, dynamic>.from(
        response,
      );
    }

    return null;
  }
}