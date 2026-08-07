import 'package:flutter/material.dart';
import 'package:the_legit_smoothie/core/constants/app_colors.dart';

class ReportIssueTab extends StatefulWidget {
  const ReportIssueTab({super.key});

  @override
  State<ReportIssueTab> createState() => _ReportIssueTabState();
}

class _ReportIssueTabState extends State<ReportIssueTab> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _stepsController = TextEditingController();

  String _issueType = 'App Glitch / Bug';
  String _severityLevel = 'Medium';
  bool _includeLogs = true;
  bool _isSubmitting = false;
  final List<String> _attachedScreenshots = [];

  final List<String> _issueTypes = [
    'App Glitch / Bug',
    'POS & Printing Error',
    'Payout / Wallet Discrepancy',
    'Order Sync Issue',
    'Customer / Rider Misconduct',
    'Other Technical Issue',
  ];

  final List<Map<String, dynamic>> _severityLevels = [
    {'label': 'Low', 'color': Colors.blue, 'desc': 'Minor visual bug'},
    {'label': 'Medium', 'color': Colors.orange, 'desc': 'Feature partially affected'},
    {'label': 'Critical', 'color': Colors.red, 'desc': 'Cannot process orders / Cash loss'},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _stepsController.dispose();
    super.dispose();
  }

  void _addMockScreenshot() {
    if (_attachedScreenshots.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum 3 screenshots allowed.'),
        ),
      );
      return;
    }

    setState(() {
      _attachedScreenshots.add('screenshot_${_attachedScreenshots.length + 1}.png');
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Image attached successfully!'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    // Simulate network submission
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    // Show confirmation dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final reportId = 'REP-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}';

        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkText : AppColors.cardWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.bug_report_rounded,
                  color: Colors.green,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Report Filed',
                style: TextStyle(
                  color: isDark ? AppColors.cream : AppColors.darkText,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Issue ID: $reportId',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: isDark ? AppColors.cream : AppColors.bobaBrown,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Thank you for bringing this to our attention. Our engineering team will review the system diagnostics and get back to you shortly.',
                style: TextStyle(
                  color: isDark
                      ? AppColors.cream.withValues(alpha: 0.8)
                      : AppColors.greyText,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Return to settings tab
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isDark ? AppColors.cream : AppColors.bobaBrown,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Done',
                style: TextStyle(
                  color: isDark ? AppColors.bobaBrown : AppColors.cardWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
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
          'Report an Issue',
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
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Banner Note ---
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.cream.withValues(alpha: 0.08)
                      : AppColors.bobaBrown.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark
                        ? AppColors.cream.withValues(alpha: 0.2)
                        : AppColors.bobaBrown.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: isDark ? AppColors.cream : AppColors.bobaBrown,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Encountered a bug or error? Provide details below so our tech team can investigate quickly.',
                        style: TextStyle(
                          fontSize: 12,
                          color: primaryTextColor,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // --- Issue Classification ---
              _buildSectionTitle('1. Issue Type', primaryTextColor),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _issueType,
                dropdownColor: cardColor,
                style: TextStyle(color: primaryTextColor, fontSize: 14),
                decoration: _inputDecoration(
                  isDark: isDark,
                  hintText: 'Select Issue Category',
                  prefixIcon: Icons.error_outline_rounded,
                ),
                items: _issueTypes
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _issueType = val;
                    });
                  }
                },
              ),

              const SizedBox(height: 20),

              // --- Severity Selector ---
              _buildSectionTitle('2. Severity Level', primaryTextColor),
              const SizedBox(height: 10),
              Row(
                children: _severityLevels.map((sev) {
                  final bool isSelected = _severityLevel == sev['label'];
                  final Color sevColor = sev['color'] as Color;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _severityLevel = sev['label'];
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? sevColor.withValues(alpha: 0.15)
                              : cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? sevColor
                                : (isDark
                                    ? AppColors.bobaBrown.withValues(alpha: 0.4)
                                    : AppColors.greyBorder),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              sev['label'],
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? sevColor : primaryTextColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              sev['desc'],
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              style: TextStyle(
                                fontSize: 9,
                                color: secondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // --- Issue Title & Description ---
              _buildSectionTitle('3. Describe What Happened', primaryTextColor),
              const SizedBox(height: 10),
              TextFormField(
                controller: _titleController,
                style: TextStyle(color: primaryTextColor, fontSize: 14),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Title is required' : null,
                decoration: _inputDecoration(
                  isDark: isDark,
                  hintText: 'Short summary (e.g., Cart button not responding)',
                  prefixIcon: Icons.title_rounded,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                style: TextStyle(color: primaryTextColor, fontSize: 14),
                validator: (val) => val == null || val.trim().isEmpty
                    ? 'Please describe the bug'
                    : null,
                decoration: _inputDecoration(
                  isDark: isDark,
                  hintText: 'Explain what went wrong in detail...',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _stepsController,
                maxLines: 2,
                style: TextStyle(color: primaryTextColor, fontSize: 14),
                decoration: _inputDecoration(
                  isDark: isDark,
                  hintText: 'Steps to reproduce (e.g., 1. Open order, 2. Tap print)',
                ),
              ),

              const SizedBox(height: 24),

              // --- Screenshot Attachments ---
              _buildSectionTitle('4. Screenshots / Proof', primaryTextColor),
              const SizedBox(height: 10),
              Row(
                children: [
                  ..._attachedScreenshots.map((img) => Container(
                        margin: const EdgeInsets.only(right: 10),
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.cream.withValues(alpha: 0.1)
                              : AppColors.bobaBrown.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? AppColors.cream
                                : AppColors.bobaBrown,
                          ),
                        ),
                        child: Stack(
                          children: [
                            const Center(
                              child: Icon(
                                Icons.image_rounded,
                                color: Colors.grey,
                                size: 28,
                              ),
                            ),
                            Positioned(
                              top: 2,
                              right: 2,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _attachedScreenshots.remove(img);
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                  if (_attachedScreenshots.length < 3)
                    InkWell(
                      onTap: _addMockScreenshot,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? AppColors.bobaBrown.withValues(alpha: 0.4)
                                : AppColors.greyBorder,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo_rounded,
                              size: 20,
                              color: secondaryTextColor,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Add',
                              style: TextStyle(
                                fontSize: 10,
                                color: secondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 20),

              // --- Include Diagnostic Logs Switch ---
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark
                        ? AppColors.bobaBrown.withValues(alpha: 0.4)
                        : AppColors.greyBorder,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.settings_system_daydream_rounded,
                      size: 22,
                      color: isDark ? AppColors.cream : AppColors.bobaBrown,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Attach Device & App Logs',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: primaryTextColor,
                            ),
                          ),
                          Text(
                            'Helps engineers debug app crash traces',
                            style: TextStyle(
                              fontSize: 11,
                              color: secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _includeLogs,
                      activeColor: isDark
                          ? AppColors.bobaBrown
                          : AppColors.cardWhite,
                      activeTrackColor:
                          isDark ? AppColors.cream : AppColors.bobaBrown,
                      onChanged: (val) {
                        setState(() {
                          _includeLogs = val;
                        });
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // --- Submit Button ---
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isDark ? AppColors.cream : AppColors.bobaBrown,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: isDark
                                ? AppColors.bobaBrown
                                : AppColors.cardWhite,
                          ),
                        )
                      : Text(
                          'Submit Issue Report',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.bobaBrown
                                : AppColors.cardWhite,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: color,
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
          : AppColors.cardWhite,
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