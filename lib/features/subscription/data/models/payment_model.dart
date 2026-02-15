import 'package:equatable/equatable.dart';

/// Payment Method Type
///
/// Supported payment method types for subscriptions.
enum PaymentMethodType {
  card('CARD', 'Card'),
  upi('UPI', 'UPI'),
  netBanking('NETBANKING', 'Net Banking');

  const PaymentMethodType(this.value, this.label);
  final String value;
  final String label;
}

/// Card Brand
///
/// Supported card brands.
enum CardBrand {
  visa('VISA', 'Visa'),
  mastercard('MASTERCARD', 'Mastercard'),
  rupay('RUPAY', 'RuPay'),
  amex('AMEX', 'American Express'),
  discover('DISCOVER', 'Discover'),
  diners('DINERS', 'Diners Club'),
  unknown('UNKNOWN', 'Unknown');

  const CardBrand(this.value, this.label);
  final String value;
  final String label;
}

/// Payment Method Model
///
/// Represents a saved payment method for recurring payments.
class PaymentMethodModel extends Equatable {
  const PaymentMethodModel({
    required this.id,
    required this.type,
    required this.isDefault,
    required this.createdAt,
    this.last4,
    this.brand,
    this.expiryMonth,
    this.expiryYear,
    this.vpa,
    this.bankName,
  });

  /// Creates a [PaymentMethodModel] instance from JSON.
  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: json['id'] as String,
      type: PaymentMethodType.values.firstWhere(
        (e) => e.value == json['type'],
        orElse: () => PaymentMethodType.card,
      ),
      isDefault: json['isDefault'] as bool? ?? false,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : DateTime.now(),
      last4: json['last4'] as String?,
      brand: json['brand'] != null
          ? CardBrand.values.firstWhere(
              (e) => e.value == json['brand'],
              orElse: () => CardBrand.unknown,
            )
          : null,
      expiryMonth: json['expiryMonth'] as int?,
      expiryYear: json['expiryYear'] as int?,
      vpa: json['vpa'] as String?,
      bankName: json['bankName'] as String?,
    );
  }

  /// Unique identifier for the payment method
  final String id;

  /// Type of payment method
  final PaymentMethodType type;

  /// Whether this is the default payment method
  final bool isDefault;

  /// When the payment method was added
  final DateTime createdAt;

  // Card-specific fields
  /// Last 4 digits of the card (for cards only)
  final String? last4;

  /// Card brand (for cards only)
  final CardBrand? brand;

  /// Expiry month (1-12, for cards only)
  final int? expiryMonth;

  /// Expiry year (e.g., 2025, for cards only)
  final int? expiryYear;

  // UPI-specific fields
  /// UPI Virtual Payment Address (for UPI only)
  final String? vpa;

  // Net Banking specific fields
  /// Bank name (for net banking only)
  final String? bankName;

  /// Converts the model to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.value,
      'isDefault': isDefault,
      'createdAt': createdAt.toIso8601String(),
      if (last4 != null) 'last4': last4,
      if (brand != null) 'brand': brand!.value,
      if (expiryMonth != null) 'expiryMonth': expiryMonth,
      if (expiryYear != null) 'expiryYear': expiryYear,
      if (vpa != null) 'vpa': vpa,
      if (bankName != null) 'bankName': bankName,
    };
  }

  /// Creates a copy with modified fields.
  PaymentMethodModel copyWith({
    String? id,
    PaymentMethodType? type,
    bool? isDefault,
    DateTime? createdAt,
    String? last4,
    CardBrand? brand,
    int? expiryMonth,
    int? expiryYear,
    String? vpa,
    String? bankName,
  }) {
    return PaymentMethodModel(
      id: id ?? this.id,
      type: type ?? this.type,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      last4: last4 ?? this.last4,
      brand: brand ?? this.brand,
      expiryMonth: expiryMonth ?? this.expiryMonth,
      expiryYear: expiryYear ?? this.expiryYear,
      vpa: vpa ?? this.vpa,
      bankName: bankName ?? this.bankName,
    );
  }

  /// Check if this is a card payment method
  bool get isCard => type == PaymentMethodType.card;

  /// Check if this is a UPI payment method
  bool get isUpi => type == PaymentMethodType.upi;

  /// Check if this is a net banking payment method
  bool get isNetbanking => type == PaymentMethodType.netBanking;

  /// Check if card is expired
  bool get isExpired {
    if (!isCard || expiryMonth == null || expiryYear == null) {
      return false;
    }
    final now = DateTime.now();
    final expiry = DateTime(expiryYear!, expiryMonth! + 1, 0);
    return now.isAfter(expiry);
  }

  /// Get display name for the payment method
  String get displayName {
    switch (type) {
      case PaymentMethodType.card:
        return '${brand?.label ?? 'Card'} •••• ${last4 ?? '****'}';
      case PaymentMethodType.upi:
        return vpa ?? 'UPI';
      case PaymentMethodType.netBanking:
        return bankName ?? 'Net Banking';
    }
  }

  /// Get card brand (alias for brand field)
  CardBrand? get cardBrand => brand;

  /// Get UPI VPA (alias for vpa field)
  String? get upiVpa => vpa;

  /// Get expiry string for cards (MM/YY)
  String? get expiryString {
    if (expiryMonth == null || expiryYear == null) {
      return null;
    }
    final month = expiryMonth.toString().padLeft(2, '0');
    final year = (expiryYear! % 100).toString().padLeft(2, '0');
    return '$month/$year';
  }

  @override
  List<Object?> get props => [
        id,
        type,
        isDefault,
        createdAt,
        last4,
        brand,
        expiryMonth,
        expiryYear,
        vpa,
        bankName,
      ];
}

