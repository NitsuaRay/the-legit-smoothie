import 'package:flutter/material.dart';
import 'package:the_legit_smoothie/core/constants/app_colors.dart';

class PaymentMethodsTab extends StatefulWidget {
  const PaymentMethodsTab({super.key});

  @override
  State<PaymentMethodsTab> createState() => _PaymentMethodsTabState();
}

class _PaymentMethodsTabState extends State<PaymentMethodsTab> {
  // Mock Data for Payment Methods
  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': '1',
      'type': 'GCash',
      'detail': '+63 912 345 6789',
      'icon': Icons.phone_android_rounded,
      'isDefault': true,
    },
    {
      'id': '2',
      'type': 'Credit / Debit Card',
      'detail': '•••• •••• •••• 4242',
      'icon': Icons.credit_card_rounded,
      'isDefault': false,
    },
    {
      'id': '3',
      'type': 'Cash on Delivery (COD)',
      'detail': 'Pay when your order arrives',
      'icon': Icons.money_rounded,
      'isDefault': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardColor = isDark ? AppColors.darkText : AppColors.cardWhite;
    final primaryTextColor = isDark ? AppColors.cream : AppColors.darkText;
    final secondaryTextColor = isDark
        ? AppColors.cream.withValues(alpha: 0.7)
        : AppColors.greyText;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bobaBrown : AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Custom Header Section ---
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? AppColors.bobaBrown.withValues(alpha: 0.4)
                            : AppColors.greyBorder,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        color: isDark ? AppColors.cream : AppColors.bobaBrown,
                        size: 20,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Payment Methods',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: primaryTextColor,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          'Manage your preferred payment options',
                          style: TextStyle(
                            fontSize: 13,
                            color: secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cream : AppColors.bobaBrown,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.add_rounded,
                        color: isDark ? AppColors.darkText : AppColors.cardWhite,
                        size: 20,
                      ),
                      onPressed: () => _showPaymentBottomSheet(context, isDark, cardColor, primaryTextColor, secondaryTextColor),
                    ),
                  ),
                ],
              ),
            ),

            // --- Payment Method List ---
            Expanded(
              child: _paymentMethods.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.cream.withValues(alpha: 0.1)
                                  : AppColors.bobaBrown.withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.payment_rounded,
                              size: 48,
                              color: isDark ? AppColors.cream : AppColors.bobaBrown,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No payment methods saved',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: primaryTextColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Add a payment method for quick checkouts.',
                            style: TextStyle(fontSize: 13, color: secondaryTextColor),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      itemCount: _paymentMethods.length,
                      itemBuilder: (context, index) {
                        final methodItem = _paymentMethods[index];
                        final isDefault = methodItem['isDefault'] == true;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDefault
                                  ? (isDark ? AppColors.cream : AppColors.bobaBrown)
                                  : (isDark
                                      ? AppColors.bobaBrown.withValues(alpha: 0.4)
                                      : AppColors.greyBorder),
                              width: isDefault ? 1.5 : 1.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        methodItem['icon'],
                                        size: 20,
                                        color: isDark ? AppColors.cream : AppColors.bobaBrown,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        methodItem['type'],
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: primaryTextColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (isDefault)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? AppColors.cream.withValues(alpha: 0.15)
                                            : AppColors.bobaBrown.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        'Default',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? AppColors.cream : AppColors.bobaBrown,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.only(left: 30),
                                child: Text(
                                  methodItem['detail'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: primaryTextColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Divider(
                                height: 24,
                                color: isDark
                                    ? AppColors.bobaBrown.withValues(alpha: 0.3)
                                    : AppColors.greyBorder,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (!isDefault)
                                    TextButton.icon(
                                      onPressed: () {
                                        setState(() {
                                          for (var element in _paymentMethods) {
                                            element['isDefault'] = false;
                                          }
                                          methodItem['isDefault'] = true;
                                        });
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Default payment method updated!'),
                                            backgroundColor: AppColors.success,
                                          ),
                                        );
                                      },
                                      icon: Icon(Icons.check_circle_outline_rounded, size: 16, color: isDark ? AppColors.cream : AppColors.bobaBrown),
                                      label: Text(
                                        'Set as Default',
                                        style: TextStyle(fontSize: 12, color: isDark ? AppColors.cream : AppColors.bobaBrown),
                                      ),
                                    ),
                                  const Spacer(),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                                    onPressed: () {
                                      setState(() {
                                        _paymentMethods.removeAt(index);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentBottomSheet(
    BuildContext context,
    bool isDark,
    Color cardColor,
    Color primaryTextColor,
    Color secondaryTextColor,
  ) {
    String selectedType = 'GCash';
    final detailController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: secondaryTextColor.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Add Payment Method',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    dropdownColor: cardColor,
                    style: TextStyle(color: primaryTextColor),
                    decoration: InputDecoration(
                      labelText: 'Payment Type',
                      labelStyle: TextStyle(color: secondaryTextColor),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: secondaryTextColor.withValues(alpha: 0.3))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? AppColors.cream : AppColors.bobaBrown)),
                    ),
                    items: ['GCash', 'Credit / Debit Card', 'Maya', 'Cash on Delivery (COD)']
                        .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setModalState(() {
                          selectedType = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: detailController,
                    style: TextStyle(color: primaryTextColor),
                    decoration: InputDecoration(
                      labelText: selectedType == 'Credit / Debit Card' ? 'Card Number (Last 4 digits)' : 'Account Number / Phone Number',
                      labelStyle: TextStyle(color: secondaryTextColor),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: secondaryTextColor.withValues(alpha: 0.3))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? AppColors.cream : AppColors.bobaBrown)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        IconData iconData = Icons.payment_rounded;
                        if (selectedType == 'GCash' || selectedType == 'Maya') {
                          iconData = Icons.phone_android_rounded;
                        } else if (selectedType == 'Credit / Debit Card') {
                          iconData = Icons.credit_card_rounded;
                        } else if (selectedType == 'Cash on Delivery (COD)') {
                          iconData = Icons.money_rounded;
                        }

                        setState(() {
                          _paymentMethods.add({
                            'id': DateTime.now().millisecondsSinceEpoch.toString(),
                            'type': selectedType,
                            'detail': detailController.text.isEmpty ? 'Primary account' : detailController.text,
                            'icon': iconData,
                            'isDefault': _paymentMethods.isEmpty,
                          });
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? AppColors.cream : AppColors.bobaBrown,
                        foregroundColor: isDark ? AppColors.darkText : AppColors.cardWhite,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Save Payment Method'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}