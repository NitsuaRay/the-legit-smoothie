import 'package:flutter/material.dart';
import 'package:the_legit_smoothie/core/constants/app_colors.dart';

class PrivacyPolicyTab extends StatelessWidget {
  const PrivacyPolicyTab({super.key});

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
                          'Privacy Policy',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: primaryTextColor,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          'Effective Date: August 1, 2026',
                          style: TextStyle(
                            fontSize: 13,
                            color: secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // --- Scrollable Content ---
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('1. Introduction & Overview', primaryTextColor),
                        const SizedBox(height: 8),
                        _buildSectionBody(
                          'The Legit Smoothie ("we," "our," or "us") is deeply committed to safeguarding your privacy and ensuring the security of your personal information. This Privacy Policy outlines our data collection, utilization, disclosure, and protection practices when you utilize our mobile application, website, and related ordering services. By accessing or using our platform, you signify your understanding and acceptance of the practices detailed within this policy.',
                          secondaryTextColor,
                        ),
                        const SizedBox(height: 20),

                        _buildSectionTitle('2. Information We Collect', primaryTextColor),
                        const SizedBox(height: 8),
                        _buildSectionBody(
                          'To provide a seamless ordering and delivery experience, we gather various categories of information categorized as follows:\n\n'
                          '• **Personal Identification Data:** Full name, registered username, email address, and verified mobile/contact numbers.\n'
                          '• **Location & Delivery Data:** Primary delivery addresses, precise geographic coordinates for dispatching orders, and delivery access instructions.\n'
                          '• **Financial & Transactional Data:** Records of purchases, preferred payment gateway details (such as GCash, Maya, or masked credit/debit card indicators), and billing histories. Note: We do not store full raw credit card numbers or sensitive gateway passwords on our local servers.\n'
                          '• **Technical & Usage Data:** Internet protocol (IP) addresses, device identifiers, operating system specs, app version data, and interaction analytics within our application interface.',
                          secondaryTextColor,
                        ),
                        const SizedBox(height: 20),

                        _buildSectionTitle('3. Purpose and Legal Basis for Processing', primaryTextColor),
                        const SizedBox(height: 8),
                        _buildSectionBody(
                          'We process your personal information strictly under authorized legal grounds, which include:\n\n'
                          '• **Contractual Fulfillment:** Executing and managing your smoothie orders, processing secure online payments, and organizing real-time deliveries.\n'
                          '• **Legitimate Business Interests:** Improving user interface workflows, analyzing menu performance trends, and preventing fraudulent or unauthorized system access.\n'
                          '• **Legal Compliance:** Adhering to relevant consumer protection, taxation laws, and regulatory requirements mandated within the Republic of the Philippines.',
                          secondaryTextColor,
                        ),
                        const SizedBox(height: 20),

                        _buildSectionTitle('4. Information Sharing and Disclosure', primaryTextColor),
                        const SizedBox(height: 8),
                        _buildSectionBody(
                          'We treat your personal data with utmost confidentiality. We do not sell, trade, or rent your personal information to third parties. Data is shared exclusively with:\n\n'
                          '• **Delivery Personnel:** Authorized riders and fulfillment partners strictly to locate your address and complete the transfer of your orders.\n'
                          '• **Payment Processors:** Secure third-party financial institutions and digital wallet gateways required to clear and authenticate transactions.\n'
                          '• **Legal Authorities:** When compelled by law, court orders, or government regulatory bodies to protect legal rights or ensure user safety.',
                          secondaryTextColor,
                        ),
                        const SizedBox(height: 20),

                        _buildSectionTitle('5. Data Security Measures', primaryTextColor),
                        const SizedBox(height: 8),
                        _buildSectionBody(
                          'We employ industry-standard administrative, technical, and physical security controls—including encrypted transmission protocols (HTTPS/SSL) and restricted internal database access—to protect your information from accidental loss, disclosure, alteration, or unauthorized destruction.',
                          secondaryTextColor,
                        ),
                        const SizedBox(height: 20),

                        _buildSectionTitle('6. Your Data Protection Rights', primaryTextColor),
                        const SizedBox(height: 8),
                        _buildSectionBody(
                          'Depending on your jurisdiction, you maintain full rights regarding your personal information, including the right to access, rectify inaccuracies, request deletion of your account history, or withdraw consent for marketing communications at any time via your account settings or by contacting support.',
                          secondaryTextColor,
                        ),
                        const SizedBox(height: 20),

                        _buildSectionTitle('7. Updates to This Policy', primaryTextColor),
                        const SizedBox(height: 8),
                        _buildSectionBody(
                          'We may periodically update this Privacy Policy to reflect modifications in our operational workflows or legal frameworks. Any significant changes will be communicated via in-app notices or updated publication dates on this page.',
                          secondaryTextColor,
                        ),
                        const SizedBox(height: 20),

                        _buildSectionTitle('8. Contact Information', primaryTextColor),
                        const SizedBox(height: 8),
                        _buildSectionBody(
                          'For any inquiries, data privacy concerns, or formal requests regarding this policy, please reach out to our Data Protection Officer at privacy@thelegitsmoothie.ph or through our in-app Help Center & Support portal.',
                          secondaryTextColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: color,
      ),
    );
  }

  Widget _buildSectionBody(String body, Color color) {
    return Text(
      body,
      style: TextStyle(
        fontSize: 13,
        color: color,
        height: 1.5,
      ),
    );
  }
}