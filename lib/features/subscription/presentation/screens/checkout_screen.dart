import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../app/theme.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../../shared/widgets/loading_state_widget.dart';
import '../../data/models/subscription_models.dart';
import '../providers/subscription_provider.dart';
import '../widgets/widgets.dart';

/// Checkout Screen
///
/// Handles the subscription checkout process:
/// - Displays selected plan summary
/// - Payment method selection
/// - Razorpay payment integration
/// - Payment verification
/// - Success/failure handling
class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  static const String routeName = 'checkout';
  static const String routePath = '/subscription/checkout';

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  PaymentMethodType _selectedPaymentType = PaymentMethodType.card;
  PaymentMethodModel? _selectedPaymentMethod;
  bool _isProcessing = false;
  bool _paymentSuccess = false;
  bool _paymentFailed = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPaymentMethods();
    });
  }

  /// Load saved payment methods
  Future<void> _loadPaymentMethods() async {
    await ref.read(subscriptionProvider.notifier).loadPaymentMethods();
    // Set default payment method if available
    final state = ref.read(subscriptionProvider);
    if (state.defaultPaymentMethod != null) {
      setState(() {
        _selectedPaymentMethod = state.defaultPaymentMethod;
        _selectedPaymentType = state.defaultPaymentMethod?.type ?? PaymentMethodType.card;
      });
    }
  }

  /// Handle payment method type change
  void _onPaymentTypeChanged(PaymentMethodType type) {
    setState(() {
      _selectedPaymentType = type;
      _selectedPaymentMethod = null;
    });
  }

  /// Handle saved payment method selection
  void _onPaymentMethodSelected(PaymentMethodModel method) {
    setState(() {
      _selectedPaymentMethod = method;
      _selectedPaymentType = method.type;
    });
  }

  /// Initiate checkout process
  Future<void> _initiateCheckout() async {
    final state = ref.read(subscriptionProvider);
    final selectedPlan = state.selectedPlan;

    if (selectedPlan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a plan first'),
          backgroundColor: SpendexColors.expense,
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
      _paymentFailed = false;
      _errorMessage = null;
    });

    try {
      // Create checkout session
      await ref.read(subscriptionProvider.notifier).createCheckout(
            planId: selectedPlan.id,
            billingCycle: state.selectedBillingCycle,
            paymentMethodType: _selectedPaymentType,
          );

      final checkoutState = ref.read(subscriptionProvider);

      if (checkoutState.checkoutSession != null) {
        // Handle payment based on type
        if (_selectedPaymentType == PaymentMethodType.upi) {
          // Navigate to UPI payment screen
          if (mounted) {
            context.push('/subscription/upi-payment');
          }
        } else {
          // Open Razorpay for card/netbanking
          await _openRazorpay(checkoutState.checkoutSession);
        }
      } else if (checkoutState.error != null) {
        setState(() {
          _paymentFailed = true;
          _errorMessage = checkoutState.error;
        });
      }
    } catch (e) {
      setState(() {
        _paymentFailed = true;
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  /// Open Razorpay checkout
  Future<void> _openRazorpay(CheckoutResponse? checkout) async {
    if (checkout == null) return;

    // In a real app, this would open the Razorpay SDK
    // For now, we'll simulate the callback
    _showPaymentSimulationDialog(checkout);
  }

  /// Show payment simulation dialog (for demo purposes)
  void _showPaymentSimulationDialog(CheckoutResponse checkout) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary =
        isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          'Payment Simulation',
          style: SpendexTheme.headlineSmall.copyWith(color: textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Amount: ₹${checkout.amountInRupees.toStringAsFixed(2)}',
              style: SpendexTheme.bodyMedium,
            ),
            Text(
              'Order ID: ${checkout.orderId}',
              style: SpendexTheme.bodySmall,
            ),
            const SizedBox(height: SpendexTheme.spacingLg),
            const Text('Select payment result:'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _handlePaymentFailure('Payment was cancelled');
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _handlePaymentFailure('Payment failed');
            },
            style: TextButton.styleFrom(
              foregroundColor: SpendexColors.expense,
            ),
            child: const Text('Fail'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _handlePaymentSuccess(
                checkout.orderId,
                'pay_${DateTime.now().millisecondsSinceEpoch}',
                'sig_simulated',
              );
            },
            child: const Text('Success'),
          ),
        ],
      ),
    );
  }

  /// Handle successful payment
  Future<void> _handlePaymentSuccess(
    String orderId,
    String paymentId,
    String signature,
  ) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      await ref.read(subscriptionProvider.notifier).verifyPayment(
            orderId: orderId,
            paymentId: paymentId,
            signature: signature,
          );

      final state = ref.read(subscriptionProvider);

      if (state.error == null) {
        setState(() {
          _paymentSuccess = true;
        });

        // Show success for 2 seconds then navigate
        await Future.delayed(const Duration(seconds: 2));

        if (mounted) {
          context.go('/subscription');
        }
      } else {
        setState(() {
          _paymentFailed = true;
          _errorMessage = state.error;
        });
      }
    } catch (e) {
      setState(() {
        _paymentFailed = true;
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  /// Handle payment failure
  void _handlePaymentFailure(String error) {
    setState(() {
      _paymentFailed = true;
      _errorMessage = error;
    });
  }

  /// Reset payment state and try again
  void _retryPayment() {
    setState(() {
      _paymentFailed = false;
      _paymentSuccess = false;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(subscriptionProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Listen for state changes
    ref.listen<SubscriptionState>(subscriptionProvider, (previous, next) {
      if (next.successMessage != null &&
          next.successMessage != previous?.successMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage ?? ''),
            backgroundColor: SpendexColors.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
        ref.read(subscriptionProvider.notifier).clearMessages();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        centerTitle: true,
        leading: _isProcessing || _paymentSuccess
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
    // No plan selected
    if (state.selectedPlan == null) {
      return ErrorStateWidget(
        message: 'No plan selected. Please select a plan first.',
        onRetry: () => context.go('/subscription/plans'),
      );
    }

    // Payment success state
    if (_paymentSuccess) {
      return _buildSuccessState(isDark);
    }

    // Payment failure state
    if (_paymentFailed) {
      return _buildFailureState(isDark);
    }

    // Processing state
    if (_isProcessing || state.isCheckingOut || state.isVerifyingPayment) {
      return _buildProcessingState(isDark);
    }

    // Normal checkout view
    return _buildCheckoutView(state, theme, isDark);
  }

  /// Build checkout view
  Widget _buildCheckoutView(
    SubscriptionState state,
    ThemeData theme,
    bool isDark,
  ) {
    final plan = state.selectedPlan;
    if (plan == null) return const SizedBox.shrink();

    final borderColor =
        isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder;
    final textPrimary =
        isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary;
    final textSecondary = isDark
        ? SpendexColors.darkTextSecondary
        : SpendexColors.lightTextSecondary;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(SpendexTheme.spacingLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Plan summary
                CheckoutSummaryCard(
                  plan: plan,
                  billingCycle: state.selectedBillingCycle,
                ),

                const SizedBox(height: SpendexTheme.spacing2xl),

                // Payment method section
                Text(
                  'Payment Method',
                  style: SpendexTheme.headlineSmall.copyWith(
                    color: textPrimary,
                  ),
                ),

                const SizedBox(height: SpendexTheme.spacingMd),

                // Payment type selector
                _buildPaymentTypeSelector(isDark),

                const SizedBox(height: SpendexTheme.spacingLg),

                // Saved payment methods or add new
                if (_selectedPaymentType == PaymentMethodType.card ||
                    _selectedPaymentType == PaymentMethodType.upi)
                  _buildPaymentMethodsSection(state, isDark),

                const SizedBox(height: SpendexTheme.spacing2xl),

                // Security badges
                _buildSecuritySection(textSecondary),
              ],
            ),
          ),
        ),

        // Pay button
        _buildPayButton(state, borderColor),
      ],
    );
  }

  /// Build payment type selector
  Widget _buildPaymentTypeSelector(bool isDark) {
    final borderColor =
        isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder;
    final cardColor =
        isDark ? SpendexColors.darkCard : SpendexColors.lightCard;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          _buildPaymentTypeOption(
            type: PaymentMethodType.card,
            icon: Iconsax.card,
            label: 'Credit / Debit Card',
            subtitle: 'Visa, Mastercard, RuPay',
            isDark: isDark,
          ),
          Divider(height: 1, color: borderColor),
          _buildPaymentTypeOption(
            type: PaymentMethodType.upi,
            icon: Iconsax.scan_barcode,
            label: 'UPI',
            subtitle: 'GPay, PhonePe, Paytm',
            isDark: isDark,
          ),
          Divider(height: 1, color: borderColor),
          _buildPaymentTypeOption(
            type: PaymentMethodType.netbanking,
            icon: Iconsax.bank,
            label: 'Net Banking',
            subtitle: 'All major banks',
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  /// Build payment type option
  Widget _buildPaymentTypeOption({
    required PaymentMethodType type,
    required IconData icon,
    required String label,
    required String subtitle,
    required bool isDark,
  }) {
    final isSelected = _selectedPaymentType == type;
    final textPrimary =
        isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary;
    final textSecondary = isDark
        ? SpendexColors.darkTextSecondary
        : SpendexColors.lightTextSecondary;

    return InkWell(
      onTap: () => _onPaymentTypeChanged(type),
      child: Padding(
        padding: const EdgeInsets.all(SpendexTheme.spacingLg),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(SpendexTheme.spacingMd),
              decoration: BoxDecoration(
                color: isSelected
                    ? SpendexColors.primary.withValues(alpha: 0.1)
                    : textSecondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
              ),
              child: Icon(
                icon,
                color: isSelected ? SpendexColors.primary : textSecondary,
                size: 24,
              ),
            ),
            const SizedBox(width: SpendexTheme.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: SpendexTheme.titleMedium.copyWith(
                      color: textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: SpendexTheme.bodySmall.copyWith(
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? SpendexColors.primary : textSecondary,
                  width: 2,
                ),
                color: isSelected ? SpendexColors.primary : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  /// Build saved payment methods section
  Widget _buildPaymentMethodsSection(SubscriptionState state, bool isDark) {
    final textPrimary =
        isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary;
    final textSecondary = isDark
        ? SpendexColors.darkTextSecondary
        : SpendexColors.lightTextSecondary;

    // Filter payment methods by selected type
    final filteredMethods = state.paymentMethods
        .where((m) => m.type == _selectedPaymentType)
        .toList();

    if (state.isLoadingPaymentMethods) {
      return Column(
        children: List.generate(
          2,
          (_) => const Padding(
            padding: EdgeInsets.only(bottom: SpendexTheme.spacingSm),
            child: PaymentMethodCardSkeleton(),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (filteredMethods.isNotEmpty) ...[
          Text(
            'Saved ${_selectedPaymentType.label}',
            style: SpendexTheme.labelMedium.copyWith(
              color: textSecondary,
            ),
          ),
          const SizedBox(height: SpendexTheme.spacingSm),
          ...filteredMethods.map(
            (method) => Padding(
              padding: const EdgeInsets.only(bottom: SpendexTheme.spacingSm),
              child: PaymentMethodCard(
                paymentMethod: method,
                isSelected: _selectedPaymentMethod?.id == method.id,
                onTap: () => _onPaymentMethodSelected(method),
              ),
            ),
          ),
          const SizedBox(height: SpendexTheme.spacingSm),
        ],
        // Add new payment method option
        _buildAddNewPaymentMethod(textPrimary, textSecondary, isDark),
      ],
    );
  }

  /// Build add new payment method option
  Widget _buildAddNewPaymentMethod(
    Color textPrimary,
    Color textSecondary,
    bool isDark,
  ) {
    final borderColor =
        isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder;
    final cardColor =
        isDark ? SpendexColors.darkCard : SpendexColors.lightCard;

    final isSelected = _selectedPaymentMethod == null;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = null;
        });
      },
      borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(SpendexTheme.spacingLg),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
          border: Border.all(
            color: isSelected ? SpendexColors.primary : borderColor,
            width: isSelected ? 2 : 1,
          ),
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
                Iconsax.add_circle,
                color: SpendexColors.primary,
              ),
            ),
            const SizedBox(width: SpendexTheme.spacingMd),
            Expanded(
              child: Text(
                'Add new ${_selectedPaymentType.label.toLowerCase()}',
                style: SpendexTheme.titleMedium.copyWith(
                  color: SpendexColors.primary,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Iconsax.tick_circle5,
                color: SpendexColors.primary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  /// Build security section
  Widget _buildSecuritySection(Color textColor) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.shield_tick,
              size: 18,
              color: textColor,
            ),
            const SizedBox(width: SpendexTheme.spacingSm),
            Text(
              'Secured by Razorpay',
              style: SpendexTheme.labelMedium.copyWith(
                color: textColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: SpendexTheme.spacingSm),
        Text(
          '256-bit SSL encryption',
          style: SpendexTheme.bodySmall.copyWith(
            color: textColor,
          ),
        ),
      ],
    );
  }

  /// Build pay button
  Widget _buildPayButton(SubscriptionState state, Color borderColor) {
    final plan = state.selectedPlan;
    final amount = plan?.priceInRupees ?? 0;

    return Container(
      padding: const EdgeInsets.all(SpendexTheme.spacingLg),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: borderColor)),
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _initiateCheckout,
            style: ElevatedButton.styleFrom(
              backgroundColor: SpendexColors.primary,
              padding: const EdgeInsets.symmetric(
                vertical: SpendexTheme.spacingMd,
              ),
            ),
            child: Text(
              'Pay ₹${amount.toStringAsFixed(0)}',
              style: SpendexTheme.titleMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build processing state
  Widget _buildProcessingState(bool isDark) {
    return const LoadingStateWidget(
      message: 'Processing payment...',
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: SpendexColors.primary,
                  padding: const EdgeInsets.symmetric(
                    vertical: SpendexTheme.spacingMd,
                  ),
                ),
                child: const Text('Try Again'),
              ),
            ),
            const SizedBox(height: SpendexTheme.spacingMd),
            TextButton(
              onPressed: () => context.pop(),
              child: Text(
                'Go Back',
                style: TextStyle(color: textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
