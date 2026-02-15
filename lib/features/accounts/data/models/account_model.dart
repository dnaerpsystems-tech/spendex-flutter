import 'package:equatable/equatable.dart';
import '../../../../core/constants/app_constants.dart';

/// Account Model
class AccountModel extends Equatable {
  const AccountModel({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    required this.createdAt,
    required this.updatedAt,
    this.currency = 'INR',
    this.bankName,
    this.accountNumber,
    this.icon,
    this.color,
    this.creditLimit,
    this.isDefault = false,
    this.isActive = true,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: AccountType.values.firstWhere(
        (e) => e.value == json['type'],
        orElse: () => AccountType.other,
      ),
      balance: json['balance'] as int,
      currency: json['currency'] as String? ?? 'INR',
      bankName: json['bankName'] as String?,
      accountNumber: json['accountNumber'] as String?,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      creditLimit: json['creditLimit'] as int?,
      isDefault: json['isDefault'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
  final String id;
  final String name;
  final AccountType type;
  final int balance; // in paise
  final String currency;
  final String? bankName;
  final String? accountNumber;
  final String? icon;
  final String? color;
  final int? creditLimit; // in paise
  final bool isDefault;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.value,
      'balance': balance,
      'currency': currency,
      'bankName': bankName,
      'accountNumber': accountNumber,
      'icon': icon,
      'color': color,
      'creditLimit': creditLimit,
      'isDefault': isDefault,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  AccountModel copyWith({
    String? id,
    String? name,
    AccountType? type,
    int? balance,
    String? currency,
    String? bankName,
    String? accountNumber,
    String? icon,
    String? color,
    int? creditLimit,
    bool? isDefault,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AccountModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      creditLimit: creditLimit ?? this.creditLimit,
      isDefault: isDefault ?? this.isDefault,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get balance in rupees
  double get balanceInRupees => balance / 100;

  /// Get credit limit in rupees
  double? get creditLimitInRupees => creditLimit != null ? creditLimit! / 100 : null;

  /// Check if credit card
  bool get isCreditCard => type == AccountType.creditCard;

  /// Get available credit (for credit cards)
  double? get availableCredit =>
      isCreditCard && creditLimit != null ? (creditLimit! - balance) / 100 : null;

  /// Get utilized percentage (for credit cards)
  double? get utilizedPercentage => isCreditCard && creditLimit != null && creditLimit! > 0
      ? (balance / creditLimit!) * 100
      : null;

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        balance,
        currency,
        bankName,
        accountNumber,
        icon,
        color,
        creditLimit,
        isDefault,
        isActive,
        createdAt,
        updatedAt,
      ];
}

/// Accounts Summary
class AccountsSummary extends Equatable {
  const AccountsSummary({
    required this.totalBalance,
    required this.totalAssets,
    required this.totalLiabilities,
    required this.netWorth,
    required this.accountCount,
  });

  factory AccountsSummary.fromJson(Map<String, dynamic> json) {
    return AccountsSummary(
      totalBalance: json['totalBalance'] as int,
      totalAssets: json['totalAssets'] as int,
      totalLiabilities: json['totalLiabilities'] as int,
      netWorth: json['netWorth'] as int,
      accountCount: json['accountCount'] as int,
    );
  }
  final int totalBalance;
  final int totalAssets;
  final int totalLiabilities;
  final int netWorth;
  final int accountCount;

  double get totalBalanceInRupees => totalBalance / 100;
  double get totalAssetsInRupees => totalAssets / 100;
  double get totalLiabilitiesInRupees => totalLiabilities / 100;
  double get netWorthInRupees => netWorth / 100;

  @override
  List<Object?> get props => [
        totalBalance,
        totalAssets,
        totalLiabilities,
        netWorth,
        accountCount,
      ];
}

/// Create Account Request
class CreateAccountRequest {
  const CreateAccountRequest({
    required this.name,
    required this.type,
    this.balance,
    this.bankName,
    this.accountNumber,
    this.icon,
    this.color,
    this.creditLimit,
    this.isDefault = false,
  });
  final String name;
  final AccountType type;
  final int? balance;
  final String? bankName;
  final String? accountNumber;
  final String? icon;
  final String? color;
  final int? creditLimit;
  final bool isDefault;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type.value,
      if (balance != null) 'balance': balance,
      if (bankName != null) 'bankName': bankName,
      if (accountNumber != null) 'accountNumber': accountNumber,
      if (icon != null) 'icon': icon,
      if (color != null) 'color': color,
      if (creditLimit != null) 'creditLimit': creditLimit,
      'isDefault': isDefault,
    };
  }
}

/// Transfer Request
class TransferRequest {
  const TransferRequest({
    required this.fromAccountId,
    required this.toAccountId,
    required this.amount,
    this.description,
    this.date,
  });
  final String fromAccountId;
  final String toAccountId;
  final int amount;
  final String? description;
  final DateTime? date;

  Map<String, dynamic> toJson() {
    return {
      'fromAccountId': fromAccountId,
      'toAccountId': toAccountId,
      'amount': amount,
      if (description != null) 'description': description,
      if (date != null) 'date': date!.toIso8601String(),
    };
  }
}
