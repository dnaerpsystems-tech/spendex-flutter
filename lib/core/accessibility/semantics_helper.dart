import 'package:flutter/material.dart';

/// Helper class for accessibility features
class SemanticsHelper {
  SemanticsHelper._();
  
  /// Wrap a widget with semantic label for screen readers
  static Widget label({
    required Widget child,
    required String label,
    bool button = false,
    bool header = false,
    bool link = false,
    bool image = false,
    VoidCallback? onTap,
  }) {
    return Semantics(
      label: label,
      button: button,
      header: header,
      link: link,
      image: image,
      onTap: onTap,
      child: child,
    );
  }
  
  /// Wrap a button with proper semantics
  static Widget button({
    required Widget child,
    required String label,
    VoidCallback? onTap,
    bool enabled = true,
  }) {
    return Semantics(
      label: label,
      button: true,
      enabled: enabled,
      onTap: onTap,
      child: child,
    );
  }
  
  /// Wrap an image with description
  static Widget image({
    required Widget child,
    required String description,
  }) {
    return Semantics(
      label: description,
      image: true,
      child: child,
    );
  }
  
  /// Wrap a header/title
  static Widget header({
    required Widget child,
    required String label,
  }) {
    return Semantics(
      label: label,
      header: true,
      child: child,
    );
  }
  
  /// Exclude decorative elements from semantics
  static Widget excludeDecorative({
    required Widget child,
  }) {
    return ExcludeSemantics(
      child: child,
    );
  }
  
  /// Merge semantics for complex widgets
  static Widget merge({
    required Widget child,
    String? label,
  }) {
    return MergeSemantics(
      child: label != null
          ? Semantics(label: label, child: child)
          : child,
    );
  }
  
  /// Add value semantics (for progress, sliders, etc.)
  static Widget value({
    required Widget child,
    required String value,
    String? label,
    String? hint,
    double? increasedValue,
    double? decreasedValue,
  }) {
    return Semantics(
      label: label,
      value: value,
      hint: hint,
      child: child,
    );
  }
}
