import 'package:flutter/material.dart';
import 'package:the_legit_smoothie/features/promotions/service/promotion_service.dart';

import '../models/cart_item_model.dart';
import '../../catalog/models/product_model.dart';

import '../../promotions/models/applied_promotion.dart';

class CartService extends ChangeNotifier {
  static final CartService _instance =
      CartService._internal();

  factory CartService() => _instance;

  CartService._internal();

  final List<CartItemModel> _items = [];

  final PromotionService
      _promotionService =
      PromotionService();

  AppliedPromotion? _appliedPromotion;

  bool _isCalculatingPromotion =
      false;

  int _promotionRequestVersion = 0;

  // =============================================================
  // GETTERS
  // =============================================================

  List<CartItemModel> get items =>
      List.unmodifiable(_items);

  int get itemCount => _items.fold(
        0,
        (sum, item) =>
            sum + item.quantity,
      );

  double get subtotal =>
      _items.fold(
        0,
        (sum, item) =>
            sum + item.totalPrice,
      );

  AppliedPromotion?
      get appliedPromotion =>
          _appliedPromotion;

  bool get isCalculatingPromotion =>
      _isCalculatingPromotion;

  double get discountAmount =>
      _appliedPromotion
          ?.discountAmount ??
      0;

  double get discountedSubtotal {
    return (subtotal - discountAmount)
        .clamp(
          0.0,
          double.infinity,
        )
        .toDouble();
  }

  bool get hasPromotion =>
      _appliedPromotion != null &&
      discountAmount > 0;

  // =============================================================
  // ADD
  // =============================================================

  void addItem({
    required ProductModel product,
    required List<Map<String, dynamic>>
        selectedOptions,
    required double unitPrice,
    required int quantity,
  }) {
    final newItem = CartItemModel(
      id: DateTime.now()
          .microsecondsSinceEpoch
          .toString(),
      product: product,
      selectedOptions:
          selectedOptions,
      unitPrice: unitPrice,
      quantity: quantity,
    );

    _items.add(newItem);

    _cartChanged();
  }

  // =============================================================
  // INCREMENT
  // =============================================================

  void incrementQuantity(
    String cartItemId,
  ) {
    final index =
        _items.indexWhere(
      (item) =>
          item.id == cartItemId,
    );

    if (index == -1) return;

    _items[index].quantity++;

    _cartChanged();
  }

  // =============================================================
  // DECREMENT
  // =============================================================

  void decrementQuantity(
    String cartItemId,
  ) {
    final index =
        _items.indexWhere(
      (item) =>
          item.id == cartItemId,
    );

    if (index == -1) return;

    if (_items[index].quantity > 1) {
      _items[index].quantity--;
    } else {
      _items.removeAt(index);
    }

    _cartChanged();
  }

  // =============================================================
  // REMOVE
  // =============================================================

  void removeItem(
    String cartItemId,
  ) {
    _items.removeWhere(
      (item) =>
          item.id == cartItemId,
    );

    _cartChanged();
  }

  // =============================================================
  // CLEAR
  // =============================================================

  void clearCart() {
    _promotionRequestVersion++;

    _items.clear();
    _appliedPromotion = null;
    _isCalculatingPromotion = false;

    notifyListeners();
  }

  // =============================================================
  // CART CHANGED
  // =============================================================

  void _cartChanged() {
    // Immediately remove the previous promotion so
    // stale savings are never shown for a changed cart.
    _appliedPromotion = null;

    notifyListeners();

    calculatePromotion();
  }

  // =============================================================
  // PROMOTION
  // =============================================================

  Future<void>
      calculatePromotion() async {
    final int requestVersion =
        ++_promotionRequestVersion;

    if (_items.isEmpty) {
      _appliedPromotion = null;
      _isCalculatingPromotion =
          false;

      notifyListeners();
      return;
    }

    _isCalculatingPromotion = true;
    notifyListeners();

    try {
      final promotion =
          await _promotionService
              .calculateBestPromotion(
        List<CartItemModel>.from(
          _items,
        ),
      );

      // Ignore an older RPC response if the
      // cart changed while it was running.
      if (requestVersion !=
          _promotionRequestVersion) {
        return;
      }

      _appliedPromotion =
          promotion;
    } catch (error) {
      debugPrint(
        'Unable to calculate promotion: '
        '$error',
      );

      if (requestVersion !=
          _promotionRequestVersion) {
        return;
      }

      _appliedPromotion = null;
    } finally {
      if (requestVersion ==
          _promotionRequestVersion) {
        _isCalculatingPromotion =
            false;

        notifyListeners();
      }
    }
  }
}