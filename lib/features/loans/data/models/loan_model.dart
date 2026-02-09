import 'package:equatable/equatable.dart';
import '../../../../core/constants/app_constants.dart';

/// Loan Model
class LoanModel extends Equatable {
  final String id;
  final String name;
  final LoanType type;
  final int principalAmount; // in paise
  final double interestRate;
  final int tenure; // months
  final int emiAmount; // in paise
  final int totalPaid; // in paise
  final int remainingAmount; // in paise
  final int totalInterest; // in paise
  final DateTime startDate;
  final DateTime? nextEmiDate;
  final String? lender;
  final String? accountNumber;
  final LoanStatus status;
  final List<EmiSchedule> emiSchedule;
  final DateTime createdAt;
  final DateTime updatedAt;

  const LoanModel({
    required this.id,
    required this.name,
    required this.type,
    required this.principalAmount,
    required this.interestRate,
    required this.tenure,
    required this.emiAmount,
    required this.totalPaid,
    required this.remainingAmount,
    required this.totalInterest,
    required this.startDate,
    this.nextEmiDate,
    this.lender,
    this.accountNumber,
    required this.status,
    this.emiSchedule = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory LoanModel.fromJson(Map<String, dynamic> json) {
    return LoanModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: LoanType.values.firstWhere(
        (e) => e.value == json['type'],
        orElse: () => LoanType.other,
      ),
      principalAmount: json['principalAmount'] as int,
      interestRate: (json['interestRate'] as num).toDouble(),
      tenure: json['tenure'] as int,
      emiAmount: json['emiAmount'] as int,
      totalPaid: json['totalPaid'] as int,
      remainingAmount: json['remainingAmount'] as int,
      totalInterest: json['totalInterest'] as int,
      startDate: DateTime.parse(json['startDate'] as String),
      nextEmiDate: json['nextEmiDate'] != null
          ? DateTime.parse(json['nextEmiDate'] as String)
          : null,
      lender: json['lender'] as String?,
      accountNumber: json['accountNumber'] as String?,
      status: LoanStatus.values.firstWhere(
        (e) => e.value == json['status'],
        orElse: () => LoanStatus.active,
      ),
      emiSchedule: (json['emiSchedule'] as List<dynamic>?)
              ?.map((e) => EmiSchedule.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.value,
      'principalAmount': principalAmount,
      'interestRate': interestRate,
      'tenure': tenure,
      'emiAmount': emiAmount,
      'totalPaid': totalPaid,
      'remainingAmount': remainingAmount,
      'totalInterest': totalInterest,
      'startDate': startDate.toIso8601String(),
      'nextEmiDate': nextEmiDate?.toIso8601String(),
      'lender': lender,
      'accountNumber': accountNumber,
      'status': status.value,
      'emiSchedule': emiSchedule.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  double get principalAmountInRupees => principalAmount / 100;
  double get emiAmountInRupees => emiAmount / 100;
  double get totalPaidInRupees => totalPaid / 100;
  double get remainingAmountInRupees => remainingAmount / 100;
  double get totalInterestInRupees => totalInterest / 100;

  double get progressPercentage =>
      principalAmount > 0 ? (totalPaid / (principalAmount + totalInterest)) * 100 : 0;

  int get remainingEmis => emiSchedule.where((e) => !e.isPaid).length;
  int get paidEmis => emiSchedule.where((e) => e.isPaid).length;

  bool get isActive => status == LoanStatus.active;
  bool get isClosed => status == LoanStatus.closed;

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        principalAmount,
        interestRate,
        tenure,
        emiAmount,
        totalPaid,
        remainingAmount,
        totalInterest,
        startDate,
        nextEmiDate,
        lender,
        accountNumber,
        status,
        createdAt,
        updatedAt,
      ];
}

/// EMI Schedule
class EmiSchedule extends Equatable {
  final int month;
  final DateTime dueDate;
  final int emiAmount;
  final int principal;
  final int interest;
  final int balance;
  final bool isPaid;
  final DateTime? paidDate;

  const EmiSchedule({
    required this.month,
    required this.dueDate,
    required this.emiAmount,
    required this.principal,
    required this.interest,
    required this.balance,
    required this.isPaid,
    this.paidDate,
  });

  factory EmiSchedule.fromJson(Map<String, dynamic> json) {
    return EmiSchedule(
      month: json['month'] as int,
      dueDate: DateTime.parse(json['dueDate'] as String),
      emiAmount: json['emiAmount'] as int,
      principal: json['principal'] as int,
      interest: json['interest'] as int,
      balance: json['balance'] as int,
      isPaid: json['isPaid'] as bool,
      paidDate: json['paidDate'] != null
          ? DateTime.parse(json['paidDate'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'month': month,
      'dueDate': dueDate.toIso8601String(),
      'emiAmount': emiAmount,
      'principal': principal,
      'interest': interest,
      'balance': balance,
      'isPaid': isPaid,
      'paidDate': paidDate?.toIso8601String(),
    };
  }

  double get emiAmountInRupees => emiAmount / 100;
  double get principalInRupees => principal / 100;
  double get interestInRupees => interest / 100;
  double get balanceInRupees => balance / 100;

  bool get isOverdue => !isPaid && dueDate.isBefore(DateTime.now());

  @override
  List<Object?> get props => [
        month,
        dueDate,
        emiAmount,
        principal,
        interest,
        balance,
        isPaid,
        paidDate,
      ];
}

/// Loans Summary
class LoansSummary extends Equatable {
  final int totalOutstanding;
  final int totalMonthlyEmi;
  final int loanCount;
  final int activeLoanCount;

  const LoansSummary({
    required this.totalOutstanding,
    required this.totalMonthlyEmi,
    required this.loanCount,
    required this.activeLoanCount,
  });

  factory LoansSummary.fromJson(Map<String, dynamic> json) {
    return LoansSummary(
      totalOutstanding: json['totalOutstanding'] as int,
      totalMonthlyEmi: json['totalMonthlyEmi'] as int,
      loanCount: json['loanCount'] as int,
      activeLoanCount: json['activeLoanCount'] as int,
    );
  }

  double get totalOutstandingInRupees => totalOutstanding / 100;
  double get totalMonthlyEmiInRupees => totalMonthlyEmi / 100;

  @override
  List<Object?> get props => [
        totalOutstanding,
        totalMonthlyEmi,
        loanCount,
        activeLoanCount,
      ];
}

/// Create Loan Request
class CreateLoanRequest {
  final String name;
  final LoanType type;
  final int principalAmount;
  final double interestRate;
  final int tenure;
  final DateTime startDate;
  final String? lender;
  final String? accountNumber;

  const CreateLoanRequest({
    required this.name,
    required this.type,
    required this.principalAmount,
    required this.interestRate,
    required this.tenure,
    required this.startDate,
    this.lender,
    this.accountNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type.value,
      'principalAmount': principalAmount,
      'interestRate': interestRate,
      'tenure': tenure,
      'startDate': startDate.toIso8601String(),
      if (lender != null) 'lender': lender,
      if (accountNumber != null) 'accountNumber': accountNumber,
    };
  }
}

/// EMI Payment Request
class EmiPaymentRequest {
  final int month;
  final DateTime? paidDate;

  const EmiPaymentRequest({
    required this.month,
    this.paidDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'month': month,
      if (paidDate != null) 'paidDate': paidDate!.toIso8601String(),
    };
  }
}
