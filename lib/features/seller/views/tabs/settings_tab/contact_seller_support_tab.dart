import 'package:flutter/material.dart';
import 'package:the_legit_smoothie/core/constants/app_colors.dart';

class ContactSellerSupportTab extends StatefulWidget {
  const ContactSellerSupportTab({super.key});

  @override
  State<ContactSellerSupportTab> createState() =>
      _ContactSellerSupportTabState();
}

class _ContactSellerSupportTabState extends State<ContactSellerSupportTab> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _orderIdController = TextEditingController();

  String _selectedCategory = 'Order & Delivery Issue';
  bool _isSubmitting = false;
  String? _attachedFileName;

  final List<String> _supportCategories = [
    'Order & Delivery Issue',
    'Payout & Wallet Discrepancy',
    'Menu & Inventory Assistance',
    'Promotions & Discounts',
    'Technical / App Bug',
    'Other Inquiries',
  ];

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    _orderIdController.dispose();
    super.dispose();
  }

  void _submitSupportTicket() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    // Simulate network request
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    // Show success dialog
    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkText : AppColors.cardWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.green,
                size: 28,
              ),
              const SizedBox(width: 10),
              Text(
                'Ticket Submitted',
                style: TextStyle(
                  color: isDark ? AppColors.cream : AppColors.darkText,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            'Your support ticket (#TKT-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}) has been received. Our merchant support team will respond within 24 hours.',
            style: TextStyle(
              color: isDark
                  ? AppColors.cream.withValues(alpha: 0.8)
                  : AppColors.greyText,
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Return to previous screen
              },
              child: Text(
                'Done',
                style: TextStyle(
                  color: isDark ? AppColors.cream : AppColors.bobaBrown,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _mockAttachFile() {
    setState(() {
      _attachedFileName = 'screenshot_issue_0912.png';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('File attached successfully!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

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
          'Contact Seller Support',
          style: TextStyle(
            color: primaryTextColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Quick Direct Channels ---
            Text(
              'Direct Channels',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: primaryTextColor,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildQuickContactCard(
                    icon: Icons.chat_bubble_outline_rounded,
                    title: 'Live Chat',
                    subtitle: '24/7 Priority',
                    color: Colors.blueAccent,
                    isDark: isDark,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Opening Live Chat session...'),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickContactCard(
                    icon: Icons.phone_in_talk_rounded,
                    title: 'Call Support',
                    subtitle: 'Mon-Sat 8am-8pm',
                    color: Colors.green,
                    isDark: isDark,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Dialing Merchant Hotline...'),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // --- Submit Ticket Header ---
            Text(
              'Submit a Support Ticket',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: primaryTextColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Fill out the form below and our merchant specialists will assist you.',
              style: TextStyle(
                fontSize: 13,
                color: secondaryTextColor,
              ),
            ),
            const SizedBox(height: 16),

            // --- Support Ticket Form ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark
                      ? AppColors.bobaBrown.withValues(alpha: 0.4)
                      : AppColors.greyBorder,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: isDark ? 0.2 : 0.04,
                    ),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Selection
                    _buildLabel('Issue Category', primaryTextColor),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      dropdownColor: cardColor,
                      style: TextStyle(
                        color: primaryTextColor,
                        fontSize: 14,
                      ),
                      decoration: _inputDecoration(
                        isDark: isDark,
                        hintText: 'Select category',
                        prefixIcon: Icons.category_outlined,
                      ),
                      items: _supportCategories
                          .map((category) => DropdownMenuItem(
                                value: category,
                                child: Text(category),
                              ))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedCategory = val;
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 16),

                    // Order ID (Optional)
                    _buildLabel('Related Order ID (Optional)', primaryTextColor),
                    TextFormField(
                      controller: _orderIdController,
                      style: TextStyle(color: primaryTextColor, fontSize: 14),
                      decoration: _inputDecoration(
                        isDark: isDark,
                        hintText: 'e.g., #ORD-98231',
                        prefixIcon: Icons.receipt_long_rounded,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Subject
                    _buildLabel('Subject', primaryTextColor),
                    TextFormField(
                      controller: _subjectController,
                      style: TextStyle(color: primaryTextColor, fontSize: 14),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a subject';
                        }
                        return null;
                      },
                      decoration: _inputDecoration(
                        isDark: isDark,
                        hintText: 'Brief summary of the issue',
                        prefixIcon: Icons.title_rounded,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Message / Details
                    _buildLabel('Detailed Description', primaryTextColor),
                    TextFormField(
                      controller: _messageController,
                      maxLines: 4,
                      style: TextStyle(color: primaryTextColor, fontSize: 14),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please describe your issue in detail';
                        }
                        if (value.trim().length < 10) {
                          return 'Description must be at least 10 characters';
                        }
                        return null;
                      },
                      decoration: _inputDecoration(
                        isDark: isDark,
                        hintText:
                            'Explain what happened and how we can help...',
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Attachment Section
                    InkWell(
                      onTap: _mockAttachFile,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.cream.withValues(alpha: 0.05)
                              : AppColors.bobaBrown.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? AppColors.bobaBrown.withValues(alpha: 0.3)
                                : AppColors.greyBorder,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.attach_file_rounded,
                              size: 20,
                              color: isDark
                                  ? AppColors.cream
                                  : AppColors.bobaBrown,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _attachedFileName ??
                                    'Attach Screenshot / Receipt (Optional)',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: _attachedFileName != null
                                      ? (isDark
                                          ? AppColors.cream
                                          : AppColors.bobaBrown)
                                      : secondaryTextColor,
                                  fontWeight: _attachedFileName != null
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (_attachedFileName != null)
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _attachedFileName = null;
                                  });
                                },
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 18,
                                  color: secondaryTextColor,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitSupportTicket,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isDark ? AppColors.cream : AppColors.bobaBrown,
                          foregroundColor:
                              isDark ? AppColors.darkText : Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _isSubmitting
                            ? SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: isDark
                                      ? AppColors.darkText
                                      : Colors.white,
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.send_rounded, size: 18),
                                  SizedBox(width: 8),
                                  Text(
                                    'Submit Ticket',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildQuickContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final cardBackground = isDark ? AppColors.darkText : AppColors.cardWhite;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cardBackground,
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 22,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.cream : AppColors.darkText,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark
                      ? AppColors.cream.withValues(alpha: 0.6)
                      : AppColors.greyText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required bool isDark,
    required String hintText,
    IconData? prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: isDark
            ? AppColors.cream.withValues(alpha: 0.4)
            : AppColors.greyText.withValues(alpha: 0.6),
        fontSize: 13,
      ),
      prefixIcon: prefixIcon != null
          ? Icon(
              prefixIcon,
              color: isDark ? AppColors.cream : AppColors.greyText,
              size: 20,
            )
          : null,
      filled: true,
      fillColor: isDark
          ? AppColors.cream.withValues(alpha: 0.05)
          : AppColors.background,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark
              ? AppColors.bobaBrown.withValues(alpha: 0.3)
              : AppColors.greyBorder,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark
              ? AppColors.bobaBrown.withValues(alpha: 0.3)
              : AppColors.greyBorder,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? AppColors.cream : AppColors.bobaBrown,
        ),
      ),
    );
  }
}