import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../app/theme.dart';

/// Password strength levels with associated metadata
enum PasswordStrength {
  weak('Weak', 0.25, Color(0xFFEF4444)),
  fair('Fair', 0.50, Color(0xFFF97316)),
  good('Good', 0.75, Color(0xFFF59E0B)),
  strong('Strong', 1, Color(0xFF22C55E));

  const PasswordStrength(this.label, this.progress, this.color);

  final String label;
  final double progress;
  final Color color;
}

/// Password strength visualization widget with progress bar and requirements checklist.
///
/// Features:
/// - Linear progress bar showing strength (0-100%)
/// - Color-coded strength levels:
///   - Red (0-25%): Weak - Less than 8 chars or missing requirements
///   - Orange (26-50%): Fair - 8+ chars, 1-2 requirements met
///   - Yellow (51-75%): Good - 8+ chars, 3 requirements met
///   - Green (76-100%): Strong - 8+ chars, all requirements met
/// - Strength label text
/// - Expandable requirements checklist:
///   - Min 8 characters
///   - At least one uppercase letter
///   - At least one lowercase letter
///   - At least one number
///   - At least one special character
/// - Automatic strength calculation from password string
/// - Material 3 design with animations
/// - Dark mode support
///
/// Example:
/// ```dart
/// PasswordStrengthIndicator(
///   password: 'MyP@ssw0rd',
///   showRequirements: true,
/// )
/// ```
class PasswordStrengthIndicator extends StatelessWidget {
  /// Creates a password strength indicator.
  ///
  /// [password] is the password string to analyze.
  /// [showRequirements] controls checklist visibility (defaults to true).
  /// [showLabel] controls strength label visibility (defaults to true).
  /// [barHeight] sets the progress bar height (defaults to 6).
  const PasswordStrengthIndicator({
    required this.password,
    super.key,
    this.showRequirements = true,
    this.showLabel = true,
    this.barHeight = 6,
  });

  final String password;
  final bool showRequirements;
  final bool showLabel;
  final double barHeight;

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) {
      return const SizedBox.shrink();
    }

    final strength = _calculateStrength(password);
    final requirements = _getRequirements(password);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildProgressBar(strength),
            ),
            if (showLabel) ...[
              const SizedBox(width: SpendexTheme.spacingMd),
              _buildLabel(strength),
            ],
          ],
        ),
        if (showRequirements) ...[
          const SizedBox(height: SpendexTheme.spacingMd),
          ...requirements.map(_buildRequirementItem),
        ],
      ],
    );
  }

  Widget _buildProgressBar(PasswordStrength strength) {
    return Container(
      height: barHeight,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(barHeight / 2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: strength.progress,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: strength.color,
            borderRadius: BorderRadius.circular(barHeight / 2),
            boxShadow: [
              BoxShadow(
                color: strength.color.withValues(alpha: 0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(PasswordStrength strength) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpendexTheme.spacingSm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: strength.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(SpendexTheme.radiusSm),
        border: Border.all(
          color: strength.color.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        strength.label,
        style: SpendexTheme.labelMedium.copyWith(
          color: strength.color,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildRequirementItem(_PasswordRequirement requirement) {
    return Padding(
      padding: const EdgeInsets.only(bottom: SpendexTheme.spacingSm),
      child: Row(
        children: [
          Icon(
            requirement.isMet ? Iconsax.tick_circle5 : Iconsax.close_circle,
            size: 16,
            color: requirement.isMet
                ? SpendexColors.income
                : Colors.grey.shade400,
          ),
          const SizedBox(width: SpendexTheme.spacingSm),
          Expanded(
            child: Text(
              requirement.label,
              style: SpendexTheme.labelMedium.copyWith(
                color: requirement.isMet
                    ? SpendexColors.income
                    : Colors.grey.shade600,
                decoration:
                    requirement.isMet ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  PasswordStrength _calculateStrength(String password) {
    if (password.length < 8) {
      return PasswordStrength.weak;
    }

    var metRequirements = 0;

    if (_hasUppercase(password)) {
      metRequirements++;
    }
    if (_hasLowercase(password)) {
      metRequirements++;
    }
    if (_hasNumber(password)) {
      metRequirements++;
    }
    if (_hasSpecialChar(password)) {
      metRequirements++;
    }

    if (metRequirements <= 2) {
      return PasswordStrength.fair;
    } else if (metRequirements == 3) {
      return PasswordStrength.good;
    } else {
      return PasswordStrength.strong;
    }
  }

  List<_PasswordRequirement> _getRequirements(String password) {
    return [
      _PasswordRequirement(
        label: 'At least 8 characters',
        isMet: password.length >= 8,
      ),
      _PasswordRequirement(
        label: 'At least one uppercase letter',
        isMet: _hasUppercase(password),
      ),
      _PasswordRequirement(
        label: 'At least one lowercase letter',
        isMet: _hasLowercase(password),
      ),
      _PasswordRequirement(
        label: 'At least one number',
        isMet: _hasNumber(password),
      ),
      _PasswordRequirement(
        label: 'At least one special character',
        isMet: _hasSpecialChar(password),
      ),
    ];
  }

  bool _hasUppercase(String password) {
    return password.contains(RegExp('[A-Z]'));
  }

  bool _hasLowercase(String password) {
    return password.contains(RegExp('[a-z]'));
  }

  bool _hasNumber(String password) {
    return password.contains(RegExp('[0-9]'));
  }

  bool _hasSpecialChar(String password) {
    return password.contains(RegExp(r'[@$!%*?&#^()_+=\-\[\]{}|\\:";,.<>~`]'));
  }
}

/// Internal class representing a password requirement
class _PasswordRequirement {
  const _PasswordRequirement({
    required this.label,
    required this.isMet,
  });

  final String label;
  final bool isMet;
}
