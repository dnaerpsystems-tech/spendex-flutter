import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../../shared/widgets/loading_state_widget.dart';
import '../../data/models/subscription_models.dart';
import '../providers/subscription_provider.dart';

/// UPI Payment Screen
///
/// Handles UPI payment flow:
/// - Enter UPI ID with validation
/// - Display QR code for scanning
/// - Timer for payment verification
/// - Auto-polling for payment status
/// - Manual "I've paid" button
/// - UPI apps picker intent
class UpiPaymentScreen extends ConsumerStatefulWidget {
  const UpiPaymentScreen({super.key});

  static const String routeName = 'upi-payment';
  static const String routePath = '/subscription/upi-payment';

  @override
  ConsumerState<UpiPaymentScreen> createState() => _UpiPaymentScreenState();
}

class _UpiPaymentScreenState extends ConsumerState<UpiPaymentScreen> {
  final TextEditingController _upiIdController = TextEditingController();
  final FocusNode _upiIdFocusNode = FocusNode();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Timer? _pollingTimer;
  Timer? _countdownTimer;
  int _remainingSeconds = 300; // 5 minutes timeout
  bool _isPolling = false;
  bool _upiSessionCreated = false;
  bool _paymentSuccess = false;
  bool _paymentFailed = false;
  String? _errorMessage;

