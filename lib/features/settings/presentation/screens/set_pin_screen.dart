import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../app/theme.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/storage/secure_storage.dart';
import '../widgets/pin_input.dart';

class SetPinScreen extends StatefulWidget {
  const SetPinScreen({super.key});

  @override
  State<SetPinScreen> createState() => _SetPinScreenState();
}

class _SetPinScreenState extends State<SetPinScreen>
    with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  String _enteredPin = '';
  String _confirmPin = '';
  bool _isLoading = false;
  String? _errorMessage;
  String _currentPinValue = '';

  final int _pinLength = 4;

  final SecureStorageService _secureStorage = getIt<SecureStorageService>();

  bool _validatePin(String pin) {
    setState(() {
      _errorMessage = null;
    });

    if (pin.length != _pinLength) {
      setState(() {
        _errorMessage = 'PIN must be $_pinLength digits';
      });
      return false;
    }

    if (_isRepeating(pin)) {
      setState(() {
        _errorMessage = 'PIN cannot be all same digits';
      });
      return false;
    }

    if (_isSequential(pin)) {
      setState(() {
        _errorMessage = 'PIN cannot be sequential numbers';
      });
      return false;
    }

    if (_isCommonPin(pin)) {
      setState(() {
        _errorMessage = 'This PIN is too common, please choose another';
      });
      return false;
    }

    return true;
  }

  bool _isRepeating(String pin) {
    return pin.split('').toSet().length == 1;
  }

  bool _isSequential(String pin) {
    var isAscending = true;
    var isDescending = true;

    for (var i = 0; i < pin.length - 1; i++) {
      final current = int.parse(pin[i]);
      final next = int.parse(pin[i + 1]);

      if (next != current + 1) {
        isAscending = false;
      }

      if (next != current - 1) {
        isDescending = false;
      }
    }

    return isAscending || isDescending;
  }

  bool _isCommonPin(String pin) {
    const commonPins = [
      '1234',
      '0000',
      '1111',
      '2222',
      '3333',
      '4444',
      '5555',
      '6666',
      '7777',
      '8888',
      '9999',
      '1212',
      '7777',
      '2580',
      '1004',
    ];
    return commonPins.contains(pin);
  }

  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  void _onPinCompleted(String pin) {
    if (_currentStep == 0) {
      if (_validatePin(pin)) {
        setState(() {
          _enteredPin = pin;
          _currentStep = 1;
          _errorMessage = null;
          _currentPinValue = '';
        });
      } else {
        setState(() {
          _currentPinValue = '';
        });
        HapticFeedback.heavyImpact();
      }
    } else if (_currentStep == 1) {
      setState(() {
        _confirmPin = pin;
      });

      if (_enteredPin == _confirmPin) {
        _savePin();
      } else {
        setState(() {
          _errorMessage = 'PINs do not match';
          _currentStep = 0;
          _enteredPin = '';
          _confirmPin = '';
          _currentPinValue = '';
        });
        HapticFeedback.heavyImpact();
      }
    }
  }

  Future<void> _savePin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final hashedPin = _hashPin(_enteredPin);

      await _secureStorage.savePin(hashedPin);

      _enteredPin = '';
      _confirmPin = '';

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('PIN set successfully'),
            backgroundColor: SpendexColors.income,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
            ),
          ),
        );

        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to save PIN. Please try again.';
          _isLoading = false;
          _currentStep = 0;
          _enteredPin = '';
          _confirmPin = '';
          _currentPinValue = '';
        });
      }
    }
  }

  void _onBackPressed() {
    if (_currentStep == 1) {
      setState(() {
        _currentStep = 0;
        _enteredPin = '';
        _confirmPin = '';
        _errorMessage = null;
        _currentPinValue = '';
      });
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: _currentStep == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _currentStep == 1) {
          _onBackPressed();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Set PIN'),
          centerTitle: true,
          leading: _currentStep == 1
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _onBackPressed,
                )
              : null,
        ),
        body: SafeArea(
          child: Column(
            children: [
              _StepIndicator(
                currentStep: _currentStep,
                totalSteps: 2,
                isDark: isDark,
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(1, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    );
                  },
                  child: _currentStep == 0
                      ? _PinStepView(
                          key: const ValueKey(0),
                          icon: Iconsax.lock,
                          iconColor: SpendexColors.primary,
                          title: 'Create Your PIN',
                          subtitle: 'Enter a $_pinLength digit PIN to secure your app',
                          pinLength: _pinLength,
                          onCompleted: _onPinCompleted,
                          errorMessage: _errorMessage,
                          isDark: isDark,
                          resetTrigger: _currentPinValue,
                        )
                      : _PinStepView(
                          key: const ValueKey(1),
                          icon: Iconsax.shield_tick,
                          iconColor: SpendexColors.income,
                          title: 'Confirm Your PIN',
                          subtitle: 'Re-enter your PIN to confirm',
                          pinLength: _pinLength,
                          onCompleted: _onPinCompleted,
                          errorMessage: _errorMessage,
                          isDark: isDark,
                          isLoading: _isLoading,
                          resetTrigger: _currentPinValue,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({
    required this.currentStep,
    required this.totalSteps,
    required this.isDark,
  });

  final int currentStep;
  final int totalSteps;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(SpendexTheme.spacingLg),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: (currentStep + 1) / totalSteps,
                  backgroundColor: isDark
                      ? SpendexColors.darkBorder
                      : SpendexColors.lightBorder,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    SpendexColors.primary,
                  ),
                  minHeight: 4,
                  borderRadius: BorderRadius.circular(SpendexTheme.radiusFull),
                ),
              ),
            ],
          ),
          const SizedBox(height: SpendexTheme.spacingMd),
          Text(
            'Step ${currentStep + 1} of $totalSteps',
            style: SpendexTheme.bodyMedium.copyWith(
              color: isDark
                  ? SpendexColors.darkTextSecondary
                  : SpendexColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PinStepView extends StatefulWidget {
  const _PinStepView({
    required super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.pinLength,
    required this.onCompleted,
    required this.isDark,
    required this.resetTrigger,
    this.errorMessage,
    this.isLoading = false,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final int pinLength;
  final ValueChanged<String> onCompleted;
  final String? errorMessage;
  final bool isDark;
  final bool isLoading;
  final String resetTrigger;

  @override
  State<_PinStepView> createState() => _PinStepViewState();
}

class _PinStepViewState extends State<_PinStepView>
    with SingleTickerProviderStateMixin {
  late AnimationController _iconController;
  late Animation<double> _iconAnimation;
  final GlobalKey<State<StatefulWidget>> _pinInputKey = GlobalKey();
  String _previousResetTrigger = '';

  @override
  void initState() {
    super.initState();
    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _iconAnimation = CurvedAnimation(
      parent: _iconController,
      curve: Curves.elasticOut,
    );
    _iconController.forward();
    _previousResetTrigger = widget.resetTrigger;
  }

  @override
  void didUpdateWidget(_PinStepView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.resetTrigger != _previousResetTrigger) {
      _previousResetTrigger = widget.resetTrigger;
      final state = _pinInputKey.currentState;
      if (state != null && state.mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (state.mounted) {
            try {
              (state as dynamic).clear();
              if (widget.errorMessage != null) {
                (state as dynamic).showError();
              }
            } catch (_) {
              // Ignore if methods don't exist
            }
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _iconController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(SpendexTheme.spacing2xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: SpendexTheme.spacing4xl),
          ScaleTransition(
            scale: _iconAnimation,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: widget.iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.icon,
                size: 50,
                color: widget.iconColor,
              ),
            ),
          ),
          const SizedBox(height: SpendexTheme.spacing3xl),
          Text(
            widget.title,
            style: SpendexTheme.headlineMedium.copyWith(
              color: widget.isDark
                  ? SpendexColors.darkTextPrimary
                  : SpendexColors.lightTextPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: SpendexTheme.spacingMd),
          Text(
            widget.subtitle,
            style: SpendexTheme.bodyMedium.copyWith(
              color: widget.isDark
                  ? SpendexColors.darkTextSecondary
                  : SpendexColors.lightTextSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: SpendexTheme.spacing4xl),
          if (widget.isLoading)
            const CircularProgressIndicator()
          else
            PinInput(
              key: _pinInputKey,
              length: widget.pinLength,
              onCompleted: widget.onCompleted,
            ),
          const SizedBox(height: SpendexTheme.spacing2xl),
          if (widget.errorMessage != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: SpendexTheme.spacingLg,
                vertical: SpendexTheme.spacingMd,
              ),
              decoration: BoxDecoration(
                color: SpendexColors.expense.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
                border: Border.all(
                  color: SpendexColors.expense.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Iconsax.info_circle,
                    color: SpendexColors.expense,
                    size: 20,
                  ),
                  const SizedBox(width: SpendexTheme.spacingSm),
                  Flexible(
                    child: Text(
                      widget.errorMessage!,
                      style: SpendexTheme.bodyMedium.copyWith(
                        color: SpendexColors.expense,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
