import 'package:flutter/material.dart';
import 'package:the_legit_smoothie/core/constants/app_colors.dart';

class DeliveryAddressesTab extends StatefulWidget {
  const DeliveryAddressesTab({super.key});

  @override
  State<DeliveryAddressesTab> createState() => _DeliveryAddressesTabState();
}

class _DeliveryAddressesTabState extends State<DeliveryAddressesTab> {
  // Mock Data for Delivery Addresses
  final List<Map<String, dynamic>> _addresses = [
    {
      'id': '1',
      'label': 'Home',
      'address': 'Unit 4B, Sunshine Residences, Quezon City',
      'contact': '+63 912 345 6789',
      'isDefault': true,
    },
    {
      'id': '2',
      'label': 'Work / Office',
      'address': '18th Floor, Tech Tower, Ayala Avenue, Makati City',
      'contact': '+63 918 765 4321',
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
                          'Delivery Addresses',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: primaryTextColor,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          'Manage your saved delivery locations',
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
                      onPressed: () => _showAddressBottomSheet(context, isDark, cardColor, primaryTextColor, secondaryTextColor),
                    ),
                  ),
                ],
              ),
            ),

            // --- Address List ---
            Expanded(
              child: _addresses.isEmpty
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
                              Icons.location_off_rounded,
                              size: 48,
                              color: isDark ? AppColors.cream : AppColors.bobaBrown,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No saved addresses',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: primaryTextColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Add a delivery location for faster checkouts.',
                            style: TextStyle(fontSize: 13, color: secondaryTextColor),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      itemCount: _addresses.length,
                      itemBuilder: (context, index) {
                        final addressItem = _addresses[index];
                        final isDefault = addressItem['isDefault'] == true;

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
                                        Icons.location_on_rounded,
                                        size: 18,
                                        color: isDark ? AppColors.cream : AppColors.bobaBrown,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        addressItem['label'],
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
                              Text(
                                addressItem['address'],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: primaryTextColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Contact: ${addressItem['contact']}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: secondaryTextColor,
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
                                          for (var element in _addresses) {
                                            element['isDefault'] = false;
                                          }
                                          addressItem['isDefault'] = true;
                                        });
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Default address updated!'),
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
                                    icon: Icon(Icons.edit_outlined, size: 18, color: secondaryTextColor),
                                    onPressed: () {
                                      // Edit flow logic
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                                    onPressed: () {
                                      setState(() {
                                        _addresses.removeAt(index);
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

  void _showAddressBottomSheet(
    BuildContext context,
    bool isDark,
    Color cardColor,
    Color primaryTextColor,
    Color secondaryTextColor,
  ) {
    final labelController = TextEditingController();
    final addressController = TextEditingController();
    final contactController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
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
                'Add New Address',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryTextColor,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: labelController,
                style: TextStyle(color: primaryTextColor),
                decoration: InputDecoration(
                  labelText: 'Address Label (e.g. Home, Office)',
                  labelStyle: TextStyle(color: secondaryTextColor),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: secondaryTextColor.withValues(alpha: 0.3))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? AppColors.cream : AppColors.bobaBrown)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addressController,
                style: TextStyle(color: primaryTextColor),
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Complete Address',
                  labelStyle: TextStyle(color: secondaryTextColor),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: secondaryTextColor.withValues(alpha: 0.3))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? AppColors.cream : AppColors.bobaBrown)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contactController,
                style: TextStyle(color: primaryTextColor),
                decoration: InputDecoration(
                  labelText: 'Contact Number',
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
                    if (labelController.text.isNotEmpty && addressController.text.isNotEmpty) {
                      setState(() {
                        _addresses.add({
                          'id': DateTime.now().millisecondsSinceEpoch.toString(),
                          'label': labelController.text,
                          'address': addressController.text,
                          'contact': contactController.text.isEmpty ? '+63 900 000 0000' : contactController.text,
                          'isDefault': _addresses.isEmpty,
                        });
                      });
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? AppColors.cream : AppColors.bobaBrown,
                    foregroundColor: isDark ? AppColors.darkText : AppColors.cardWhite,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Save Address'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}