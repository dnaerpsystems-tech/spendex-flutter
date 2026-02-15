import 'package:equatable/equatable.dart';
import 'parsed_transaction_model.dart';

enum ParseStatus {
  unparsed,
  parsed,
  failed,
}

class SmsMessageModel extends Equatable {
  const SmsMessageModel({
    required this.id,
    required this.sender,
    required this.body,
    required this.date,
    required this.parseStatus,
    this.parsedTransaction,
    this.bankName,
  });

  factory SmsMessageModel.fromJson(Map<String, dynamic> json) {
    return SmsMessageModel(
      id: json['id'] as String,
      sender: json['sender'] as String,
      body: json['body'] as String,
      date: DateTime.parse(json['date'] as String),
      parseStatus: ParseStatus.values.firstWhere(
        (e) => e.name == json['parseStatus'],
        orElse: () => ParseStatus.unparsed,
      ),
      parsedTransaction: json['parsedTransaction'] != null
          ? ParsedTransactionModel.fromJson(
              json['parsedTransaction'] as Map<String, dynamic>,
            )
          : null,
      bankName: json['bankName'] as String?,
    );
  }
  final String id;
  final String sender;
  final String body;
  final DateTime date;
  final ParseStatus parseStatus;
  final ParsedTransactionModel? parsedTransaction;
  final String? bankName;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender': sender,
      'body': body,
      'date': date.toIso8601String(),
      'parseStatus': parseStatus.name,
      'parsedTransaction': parsedTransaction?.toJson(),
      'bankName': bankName,
    };
  }

  SmsMessageModel copyWith({
    String? id,
    String? sender,
    String? body,
    DateTime? date,
    ParseStatus? parseStatus,
    ParsedTransactionModel? parsedTransaction,
    String? bankName,
  }) {
    return SmsMessageModel(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      body: body ?? this.body,
      date: date ?? this.date,
      parseStatus: parseStatus ?? this.parseStatus,
      parsedTransaction: parsedTransaction ?? this.parsedTransaction,
      bankName: bankName ?? this.bankName,
    );
  }

  @override
  List<Object?> get props => [
        id,
        sender,
        body,
        date,
        parseStatus,
        parsedTransaction,
        bankName,
      ];
}
