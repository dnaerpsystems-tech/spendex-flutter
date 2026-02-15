import 'package:equatable/equatable.dart';
import '../../../bank_import/data/models/parsed_transaction_model.dart';
import '../../../bank_import/data/models/sms_message_model.dart';

enum EmailType {
  notification,
  statement,
  receipt,
  other,
}

class EmailAttachment extends Equatable {
  const EmailAttachment({
    required this.id,
    required this.fileName,
    required this.mimeType,
    required this.sizeInBytes,
    this.downloadUrl,
  });

  factory EmailAttachment.fromJson(Map<String, dynamic> json) {
    return EmailAttachment(
      id: json['id'] as String,
      fileName: json['fileName'] as String,
      mimeType: json['mimeType'] as String,
      sizeInBytes: (json['sizeInBytes'] as num).toInt(),
      downloadUrl: json['downloadUrl'] as String?,
    );
  }
  final String id;
  final String fileName;
  final String mimeType;
  final int sizeInBytes;
  final String? downloadUrl;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileName': fileName,
      'mimeType': mimeType,
      'sizeInBytes': sizeInBytes,
      'downloadUrl': downloadUrl,
    };
  }

  @override
  List<Object?> get props => [
        id,
        fileName,
        mimeType,
        sizeInBytes,
        downloadUrl,
      ];
}

class EmailMessageModel extends Equatable {
  const EmailMessageModel({
    required this.id,
    required this.from,
    required this.subject,
    required this.body,
    required this.date,
    required this.accountId,
    this.hasAttachment = false,
    this.attachments = const [],
    this.isRead = false,
    this.isParsed = false,
    this.parseStatus = ParseStatus.unparsed,
    this.parsedTransaction,
    this.emailType = EmailType.other,
    this.bankName,
  });

  factory EmailMessageModel.fromJson(Map<String, dynamic> json) {
    return EmailMessageModel(
      id: json['id'] as String,
      from: json['from'] as String,
      subject: json['subject'] as String,
      body: json['body'] as String,
      date: DateTime.parse(json['date'] as String),
      hasAttachment: json['hasAttachment'] as bool? ?? false,
      attachments: json['attachments'] != null
          ? (json['attachments'] as List<dynamic>)
              .map((e) => EmailAttachment.fromJson(e as Map<String, dynamic>))
              .toList()
          : const [],
      isRead: json['isRead'] as bool? ?? false,
      isParsed: json['isParsed'] as bool? ?? false,
      parseStatus: ParseStatus.values.firstWhere(
        (e) => e.name == json['parseStatus'],
        orElse: () => ParseStatus.unparsed,
      ),
      parsedTransaction: json['parsedTransaction'] != null
          ? ParsedTransactionModel.fromJson(
              json['parsedTransaction'] as Map<String, dynamic>,
            )
          : null,
      emailType: EmailType.values.firstWhere(
        (e) => e.name == json['emailType'],
        orElse: () => EmailType.other,
      ),
      bankName: json['bankName'] as String?,
      accountId: json['accountId'] as String,
    );
  }
  final String id;
  final String from;
  final String subject;
  final String body;
  final DateTime date;
  final bool hasAttachment;
  final List<EmailAttachment> attachments;
  final bool isRead;
  final bool isParsed;
  final ParseStatus parseStatus;
  final ParsedTransactionModel? parsedTransaction;
  final EmailType emailType;
  final String? bankName;
  final String accountId;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'from': from,
      'subject': subject,
      'body': body,
      'date': date.toIso8601String(),
      'hasAttachment': hasAttachment,
      'attachments': attachments.map((a) => a.toJson()).toList(),
      'isRead': isRead,
      'isParsed': isParsed,
      'parseStatus': parseStatus.name,
      'parsedTransaction': parsedTransaction?.toJson(),
      'emailType': emailType.name,
      'bankName': bankName,
      'accountId': accountId,
    };
  }

  EmailMessageModel copyWith({
    String? id,
    String? from,
    String? subject,
    String? body,
    DateTime? date,
    bool? hasAttachment,
    List<EmailAttachment>? attachments,
    bool? isRead,
    bool? isParsed,
    ParseStatus? parseStatus,
    ParsedTransactionModel? parsedTransaction,
    EmailType? emailType,
    String? bankName,
    String? accountId,
  }) {
    return EmailMessageModel(
      id: id ?? this.id,
      from: from ?? this.from,
      subject: subject ?? this.subject,
      body: body ?? this.body,
      date: date ?? this.date,
      hasAttachment: hasAttachment ?? this.hasAttachment,
      attachments: attachments ?? this.attachments,
      isRead: isRead ?? this.isRead,
      isParsed: isParsed ?? this.isParsed,
      parseStatus: parseStatus ?? this.parseStatus,
      parsedTransaction: parsedTransaction ?? this.parsedTransaction,
      emailType: emailType ?? this.emailType,
      bankName: bankName ?? this.bankName,
      accountId: accountId ?? this.accountId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        from,
        subject,
        body,
        date,
        hasAttachment,
        attachments,
        isRead,
        isParsed,
        parseStatus,
        parsedTransaction,
        emailType,
        bankName,
        accountId,
      ];

  /// Check if email is from a bank
  bool get isFromBank => bankName != null && bankName!.isNotEmpty;

  /// Check if email contains financial information
  bool get isFinancial {
    final lowerSubject = subject.toLowerCase();
    final lowerBody = body.toLowerCase();

    final financialKeywords = [
      'transaction',
      'payment',
      'debit',
      'credit',
      'statement',
      'balance',
      'transfer',
      'upi',
      'atm',
      'neft',
      'imps',
      'rtgs',
      'purchase',
      'bill',
      'invoice',
    ];

    return financialKeywords.any(
      (keyword) => lowerSubject.contains(keyword) || lowerBody.contains(keyword),
    );
  }

  /// Get formatted file size for attachments
  String getAttachmentSizeFormatted() {
    if (attachments.isEmpty) {
      return '0 B';
    }

    final totalSize = attachments.fold<int>(
      0,
      (sum, attachment) => sum + attachment.sizeInBytes,
    );

    if (totalSize < 1024) {
      return '$totalSize B';
    } else if (totalSize < 1024 * 1024) {
      return '${(totalSize / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(totalSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
}
