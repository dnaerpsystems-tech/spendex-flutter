import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../app/theme.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/security/pin_service.dart';
import '../../../../core/security/security_provider.dart';
import '../widgets/pin_input.dart';

/// Set PIN Screen for configuring user's PIN authentication.
///
/// Features:
/// - 2-step PIN entry (create and confirm)
/// - PIN validation (no repeating/sequential/common PINs)
/// - Uses PinService from DI for secure PIN storage with salt
/// - Step indicator with progress bar
/// - Animated transitions between steps
/// - Error handling with haptic feedback
/// - Material 3 design with dark mode support
class SetPinScreen extends ConsumerStatefulWidget {
  const SetPinScreen({super.key});

  @override
  ConsumerState<SetPinScreen> createState() => _SetPinScreenState();
}

class _SetPinScreenState extends ConsumerState<SetPinScreen>
    with SingleTickerProviderStateMixin {
  // Get PinService from DI
  late final PinService _pinService;

  int _currentStep = 0;
  String _enteredPin = '';
  String _confirmPin = '';
  bool _isLoading = false;
  String? _errorMessage;
  String _currentPinValue = '';
  final int _pinLength = 4;

  @override
  void initState() {
    super.initState();
    _pinService = getIt<PinService>();
  }

  /// Validates the entered PIN against security requirements.
  ///
  /// Checks:
  /// - PIN length must be exactly [_pinLength] digits
  /// - Cannot be all same digits (e.g., 1111)
  /// - Cannot be sequential (e.g., 1234 or 4321)
  /// - Cannot be a common/weak PIN
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

  /// Checks if PIN contains all same digits.
  bool _isRepeating(String pin) {
    return pin.split('').toSet().length == 1;
  }

  /// Checks if PIN is a sequential number (ascending or descending).
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

  /// Checks if PIN is in the list of commonly used PINs.
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
      '2580',
      '1004',
      '4321',
      '1122',
      '0123',
      '9876',
    ];
    return commonPins.contains(pin);
  }

  /// Handles PIN completion for both steps.
  void _onPinCompleted(String pin) {
    if (_currentStep == 0) {
      // Step 1: Create PIN
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
      // Step 2: Confirm PIN
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

  /// Saves the PIN using PinService.
  ///
  /// The PinService handles:
  /// - Generating a secure salt
  /// - Hashing the PIN with SHA-256
  /// - Storing both hash and salt in secure storage
  Future<void> _savePin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Use PinService to set PIN (handles hashing with salt)
      await _pinService.setPin(_enteredPin);

      // Clear sensitive data
      _enteredPin = '';
      _confirmPin = '';

      // Refresh the PIN auth state provider
      ref.read(pinAuthStateProvider.notifier).refresh();

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

  /// Handles back navigation with proper step handling.
  void _onBackPressed() {
    if (_currentStep == 1) {
      // Go back to step 1
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
        if (didPop == false && _currentStep == 1) {
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

/// Step indicator widget showing progress through the PIN setup flow.
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

/// Individual PIN step view with icon, title, and PIN input.
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

          // Animated icon
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

          const SizedBox(height: SpendexTheme.spacing2xl),

          // Title
          Text(
            widget.title,
            style: SpendexTheme.headlineMedium.copyWith(
              fontSize: 24,
              color: widget.isDark
                  ? SpendexColors.darkTextPrimary
                  : SpendexColors.lightTextPrimary,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: SpendexTheme.spacingSm),

          // Subtitle
          Text(
            widget.subtitle,
            style: SpendexTheme.bodyMedium.copyWith(
              color: widget.isDark
                  ? SpendexColors.darkTextSecondary
                  : SpendexColors.lightTextSecondary,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: SpendexTheme.spacing3xl),

          // PIN input or loading indicator
          if (widget.isLoading)
            Column(
              children: [
                const SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: SpendexColors.primary,
                  ),
                ),
                const SizedBox(height: SpendexTheme.spacingLg),
                Text(
                  'Setting up your PIN...',
                  style: SpendexTheme.bodyMedium.copyWith(
                    color: widget.isDark
                        ? SpendexColors.darkTextSecondary
                        : SpendexColors.lightTextSecondary,
                  ),
                ),
              ],
            )
          else
            PinInput(
              key: _pinInputKey,
              length: widget.pinLength,
              onCompleted: widget.onCompleted,
              autoFocus: true,
            ),

          // Error message
          if (widget.errorMessage != null) ...[
            const SizedBox(height: SpendexTheme.spacingLg),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: SpendexTheme.spacingLg,
                vertical: SpendexTheme.spacingMd,
              ),
              decoration: BoxDecoration(
                color: SpendexColors.expense.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Iconsax.warning_2,
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
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: SpendexTheme.spacing3xl),

          // PIN requirements hint (only on step 1)
          if (widget.icon == Iconsax.lock) ...[
            _buildRequirementsHint(),
          ],
        ],
      ),
    );
  }

  Widget _buildRequirementsHint() {
    return Container(
      padding: const EdgeInsets.all(SpendexTheme.spacingLg),
      decoration: BoxDecoration(
        color: widget.isDark
            ? SpendexColors.darkSurface
            : SpendexColors.lightSurface,
        borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
        border: Border.all(
          color: widget.isDark
              ? SpendexColors.darkBorder
              : SpendexColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PIN Requirements:',
            style: SpendexTheme.titleMedium.copyWith(
              color: widget.isDark
                  ? SpendexColors.darkTextPrimary
                  : SpendexColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: SpendexTheme.spacingSm),
          _buildRequirementItem('Must be 4 digits'),
          _buildRequirementItem('No repeating digits (1111)'),
          _buildRequirementItem('No sequential numbers (1234)'),
          _buildRequirementItem('No common PINs'),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            Iconsax.tick_circle,
            size: 16,
            color: widget.isDark
                ? SpendexColors.darkTextSecondary
                : SpendexColors.lightTextSecondary,
          ),
          const SizedBox(width: SpendexTheme.spacingSm),
          Text(
            text,
            style: SpendexTheme.bodySmall.copyWith(
              color: widget.isDark
                  ? SpendexColors.darkTextSecondary
                  : SpendexColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