/// Checkout Request
///
/// Request payload for initiating a subscription checkout.
class CheckoutRequest {
  const CheckoutRequest({
    required this.planId,
    required this.billingCycle,
    required this.paymentMethodType,
    this.successUrl,
    this.cancelUrl,
    this.couponCode,
  });

  /// ID of the plan to subscribe to
  final String planId;

  /// Selected billing cycle
  final String billingCycle;

  /// Type of payment method to use
  final String paymentMethodType;

  /// URL to redirect to on successful payment
  final String? successUrl;

  /// URL to redirect to on cancelled payment
  final String? cancelUrl;

  /// Optional coupon code for discount
  final String? couponCode;

  Map<String, dynamic> toJson() {
    return {
      'planId': planId,
      'billingCycle': billingCycle,
      'paymentMethodType': paymentMethodType,
      if (successUrl != null) 'successUrl': successUrl,
      if (cancelUrl != null) 'cancelUrl': cancelUrl,
      if (couponCode != null) 'couponCode': couponCode,
    };
  }
}

/// Checkout Response
///
/// Response from the checkout initiation containing payment details.
class CheckoutResponse extends Equatable {
  const CheckoutResponse({
    required this.checkoutUrl,
    required this.orderId,
    required this.amount,
    this.currency = 'INR',
    this.razorpayKeyId,
    this.notes,
  });

  /// Creates a [CheckoutResponse] instance from JSON.
  factory CheckoutResponse.fromJson(Map<String, dynamic> json) {
    return CheckoutResponse(
      checkoutUrl: json['checkoutUrl'] as String? ?? '',
      orderId: json['orderId'] as String,
      amount: json['amount'] as int,
      currency: json['currency'] as String? ?? 'INR',
      razorpayKeyId: json['razorpayKeyId'] as String?,
      notes: json['notes'] as Map<String, dynamic>?,
    );
  }

  /// URL to redirect the user for payment
  final String checkoutUrl;

  /// Unique order ID for payment tracking
  final String orderId;

  /// Amount to be charged in paise
  final int amount;

  /// Currency code
  final String currency;

  /// Razorpay Key ID (for Razorpay integration)
  final String? razorpayKeyId;

