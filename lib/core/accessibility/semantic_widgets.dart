import 'package:flutter/material.dart';

/// A collection of utility widgets for consistent accessibility support
/// throughout the Spendex app.

/// Semantic wrapper for buttons with customizable accessibility properties
class SemanticButton extends StatelessWidget {
  final String label;
  final String? hint;
  final Widget child;
  final bool excludeSemantics;
  final VoidCallback? onTap;
  final bool enabled;

  const SemanticButton({
    super.key,
    required this.label,
    this.hint,
    required this.child,
    this.excludeSemantics = false,
    this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      hint: hint,
      button: true,
      enabled: enabled,
      excludeSemantics: excludeSemantics,
      onTap: enabled ? onTap : null,
      child: child,
    );
  }
}

/// Semantic wrapper for cards/containers with information
class SemanticContainer extends StatelessWidget {
  final String label;
  final String? hint;
  final Widget child;
  final bool isTappable;
  final VoidCallback? onTap;

  const SemanticContainer({
    super.key,
    required this.label,
    this.hint,
    required this.child,
    this.isTappable = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      hint: hint,
      container: true,
      button: isTappable || onTap != null,
      onTap: onTap,
      child: child,
    );
  }
}

/// Semantic wrapper for list items
class SemanticListItem extends StatelessWidget {
  final String label;
  final String? value;
  final Widget child;
  final VoidCallback? onTap;

  const SemanticListItem({
    super.key,
    required this.label,
    this.value,
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: value != null ? '$label: $value' : label,
      button: onTap != null,
      onTap: onTap,
      child: child,
    );
  }
}

/// Excludes child from semantics tree (for decorative elements)
class SemanticExclude extends StatelessWidget {
  final Widget child;

  const SemanticExclude({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(child: child);
  }
}

/// Semantic wrapper for header/title elements
class SemanticHeader extends StatelessWidget {
  final String label;
  final Widget child;

  const SemanticHeader({
    super.key,
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      header: true,
      child: child,
    );
  }
}

/// Semantic wrapper for images
class SemanticImage extends StatelessWidget {
  final String description;
  final Widget child;

  const SemanticImage({
    super.key,
    required this.description,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: description,
      image: true,
      child: child,
    );
  }
}

/// Semantic wrapper for toggles/switches
class SemanticToggle extends StatelessWidget {
  final String label;
  final bool toggled;
  final String? hint;
  final Widget child;
  final VoidCallback? onTap;

  const SemanticToggle({
    super.key,
    required this.label,
    required this.toggled,
    this.hint,
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      hint: hint,
      toggled: toggled,
      onTap: onTap,
      child: child,
    );
  }
}

/// Semantic wrapper for navigation items
class SemanticNavigation extends StatelessWidget {
  final String label;
  final bool selected;
  final String? hint;
  final Widget child;
  final VoidCallback? onTap;

  const SemanticNavigation({
    super.key,
    required this.label,
    this.selected = false,
    this.hint,
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      hint: hint,
      button: true,
      selected: selected,
      onTap: onTap,
      child: child,
    );
  }
}

/// Semantic wrapper for text fields with proper labeling
class SemanticTextField extends StatelessWidget {
  final String label;
  final String? value;
  final String? hint;
  final Widget child;

  const SemanticTextField({
    super.key,
    required this.label,
    this.value,
    this.hint,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      value: value,
      hint: hint,
      textField: true,
      child: child,
    );
  }
}
