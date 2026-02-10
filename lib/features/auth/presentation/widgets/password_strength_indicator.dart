import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../app/theme.dart';

/// Password Strength Levels
enum PasswordStrength {
  empty('', 0, Colors.grey),
  veryWeak('Very Weak', 0.2, Color(0xFFEF4444)),
  weak('Weak', 0.4, Color(0xFFF97316)),
  fair('Fair', 0.6, Color(0xFFF59E0B)),
  strong('Strong', 0.8, Color(0xFF84CC16)),
  veryStrong('Very Strong', 1, Color(0xFF22C55E));

  const PasswordStrength(this.label, this.progress, this.color);

  final String label;
  final double progress;
  final Color color;
}

/// Represents a single password requirement
class PasswordRequirement {

  const PasswordRequirement({
    required this.label,
    required this.isMet,
    required this.icon,
  });
  final String label;
  final bool isMet;
  final IconData icon;
}

/// Password Validator Helper Class
class PasswordValidator {
  PasswordValidator._();

  /// Minimum 8 characters
  static bool hasMinLength(String password) => password.length >= 8;

  /// Contains uppercase letter (A-Z)
  static bool hasUppercase(String password) =>
      password.contains(RegExp(r'[A-Z]'));

  /// Contains lowercase letter (a-z)
  static bool hasLowercase(String password) =>
      password.contains(RegExp(r'[a-z]'));

  /// Contains number (0-9)
  static bool hasNumber(String password) =>
      password.contains(RegExp(r'[0-9]'));

  /// Contains special character (@$!%*?&)
  static bool hasSpecialChar(String password) =>
      password.contains(RegExp(r'[@$!%*?&#^()_+=\-\[\]{}|\\:";,.<>~`]'));

  /// Count how many requirements are met
  static int getMetRequirementsCount(String password) {
    int count = 0;
    if (hasMinLength(password)) count++;
    if (hasUppercase(password)) count++;
    if (hasLowercase(password)) count++;
    if (hasNumber(password)) count++;
    if (hasSpecialChar(password)) count++;
    return count;
  }

  /// Get password strength based on requirements met
  static PasswordStrength getStrength(String password) {
    if (password.isEmpty) return PasswordStrength.empty;

    final count = getMetRequirementsCount(password);

    switch (count) {
      case 0:
      case 1:
        return PasswordStrength.veryWeak;
      case 2:
        return PasswordStrength.weak;
      case 3:
        return PasswordStrength.fair;
      case 4:
        return PasswordStrength.strong;
      case 5:
        return PasswordStrength.veryStrong;
      default:
        return PasswordStrength.empty;
    }
  }

  /// Get list of all password requirements with their status
  static List<PasswordRequirement> getRequirements(String password) {
    return [
      PasswordRequirement(
        label: 'At least 8 characters',
        isMet: hasMinLength(password),
        icon: Iconsax.text,
      ),
      PasswordRequirement(
        label: 'Uppercase letter (A-Z)',
        isMet: hasUppercase(password),
        icon: Iconsax.text_block,
      ),
      PasswordRequirement(
        label: 'Lowercase letter (a-z)',
        isMet: hasLowercase(password),
        icon: Iconsax.smallcaps,
      ),
      PasswordRequirement(
        label: 'Number (0-9)',
        isMet: hasNumber(password),
        icon: Iconsax.hashtag,
      ),
      PasswordRequirement(
        label: 'Special character (@\$!%*?&)',
        isMet: hasSpecialChar(password),
        icon: Iconsax.star,
      ),
    ];
  }

  /// Check if password meets all requirements
  static bool isValid(String password) {
    return hasMinLength(password) &&
        hasUppercase(password) &&
        hasLowercase(password) &&
        hasNumber(password) &&
        hasSpecialChar(password);
  }

  /// Check if password is at least fair strength (minimum acceptable)
  static bool isAcceptable(String password) {
    final strength = getStrength(password);
    return strength == PasswordStrength.fair ||
        strength == PasswordStrength.strong ||
        strength == PasswordStrength.veryStrong;
  }
}

/// Password Strength Indicator Widget
///
/// Shows animated progress bar with color based on strength
/// and individual requirement checks
class PasswordStrengthIndicator extends StatefulWidget {

  const PasswordStrengthIndicator({
    super.key,
    required this.password,
    this.showRequirements = true,
    this.showLabel = true,
    this.barHeight = 4,
    this.padding,
  });
  final String password;
  final bool showRequirements;
  final bool showLabel;
  final double barHeight;
  final EdgeInsetsGeometry? padding;

  @override
  State<PasswordStrengthIndicator> createState() =>
      _PasswordStrengthIndicatorState();
}

class _PasswordStrengthIndicatorState extends State<PasswordStrengthIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(PasswordStrengthIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.password != widget.password) {
      _animationController.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final strength = PasswordValidator.getStrength(widget.password);
    final requirements = PasswordValidator.getRequirements(widget.password);

