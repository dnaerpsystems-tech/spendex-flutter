import 'package:equatable/equatable.dart';

/// Invoice Status
///
/// Represents the payment status of an invoice.
enum InvoiceStatus {
  pending('PENDING', 'Pending'),
  paid('PAID', 'Paid'),
  failed('FAILED', 'Failed'),
  refunded('REFUNDED', 'Refunded');

  const InvoiceStatus(this.value, this.label);
  final String value;
  final String label;
}

/// Invoice Item Model
///
/// Represents a line item in an invoice.
class InvoiceItem extends Equatable {
  const InvoiceItem({
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.amount,
  });

  /// Creates an [InvoiceItem] instance from JSON.
  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      description: json['description'] as String,
      quantity: json['quantity'] as int? ?? 1,
      unitPrice: json['unitPrice'] as int,
      amount: json['amount'] as int,
    );
  }

  /// Description of the item
  final String description;

  /// Quantity of items
  final int quantity;

  /// Unit price in paise
  final int unitPrice;

  /// Total amount in paise (quantity * unitPrice)
  final int amount;

  /// Converts the model to JSON.
  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'amount': amount,
    };
  }

  /// Get unit price in rupees
  double get unitPriceInRupees => unitPrice / 100;

  /// Get amount in rupees
  double get amountInRupees => amount / 100;

  @override
  List<Object?> get props => [description, quantity, unitPrice, amount];
}

/// Invoice Model
///
/// Represents an invoice for a subscription payment.
class InvoiceModel extends Equatable {
  const InvoiceModel({
    required this.id,
    required this.subscriptionId,
    required this.invoiceNumber,
    required this.amount,
    required this.currency,
    required this.tax,
    required this.total,
    required this.status,
    required this.dueDate,
    required this.periodStart,
    required this.periodEnd,
    required this.items,
    required this.createdAt,
    this.paidAt,
    this.paymentMethod,
    this.downloadUrl,
  });

  /// Creates an [InvoiceModel] instance from JSON.
  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      id: json['id'] as String,
      subscriptionId: json['subscriptionId'] as String,
      invoiceNumber: json['invoiceNumber'] as String,
      amount: json['amount'] as int,
      currency: json['currency'] as String? ?? 'INR',
      tax: json['tax'] as int? ?? 0,
      total: json['total'] as int,
      status: InvoiceStatus.values.firstWhere(
        (e) => e.value == json['status'],
        orElse: () => InvoiceStatus.pending,
      ),
      paidAt: json['paidAt'] != null
          ? DateTime.parse(json['paidAt'] as String)
          : null,
      dueDate: DateTime.parse(json['dueDate'] as String),
      periodStart: DateTime.parse(json['periodStart'] as String),
      periodEnd: DateTime.parse(json['periodEnd'] as String),
      paymentMethod: json['paymentMethod'] as String?,
      downloadUrl: json['downloadUrl'] as String?,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => InvoiceItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Unique identifier for the invoice
  final String id;

  /// ID of the associated subscription
  final String subscriptionId;

  /// Human-readable invoice number (e.g., INV-2024-001)
  final String invoiceNumber;

  /// Subtotal amount in paise (before tax)
  final int amount;

  /// Currency code
  final String currency;

  /// Tax amount in paise
  final int tax;

  /// Total amount in paise (amount + tax)
  final int total;

  /// Payment status of the invoice
  final InvoiceStatus status;

  /// Date when the invoice was paid (null if not paid)
  final DateTime? paidAt;

  /// Due date for payment
  final DateTime dueDate;

  /// Start date of the billing period
  final DateTime periodStart;

  /// End date of the billing period
  final DateTime periodEnd;

  /// Payment method used (e.g., "Visa **** 4242")
  final String? paymentMethod;

  /// URL to download the invoice PDF
  final String? downloadUrl;

  /// Line items in the invoice
  final List<InvoiceItem> items;

  /// When the invoice was created
  final DateTime createdAt;

  /// Converts the model to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subscriptionId': subscriptionId,
      'invoiceNumber': invoiceNumber,
      'amount': amount,
      'currency': currency,
      'tax': tax,
      'total': total,
      'status': status.value,
      if (paidAt != null) 'paidAt': paidAt!.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'periodStart': periodStart.toIso8601String(),
      'periodEnd': periodEnd.toIso8601String(),
      if (paymentMethod != null) 'paymentMethod': paymentMethod,
      if (downloadUrl != null) 'downloadUrl': downloadUrl,
      'items': items.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Get amount in rupees
  double get amountInRupees => amount / 100;

  /// Get tax in rupees
  double get taxInRupees => tax / 100;

  /// Get total in rupees
  double get totalInRupees => total / 100;

  /// Check if invoice is paid
  bool get isPaid => status == InvoiceStatus.paid;

  /// Check if invoice is pending
  bool get isPending => status == InvoiceStatus.pending;

  /// Check if invoice payment failed
  bool get isFailed => status == InvoiceStatus.failed;

  /// Check if invoice was refunded
  bool get isRefunded => status == InvoiceStatus.refunded;

  /// Check if invoice is overdue
  bool get isOverdue {
    if (isPaid || isRefunded) return false;
    return DateTime.now().isAfter(dueDate);
  }

  /// Get number of days until due (negative if overdue)
  int get daysUntilDue {
    return dueDate.difference(DateTime.now()).inDays;
  }

  @override
  List<Object?> get props => [
        id,
        subscriptionId,
        invoiceNumber,
        amount,
        currency,
        tax,
        total,
        status,
        paidAt,
        dueDate,
        periodStart,
        periodEnd,
        paymentMethod,
        downloadUrl,
        items,
        createdAt,
      ];
}

/// Invoices Response Model
///
/// Represents a paginated API response containing invoices.
class InvoicesResponse extends Equatable {
  const InvoicesResponse({
    required this.invoices,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  /// Creates an [InvoicesResponse] instance from JSON.
  factory InvoicesResponse.fromJson(Map<String, dynamic> json) {
    return InvoicesResponse(
      invoices: (json['invoices'] as List<dynamic>?)
              ?.map((e) => InvoiceModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      total: json['total'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      pageSize: json['pageSize'] as int? ?? 20,
      totalPages: json['totalPages'] as int? ?? 1,
    );
  }

  /// List of invoices
  final List<InvoiceModel> invoices;

  /// Total number of invoices
  final int total;

  /// Current page number
  final int page;

  /// Number of items per page
  final int pageSize;

  /// Total number of pages
  final int totalPages;

  /// Converts the model to JSON.
  Map<String, dynamic> toJson() {
    return {
      'invoices': invoices.map((e) => e.toJson()).toList(),
      'total': total,
      'page': page,
      'pageSize': pageSize,
      'totalPages': totalPages,
    };
  }

  /// Check if there are more pages
  bool get hasMorePages => page < totalPages;

  /// Check if this is the first page
  bool get isFirstPage => page == 1;

  /// Check if this is the last page
  bool get isLastPage => page >= totalPages;

  @override
  List<Object?> get props => [invoices, total, page, pageSize, totalPages];
}
