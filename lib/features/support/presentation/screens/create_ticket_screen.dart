// ignore_for_file: use_build_context_synchronously

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import '../../../../app/theme.dart';
import '../../data/datasources/support_local_datasource.dart';
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
/// - Email injection vulnerability protection
/// - Rate limiting for ticket submission
/// - Form dirty state for back confirmation
class CreateTicketScreen extends ConsumerStatefulWidget {
  const CreateTicketScreen({
    super.key,
    this.initialCategory,
  });

  /// Optional initial category when navigating from quick actions
  final TicketCategory? initialCategory;

  @override
  ConsumerState<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends ConsumerState<CreateTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();

  late TicketCategory _selectedCategory;
  TicketPriority _selectedPriority = TicketPriority.medium;

  String _deviceInfo = 'Loading device info...';
  bool _isSubmitting = false;
  bool _isFormDirty = false;

  // Rate limiting
  static DateTime? _lastSubmissionTime;
  static const Duration _minSubmissionInterval = Duration(minutes: 1);

  // Device info caching
  static DeviceInfoPlugin? _deviceInfoPlugin;
  static String? _cachedDeviceInfo;

  bool get _canSubmit {
    if (_lastSubmissionTime == null) {
      return true;
    }
    return DateTime.now().difference(_lastSubmissionTime!) > _minSubmissionInterval;
  }

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory ?? TicketCategory.bugReport;
    _loadDeviceInfo();