  // UPI ID validation regex
  static final RegExp _upiIdRegex = RegExp(r'^[\w.-]+@[\w.-]+$');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkExistingSession();
    });
  }

  @override
  void dispose() {
    _upiIdController.dispose();
    _upiIdFocusNode.dispose();
    _pollingTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  /// Check if there's an existing UPI session
  void _checkExistingSession() {
    final state = ref.read(subscriptionProvider);
    if (state.upiSession != null) {
      setState(() {
        _upiSessionCreated = true;
      });
      _startPolling();
      _startCountdown();
    }
  }

  /// Validate UPI ID
  String? _validateUpiId(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your UPI ID';
    }
    if (!_upiIdRegex.hasMatch(value)) {
      return 'Please enter a valid UPI ID (e.g., name@bank)';
    }
    return null;
  }

  /// Create UPI payment session
  Future<void> _createUpiSession() async {
    if (!_formKey.currentState!.validate()) return;

    final state = ref.read(subscriptionProvider);
    if (state.checkoutSession == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No active checkout session'),
          backgroundColor: SpendexColors.expense,
        ),
      );
      return;
    }

    try {
      await ref.read(subscriptionProvider.notifier).createUpiPayment(
            orderId: state.checkoutSession?.orderId ?? '',
            vpa: _upiIdController.text.trim(),
          );

      final newState = ref.read(subscriptionProvider);
      if (newState.upiSession != null) {
        setState(() {
          _upiSessionCreated = true;
        });
        _startPolling();
        _startCountdown();
      } else if (newState.error != null) {
        setState(() {
          _errorMessage = newState.error;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  /// Start polling for payment status
  void _startPolling() {
    _pollingTimer?.cancel();
    _isPolling = true;

    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }

      await _checkPaymentStatus();
    });
  }

  /// Start countdown timer
  void _startCountdown() {
    _countdownTimer?.cancel();
    _remainingSeconds = 300;

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _remainingSeconds--;
      });

      if (_remainingSeconds <= 0) {
        timer.cancel();
        _handleTimeout();
      }
    });
  }

  /// Check payment status
  Future<void> _checkPaymentStatus() async {
    final state = ref.read(subscriptionProvider);
    if (state.checkoutSession == null) return;

    try {
      final status = await ref
          .read(subscriptionProvider.notifier)
          .checkPaymentStatus(state.checkoutSession?.orderId ?? '');

      if (status == 'SUCCESS' || status == 'CAPTURED') {
        _handlePaymentSuccess();
      } else if (status == 'FAILED') {
        _handlePaymentFailure('Payment failed');
      }
    } catch (e) {
      // Continue polling on error
    }
  }

  /// Handle payment success
  void _handlePaymentSuccess() {
    _pollingTimer?.cancel();
    _countdownTimer?.cancel();

    setState(() {
      _paymentSuccess = true;
      _isPolling = false;
    });

    // Navigate to subscription screen after delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        context.go('/subscription');
      }
    });
  }

  /// Handle payment failure
  void _handlePaymentFailure(String error) {
    _pollingTimer?.cancel();
    _countdownTimer?.cancel();

    setState(() {
      _paymentFailed = true;
      _errorMessage = error;
      _isPolling = false;
    });
  }

  /// Handle timeout
  void _handleTimeout() {
    _pollingTimer?.cancel();

    setState(() {
      _paymentFailed = true;
      _errorMessage = 'Payment timeout. Please try again.';
      _isPolling = false;
    });
  }

  /// Manual check payment
  Future<void> _manualCheckPayment() async {
    setState(() {
      _isPolling = true;
    });

    await _checkPaymentStatus();

    if (!_paymentSuccess && !_paymentFailed && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment not received yet. Please complete the payment in your UPI app.'),
          backgroundColor: SpendexColors.warning,
        ),
      );
    }

    setState(() {
      _isPolling = false;
    });
  }

  /// Open UPI app with intent
  Future<void> _openUpiApp() async {
    final state = ref.read(subscriptionProvider);
    final intentUrl = state.upiSession?.intentUrl;

    if (intentUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('UPI intent not available'),
          backgroundColor: SpendexColors.expense,
        ),
      );
      return;
    }

    try {
      final uri = Uri.parse(intentUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No UPI app found'),
              backgroundColor: SpendexColors.expense,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: SpendexColors.expense,
          ),
        );
      }
    }
  }

  /// Retry payment
  void _retryPayment() {
    setState(() {
      _paymentFailed = false;
      _paymentSuccess = false;
      _upiSessionCreated = false;
      _errorMessage = null;
      _remainingSeconds = 300;
    });
    _upiIdController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(subscriptionProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pay with UPI'),
        centerTitle: true,
        leading: _isPolling || _paymentSuccess
            ? null
            : IconButton(
                icon: const Icon(Iconsax.arrow_left),
                onPressed: () => context.pop(),
              ),
      ),
      body: _buildBody(state, theme, isDark),
    );
  }

  Widget _buildBody(SubscriptionState state, ThemeData theme, bool isDark) {
    // No checkout session
    if (state.checkoutSession == null) {
      return ErrorStateWidget(
        message: 'No active checkout session',
        onRetry: () => context.go('/subscription/checkout'),
      );
    }

    // Payment success
    if (_paymentSuccess) {
      return _buildSuccessState(isDark);
    }

    // Payment failure
    if (_paymentFailed) {
      return _buildFailureState(isDark);
    }

    // Creating UPI session
    if (state.isCheckingOut && !_upiSessionCreated) {
      return const LoadingStateWidget(
        message: 'Creating UPI payment...',
      );
    }

    // UPI session created - show QR/waiting
    if (_upiSessionCreated && state.upiSession != null) {
      return _buildWaitingState(state, isDark);
    }

    // Enter UPI ID form
    return _buildUpiIdForm(state, isDark);
  }

  /// Build UPI ID form
  Widget _buildUpiIdForm(SubscriptionState state, bool isDark) {
    final checkout = state.checkoutSession;
    final borderColor =
        isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder;
    final cardColor =
        isDark ? SpendexColors.darkCard : SpendexColors.lightCard;
    final textPrimary =
        isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary;
    final textSecondary = isDark
        ? SpendexColors.darkTextSecondary
        : SpendexColors.lightTextSecondary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(SpendexTheme.spacingLg),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Order summary
            Container(
              padding: const EdgeInsets.all(SpendexTheme.spacingLg),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(SpendexTheme.spacingMd),
                    decoration: BoxDecoration(
                      color: SpendexColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
                    ),
                    child: const Icon(
                      Iconsax.money_send,
                      color: SpendexColors.primary,
                    ),
                  ),
                  const SizedBox(width: SpendexTheme.spacingMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Amount to Pay',
                          style: SpendexTheme.bodySmall.copyWith(
                            color: textSecondary,
                          ),
                        ),
                        Text(
                          '₹${checkout?.amountInRupees.toStringAsFixed(2) ?? '0.00'}',
                          style: SpendexTheme.headlineMedium.copyWith(
                            color: textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: SpendexTheme.spacing2xl),

            // UPI ID input section
            Text(
              'Enter UPI ID',
              style: SpendexTheme.headlineSmall.copyWith(
                color: textPrimary,
              ),
            ),
            const SizedBox(height: SpendexTheme.spacingSm),
            Text(
              'Enter your UPI ID to receive a payment request',
              style: SpendexTheme.bodySmall.copyWith(
                color: textSecondary,
              ),
            ),

            const SizedBox(height: SpendexTheme.spacingLg),

            // UPI ID text field
            TextFormField(
              controller: _upiIdController,
              focusNode: _upiIdFocusNode,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              validator: _validateUpiId,
              decoration: InputDecoration(
                hintText: 'name@bank',
                prefixIcon: const Icon(Iconsax.scan_barcode),
                suffixIcon: IconButton(
                  icon: const Icon(Iconsax.close_circle),
                  onPressed: () => _upiIdController.clear(),
                ),
              ),
              onFieldSubmitted: (_) => _createUpiSession(),
            ),

            const SizedBox(height: SpendexTheme.spacingLg),

            // Pay button
            ElevatedButton(
              onPressed: _createUpiSession,
              child: const Text('Continue'),
            ),

            const SizedBox(height: SpendexTheme.spacing3xl),

            // OR divider
            Row(
              children: [
                Expanded(child: Divider(color: borderColor)),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SpendexTheme.spacingMd,
                  ),
                  child: Text(
                    'OR',
                    style: SpendexTheme.labelMedium.copyWith(
                      color: textSecondary,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: borderColor)),
              ],
            ),

            const SizedBox(height: SpendexTheme.spacing2xl),

            // Open UPI app button
            OutlinedButton.icon(
              onPressed: _openUpiApp,
              icon: const Icon(Iconsax.mobile),
              label: const Text('Open UPI App'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: SpendexTheme.spacingMd,
                ),
              ),
            ),

            const SizedBox(height: SpendexTheme.spacing2xl),

            // UPI apps list
            _buildUpiAppsGrid(textSecondary),
          ],
        ),
      ),
    );
  }

  /// Build UPI apps grid
  Widget _buildUpiAppsGrid(Color textColor) {
    final apps = [
      {'name': 'Google Pay', 'icon': Iconsax.google},
      {'name': 'PhonePe', 'icon': Iconsax.mobile},
      {'name': 'Paytm', 'icon': Iconsax.wallet_3},
      {'name': 'BHIM', 'icon': Iconsax.bank},
    ];

    return Column(
      children: [
        Text(
          'Supported UPI Apps',
          style: SpendexTheme.labelMedium.copyWith(
            color: textColor,
          ),
        ),
        const SizedBox(height: SpendexTheme.spacingMd),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: apps.map((app) {
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(SpendexTheme.spacingMd),
                  decoration: BoxDecoration(
                    color: textColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
                  ),
                  child: Icon(
                    app['icon'] as IconData,
                    color: textColor,
                    size: 24,
                  ),
                ),
                const SizedBox(height: SpendexTheme.spacingXs),
                Text(
                  app['name'] as String,
                  style: SpendexTheme.labelSmall.copyWith(
                    color: textColor,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Build waiting state with QR code
  Widget _buildWaitingState(SubscriptionState state, bool isDark) {
    final upiSession = state.upiSession;
    final borderColor =
        isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder;
    final cardColor =
        isDark ? SpendexColors.darkCard : SpendexColors.lightCard;
    final textPrimary =
        isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary;
    final textSecondary = isDark
        ? SpendexColors.darkTextSecondary
        : SpendexColors.lightTextSecondary;

    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(SpendexTheme.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timer
          Container(
            padding: const EdgeInsets.all(SpendexTheme.spacingLg),
            decoration: BoxDecoration(
              color: SpendexColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Iconsax.timer_1,
                  color: SpendexColors.warning,
                ),
                const SizedBox(width: SpendexTheme.spacingSm),
                Text(
                  'Complete payment in ${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                  style: SpendexTheme.titleMedium.copyWith(
                    color: SpendexColors.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: SpendexTheme.spacing2xl),

          // QR Code section
          if (upiSession?.qrCode != null) ...[
            Text(
              'Scan QR Code',
              textAlign: TextAlign.center,
              style: SpendexTheme.headlineSmall.copyWith(
                color: textPrimary,
              ),
            ),
            const SizedBox(height: SpendexTheme.spacingMd),
            Container(
              padding: const EdgeInsets.all(SpendexTheme.spacingLg),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
                border: Border.all(color: borderColor),
              ),
              child: Center(
                child: Image.memory(
                  base64Decode(upiSession?.qrCode ?? ''),
                  width: 200,
                  height: 200,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 200,
                    height: 200,
                    color: Colors.grey[200],
                    child: const Icon(
                      Iconsax.scan_barcode,
                      size: 64,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: SpendexTheme.spacingMd),
            Text(
              'Open any UPI app and scan this QR code',
              textAlign: TextAlign.center,
              style: SpendexTheme.bodySmall.copyWith(
                color: textSecondary,
              ),
            ),
          ],

          const SizedBox(height: SpendexTheme.spacing2xl),

          // UPI ID info
          Container(
            padding: const EdgeInsets.all(SpendexTheme.spacingLg),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pay to UPI ID',
                      style: SpendexTheme.bodySmall.copyWith(
                        color: textSecondary,
                      ),
                    ),
                    Text(
                      upiSession?.vpa ?? '',
                      style: SpendexTheme.titleMedium.copyWith(
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: SpendexTheme.spacingMd),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Amount',
                      style: SpendexTheme.bodySmall.copyWith(
                        color: textSecondary,
                      ),
                    ),
                    Text(
                      '₹${state.checkoutSession?.amountInRupees.toStringAsFixed(2) ?? '0.00'}',
                      style: SpendexTheme.titleMedium.copyWith(
                        color: SpendexColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: SpendexTheme.spacing2xl),

          // Manual check button
          ElevatedButton.icon(
            onPressed: _isPolling ? null : _manualCheckPayment,
            icon: _isPolling
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Iconsax.refresh),
            label: Text(_isPolling ? 'Checking...' : 'I\'ve Made the Payment'),
          ),

          const SizedBox(height: SpendexTheme.spacingMd),

          // Open UPI app button
          OutlinedButton.icon(
            onPressed: _openUpiApp,
            icon: const Icon(Iconsax.mobile),
            label: const Text('Open UPI App'),
          ),

          const SizedBox(height: SpendexTheme.spacing2xl),

          // Info text
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Iconsax.info_circle,
                size: 16,
                color: textSecondary,
              ),
              const SizedBox(width: SpendexTheme.spacingXs),
              Text(
                'We\'re checking for your payment automatically',
                style: SpendexTheme.bodySmall.copyWith(
                  color: textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build success state
  Widget _buildSuccessState(bool isDark) {
    final textPrimary =
        isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary;
    final textSecondary = isDark
        ? SpendexColors.darkTextSecondary
        : SpendexColors.lightTextSecondary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SpendexTheme.spacing3xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(SpendexTheme.spacing2xl),
              decoration: BoxDecoration(
                color: SpendexColors.income.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Iconsax.tick_circle5,
                size: 64,
                color: SpendexColors.income,
              ),
            ),
            const SizedBox(height: SpendexTheme.spacing2xl),
            Text(
              'Payment Successful',
              style: SpendexTheme.headlineMedium.copyWith(
                color: textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: SpendexTheme.spacingSm),
            Text(
              'Your subscription has been activated',
              textAlign: TextAlign.center,
              style: SpendexTheme.bodyMedium.copyWith(
                color: textSecondary,
              ),
            ),
            const SizedBox(height: SpendexTheme.spacingLg),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(SpendexColors.primary),
            ),
            const SizedBox(height: SpendexTheme.spacingSm),
            Text(
              'Redirecting...',
              style: SpendexTheme.bodySmall.copyWith(
                color: textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build failure state
  Widget _buildFailureState(bool isDark) {
    final textPrimary =
        isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary;
    final textSecondary = isDark
        ? SpendexColors.darkTextSecondary
        : SpendexColors.lightTextSecondary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SpendexTheme.spacing3xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(SpendexTheme.spacing2xl),
              decoration: BoxDecoration(
                color: SpendexColors.expense.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Iconsax.close_circle5,
                size: 64,
                color: SpendexColors.expense,
              ),
            ),
            const SizedBox(height: SpendexTheme.spacing2xl),
            Text(
              'Payment Failed',
              style: SpendexTheme.headlineMedium.copyWith(
                color: textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: SpendexTheme.spacingSm),
            Text(
              _errorMessage ?? 'Something went wrong with your payment',
              textAlign: TextAlign.center,
              style: SpendexTheme.bodyMedium.copyWith(
                color: textSecondary,
              ),
            ),
            const SizedBox(height: SpendexTheme.spacing2xl),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _retryPayment,
                child: const Text('Try Again'),
              ),
            ),
            const SizedBox(height: SpendexTheme.spacingMd),
            TextButton(
              onPressed: () => context.go('/subscription/checkout'),
              child: const Text('Choose Different Payment Method'),
            ),
          ],
        ),
      ),
    );
  }
}
