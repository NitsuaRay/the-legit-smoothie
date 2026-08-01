import 'package:flutter/material.dart';

class CartBottomSheet extends StatelessWidget {
  final List<Map<String, dynamic>> cartItems;
  final Function(int index, int newQuantity) onUpdateQuantity;
  final Function(int index) onRemoveItem;
  final VoidCallback onCheckout;

  const CartBottomSheet({
    super.key,
    required this.cartItems,
    required this.onUpdateQuantity,
    required this.onRemoveItem,
    required this.onCheckout,
  });

  static void show(
    BuildContext context, {
    required List<Map<String, dynamic>> cartItems,
    required Function(int index, int newQuantity) onUpdateQuantity,
    required Function(int index) onRemoveItem,
    required VoidCallback onCheckout,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => CartBottomSheet(
        cartItems: cartItems,
        onUpdateQuantity: onUpdateQuantity,
        onRemoveItem: onRemoveItem,
        onCheckout: onCheckout,
      ),
    );
  }

  double get _totalCartPrice => cartItems.fold(
        0.0,
        (sum, item) =>
            sum + ((item['price'] as double) * (item['quantity'] as int)),
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return StatefulBuilder(
      builder: (context, setCartState) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bottom Sheet Handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Your Order (${cartItems.length})',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Cart Items List
              if (cartItems.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Text(
                      'Your cart is empty',
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: cartItems.length,
                    separatorBuilder: (_, __) => const Divider(height: 24),
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      final quantity = item['quantity'] as int;

                      return Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['name'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Size: ${item['selectedSize']} • Sweetness: ${item['sugarLevel']}%',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '₱${((item['price'] as double) * quantity).toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Quantity Controls
                          Row(
                            children: [
                              IconButton.filledTonal(
                                iconSize: 16,
                                visualDensity: VisualDensity.compact,
                                icon: const Icon(Icons.remove_rounded),
                                onPressed: () {
                                  if (quantity > 1) {
                                    onUpdateQuantity(index, quantity - 1);
                                  } else {
                                    onRemoveItem(index);
                                  }
                                  setCartState(() {});
                                  if (cartItems.isEmpty) {
                                    Navigator.pop(context);
                                  }
                                },
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  '$quantity',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton.filledTonal(
                                iconSize: 16,
                                visualDensity: VisualDensity.compact,
                                icon: const Icon(Icons.add_rounded),
                                onPressed: () {
                                  onUpdateQuantity(index, quantity + 1);
                                  setCartState(() {});
                                },
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),

              const SizedBox(height: 16),
              Divider(color: colorScheme.outlineVariant.withOpacity(0.5)),
              const SizedBox(height: 12),

              // Total & Checkout Button
              FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                onPressed: cartItems.isEmpty
                    ? null
                    : () {
                        Navigator.pop(context);
                        onCheckout();
                      },
                child: Text(
                  'Checkout • ₱${_totalCartPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class FloatingCartBar extends StatelessWidget {
  final int totalCount;
  final double totalPrice;
  final VoidCallback onTap;

  const FloatingCartBar({
    super.key,
    required this.totalCount,
    required this.totalPrice,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: FilledButton(
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: onTap,
          child: Row(
            children: [
              Badge(
                label: Text('$totalCount'),
                child: const Icon(Icons.shopping_bag_outlined),
              ),
              const SizedBox(width: 16),
              const Text(
                'View Cart',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Spacer(),
              Text(
                '₱${totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_forward_ios_rounded, size: 14),
            ],
          ),
        ),
      ),
    );
  }
}