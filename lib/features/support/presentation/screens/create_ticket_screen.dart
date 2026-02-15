import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme.dart';
import '../../data/models/ticket_model.dart';

/// Create Ticket Screen
///
/// Form screen for creating new support tickets with:
/// - Subject TextField
/// - Category dropdown
/// - Priority selector
/// - Description TextArea
/// - Auto-filled device info
/// - Submit button that opens email with pre-filled content
class CreateTicketScreen extends ConsumerStatefulWidget {
  const CreateTicketScreen({super.key});

  @override
  ConsumerState<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends ConsumerState<CreateTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  TicketCategory _selectedCategory = TicketCategory.bugReport;
  TicketPriority _selectedPriority = TicketPriority.medium;
  String _deviceInfo = 'Loading device info...';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadDeviceInfo();
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadDeviceInfo() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      String info;

      if (defaultTargetPlatform == TargetPlatform.android) {
        final androidInfo = await deviceInfo.androidInfo;
        info = 'Device: ${androidInfo.brand} ${androidInfo.model}\n'
            'Android Version: ${androidInfo.version.release}\n'
            'SDK: ${androidInfo.version.sdkInt}';
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final iosInfo = await deviceInfo.iosInfo;
        info = 'Device: ${iosInfo.name}\n'
            'Model: ${iosInfo.model}\n'
            'iOS Version: ${iosInfo.systemVersion}';
      } else {
        info = 'Platform: ${defaultTargetPlatform.toString()}';
      }

      if (mounted) {
        setState(() {
          _deviceInfo = info;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _deviceInfo = 'Could not retrieve device info';
        });
      }
    }
  }

  Future<void> _submitTicket() async {
    if (_formKey.currentState?.validate() != true) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final subject = '[Spendex] ${_selectedCategory.label}: ${_subjectController.text}';
      final body = '''
Subject: ${_subjectController.text}

Category: ${_selectedCategory.label}
Priority: ${_selectedPriority.label}

Description:
${_descriptionController.text}

---
Device Information:
$_deviceInfo

App Version: 1.0.0
Submitted via: Spendex App
''';

      final Uri emailUri = Uri(
        scheme: 'mailto',
        path: 'support@spendex.in',
        query: Uri.encodeFull('subject=$subject&body=$body'),
      );

      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ticket submitted successfully'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: SpendexColors.income,
            ),
          );
          context.pop();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open email client'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: SpendexColors.expense,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? SpendexColors.darkBackground : SpendexColors.lightBackground;
    final cardColor = isDark ? SpendexColors.darkCard : SpendexColors.lightCard;
    final textColor = isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary;
    final secondaryTextColor = isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary;
    final borderColor = isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Create Ticket'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Subject Field
              Text(
                'Subject',
                style: SpendexTheme.labelMedium.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _subjectController,
                decoration: InputDecoration(
                  hintText: 'Brief summary of your issue',
                  hintStyle: TextStyle(color: secondaryTextColor),
                  filled: true,
                  fillColor: cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: SpendexColors.primary, width: 2),
                  ),
                  prefixIcon: Icon(Iconsax.edit_2, color: secondaryTextColor),
                ),
                style: TextStyle(color: textColor),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a subject';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Category Dropdown
              Text(
                'Category',
                style: SpendexTheme.labelMedium.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                child: DropdownButtonFormField<TicketCategory>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    prefixIcon: Icon(Iconsax.category, color: secondaryTextColor),
                  ),
                  dropdownColor: cardColor,
                  style: TextStyle(color: textColor),
                  items: TicketCategory.values.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category.label),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    }
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Priority Selector
              Text(
                'Priority',
                style: SpendexTheme.labelMedium.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: TicketPriority.values.map((priority) {
                  final isSelected = _selectedPriority == priority;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedPriority = priority;
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.only(
                          right: priority != TicketPriority.urgent ? 8 : 0,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? priority.color.withValues(alpha: 0.2) : cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? priority.color : borderColor,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              priority.icon,
                              color: isSelected ? priority.color : secondaryTextColor,
                              size: 20,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              priority.label,
                              style: SpendexTheme.bodySmall.copyWith(
                                color: isSelected ? priority.color : secondaryTextColor,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
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

              // Description Field
              Text(
                'Description',
                style: SpendexTheme.labelMedium.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: 'Please describe your issue in detail...',
                  hintStyle: TextStyle(color: secondaryTextColor),
                  filled: true,
                  fillColor: cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: SpendexColors.primary, width: 2),
                  ),
                ),
                style: TextStyle(color: textColor),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a description';
                  }
                  if (value.trim().length < 20) {
                    return 'Description should be at least 20 characters';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Device Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Iconsax.mobile, color: SpendexColors.primary, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Device Information',
                          style: SpendexTheme.labelMedium.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _deviceInfo,
                      style: SpendexTheme.bodySmall.copyWith(
                        color: secondaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'This information will be included with your ticket.',
                      style: SpendexTheme.bodySmall.copyWith(
                        color: secondaryTextColor,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitTicket,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SpendexColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: SpendexColors.primary.withValues(alpha: 0.5),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Iconsax.send_1),
                            const SizedBox(width: 8),
                            Text(
                              'Submit Ticket',
                              style: SpendexTheme.titleMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
