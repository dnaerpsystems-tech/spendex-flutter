import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme.dart';

/// Social authentication provider types
enum SocialAuthProvider {
  google,
  apple,
  facebook,
}

/// Small circular icon buttons for social authentication.
///
/// Displays Google, Apple, and Facebook sign-in buttons with:
/// - Circular icon-only design
/// - Brand-specific colors
/// - Loading states per button
/// - Platform-aware Apple button (iOS/macOS only)
class SocialAuthIconButtons extends StatelessWidget {
  const SocialAuthIconButtons({
    required this.onGooglePressed,
    required this.onApplePressed,
    required this.onFacebookPressed,
    super.key,
    this.isGoogleLoading = false,
    this.isAppleLoading = false,
    this.isFacebookLoading = false,
    this.showApple = true,
    this.spacing = 16,
    this.buttonSize = 52,
  });

  /// Callback when Google button is pressed
  final VoidCallback? onGooglePressed;

  /// Callback when Apple button is pressed
  final VoidCallback? onApplePressed;

  /// Callback when Facebook button is pressed
  final VoidCallback? onFacebookPressed;

  /// Whether Google sign-in is loading
  final bool isGoogleLoading;

  /// Whether Apple sign-in is loading
  final bool isAppleLoading;

  /// Whether Facebook sign-in is loading
  final bool isFacebookLoading;

  /// Whether to show the Apple button (should be false on non-Apple platforms)
  final bool showApple;

  /// Spacing between buttons
  final double spacing;

  /// Size of each button
  final double buttonSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Google Button
        _SocialIconButton(
          provider: SocialAuthProvider.google,
          onPressed: onGooglePressed,
          isLoading: isGoogleLoading,
          size: buttonSize,
        ),
        SizedBox(width: spacing),
        // Apple Button (only on iOS/macOS)
        if (showApple) ...[
          _SocialIconButton(
            provider: SocialAuthProvider.apple,
            onPressed: onApplePressed,
            isLoading: isAppleLoading,
            size: buttonSize,
          ),
          SizedBox(width: spacing),
        ],
        // Facebook Button
        _SocialIconButton(
          provider: SocialAuthProvider.facebook,
          onPressed: onFacebookPressed,
          isLoading: isFacebookLoading,
          size: buttonSize,
        ),
      ],
    );
  }
}

/// Individual social icon button with brand styling
class _SocialIconButton extends StatelessWidget {
  const _SocialIconButton({
    required this.provider,
    required this.onPressed,
    required this.isLoading,
    required this.size,
  });

  final SocialAuthProvider provider;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double size;

  // Brand colors
  static const Color _googleRed = Color(0xFFEA4335);
  static const Color _appleBlack = Color(0xFF000000);
  static const Color _facebookBlue = Color(0xFF1877F2);

  Color get _brandColor {
    switch (provider) {
      case SocialAuthProvider.google:
        return _googleRed;
      case SocialAuthProvider.apple:
        return _appleBlack;
      case SocialAuthProvider.facebook:
        return _facebookBlue;
    }
  }

  IconData get _icon {
    switch (provider) {
      case SocialAuthProvider.google:
        return Icons.g_mobiledata_rounded;
      case SocialAuthProvider.apple:
        return Icons.apple;
      case SocialAuthProvider.facebook:
        return Icons.facebook;
    }
  }

  String get _semanticLabel {
    switch (provider) {
      case SocialAuthProvider.google:
        return 'Sign in with Google';
      case SocialAuthProvider.apple:
        return 'Sign in with Apple';
      case SocialAuthProvider.facebook:
        return 'Sign in with Facebook';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDisabled = onPressed == null || isLoading;

    // Background and border colors
    final backgroundColor =
        isDark ? SpendexColors.darkSurface : SpendexColors.lightSurface;
    final borderColor =
        isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder;

    return Semantics(
      label: _semanticLabel,
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled
              ? null
              : () {
                  HapticFeedback.lightImpact();
                  onPressed?.call();
                },
          borderRadius: BorderRadius.circular(size / 2),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: isDisabled ? borderColor : _brandColor.withValues(alpha: 0.3),
                width: 1.5,
              ),
              boxShadow: isDisabled
                  ? null
                  : [
                      BoxShadow(
                        color: _brandColor.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: isLoading
                    ? SizedBox(
                        width: size * 0.4,
                        height: size * 0.4,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(_brandColor),
                        ),
                      )
                    : Icon(
                        _icon,
                        color: isDisabled
                            ? (isDark
                                ? SpendexColors.darkTextTertiary
                                : SpendexColors.lightTextTertiary)
                            : _brandColor,
                        size: size * 0.5,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A row of social auth buttons with "Or continue with" divider
class SocialAuthSection extends StatelessWidget {
  const SocialAuthSection({
    required this.onGooglePressed,
    required this.onApplePressed,
    required this.onFacebookPressed,
    super.key,
    this.isGoogleLoading = false,
    this.isAppleLoading = false,
    this.isFacebookLoading = false,
    this.showApple = true,
    this.dividerText = 'Or continue with',
  });

  final VoidCallback? onGooglePressed;
  final VoidCallback? onApplePressed;
  final VoidCallback? onFacebookPressed;
  final bool isGoogleLoading;
  final bool isAppleLoading;
  final bool isFacebookLoading;
  final bool showApple;
  final String dividerText;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Divider with text
        Row(
          children: [
            Expanded(
              child: Divider(
                color: isDark
                    ? SpendexColors.darkBorder
                    : SpendexColors.lightBorder,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                dividerText,
                style: SpendexTheme.bodySmall.copyWith(
                  color: isDark
                      ? SpendexColors.darkTextTertiary
                      : SpendexColors.lightTextTertiary,
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: isDark
                    ? SpendexColors.darkBorder
                    : SpendexColors.lightBorder,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Social buttons
        SocialAuthIconButtons(
          onGooglePressed: onGooglePressed,
          onApplePressed: onApplePressed,
          onFacebookPressed: onFacebookPressed,
          isGoogleLoading: isGoogleLoading,
          isAppleLoading: isAppleLoading,
          isFacebookLoading: isFacebookLoading,
          showApple: showApple,
        ),
      ],
    );
  }
}