    // Add listeners for form dirty state
    _subjectController.addListener(_onFormChanged);
    _descriptionController.addListener(_onFormChanged);
  }

  @override
  void dispose() {
    _subjectController.removeListener(_onFormChanged);
    _descriptionController.removeListener(_onFormChanged);
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onFormChanged() {
    final isDirty = _subjectController.text.isNotEmpty ||
        _descriptionController.text.isNotEmpty;
    if (isDirty != _isFormDirty) {
      setState(() => _isFormDirty = isDirty);
    }
  }

  /// Sanitize input to prevent email header injection
  String _sanitizeForEmail(String input) {
    // Remove newlines, carriage returns, and other control characters
    return input
        .replaceAll(RegExp(r'[\r\n\t]'), ' ')
        .replaceAll(RegExp(r'[^\x20-\x7E\u00A0-\uFFFF]'), '')
        .trim();
  }

  /// Sanitize for email body (preserve some formatting)
  String _sanitizeForEmailBody(String input) {
    // Only remove dangerous characters, keep newlines for formatting
    return input
        .replaceAll(RegExp(r'[\r]'), '')
        .replaceAll(RegExp(r'[^\x20-\x7E\u00A0-\uFFFF\n]'), '')
        .trim();
  }

  Future<void> _loadDeviceInfo() async {
    // Use cached device info if available
    if (_cachedDeviceInfo != null) {
      setState(() => _deviceInfo = _cachedDeviceInfo!);
      return;
    }

    _deviceInfoPlugin ??= DeviceInfoPlugin();

    try {
      String info;
      if (defaultTargetPlatform == TargetPlatform.android) {
        final androidInfo = await _deviceInfoPlugin!.androidInfo;
        info = '${androidInfo.brand} ${androidInfo.model} (Android ${androidInfo.version.release})';
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final iosInfo = await _deviceInfoPlugin!.iosInfo;
        info = '${iosInfo.name} (iOS ${iosInfo.systemVersion})';
      } else if (kIsWeb) {
        final webInfo = await _deviceInfoPlugin!.webBrowserInfo;
        info = '${webInfo.browserName.name} on ${webInfo.platform ?? "Unknown"}';
      } else {
        info = 'Platform: ${defaultTargetPlatform.toString().split(".").last}';
      }

      _cachedDeviceInfo = info;
      if (mounted) {
        setState(() => _deviceInfo = info);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _deviceInfo = 'Unable to detect device');
      }
    }
  }

  Future<bool> _showDiscardDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Discard Changes?'),
            content: const Text(
              'You have unsaved changes. Are you sure you want to leave?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Keep Editing'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(
                  foregroundColor: SpendexColors.expense,
                ),
                child: const Text('Discard'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _submitTicket() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    // Check rate limiting
    if (_canSubmit == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please wait before submitting another ticket'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Sanitize inputs
      final sanitizedSubject = _sanitizeForEmail(_subjectController.text);
      final sanitizedDescription = _sanitizeForEmailBody(_descriptionController.text);

      // Create ticket locally
      final ticket = Ticket(
        id: const Uuid().v4(),
        subject: sanitizedSubject,
        description: sanitizedDescription,
        category: _selectedCategory,
        priority: _selectedPriority,
        status: TicketStatus.open,
        createdAt: DateTime.now(),
        deviceInfo: _deviceInfo,
        appVersion: '1.0.0',
      );

      // Save ticket locally
      await SupportLocalDataSource.instance.saveTicket(ticket);

      // Build email
      final subject = Uri.encodeComponent(
        '[Spendex Support] ${_selectedCategory.label}: $sanitizedSubject',
      );
      final body = Uri.encodeComponent('''
Subject: $sanitizedSubject

Category: ${_selectedCategory.label}
Priority: ${_selectedPriority.label}

Description:
$sanitizedDescription

---
Device Information: $_deviceInfo
App Version: 1.0.0
Ticket ID: ${ticket.id}
Submitted via: Spendex App
''');

      final emailUri = Uri.parse(
        'mailto:support@spendex.in?subject=$subject&body=$body',
      );

      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri, mode: LaunchMode.externalApplication);
        _lastSubmissionTime = DateTime.now();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ticket created and saved locally'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: SpendexColors.income,
            ),
          );
          // Clear form dirty state before popping
          setState(() => _isFormDirty = false);
          context.pop();
        }
      } else {
        // Still save the ticket locally even if email fails
        _lastSubmissionTime = DateTime.now();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Could not open email client, but ticket saved locally',
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: SpendexColors.transfer,
              action: SnackBarAction(
                label: 'View Tickets',
                textColor: Colors.white,
                onPressed: () {
                  context.pop();
                },
              ),
            ),
          );
          setState(() => _isFormDirty = false);
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: SpendexColors.expense,
          ),
        );
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
    final backgroundColor =
        isDark ? SpendexColors.darkBackground : SpendexColors.lightBackground;
    final cardColor =
        isDark ? SpendexColors.darkCard : SpendexColors.lightCard;
    final textColor =
        isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary;
    final secondaryTextColor = isDark
        ? SpendexColors.darkTextSecondary
        : SpendexColors.lightTextSecondary;
    final borderColor =
        isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder;

    return PopScope(
      canPop: _isFormDirty == false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop == false && _isFormDirty) {
          final shouldPop = await _showDiscardDialog();
          if (shouldPop && mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
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
                  maxLength: 100,
                  decoration: InputDecoration(
                    hintText: 'Brief summary of your issue',
                    hintStyle: TextStyle(color: secondaryTextColor),
                    counterText: '',
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
                      borderSide:
                          const BorderSide(color: SpendexColors.primary, width: 2),
                    ),
                    prefixIcon: Icon(Iconsax.edit_2, color: secondaryTextColor),
                  ),
                  style: TextStyle(color: textColor),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a subject';
                    }
                    if (value.trim().length < 5) {
                      return 'Subject should be at least 5 characters';
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
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  child: DropdownButtonFormField<TicketCategory>(
                    initialValue: _selectedCategory,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12,),
                      prefixIcon: Icon(Iconsax.category, color: secondaryTextColor),
                    ),
                    dropdownColor: cardColor,
                    style: TextStyle(color: textColor),
                    items: TicketCategory.values.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Row(
                          children: [
                            Text(category.emoji, style: const TextStyle(fontSize: 16)),
                            const SizedBox(width: 8),
                            Text(category.label),
                          ],
                        ),
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
                            color: isSelected
                                ? priority.color.withValues(alpha: 0.2)
                                : cardColor,
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
                                color: isSelected
                                    ? priority.color
                                    : secondaryTextColor,
                                size: 20,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                priority.label,
                                style: SpendexTheme.bodySmall.copyWith(
                                  color: isSelected
                                      ? priority.color
                                      : secondaryTextColor,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
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
                  maxLength: 2000,
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
                      borderSide:
                          const BorderSide(color: SpendexColors.primary, width: 2),
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
                          const Icon(
                            Iconsax.mobile,
                            color: SpendexColors.primary,
                            size: 20,
                          ),
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
                      disabledBackgroundColor:
                          SpendexColors.primary.withValues(alpha: 0.5),
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
                const SizedBox(height: 16),

                // Info text
                Center(
                  child: Text(
                    'Ticket will be sent via email and saved locally',
                    style: SpendexTheme.bodySmall.copyWith(
                      color: secondaryTextColor,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
