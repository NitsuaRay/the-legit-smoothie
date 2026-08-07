import 'package:flutter/material.dart';
import 'package:the_legit_smoothie/core/constants/app_colors.dart';

class PrivacyPolicyTab extends StatelessWidget {
  const PrivacyPolicyTab({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryTextColor = isDark ? AppColors.cream : AppColors.darkText;
    final secondaryTextColor = isDark
        ? AppColors.cream.withValues(alpha: 0.7)
        : AppColors.greyText;
    final cardColor = isDark ? AppColors.darkText : AppColors.cardWhite;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkText : AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: primaryTextColor,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Privacy Policy',
          style: TextStyle(
            color: primaryTextColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Effective Date Header Card ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? AppColors.bobaBrown.withValues(alpha: 0.4)
                      : AppColors.greyBorder,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.cream.withValues(alpha: 0.15)
                          : AppColors.bobaBrown.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.shield_outlined,
                      color: isDark ? AppColors.cream : AppColors.bobaBrown,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Merchant Data Protection',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: primaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Last updated: August 2026',
                          style: TextStyle(
                            fontSize: 12,
                            color: secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // --- Section 1: Overview ---
            _buildPolicySection(
              title: '1. Information We Collect',
              content:
                  'As a merchant using The Legit Smoothie Platform, we collect operational data necessary to process orders and manage payouts:\n\n'
                  '• Merchant Account Information: Store name, contact number, registered email, and business location.\n'
                  '• Financial & Payout Details: Linked GCash account numbers, bank account details, and transaction logs.\n'
                  '• Order & Inventory Analytics: Sales reports, menu item availability, and stock movement logs.',
              isDark: isDark,
              primaryTextColor: primaryTextColor,
              secondaryTextColor: secondaryTextColor,
            ),

            const SizedBox(height: 16),

            // --- Section 2: How Data is Used ---
            _buildPolicySection(
              title: '2. How We Use Your Data',
              content:
                  'Your data is utilized strictly for merchant platform operations:\n\n'
                  '• Processing customer smoothie orders and coordinating delivery riders.\n'
                  '• Calculating sales revenue, platform fees, and automated weekly payouts.\n'
                  '• Improving store visibility and recommending promotional campaign strategies.',
              isDark: isDark,
              primaryTextColor: primaryTextColor,
              secondaryTextColor: secondaryTextColor,
            ),

            const SizedBox(height: 16),

            // --- Section 3: Customer Data Handling ---
            _buildPolicySection(
              title: '3. Handling Customer Personal Data',
              content:
                  'Merchants are provided limited access to customer information (such as delivery address and order items) solely for order fulfillment.\n\n'
                  'Merchants are strictly prohibited from storing, exporting, or contacting customers directly outside platform-approved communication channels.',
              isDark: isDark,
              primaryTextColor: primaryTextColor,
              secondaryTextColor: secondaryTextColor,
            ),

            const SizedBox(height: 16),

            // --- Section 4: Security & Retention ---
            _buildPolicySection(
              title: '4. Security & Data Retention',
              content:
                  'We implement industry-standard encryption protocols to protect financial records and store data. Operational records are retained for as long as your merchant account remains active or as required by financial regulations.',
              isDark: isDark,
              primaryTextColor: primaryTextColor,
              secondaryTextColor: secondaryTextColor,
            ),

            const SizedBox(height: 16),

            // --- Section 5: Data Rights & Contact ---
            _buildPolicySection(
              title: '5. Your Privacy Rights',
              content:
                  'You have the right to request access to, correction of, or deletion of your personal merchant profile data. For privacy-related inquiries or data request submissions, please contact our Data Protection Officer at privacy@thelegitsmoothie.com.',
              isDark: isDark,
              primaryTextColor: primaryTextColor,
              secondaryTextColor: secondaryTextColor,
            ),

            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildPolicySection({
    required String title,
    required String content,
    required bool isDark,
    required Color primaryTextColor,
    required Color secondaryTextColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkText : AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppColors.bobaBrown.withValues(alpha: 0.4)
              : AppColors.greyBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.cream : AppColors.bobaBrown,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: TextStyle(
              fontSize: 13,
              color: secondaryTextColor,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}