import 'package:flutter/material.dart';

import '../../../../app/theme.dart';

/// Auth Header Widget
///
/// A professional auth header with:
/// - Animated logo with scale and fade
/// - Title and subtitle
/// - Customizable for each screen
class AuthHeader extends StatefulWidget {
  final String title;
  final String subtitle;
  final bool showLogo;
  final bool animate;
  final Widget? customLogo;
  final double logoSize;
  final Duration animationDuration;
  final TextAlign textAlign;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.showLogo = true,
    this.animate = true,
    this.customLogo,
    this.logoSize = 80,
    this.animationDuration = const Duration(milliseconds: 800),
    this.textAlign = TextAlign.center,
  });

  @override
  State<AuthHeader> createState() => _AuthHeaderState();
}

class _AuthHeaderState extends State<AuthHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );

    if (widget.animate) {
      _animationController.forward();
    } else {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Column(
          crossAxisAlignment: widget.textAlign == TextAlign.center
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
          children: [
            // Logo
            if (widget.showLogo) ...[
              FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: widget.customLogo ?? _buildDefaultLogo(),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Title
            SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  widget.title,
                  style: SpendexTheme.displayLarge.copyWith(
                    color: isDark
                        ? SpendexColors.darkTextPrimary
                        : SpendexColors.lightTextPrimary,
                    fontSize: 28,
                  ),
                  textAlign: widget.textAlign,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Subtitle
            SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  widget.subtitle,
                  style: SpendexTheme.bodyMedium.copyWith(
                    color: isDark
                        ? SpendexColors.darkTextSecondary
                        : SpendexColors.lightTextSecondary,
                  ),
                  textAlign: widget.textAlign,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDefaultLogo() {
    return Container(
      width: widget.logoSize,
      height: widget.logoSize,
      decoration: BoxDecoration(
        gradient: SpendexColors.primaryGradient,
        borderRadius: BorderRadius.circular(widget.logoSize * 0.25),
        boxShadow: [
          BoxShadow(
            color: SpendexColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Text(
          'S',
          style: TextStyle(
            fontSize: widget.logoSize * 0.5,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// Compact Auth Header for smaller spaces
class AuthHeaderCompact extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? leadingIcon;
  final VoidCallback? onBack;

  const AuthHeaderCompact({
    super.key,
    required this.title,
    this.subtitle,
    this.leadingIcon,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (onBack != null) ...[
          IconButton(
            onPressed: onBack,
            icon: Icon(
              leadingIcon ?? Icons.arrow_back_ios_new_rounded,
              color: isDark
                  ? SpendexColors.darkTextPrimary
                  : SpendexColors.lightTextPrimary,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(height: 24),
        ],
        Text(
          title,
          style: SpendexTheme.displayLarge.copyWith(
            color: isDark
                ? SpendexColors.darkTextPrimary
                : SpendexColors.lightTextPrimary,
            fontSize: 24,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            style: SpendexTheme.bodyMedium.copyWith(
              color: isDark
                  ? SpendexColors.darkTextSecondary
                  : SpendexColors.lightTextSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

/// Auth Divider with text in the middle
class AuthDivider extends StatelessWidget {
  final String text;
  final double spacing;

  const AuthDivider({
    super.key,
    this.text = 'or continue with',
    this.spacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dividerColor =
        isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder;
    final textColor =
        isDark ? SpendexColors.darkTextTertiary : SpendexColors.lightTextTertiary;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: spacing),
      child: Row(
        children: [
          Expanded(child: Divider(color: dividerColor)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              text,
              style: SpendexTheme.bodyMedium.copyWith(color: textColor),
            ),
          ),
          Expanded(child: Divider(color: dividerColor)),
        ],
      ),
    );
  }
}

/// Auth Footer for links at the bottom
class AuthFooter extends StatelessWidget {
  final String text;
  final String linkText;
  final VoidCallback? onLinkPressed;

  const AuthFooter({
    super.key,
    required this.text,
    required this.linkText,
    this.onLinkPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          text,
          style: SpendexTheme.bodyMedium.copyWith(
            color: isDark
                ? SpendexColors.darkTextSecondary
                : SpendexColors.lightTextSecondary,
          ),
        ),
        TextButton(
          onPressed: onLinkPressed,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            linkText,
            style: SpendexTheme.titleMedium.copyWith(
              color: SpendexColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}
