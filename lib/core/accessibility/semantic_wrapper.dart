import 'package:flutter/material.dart';

/// A collection of semantic wrapper widgets for consistent accessibility
/// support throughout the application.
///
/// These widgets make it easy to add proper semantics to common UI patterns
/// like cards, buttons, transactions, and form fields.

/// A semantic wrapper for card-like containers with informational content.
///
/// Use this for dashboard cards, summary cards, and similar read-only containers.
class SemanticCard extends StatelessWidget {
  const SemanticCard({
    required this.label,
    required this.child,
    super.key,
    this.hint,
    this.onTap,
    this.isButton = false,
  });

  /// The accessible label describing the card's content.
  final String label;

  /// The hint text for additional context.
  final String? hint;

  /// The child widget to display.
  final Widget child;

  /// Optional tap callback. If provided, the card is treated as interactive.
  final VoidCallback? onTap;

  /// Whether this card should be treated as a button.
  final bool isButton;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      hint: hint,
      button: isButton || onTap != null,
      container: true,
      onTap: onTap,
      child: child,
    );
  }
}

/// A semantic wrapper for transaction items.
///
/// Provides consistent accessibility labels for transaction list items.
class SemanticTransaction extends StatelessWidget {
  const SemanticTransaction({
    required this.description,
    required this.amount,
    required this.type,
    required this.child,
    super.key,
    this.category,
    this.date,
    this.onTap,
  });

  /// The transaction description or title.
  final String description;

  /// The formatted amount string.
  final String amount;

  /// The transaction type (income, expense, transfer).
  final String type;

  /// The category name if available.
  final String? category;

  /// The formatted date if available.
  final String? date;

  /// The child widget to display.
  final Widget child;

  /// Optional tap callback.
  final VoidCallback? onTap;

  String _buildLabel() {
    final parts = <String>[description];
    if (category != null) {
      parts.add(category!);
    }
    parts.add(amount);
    parts.add(type);
    if (date != null) {
      parts.add(date!);
    }
    return parts.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: _buildLabel(),
      button: onTap != null,
      onTap: onTap,
      child: child,
    );
  }
}

/// A semantic wrapper for action buttons with icons and labels.
///
/// Use this for quick action buttons, FAB menu options, etc.
class SemanticActionButton extends StatelessWidget {
  const SemanticActionButton({
    required this.label,
    required this.child,
    required this.onTap,
    super.key,
    this.hint,
    this.enabled = true,
  });

  /// The accessible label for the button.
  final String label;

  /// Additional hint text.
  final String? hint;

  /// The child widget to display.
  final Widget child;

  /// The tap callback.
  final VoidCallback onTap;

  /// Whether the button is enabled.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      hint: hint,
      button: true,
      enabled: enabled,
      onTap: enabled ? onTap : null,
      child: child,
    );
  }
}

/// A semantic wrapper for financial summary items.
///
/// Provides proper labels for balance displays, income/expense summaries, etc.
class SemanticFinancialValue extends StatelessWidget {
  const SemanticFinancialValue({
    required this.label,
    required this.value,
    required this.child,
    super.key,
  });

  /// The label describing what this value represents.
  final String label;

  /// The formatted value string.
  final String value;

  /// The child widget to display.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label: $value',
      child: ExcludeSemantics(
        child: child,
      ),
    );
  }
}

/// A semantic wrapper for navigation items.
///
/// Use for bottom navigation items, tab bar items, etc.
class SemanticNavItem extends StatelessWidget {
  const SemanticNavItem({
    required this.label,
    required this.child,
    super.key,
    this.hint,
    this.selected = false,
    this.onTap,
  });

  /// The accessible label for the navigation item.
  final String label;

  /// Additional hint text.
  final String? hint;

  /// Whether this item is currently selected.
  final bool selected;

  /// The child widget to display.
  final Widget child;

  /// Optional tap callback.
  final VoidCallback? onTap;

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

/// A semantic wrapper for form sections.
///
/// Groups related form fields together for screen reader navigation.
class SemanticFormSection extends StatelessWidget {
  const SemanticFormSection({
    required this.label,
    required this.child,
    super.key,
  });

  /// The label for this form section.
  final String label;

  /// The child widget containing form fields.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      container: true,
      explicitChildNodes: true,
      child: child,
    );
  }
}

/// A semantic wrapper for alert/warning cards.
///
/// Provides appropriate semantics for budget alerts, warnings, etc.
class SemanticAlert extends StatelessWidget {
  const SemanticAlert({
    required this.title,
    required this.message,
    required this.child,
    super.key,
    this.isError = false,
    this.onTap,
  });

  /// The alert title.
  final String title;

  /// The alert message.
  final String message;

  /// The child widget to display.
  final Widget child;

  /// Whether this is an error alert.
  final bool isError;

  /// Optional tap callback.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$title. $message',
      button: onTap != null,
      liveRegion: isError,
      onTap: onTap,
      child: child,
    );
  }
}
