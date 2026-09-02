import '../../catalog/models/product_model.dart';

class CartItemModel {
  final String id;
  final ProductModel product;
  final List<Map<String, dynamic>> selectedOptions; // [{'group': 'Size', 'name': '22oz', 'extra_price': 15.0}]
  final double unitPrice;
  int quantity;

  CartItemModel({
    required this.id,
    required this.product,
    required this.selectedOptions,
    required this.unitPrice,
    this.quantity = 1,
  });

  double get totalPrice => unitPrice * quantity;
}