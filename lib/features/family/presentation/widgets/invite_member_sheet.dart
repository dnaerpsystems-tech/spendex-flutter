import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../app/theme.dart';
import '../../../../core/constants/app_constants.dart';
import 'member_role_selector.dart';
import 'role_badge.dart';

/// Bottom sheet for inviting a new family member
class InviteMemberSheet extends ConsumerStatefulWidget {
  const InviteMemberSheet({
    required this.onInvite,
    super.key,
  });

  final Future<void> Function(String email, UserRole role) onInvite;

  /// Show the invite member bottom sheet
  static Future<void> show({
    required BuildContext context,
    required Future<void> Function(String email, UserRole role) onInvite,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => InviteMemberSheet(onInvite: onInvite),
    );
  }

  @override
  ConsumerState<InviteMemberSheet> createState() => _InviteMemberSheetState();
}

class _InviteMemberSheetState extends ConsumerState<InviteMemberSheet> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _emailFocusNode = FocusNode();
  UserRole _selectedRole = UserRole.member;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Auto focus email field after sheet opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _emailFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  /// Validate email format
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an email address';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Handle invite submission
  Future<void> _handleInvite() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await widget.onInvite(_emailController.text.trim(), _selectedRole);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Show role selector
  Future<void> _showRoleSelector() async {
    final role = await MemberRoleSelector.show(
      context: context,
      currentRole: _selectedRole,
    );
    if (role != null && mounted) {
      setState(() {
        _selectedRole = role;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? SpendexColors.darkSurface : SpendexColors.lightSurface;
    final textPrimary = isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary;
    final textSecondary =
        isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary;
    final borderColor = isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder;

    // Adjust for keyboard
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(SpendexTheme.radiusXl),
        ),
      ),
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(SpendexTheme.spacingLg),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: borderColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: SpendexTheme.spacingLg),

                  // Header
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: SpendexColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
                        ),
                        child: const Icon(
                          Iconsax.user_add,
                          size: 22,
                          color: SpendexColors.primary,
                        ),
                      ),
                      const SizedBox(width: SpendexTheme.spacingMd),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Invite Member',
                              style: SpendexTheme.headlineSmall.copyWith(
                                color: textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Send an invitation to join your family',
                              style: SpendexTheme.bodySmall.copyWith(
                                color: textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: SpendexTheme.spacing2xl),

                  // Email field
                  Text(
                    'Email Address',
                    style: SpendexTheme.labelMedium.copyWith(
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: SpendexTheme.spacingSm),
                  TextFormField(
                    controller: _emailController,
                    focusNode: _emailFocusNode,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: _validateEmail,
                    style: SpendexTheme.bodyMedium.copyWith(
                      color: textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter email address',
                      hintStyle: SpendexTheme.bodyMedium.copyWith(
                        color: textSecondary,
                      ),
                      prefixIcon: const Icon(Iconsax.sms, size: 20),
                      prefixIconColor: textSecondary,
                    ),
                  ),
                  const SizedBox(height: SpendexTheme.spacingLg),

                  // Role selector
                  Text(
                    'Role',
                    style: SpendexTheme.labelMedium.copyWith(
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: SpendexTheme.spacingSm),
                  InkWell(
                    onTap: _isLoading ? null : _showRoleSelector,
                    borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
                    child: Container(
                      padding: const EdgeInsets.all(SpendexTheme.spacingMd),
                      decoration: BoxDecoration(
                        border: Border.all(color: borderColor),
                        borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            MemberRoleSelector.getRoleIcon(_selectedRole),
                            size: 20,
                            color: textSecondary,
                          ),
                          const SizedBox(width: SpendexTheme.spacingMd),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RoleBadge(
                                  role: _selectedRole,
                                  size: RoleBadgeSize.small,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  MemberRoleSelector.getRoleDescription(
                                    _selectedRole,
                                  ),
                                  style: SpendexTheme.bodySmall.copyWith(
                                    color: textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Iconsax.arrow_down_1,
                            size: 18,
                            color: textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Error message
                  if (_errorMessage != null) ...[
                    const SizedBox(height: SpendexTheme.spacingMd),
                    Container(
                      padding: const EdgeInsets.all(SpendexTheme.spacingMd),
                      decoration: BoxDecoration(
                        color: SpendexColors.expense.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(SpendexTheme.radiusSm),
                        border: Border.all(
                          color: SpendexColors.expense.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Iconsax.warning_2,
                            size: 18,
                            color: SpendexColors.expense,
                          ),
                          const SizedBox(width: SpendexTheme.spacingSm),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: SpendexTheme.bodySmall.copyWith(
                                color: SpendexColors.expense,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: SpendexTheme.spacing2xl),

                  // Send invite button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleInvite,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Iconsax.send_1, size: 18),
                              const SizedBox(width: SpendexTheme.spacingSm),
                              Text(
                                'Send Invite',
                                style: SpendexTheme.titleMedium.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(height: SpendexTheme.spacingSm),

                  // Info text
                  Center(
                    child: Text(
                      'Invite expires in 7 days',
                      style: SpendexTheme.labelSmall.copyWith(
                        color: textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
