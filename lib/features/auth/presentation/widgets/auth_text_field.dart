import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../app/theme.dart';

/// Auth Email Field with validation and styling
class AuthEmailField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final bool autofocus;
  final bool enabled;
  final String? hintText;
  final String? labelText;

  const AuthEmailField({
    super.key,
    required this.controller,
    this.focusNode,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.autofocus = false,
    this.enabled = true,
    this.hintText,
    this.labelText,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null) ...[
          Text(
            labelText!,
            style: SpendexTheme.labelMedium.copyWith(
              color: isDark
                  ? SpendexColors.darkTextSecondary
                  : SpendexColors.lightTextSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofocus: autofocus,
          enabled: enabled,
          autocorrect: false,
          enableSuggestions: false,
          style: SpendexTheme.bodyMedium.copyWith(
            color: isDark
                ? SpendexColors.darkTextPrimary
                : SpendexColors.lightTextPrimary,
          ),
          decoration: InputDecoration(
            hintText: hintText ?? 'Enter your email',
            hintStyle: SpendexTheme.bodyMedium.copyWith(
              color: isDark
                  ? SpendexColors.darkTextTertiary
                  : SpendexColors.lightTextTertiary,
            ),
            prefixIcon: Icon(
              Iconsax.sms,
              color: isDark
                  ? SpendexColors.darkTextTertiary
                  : SpendexColors.lightTextTertiary,
              size: 20,
            ),
            filled: true,
            fillColor: isDark
                ? SpendexColors.darkSurface
                : SpendexColors.lightSurface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
              borderSide: BorderSide(
                color: isDark
                    ? SpendexColors.darkBorder
                    : SpendexColors.lightBorder,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
              borderSide: BorderSide(
                color: isDark
                    ? SpendexColors.darkBorder
                    : SpendexColors.lightBorder,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
              borderSide: const BorderSide(
                color: SpendexColors.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
              borderSide: const BorderSide(
                color: SpendexColors.expense,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
              borderSide: const BorderSide(
                color: SpendexColors.expense,
                width: 2,
              ),
            ),
            errorStyle: SpendexTheme.labelMedium.copyWith(
              color: SpendexColors.expense,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          validator: validator,
          onChanged: onChanged,
          onFieldSubmitted: onFieldSubmitted,
        ),
      ],
    );
  }
}

/// Auth Password Field with visibility toggle and styling
class AuthPasswordField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final bool autofocus;
  final bool enabled;
  final String? hintText;
  final String? labelText;
  final TextInputAction textInputAction;
  final bool enableInteractiveSelection;

  const AuthPasswordField({
    super.key,
    required this.controller,
    this.focusNode,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.autofocus = false,
    this.enabled = true,
    this.hintText,
    this.labelText,
    this.textInputAction = TextInputAction.done,
    this.enableInteractiveSelection = true,
  });

  @override
  State<AuthPasswordField> createState() => _AuthPasswordFieldState();
}

class _AuthPasswordFieldState extends State<AuthPasswordField> {
  bool _obscureText = true;

  void _toggleVisibility() {
    HapticFeedback.selectionClick();
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText != null) ...[
          Text(
            widget.labelText!,
            style: SpendexTheme.labelMedium.copyWith(
              color: isDark
                  ? SpendexColors.darkTextSecondary
                  : SpendexColors.lightTextSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          obscureText: _obscureText,
          keyboardType: TextInputType.visiblePassword,
          textInputAction: widget.textInputAction,
          autofocus: widget.autofocus,
          enabled: widget.enabled,
          autocorrect: false,
          enableSuggestions: false,
          enableInteractiveSelection: widget.enableInteractiveSelection,
          style: SpendexTheme.bodyMedium.copyWith(
            color: isDark
                ? SpendexColors.darkTextPrimary
                : SpendexColors.lightTextPrimary,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText ?? 'Enter your password',
            hintStyle: SpendexTheme.bodyMedium.copyWith(
              color: isDark
                  ? SpendexColors.darkTextTertiary
                  : SpendexColors.lightTextTertiary,
            ),
            prefixIcon: Icon(
              Iconsax.lock,
              color: isDark
                  ? SpendexColors.darkTextTertiary
                  : SpendexColors.lightTextTertiary,
              size: 20,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureText ? Iconsax.eye_slash : Iconsax.eye,
                color: isDark
                    ? SpendexColors.darkTextTertiary
                    : SpendexColors.lightTextTertiary,
                size: 20,
              ),
              onPressed: _toggleVisibility,
              splashRadius: 20,
            ),
            filled: true,
            fillColor: isDark
                ? SpendexColors.darkSurface
                : SpendexColors.lightSurface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
              borderSide: BorderSide(
                color: isDark
                    ? SpendexColors.darkBorder
                    : SpendexColors.lightBorder,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
              borderSide: BorderSide(
                color: isDark
                    ? SpendexColors.darkBorder
                    : SpendexColors.lightBorder,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
              borderSide: const BorderSide(
                color: SpendexColors.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
              borderSide: const BorderSide(
                color: SpendexColors.expense,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
              borderSide: const BorderSide(
                color: SpendexColors.expense,
                width: 2,
              ),
            ),
            errorStyle: SpendexTheme.labelMedium.copyWith(
              color: SpendexColors.expense,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          validator: widget.validator,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onFieldSubmitted,
        ),
      ],
    );
  }
}

/// Styled Text Form Field for auth screens
class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final bool autofocus;
  final bool enabled;
  final String? hintText;
  final String? labelText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final int maxLines;
  final bool obscureText;

  const AuthTextField({
    super.key,
    required this.controller,
    this.focusNode,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.autofocus = false,
    this.enabled = true,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.inputFormatters,
    this.maxLength,
    this.maxLines = 1,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null) ...[
          Text(
            labelText!,
            style: SpendexTheme.labelMedium.copyWith(
              color: isDark
                  ? SpendexColors.darkTextSecondary
                  : SpendexColors.lightTextSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          autofocus: autofocus,
          enabled: enabled,
          obscureText: obscureText,
          maxLength: maxLength,
          maxLines: maxLines,
          inputFormatters: inputFormatters,
          style: SpendexTheme.bodyMedium.copyWith(
            color: isDark
                ? SpendexColors.darkTextPrimary
                : SpendexColors.lightTextPrimary,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: SpendexTheme.bodyMedium.copyWith(
              color: isDark
                  ? SpendexColors.darkTextTertiary
                  : SpendexColors.lightTextTertiary,
            ),
            prefixIcon: prefixIcon != null
                ? Icon(
                    prefixIcon,
                    color: isDark
                        ? SpendexColors.darkTextTertiary
                        : SpendexColors.lightTextTertiary,
                    size: 20,
                  )
                : null,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: isDark
                ? SpendexColors.darkSurface
                : SpendexColors.lightSurface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
              borderSide: BorderSide(
                color: isDark
                    ? SpendexColors.darkBorder
                    : SpendexColors.lightBorder,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
              borderSide: BorderSide(
                color: isDark
                    ? SpendexColors.darkBorder
                    : SpendexColors.lightBorder,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
              borderSide: const BorderSide(
                color: SpendexColors.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
              borderSide: const BorderSide(
                color: SpendexColors.expense,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
              borderSide: const BorderSide(
                color: SpendexColors.expense,
                width: 2,
              ),
            ),
            errorStyle: SpendexTheme.labelMedium.copyWith(
              color: SpendexColors.expense,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            counterText: '',
          ),
          validator: validator,
          onChanged: onChanged,
          onFieldSubmitted: onFieldSubmitted,
        ),
      ],
    );
  }
}
