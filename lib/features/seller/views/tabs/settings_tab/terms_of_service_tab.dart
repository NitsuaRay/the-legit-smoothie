import 'package:flutter/material.dart';
import 'package:the_legit_smoothie/core/constants/app_colors.dart';

class TermsOfServiceTab extends StatelessWidget {
  const TermsOfServiceTab({super.key});

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
          'Terms of Service',
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
            // --- Header Summary Card ---
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
                      Icons.gavel_rounded,
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
                          'Merchant Partner Agreement',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: primaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Version 2.4 • Effective Aug 2026',
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

            // --- Section 1: Merchant Account & Onboarding ---
            _buildTermSection(
              title: '1. Account Registration & Store Profile',
              content:
                  '• Merchants must provide accurate sanitary permits, business registration, and valid payout details.\n'
                  '• You are responsible for maintaining the confidentiality of your seller credentials and restricting unauthorized access to your account POS dashboard.',
              isDark: isDark,
              secondaryTextColor: secondaryTextColor,
            ),

            const SizedBox(height: 16),

            // --- Section 2: Order Fulfillment & Preparation ---
            _buildTermSection(
              title: '2. Order Fulfillment Standards',
              content:
                  '• Merchants agree to prepare beverage orders within the standardized target window (typically 5–10 minutes).\n'
                  '• All drinks must strictly match the quality, ingredients, and cup sizes listed on your digital store menu.\n'
                  '• Repeated order rejections or delays may temporarily impact store ranking or visibility.',
              isDark: isDark,
              secondaryTextColor: secondaryTextColor,
            ),

            const SizedBox(height: 16),

            // --- Section 3: Pricing, Fees & Payouts ---
            _buildTermSection(
              title: '3. Pricing, Platform Fees & Disbursements',
              content:
                  '• Menu prices set on the app must remain consistent with your physical store menu unless participating in authorized platform campaigns.\n'
                  '• The Legit Smoothie deducts a standard platform commission fee on successfully completed transactions as agreed upon during onboarding.\n'
                  '• Earnings are disbursed twice weekly to your verified GCash or bank account after deducting applicable service fees.',
              isDark: isDark,
              secondaryTextColor: secondaryTextColor,
            ),

            const SizedBox(height: 16),

            // --- Section 4: Store Promotions & Discounts ---
            _buildTermSection(
              title: '4. Store-Sponsored Campaigns',
              content:
                  '• Discount vouchers created via the Seller App are funded directly by the merchant.\n'
                  '• Platform-wide co-funded campaigns will be clearly designated in campaign terms prior to merchant enrollment.',
              isDark: isDark,
              secondaryTextColor: secondaryTextColor,
            ),

            const SizedBox(height: 16),

            // --- Section 5: Termination & Suspension ---
            _buildTermSection(
              title: '5. Account Suspension & Termination',
              content:
                  '• The platform reserves the right to suspend or terminate merchant access for serious breaches, including food safety violations, fraudulent transactions, or offensive behavior toward delivery riders and customers.',
              isDark: isDark,
              secondaryTextColor: secondaryTextColor,
            ),

            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildTermSection({
    required String title,
    required String content,
    required bool isDark,
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