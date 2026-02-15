import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../../core/config/environment.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/subscription_models.dart';

/// Callback type for payment success.
typedef PaymentSuccessCallback = void Function(PaymentSuccessResponse response);

/// Callback type for payment error.
typedef PaymentErrorCallback = void Function(PaymentFailureResponse response);

/// Callback type for external wallet selection.
typedef ExternalWalletCallback = void Function(ExternalWalletResponse response);

/// Service for handling Razorpay payments.
class RazorpayService {
  RazorpayService() {
    _razorpay = Razorpay()
      ..on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess)
      ..on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError)
      ..on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }
  late final Razorpay _razorpay;
  PaymentSuccessCallback? _onSuccess;
  PaymentErrorCallback? _onError;
  ExternalWalletCallback? _onExternalWallet;

  /// Starts a payment with Razorpay.
  void startPayment({
    required CheckoutResponse checkoutResponse,
    required String userEmail,
    required String userPhone,
    required String userName,
    PaymentSuccessCallback? onSuccess,
    PaymentErrorCallback? onError,
    ExternalWalletCallback? onExternalWallet,
  }) {
    _onSuccess = onSuccess;
    _onError = onError;
    _onExternalWallet = onExternalWallet;
    final options = <String, dynamic>{
      'key': EnvironmentConfig.razorpayKey,
      'amount': checkoutResponse.amountInPaise,
      'currency': checkoutResponse.currency,
      'name': 'Spendex',
      'description': checkoutResponse.description ?? 'Subscription Payment',
      'order_id': checkoutResponse.orderId,
      'prefill': {
        'email': userEmail,
        'contact': userPhone,
        'name': userName,
      },
      'theme': {'color': '#10B981'},
      'retry': {'enabled': true, 'max_count': 3},
      'remember_customer': true,
    };
    if (checkoutResponse.notes != null) {
      options['notes'] = checkoutResponse.notes;
    }
    try {
      _razorpay.open(options);
    } catch (e) {
      AppLogger.d('Razorpay open error: $e');
      _onError?.call(
        PaymentFailureResponse(
          Razorpay.UNKNOWN_ERROR,
          'Failed to open payment gateway: $e',
          null,
        ),
      );
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    AppLogger.d('Payment successful: ${response.paymentId}');
    _onSuccess?.call(response);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    AppLogger.d('Payment failed: ${response.code} - ${response.message}');
    _onError?.call(response);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    AppLogger.d('External wallet selected: ${response.walletName}');
    _onExternalWallet?.call(response);
  }

  void clearCallbacks() {
    _onSuccess = null;
    _onError = null;
    _onExternalWallet = null;
  }

  void dispose() {
    clearCallbacks();
    _razorpay.clear();
  }
}

/// Extension to convert payment response to verification request.
extension PaymentResponseExtension on PaymentSuccessResponse {
  PaymentVerificationRequest toVerificationRequest(String orderId) {
    return PaymentVerificationRequest(
      orderId: orderId,
      paymentId: paymentId ?? '',
      signature: signature ?? '',
    );
  }
}

/// Result of a payment attempt.
class PaymentResult {
  const PaymentResult({
    required this.isSuccess,
    this.paymentId,
    this.orderId,
    this.signature,
    this.errorMessage,
    this.errorCode,
  });
  factory PaymentResult.success(PaymentSuccessResponse response) {
    return PaymentResult(
      isSuccess: true,
      paymentId: response.paymentId,
      orderId: response.orderId,
      signature: response.signature,
    );
  }
  factory PaymentResult.failure(PaymentFailureResponse response) {
    return PaymentResult(
      isSuccess: false,
      errorMessage: response.message,
      errorCode: response.code,
    );
  }
  final bool isSuccess;
  final String? paymentId;
  final String? orderId;
  final String? signature;
  final String? errorMessage;
  final int? errorCode;
}
