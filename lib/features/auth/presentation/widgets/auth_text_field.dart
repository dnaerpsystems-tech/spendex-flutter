import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../app/theme.dart';

/// Reusable Auth Text Field Widget
///
/// A professional text field with:
/// - Label above field
/// - Prefix and suffix icons
/// - Password visibility toggle
/// - Error display
/// - Focus node management
/// - Animations on focus
/// - Dark mode support
class AuthTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final bool isPassword;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final FocusNode? focusNode;
  final bool enabled;
  final int maxLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final bool autofocus;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hintText = '',
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.focusNode,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
    this.autofocus = false,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField>
    with SingleTickerProviderStateMixin {
  late FocusNode _focusNode;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _borderColorAnimation;
  bool _obscurePassword = true;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    if (widget.isPassword) {
      _obscurePassword = widget.obscureText;
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    _animationController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });

    if (_focusNode.hasFocus) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    final borderColor = _isFocused
        ? SpendexColors.primary
        : (isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder);

    final backgroundColor =
        isDark ? SpendexColors.darkSurface : SpendexColors.lightSurface;

    final labelColor =
        isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary;

    final hintColor =
        isDark ? SpendexColors.darkTextTertiary : SpendexColors.lightTextTertiary;

    final iconColor =
        isDark ? SpendexColors.darkTextTertiary : SpendexColors.lightTextTertiary;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Label
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: SpendexTheme.labelMedium.copyWith(
                  color: _isFocused ? SpendexColors.primary : labelColor,
                  fontWeight: _isFocused ? FontWeight.w600 : FontWeight.w500,
                ),
                child: Text(widget.label),
              ),
              const SizedBox(height: 8),

              // Text Field
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
                  boxShadow: _isFocused
                      ? [
                          BoxShadow(
                            color: SpendexColors.primary.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: TextFormField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  obscureText: widget.isPassword ? _obscurePassword : widget.obscureText,
                  keyboardType: widget.keyboardType,
                  textInputAction: widget.textInputAction,
                  validator: widget.validator,
                  onChanged: widget.onChanged,
                  onFieldSubmitted: widget.onFieldSubmitted,
                  enabled: widget.enabled,
                  maxLines: widget.maxLines,
                  maxLength: widget.maxLength,
                  inputFormatters: widget.inputFormatters,
                  autofocus: widget.autofocus,
                  style: SpendexTheme.bodyMedium.copyWith(
                    color: isDark
                        ? SpendexColors.darkTextPrimary
                        : SpendexColors.lightTextPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    hintStyle: SpendexTheme.bodyMedium.copyWith(color: hintColor),
                    filled: true,
                    fillColor: backgroundColor,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    prefixIcon: widget.prefixIcon != null
                        ? Icon(
                            widget.prefixIcon,
                            color: _isFocused ? SpendexColors.primary : iconColor,
                            size: 20,
                          )
                        : null,
                    suffixIcon: widget.isPassword
                        ? IconButton(
                            icon: Icon(
                              _obscurePassword ? Iconsax.eye_slash : Iconsax.eye,
                              color: iconColor,
                              size: 20,
                            ),
                            onPressed: _togglePasswordVisibility,
                            splashRadius: 20,
                          )
                        : widget.suffixIcon,
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(SpendexTheme.radiusMd),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(SpendexTheme.radiusMd),
                      borderSide: BorderSide(
                        color: isDark
                            ? SpendexColors.darkBorder
                            : SpendexColors.lightBorder,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(SpendexTheme.radiusMd),
                      borderSide: const BorderSide(
                        color: SpendexColors.primary,
                        width: 2,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(SpendexTheme.radiusMd),
                      borderSide: const BorderSide(
                        color: SpendexColors.expense,
                        width: 1,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(SpendexTheme.radiusMd),
                      borderSide: const BorderSide(
                        color: SpendexColors.expense,
                        width: 2,
                      ),
                    ),
                    errorStyle: SpendexTheme.labelMedium.copyWith(
                      color: SpendexColors.expense,
                    ),
                    counterText: '',
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Email Text Field - Pre-configured for email input
class AuthEmailField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final FocusNode? focusNode;
  final bool autofocus;

  const AuthEmailField({
    super.key,
    required this.controller,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.focusNode,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return AuthTextField(
      controller: controller,
      label: 'Email',
      hintText: 'Enter your email address',
      prefixIcon: Iconsax.sms,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      focusNode: focusNode,
      autofocus: autofocus,
    );
  }
}

/// Password Text Field - Pre-configured for password input
class AuthPasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final FocusNode? focusNode;
  final TextInputAction textInputAction;

  const AuthPasswordField({
    super.key,
    required this.controller,
    this.label = 'Password',
    this.hintText = 'Enter your password',
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.focusNode,
    this.textInputAction = TextInputAction.done,
  });

  @override
  Widget build(BuildContext context) {
    return AuthTextField(
      controller: controller,
      label: label,
      hintText: hintText,
      prefixIcon: Iconsax.lock,
      isPassword: true,
      obscureText: true,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: textInputAction,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      focusNode: focusNode,
    );
  }
}
