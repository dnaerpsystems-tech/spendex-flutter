import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme.dart';

/// Primary Auth Button with gradient and loading state
///
/// A professional gradient elevated button with:
/// - Loading state with spinner
/// - Disabled state
/// - Haptic feedback
/// - Gradient background
/// - Customizable text and icon
class AuthPrimaryButton extends StatelessWidget {

  const AuthPrimaryButton({
    required this.text,
    super.key,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.icon,
    this.width,
    this.height = 52,
    this.borderRadius,
  });
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final IconData? icon;
  final double? width;
  final double height;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final isDisabled = !isEnabled || isLoading;

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: isDisabled
              ? LinearGradient(
                  colors: [
                    SpendexColors.primary.withValues(alpha:0.5),
                    SpendexColors.primaryDark.withValues(alpha:0.5),
                  ],
                )
              : SpendexColors.primaryGradient,
          borderRadius: borderRadius ?? BorderRadius.circular(SpendexTheme.radiusMd),
          boxShadow: isDisabled
              ? null
              : [
                  BoxShadow(
                    color: SpendexColors.primary.withValues(alpha:0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: ElevatedButton(
          onPressed: isDisabled
              ? null
              : () {
                  HapticFeedback.mediumImpact();
                  onPressed?.call();
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            disabledForegroundColor: Colors.white.withValues(alpha:0.7),
            shadowColor: Colors.transparent,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius:
                  borderRadius ?? BorderRadius.circular(SpendexTheme.radiusMd),
            ),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, size: 20),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        text,
                        style: SpendexTheme.titleMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// Outlined Auth Button with icon support
///
/// A professional outlined button with:
/// - Loading state
/// - Disabled state
/// - Icon support
/// - Haptic feedback
class AuthOutlinedButton extends StatelessWidget {

  const AuthOutlinedButton({
    required this.text,
    super.key,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.icon,
    this.color,
    this.width,
    this.height = 52,
  });
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final IconData? icon;
  final Color? color;
  final double? width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDisabled = !isEnabled || isLoading;

    final buttonColor = color ?? SpendexColors.primary;
    final borderColor = isDisabled
        ? (isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder)
        : buttonColor;
    final textColor = isDisabled
        ? (isDark ? SpendexColors.darkTextTertiary : SpendexColors.lightTextTertiary)
        : buttonColor;

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: OutlinedButton(
        onPressed: isDisabled
            ? null
            : () {
                HapticFeedback.lightImpact();
                onPressed?.call();
              },
        style: OutlinedButton.styleFrom(
          foregroundColor: textColor,
          side: BorderSide(
            color: borderColor,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
          ),
          backgroundColor: Colors.transparent,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: isLoading
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(buttonColor),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 20),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      text,
                      style: SpendexTheme.titleMedium.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

/// Text Button for links and secondary actions
///
/// A professional text button with:
/// - Haptic feedback
/// - Customizable color
/// - Underline option
class AuthTextButton extends StatelessWidget {

  const AuthTextButton({
    required this.text,
    super.key,
    this.onPressed,
    this.isEnabled = true,
    this.color,
    this.underline = false,
    this.fontWeight = FontWeight.w600,
    this.fontSize,
  });
  final String text;
  final VoidCallback? onPressed;
  final bool isEnabled;
  final Color? color;
  final bool underline;
  final FontWeight fontWeight;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final buttonColor = color ?? SpendexColors.primary;
    final textColor = isEnabled
        ? buttonColor
        : (isDark ? SpendexColors.darkTextTertiary : SpendexColors.lightTextTertiary);

    return TextButton(
      onPressed: isEnabled
          ? () {
              HapticFeedback.selectionClick();
              onPressed?.call();
            }
          : null,
      style: TextButton.styleFrom(
        foregroundColor: textColor,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontWeight: fontWeight,
          fontSize: fontSize ?? 14,
          decoration: underline ? TextDecoration.underline : null,
          decorationColor: textColor,
        ),
      ),
    );
  }
}

/// Social Login Button (Google, Apple, etc.)
class AuthSocialButton extends StatelessWidget {

  const AuthSocialButton({
    required this.text,
    super.key,
    this.iconAsset,
    this.icon,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.backgroundColor,
    this.foregroundColor,
    this.height = 52,
  });
  final String text;
  final String? iconAsset;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double height;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDisabled = !isEnabled || isLoading;

    final bgColor = backgroundColor ??
        (isDark ? SpendexColors.darkSurface : SpendexColors.lightSurface);
    final fgColor = foregroundColor ??
        (isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary);
    final borderColor =
        isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder;

    return SizedBox(
      width: double.infinity,
      height: height,
      child: OutlinedButton(
        onPressed: isDisabled
            ? null
            : () {
                HapticFeedback.lightImpact();
                onPressed?.call();
              },
        style: OutlinedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          side: BorderSide(color: borderColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: isLoading
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(fgColor),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 22),
                      const SizedBox(width: 12),
                    ] else if (iconAsset != null) ...[
                      Image.asset(
                        iconAsset!,
                        width: 22,
                        height: 22,
                      ),
                      const SizedBox(width: 12),
                    ],
                    Text(
                      text,
                      style: SpendexTheme.titleMedium.copyWith(
                        color: fgColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

/// Icon Button for auth screens
class AuthIconButton extends StatelessWidget {

  const AuthIconButton({
    required this.icon,
    super.key,
    this.onPressed,
    this.isEnabled = true,
    this.color,
    this.size = 24,
  });
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isEnabled;
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = color ??
        (isEnabled
            ? (isDark
                ? SpendexColors.darkTextPrimary
                : SpendexColors.lightTextPrimary)
            : (isDark
                ? SpendexColors.darkTextTertiary
                : SpendexColors.lightTextTertiary));

    return IconButton(
      onPressed: isEnabled
          ? () {
              HapticFeedback.selectionClick();
              onPressed?.call();
            }
          : null,
      icon: Icon(
        icon,
        color: iconColor,
        size: size,
      ),
      splashRadius: 24,
    );
  }
}
