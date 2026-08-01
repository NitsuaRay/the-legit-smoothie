import 'package:flutter/material.dart';
import 'package:the_legit_smoothie/core/constants/app_colors.dart';

class CustomerCartTab extends StatefulWidget {
  const CustomerCartTab({super.key});

  @override
  State<CustomerCartTab> createState() => _CustomerCartTabState();
}

class _CustomerCartTabState extends State<CustomerCartTab> {
  final List<Map<String, dynamic>> _cartItems = [
    {
      'name': 'Tropical Mango Splash',
      'category': 'Smoothies',
      'price': 120.00,
      'quantity': 2,
      'size': 'Regular',
      'image': 'assets/bgWhite.png',
    },
    {
      'name': 'Acai Energy Bowl',
      'category': 'Bowls',
      'price': 180.00,
      'quantity': 1,
      'size': 'Large',
      'image': 'assets/bgWhite.png',
    },
    {
      'name': 'Green Detox Booster',
      'category': 'Fresh Juice',
      'price': 110.00,
      'quantity': 1,
      'size': 'Regular',
      'image': 'assets/bgWhite.png',
    },
  ];

  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _promoController = TextEditingController();
  bool _isPromoApplied = false;

  double get _subtotal {
    return _cartItems.fold(
      0.0,
      (sum, item) => sum + (item['price'] * item['quantity']),
    );
  }

  double get _discount => _isPromoApplied ? 30.00 : 0.00;
  final double _deliveryFee = 45.00;

  @override
  void dispose() {
    _noteController.dispose();
    _promoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = Colors.transparent;
    final surfaceColor = isDarkMode ? AppColors.bobaBrown : AppColors.cardWhite;
    final textColor = isDarkMode ? AppColors.cream : AppColors.darkText;
    final subtextColor = isDarkMode ? AppColors.cream.withOpacity(0.7) : AppColors.greyText;
    final borderColor = isDarkMode ? AppColors.cream.withOpacity(0.2) : AppColors.greyBorder;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: _cartItems.isEmpty
            ? Column(
                children: [
                  _buildModernHeader(textColor, subtextColor, isDarkMode),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_bag_outlined,
                            size: 64,
                            color: subtextColor,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Your cart is empty!',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Add some fresh drinks to start your order.',
                            style: TextStyle(color: subtextColor, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Modern Header with Catchy Icon & Badge
                    _buildModernHeader(textColor, subtextColor, isDarkMode),
                    const SizedBox(height: 16),

                    // 1. Cart Items List
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _cartItems.length,
                      itemBuilder: (context, index) {
                        final item = _cartItems[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDarkMode ? AppColors.darkText.withOpacity(0.2) : AppColors.cardWhite,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: borderColor),
                            boxShadow: [
                              BoxShadow(
                                color: isDarkMode
                                    ? Colors.black.withOpacity(0.2)
                                    : AppColors.darkText.withOpacity(0.03),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  width: 70,
                                  height: 70,
                                  color: AppColors.cream.withOpacity(0.2),
                                  child: Image.asset(
                                    item['image'],
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        const Icon(
                                      Icons.local_drink_rounded,
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['name'],
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: textColor,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Size: ${item['size']}',
                                      style: TextStyle(
                                        color: subtextColor,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '₱${(item['price'] * item['quantity']).toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: isDarkMode ? AppColors.cream : AppColors.secondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        _cartItems.removeAt(index);
                                      });
                                    },
                                    child: Icon(
                                      Icons.delete_outline_rounded,
                                      size: 18,
                                      color: subtextColor,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            if (item['quantity'] > 1) {
                                              item['quantity']--;
                                            }
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: borderColor),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Icon(Icons.remove, size: 14, color: textColor),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                        child: Text(
                                          '${item['quantity']}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: textColor,
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            item['quantity']++;
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: AppColors.secondary,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: const Icon(Icons.add, size: 14, color: AppColors.cardWhite),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),

                    // 2. Promo Code Input Section
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.local_offer_outlined, color: subtextColor, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _promoController,
                              style: TextStyle(color: textColor, fontSize: 13),
                              decoration: InputDecoration(
                                hintText: 'Enter promo code (e.g. LEGIT30)',
                                hintStyle: TextStyle(color: subtextColor, fontSize: 13),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                if (_promoController.text.trim().isNotEmpty) {
                                  _isPromoApplied = true;
                                }
                              });
                            },
                            child: const Text(
                              'Apply',
                              style: TextStyle(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 3. Order Note Section
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 2.0),
                            child: Icon(Icons.note_alt_outlined, color: subtextColor, size: 20),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _noteController,
                              maxLines: 2,
                              style: TextStyle(color: textColor, fontSize: 13),
                              decoration: InputDecoration(
                                hintText: 'Add a note for your order (e.g., less ice, extra straw)',
                                hintStyle: TextStyle(color: subtextColor, fontSize: 13),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 4. Detailed Bill Summary Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: borderColor),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order Summary',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Subtotal', style: TextStyle(color: subtextColor, fontSize: 13)),
                              Text('₱${_subtotal.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Delivery Fee', style: TextStyle(color: subtextColor, fontSize: 13)),
                              Text('₱${_deliveryFee.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 13)),
                            ],
                          ),
                          if (_isPromoApplied) ...[
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Promo Discount', style: TextStyle(color: AppColors.success, fontSize: 13)),
                                Text('-₱${_discount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.success, fontSize: 13)),
                              ],
                            ),
                          ],
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: Divider(color: borderColor),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Amount',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              Text(
                                '₱${(_subtotal + _deliveryFee - _discount).toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode ? AppColors.cream : AppColors.secondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secondary,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: _cartItems.isEmpty ? null : () {},
                              child: const Text(
                                'Proceed to Checkout',
                                style: TextStyle(
                                  color: AppColors.cardWhite,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
      ),
    );
  }

  // Modern & Catchy Header Widget with an Icon & Badge counter
  Widget _buildModernHeader(Color textColor, Color subtextColor, bool isDarkMode) {
    int totalItemsCount = _cartItems.fold(0, (sum, item) => sum + (item['quantity'] as int));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '🥤 Review Your Order',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Freshly blended goodness waiting for you',
                style: TextStyle(
                  fontSize: 13,
                  color: subtextColor,
                ),
              ),
            ],
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDarkMode ? AppColors.darkText.withOpacity(0.3) : AppColors.cardWhite,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDarkMode ? AppColors.cream.withOpacity(0.2) : AppColors.greyBorder,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.local_mall_rounded,
                  color: AppColors.secondary,
                  size: 22,
                ),
              ),
              if (_cartItems.isNotEmpty)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      '$totalItemsCount',
                      style: const TextStyle(
                        color: AppColors.cardWhite,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}