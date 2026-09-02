import 'package:flutter/material.dart';
import '../models/cart_item_model.dart';
import '../../catalog/models/product_model.dart';

class CartService extends ChangeNotifier {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  final List<CartItemModel> _items = [];

  List<CartItemModel> get items => List.unmodifiable(_items);

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => _items.fold(0, (sum, item) => sum + item.totalPrice);

  void addItem({
    required ProductModel product,
    required List<Map<String, dynamic>> selectedOptions,
    required double unitPrice,
    required int quantity,
  }) {
    final newItem = CartItemModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      product: product,
      selectedOptions: selectedOptions,
      unitPrice: unitPrice,
      quantity: quantity,
    );

    _items.add(newItem);
    notifyListeners();
  }

  void incrementQuantity(String cartItemId) {
    final index = _items.indexWhere((item) => item.id == cartItemId);
    if (index != -1) {
      _items[index].quantity++;
      notifyListeners();
    }
  }

  void decrementQuantity(String cartItemId) {
    final index = _items.indexWhere((item) => item.id == cartItemId);
    if (index != -1) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  void removeItem(String cartItemId) {
    _items.removeWhere((item) => item.id == cartItemId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}