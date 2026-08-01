import 'package:flutter/material.dart';
import 'package:the_legit_smoothie/core/constants/app_colors.dart';

class HelpCenterTab extends StatelessWidget {
  const HelpCenterTab({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardColor = isDark ? AppColors.darkText : AppColors.cardWhite;
    final primaryTextColor = isDark ? AppColors.cream : AppColors.darkText;
    final secondaryTextColor = isDark
        ? AppColors.cream.withValues(alpha: 0.7)
        : AppColors.greyText;

    final List<Map<String, String>> faqs = [
      {
        'question': 'How can I track my smoothie order?',
        'answer': 'You can track your active orders in real-time by navigating to the Orders tab on the bottom navigation bar and selecting your current order to view live progress updates.'
      },
      {
        'question': 'What payment methods do you accept?',
        'answer': 'We currently accept GCash, Maya, major credit/debit cards (Visa, Mastercard), and Cash on Delivery (COD) for maximum flexibility and convenience.'
      },
      {
        'question': 'Can I modify or cancel my order after placement?',
        'answer': 'Orders can only be modified or cancelled within 2 minutes of submission before our blenders begin preparation. If urgent changes are needed, please contact our support team immediately via Live Chat.'
      },
      {
        'question': 'How do I update or add a delivery address?',
        'answer': 'You can effortlessly manage, save, or update your delivery locations anytime by navigating to Settings > Delivery Addresses within your account profile.'
      },
      {
        'question': 'What should I do if my order arrives damaged or incorrect?',
        'answer': 'We strive for perfection with every blend! If there is an issue with your order, please reach out to us via Live Chat or email within 24 hours with a photo of the item, and our team will resolve it promptly.'
      },
      {
        'question': 'How do loyalty rewards or discounts work?',
        'answer': 'Keep an eye on our promotions tab and app notifications for seasonal discounts, voucher codes, and special referral rewards applied directly during checkout.'
      },
    ];

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
                          'Help Center & Support',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: primaryTextColor,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          'Professional assistance & detailed FAQs',
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
                  // --- Quick Support Banner ---
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
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.cream.withValues(alpha: 0.15)
                                : AppColors.bobaBrown.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.support_agent_rounded,
                            size: 28,
                            color: isDark ? AppColors.cream : AppColors.bobaBrown,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Dedicated Customer Support',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: primaryTextColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Our support specialists are available daily from 9:00 AM to 10:00 PM PHT to assist you.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: secondaryTextColor,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- Contact Actions Grid/List ---
                  Row(
                    children: [
                      Expanded(
                        child: _buildSupportActionCard(
                          context,
                          icon: Icons.chat_bubble_outline_rounded,
                          title: 'Live Chat',
                          subtitle: 'Instant agent support',
                          cardColor: cardColor,
                          primaryTextColor: primaryTextColor,
                          secondaryTextColor: secondaryTextColor,
                          isDark: isDark,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Connecting to live support agent...')),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildSupportActionCard(
                          context,
                          icon: Icons.email_outlined,
                          title: 'Email Us',
                          subtitle: 'support@thelegitsmoothie.ph',
                          cardColor: cardColor,
                          primaryTextColor: primaryTextColor,
                          secondaryTextColor: secondaryTextColor,
                          isDark: isDark,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Opening secure email client...')),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // --- FAQs Section Title ---
                  Text(
                    'Frequently Asked Questions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- FAQ Accordions ---
                  ...faqs.map((faq) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
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
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ExpansionTile(
                          iconColor: isDark ? AppColors.cream : AppColors.bobaBrown,
                          collapsedIconColor: secondaryTextColor,
                          title: Text(
                            faq['question']!,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: primaryTextColor,
                            ),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: Text(
                                faq['answer']!,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: secondaryTextColor,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color cardColor,
    required Color primaryTextColor,
    required Color secondaryTextColor,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 24,
              color: isDark ? AppColors.cream : AppColors.bobaBrown,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: primaryTextColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: secondaryTextColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}