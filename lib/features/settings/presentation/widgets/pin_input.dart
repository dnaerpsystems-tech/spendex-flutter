import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme.dart';

/// A PIN digit input widget for entering secure PIN codes.
///
/// Features:
/// - Configurable PIN length (4-6 digits, default 4)
/// - Auto-focus next box on input
/// - Auto-focus previous box on backspace
/// - Obscure text with dots for security
/// - Error state with shake animation
/// - Styled digit boxes with borders and spacing
/// - Callbacks for completion and value changes
/// - Proper controller and focus node management
/// - Material 3 design with dark mode support
///
/// Example:
/// ```dart
/// PinInput(
///   length: 4,
///   onCompleted: (pin) {
///     print('PIN entered: $pin');
///   },
///   onChanged: (pin) {
///     print('Current PIN: $pin');
///   },
/// )
/// ```
class PinInput extends StatefulWidget {
  /// Creates a PIN input widget.
  ///
  /// [length] is the number of digits (must be between 4-6, defaults to 4).
  /// [onCompleted] callback triggered when all digits are entered.
  /// [onChanged] callback triggered when any digit changes.
  /// [obscureText] controls whether to show dots instead of numbers (defaults to true).
  /// [boxSize] is the width/height of each digit box (defaults to 56).
  /// [spacing] is the gap between boxes (defaults to 12).
  /// [autoFocus] controls whether to auto-focus first box (defaults to true).
  const PinInput({
    super.key,
    this.length = 4,
    this.onCompleted,
    this.onChanged,
    this.obscureText = true,
    this.boxSize = 56,
    this.spacing = 12,
    this.autoFocus = true,
  }) : assert(length >= 4 && length <= 6, 'PIN length must be between 4-6');

  final int length;
  final ValueChanged<String>? onCompleted;
  final ValueChanged<String>? onChanged;
  final bool obscureText;
  final double boxSize;
  final double spacing;
  final bool autoFocus;

  @override
  State<PinInput> createState() => PinInputState();
}

class PinInputState extends State<PinInput>
    with SingleTickerProviderStateMixin {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();

    _controllers = List.generate(
      widget.length,
      (index) => TextEditingController(),
    );

    _focusNodes = List.generate(
      widget.length,
      (index) => FocusNode(),
    );

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(
        parent: _shakeController,
        curve: Curves.elasticIn,
      ),
    );

    if (widget.autoFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNodes[0].requestFocus();
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    _shakeController.dispose();
    super.dispose();
  }

  String get _currentPin {
    return _controllers.map((c) => c.text).join();
  }

  void _onChanged(int index, String value) {
    if (value.isNotEmpty) {
      if (index < widget.length - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }

      final pin = _currentPin;
      widget.onChanged?.call(pin);

      if (pin.length == widget.length) {
        widget.onCompleted?.call(pin);
      }
    }
  }

  void _onKeyEvent(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_controllers[index].text.isEmpty && index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }
  }

  /// Shows error state with shake animation
  void showError() {
    setState(() {
      _hasError = true;
    });
    _shakeController.forward(from: 0).then((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            _hasError = false;
          });
        }
      });
    });
  }

  /// Clears all input boxes
  void clear() {
    for (final controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        final offset = _shakeController.isAnimating
            ? (_shakeAnimation.value *
                (1 - _shakeController.value) *
                (_shakeController.value < 0.5 ? 1 : -1))
            : 0.0;

        return Transform.translate(
          offset: Offset(offset, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.length,
              (index) => Padding(
                padding: EdgeInsets.only(
                  right: index < widget.length - 1 ? widget.spacing : 0,
                ),
                child: _buildPinBox(index, isDark),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPinBox(int index, bool isDark) {
    final borderColor = _hasError
        ? SpendexColors.expense
        : isDark
            ? SpendexColors.darkBorder
            : SpendexColors.lightBorder;

    final focusedBorderColor = _hasError
        ? SpendexColors.expense
        : SpendexColors.primary;

    final backgroundColor = isDark
        ? SpendexColors.darkSurface
        : SpendexColors.lightSurface;

    final textColor =
        isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary;

    return Container(
      width: widget.boxSize,
      height: widget.boxSize,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
        border: Border.all(
          color: _controllers[index].text.isNotEmpty || _focusNodes[index].hasFocus
              ? focusedBorderColor
              : borderColor,
          width: _controllers[index].text.isNotEmpty || _focusNodes[index].hasFocus
              ? 2
              : 1,
        ),
        boxShadow: _focusNodes[index].hasFocus
            ? [
                BoxShadow(
                  color: focusedBorderColor.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: (event) => _onKeyEvent(index, event),
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          obscureText: widget.obscureText,
          obscuringCharacter: '●',
          style: SpendexTheme.headlineMedium.copyWith(
            color: textColor,
            fontWeight: FontWeight.w700,
            fontSize: 24,
          ),
          decoration: const InputDecoration(
            border: InputBorder.none,
            counterText: '',
            contentPadding: EdgeInsets.zero,
          ),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          onChanged: (value) => _onChanged(index, value),
        ),
      ),
    );
  }
}