    if (widget.password.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: widget.padding ?? EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Strength Bar with Label
          Row(
            children: [
              Expanded(
                child: _buildStrengthBar(strength, isDark),
              ),
              if (widget.showLabel && strength != PasswordStrength.empty) ...[
                const SizedBox(width: 12),
                _buildStrengthLabel(strength),
              ],
            ],
          ),

          // Requirements List
          if (widget.showRequirements) ...[
            const SizedBox(height: 12),
            ...requirements.map((req) => _buildRequirementItem(req, isDark)),
          ],
        ],
      ),
    );
  }

  Widget _buildStrengthBar(PasswordStrength strength, bool isDark) {
    final backgroundColor =
        isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: strength.progress),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Container(
          height: widget.barHeight,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(widget.barHeight / 2),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: constraints.maxWidth * value,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          strength.color,
                          strength.color.withValues(alpha:0.8),
                        ],
                      ),
                      borderRadius:
                          BorderRadius.circular(widget.barHeight / 2),
                      boxShadow: [
                        BoxShadow(
                          color: strength.color.withValues(alpha:0.4),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildStrengthLabel(PasswordStrength strength) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: Container(
        key: ValueKey(strength),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: strength.color.withValues(alpha:0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          strength.label,
          style: SpendexTheme.labelMedium.copyWith(
            color: strength.color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildRequirementItem(PasswordRequirement requirement, bool isDark) {
    final metColor = SpendexColors.income;
    final unmetColor =
        isDark ? SpendexColors.darkTextTertiary : SpendexColors.lightTextTertiary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: requirement.isMet ? 1 : 0),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          final color = Color.lerp(unmetColor, metColor, value)!;
          return Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: requirement.isMet
                      ? metColor.withValues(alpha:0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: color.withValues(alpha:0.3),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: requirement.isMet
                        ? Icon(
                            Iconsax.tick_circle5,
                            key: const ValueKey('met'),
                            size: 14,
                            color: metColor,
                          )
                        : Icon(
                            Iconsax.close_circle,
                            key: const ValueKey('unmet'),
                            size: 14,
                            color: unmetColor,
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: SpendexTheme.labelMedium.copyWith(
                    color: color,
                    decoration:
                        requirement.isMet ? TextDecoration.lineThrough : null,
                    decorationColor: color,
                  ),
                  child: Text(requirement.label),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Compact Password Strength Indicator
/// Shows only the progress bar without requirements
class PasswordStrengthBar extends StatelessWidget {

  const PasswordStrengthBar({
    super.key,
    required this.password,
    this.height = 4,
    this.showLabel = true,
  });
  final String password;
  final double height;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    return PasswordStrengthIndicator(
      password: password,
      showRequirements: false,
      showLabel: showLabel,
      barHeight: height,
    );
  }
}

/// Password Match Indicator
/// Shows if confirm password matches the original password
class PasswordMatchIndicator extends StatelessWidget {

  const PasswordMatchIndicator({
    super.key,
    required this.password,
    required this.confirmPassword,
  });
  final String password;
  final String confirmPassword;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (confirmPassword.isEmpty) {
      return const SizedBox.shrink();
    }

    final isMatch = password == confirmPassword && password.isNotEmpty;
    final color = isMatch
        ? SpendexColors.income
        : SpendexColors.expense;
    final unmetColor =
        isDark ? SpendexColors.darkTextTertiary : SpendexColors.lightTextTertiary;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: isMatch ? color.withValues(alpha:0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: (isMatch ? color : unmetColor).withValues(alpha:0.3),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: isMatch
                        ? Icon(
                            Iconsax.tick_circle5,
                            key: const ValueKey('match'),
                            size: 14,
                            color: color,
                          )
                        : Icon(
                            Iconsax.close_circle,
                            key: const ValueKey('no-match'),
                            size: 14,
                            color: unmetColor,
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: SpendexTheme.labelMedium.copyWith(
                  color: isMatch ? color : unmetColor,
                ),
                child: Text(
                  isMatch ? 'Passwords match' : 'Passwords do not match',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Segmented Password Strength Bar
/// Shows strength as segmented blocks instead of a continuous bar
class SegmentedPasswordStrengthBar extends StatelessWidget {

  const SegmentedPasswordStrengthBar({
    super.key,
    required this.password,
    this.segments = 5,
    this.height = 4,
    this.gap = 4,
  });
  final String password;
  final int segments;
  final double height;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final strength = PasswordValidator.getStrength(password);
    final filledSegments = PasswordValidator.getMetRequirementsCount(password);
    final backgroundColor =
        isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder;

    return Row(
      children: List.generate(segments, (index) {
        final isFilled = index < filledSegments;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: index < segments - 1 ? gap : 0),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: isFilled ? 1 : 0),
              duration: Duration(milliseconds: 200 + (index * 50)),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Container(
                  height: height,
                  decoration: BoxDecoration(
                    color: Color.lerp(backgroundColor, strength.color, value),
                    borderRadius: BorderRadius.circular(height / 2),
                  ),
                );
              },
            ),
          ),
        );
      }),
    );
  }
}