  /// Additional notes/metadata
  final Map<String, dynamic>? notes;

  /// Get amount in rupees
  double get amountInRupees => amount / 100;

  /// Get amount in paise (same as amount field)
  int get amountInPaise => amount;

  /// Get description from notes or default
  String? get description => notes?['description'] as String?;

  Map<String, dynamic> toJson() {
    return {
      'checkoutUrl': checkoutUrl,
      'orderId': orderId,
      'amount': amount,
      'currency': currency,
      if (razorpayKeyId != null) 'razorpayKeyId': razorpayKeyId,
      if (notes != null) 'notes': notes,
    };
  }

  @override
  List<Object?> get props => [
        checkoutUrl,
        orderId,
        amount,
        currency,
        razorpayKeyId,
        notes,
      ];
}

/// Payment Verification Request
///
/// Request payload for verifying a completed Razorpay payment.
class PaymentVerificationRequest {
  const PaymentVerificationRequest({
    required this.orderId,
    required this.paymentId,
    required this.signature,
  });

  /// Razorpay order ID
  final String orderId;

  /// Razorpay payment ID
  final String paymentId;

  /// Razorpay signature for verification
  final String signature;

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'paymentId': paymentId,
      'signature': signature,
    };
  }
}

/// UPI Create Request
///
/// Request payload for creating a UPI payment intent.
class UpiCreateRequest {
  const UpiCreateRequest({
    required this.orderId,
    required this.vpa,
  });

  /// Order ID to pay for
  final String orderId;

  /// UPI Virtual Payment Address
  final String vpa;

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'vpa': vpa,
    };
  }
}

/// UPI Create Response
///
/// Response from creating a UPI payment intent.
class UpiCreateResponse extends Equatable {
  const UpiCreateResponse({
    required this.vpa,
    required this.transactionId,
    this.qrCode,
    this.intentUrl,
    this.expiresAt,
  });

  /// Creates a [UpiCreateResponse] instance from JSON.
  factory UpiCreateResponse.fromJson(Map<String, dynamic> json) {
    return UpiCreateResponse(
      vpa: json['vpa'] as String,
      transactionId: json['transactionId'] as String,
      qrCode: json['qrCode'] as String?,
      intentUrl: json['intentUrl'] as String?,
      expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt'] as String) : null,
    );
  }

  /// UPI Virtual Payment Address for receiving payment
  final String vpa;

  /// Transaction ID for tracking
  final String transactionId;

  /// Base64 encoded QR code image
  final String? qrCode;

  /// UPI intent URL for app redirect
  final String? intentUrl;

  /// When the payment link expires
  final DateTime? expiresAt;

  Map<String, dynamic> toJson() {
    return {
      'vpa': vpa,
      'transactionId': transactionId,
      if (qrCode != null) 'qrCode': qrCode,
      if (intentUrl != null) 'intentUrl': intentUrl,
      if (expiresAt != null) 'expiresAt': expiresAt!.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [vpa, transactionId, qrCode, intentUrl, expiresAt];
}

/// Payment Methods Response
///
/// Response containing a list of saved payment methods.
class PaymentMethodsResponse extends Equatable {
  const PaymentMethodsResponse({
    required this.paymentMethods,
  });

  /// Creates a [PaymentMethodsResponse] instance from JSON.
  factory PaymentMethodsResponse.fromJson(Map<String, dynamic> json) {
    return PaymentMethodsResponse(
      paymentMethods: (json['paymentMethods'] as List<dynamic>?)
              ?.map(
                (e) => PaymentMethodModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  /// List of saved payment methods
  final List<PaymentMethodModel> paymentMethods;

  /// Get the default payment method
  PaymentMethodModel? get defaultMethod {
    try {
      return paymentMethods.firstWhere((m) => m.isDefault);
    } catch (_) {
      return paymentMethods.isNotEmpty ? paymentMethods.first : null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'paymentMethods': paymentMethods.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [paymentMethods];
}
