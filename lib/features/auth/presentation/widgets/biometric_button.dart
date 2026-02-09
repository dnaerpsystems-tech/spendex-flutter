import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../app/theme.dart';

/// Biometric Button Widget
///
/// A professional biometric button with:
/// - Fingerprint or face icon based on platform
/// - Animated pulse effect
/// - Loading state
/// - Disabled state when biometric not available
class BiometricButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final bool isAvailable;
  final String? label;
  final double size;
  final bool showPulse;
  final BiometricType biometricType;

  const BiometricButton({
    super.key,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.isAvailable = true,
    this.label,
    this.size = 64,
    this.showPulse = true,
    this.biometricType = BiometricType.fingerprint,
  });

  @override
  State<BiometricButton> createState() => _BiometricButtonState();
}

enum BiometricType {
  fingerprint,
  faceId,
  iris,
}

class _BiometricButtonState extends State<BiometricButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.showPulse && widget.isEnabled && widget.isAvailable) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(BiometricButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showPulse && widget.isEnabled && widget.isAvailable) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  IconData _getBiometricIcon() {
    switch (widget.biometricType) {
      case BiometricType.fingerprint:
        return Iconsax.finger_scan;
      case BiometricType.faceId:
        return Iconsax.scan;
      case BiometricType.iris:
        return Iconsax.eye;
    }
  }

  String _getDefaultLabel() {
    if (Platform.isIOS) {
      return 'Use Face ID';
    }
    return 'Use Fingerprint';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDisabled = !widget.isEnabled || !widget.isAvailable || widget.isLoading;

    final backgroundColor = isDisabled
        ? (isDark
            ? SpendexColors.darkSurface.withOpacity(0.5)
            : SpendexColors.lightSurface.withOpacity(0.5))
        : (isDark ? SpendexColors.darkSurface : SpendexColors.lightSurface);

    final borderColor = isDisabled
        ? (isDark
            ? SpendexColors.darkBorder.withOpacity(0.5)
            : SpendexColors.lightBorder.withOpacity(0.5))
        : SpendexColors.primary.withOpacity(0.3);

    final iconColor = isDisabled
        ? (isDark ? SpendexColors.darkTextTertiary : SpendexColors.lightTextTertiary)
        : SpendexColors.primary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Biometric Icon Button
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Transform.scale(
              scale: widget.showPulse && widget.isEnabled && widget.isAvailable
                  ? _pulseAnimation.value
                  : 1.0,
              child: child,
            );
          },
          child: GestureDetector(
            onTap: isDisabled
                ? null
                : () {
                    HapticFeedback.mediumImpact();
                    widget.onPressed?.call();
                  },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: backgroundColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: borderColor,
                  width: 2,
                ),
                boxShadow: isDisabled
                    ? null
                    : [
                        BoxShadow(
                          color: SpendexColors.primary.withOpacity(0.2),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: widget.isLoading
                    ? SizedBox(
                        width: widget.size * 0.4,
                        height: widget.size * 0.4,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(iconColor),
                        ),
                      )
                    : Icon(
                        _getBiometricIcon(),
                        color: iconColor,
                        size: widget.size * 0.45,
                      ),
              ),
            ),
          ),
        ),

        // Label
        if (widget.label != null || widget.isAvailable) ...[
          const SizedBox(height: 12),
          Text(
            widget.label ?? _getDefaultLabel(),
            style: SpendexTheme.labelMedium.copyWith(
              color: isDisabled
                  ? (isDark
                      ? SpendexColors.darkTextTertiary
                      : SpendexColors.lightTextTertiary)
                  : (isDark
                      ? SpendexColors.darkTextSecondary
                      : SpendexColors.lightTextSecondary),
            ),
          ),
        ],

        // Not available message
        if (!widget.isAvailable) ...[
          const SizedBox(height: 8),
          Text(
            'Biometric not available',
            style: SpendexTheme.labelMedium.copyWith(
              color: SpendexColors.warning,
              fontSize: 11,
            ),
          ),
        ],
      ],
    );
  }
}

/// Biometric Login Button (Full Width)
///
/// A full-width button for biometric login with icon and text
class BiometricLoginButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final bool isAvailable;
  final BiometricType biometricType;

  const BiometricLoginButton({
    super.key,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.isAvailable = true,
    this.biometricType = BiometricType.fingerprint,
  });

  @override
  State<BiometricLoginButton> createState() => _BiometricLoginButtonState();
}

class _BiometricLoginButtonState extends State<BiometricLoginButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    if (widget.isEnabled && widget.isAvailable && !widget.isLoading) {
      _shimmerController.repeat();
    }
  }

  @override
  void didUpdateWidget(BiometricLoginButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isEnabled && widget.isAvailable && !widget.isLoading) {
      if (!_shimmerController.isAnimating) {
        _shimmerController.repeat();
      }
    } else {
      _shimmerController.stop();
    }
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  IconData _getBiometricIcon() {
    switch (widget.biometricType) {
      case BiometricType.fingerprint:
        return Iconsax.finger_scan;
      case BiometricType.faceId:
        return Iconsax.scan;
      case BiometricType.iris:
        return Iconsax.eye;
    }
  }

  String _getButtonText() {
    if (Platform.isIOS) {
      return 'Login with Face ID';
    }
    return 'Login with Fingerprint';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDisabled = !widget.isEnabled || !widget.isAvailable || widget.isLoading;

    final backgroundColor =
        isDark ? SpendexColors.darkSurface : SpendexColors.lightSurface;
    final borderColor = isDisabled
        ? (isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder)
        : SpendexColors.primary.withOpacity(0.5);
    final iconColor = isDisabled
        ? (isDark ? SpendexColors.darkTextTertiary : SpendexColors.lightTextTertiary)
        : SpendexColors.primary;
    final textColor = isDisabled
        ? (isDark ? SpendexColors.darkTextTertiary : SpendexColors.lightTextTertiary)
        : (isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary);

    if (!widget.isAvailable) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: isDisabled
            ? null
            : () {
                HapticFeedback.mediumImpact();
                widget.onPressed?.call();
              },
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          side: BorderSide(color: borderColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: widget.isLoading
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(iconColor),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getBiometricIcon(),
                      color: iconColor,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _getButtonText(),
                      style: SpendexTheme.titleMedium.copyWith(
                        color: textColor,
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

/// Small biometric icon button for inline use
class BiometricIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final double size;

  const BiometricIconButton({
    super.key,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDisabled = !isEnabled || isLoading;

    final iconColor = isDisabled
        ? (isDark ? SpendexColors.darkTextTertiary : SpendexColors.lightTextTertiary)
        : SpendexColors.primary;

    return InkWell(
      onTap: isDisabled
          ? null
          : () {
              HapticFeedback.mediumImpact();
              onPressed?.call();
            },
      borderRadius: BorderRadius.circular(size / 2),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isDisabled
                ? (isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder)
                : SpendexColors.primary.withOpacity(0.3),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: isLoading
              ? SizedBox(
                  width: size * 0.4,
                  height: size * 0.4,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(iconColor),
                  ),
                )
              : Icon(
                  Iconsax.finger_scan,
                  color: iconColor,
                  size: size * 0.5,
                ),
        ),
      ),
    );
  }
}
