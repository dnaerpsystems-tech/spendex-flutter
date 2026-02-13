import 'package:equatable/equatable.dart';

enum EmailProvider {
  gmail,
  outlook,
  yahoo,
  icloud,
  other,
}

class EmailAccountModel extends Equatable {
  final String id;
  final String email;
  final EmailProvider provider;
  final String displayName;
  final bool isConnected;
  final DateTime? lastSyncDate;
  final String imapServer;
  final int imapPort;
  final String username;
  final String encryptedPassword;
  final bool useSsl;

  const EmailAccountModel({
    required this.id,
    required this.email,
    required this.provider,
    required this.displayName,
    required this.isConnected,
    this.lastSyncDate,
    required this.imapServer,
    required this.imapPort,
    required this.username,
    required this.encryptedPassword,
    this.useSsl = true,
  });

  factory EmailAccountModel.fromJson(Map<String, dynamic> json) {
    return EmailAccountModel(
      id: json['id'] as String,
      email: json['email'] as String,
      provider: EmailProvider.values.firstWhere(
        (e) => e.name == json['provider'],
        orElse: () => EmailProvider.other,
      ),
      displayName: json['displayName'] as String,
      isConnected: json['isConnected'] as bool? ?? false,
      lastSyncDate: json['lastSyncDate'] != null
          ? DateTime.parse(json['lastSyncDate'] as String)
          : null,
      imapServer: json['imapServer'] as String,
      imapPort: (json['imapPort'] as num).toInt(),
      username: json['username'] as String,
      encryptedPassword: json['encryptedPassword'] as String,
      useSsl: json['useSsl'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'provider': provider.name,
      'displayName': displayName,
      'isConnected': isConnected,
      'lastSyncDate': lastSyncDate?.toIso8601String(),
      'imapServer': imapServer,
      'imapPort': imapPort,
      'username': username,
      'encryptedPassword': encryptedPassword,
      'useSsl': useSsl,
    };
  }

  EmailAccountModel copyWith({
    String? id,
    String? email,
    EmailProvider? provider,
    String? displayName,
    bool? isConnected,
    DateTime? lastSyncDate,
    String? imapServer,
    int? imapPort,
    String? username,
    String? encryptedPassword,
    bool? useSsl,
  }) {
    return EmailAccountModel(
      id: id ?? this.id,
      email: email ?? this.email,
      provider: provider ?? this.provider,
      displayName: displayName ?? this.displayName,
      isConnected: isConnected ?? this.isConnected,
      lastSyncDate: lastSyncDate ?? this.lastSyncDate,
      imapServer: imapServer ?? this.imapServer,
      imapPort: imapPort ?? this.imapPort,
      username: username ?? this.username,
      encryptedPassword: encryptedPassword ?? this.encryptedPassword,
      useSsl: useSsl ?? this.useSsl,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        provider,
        displayName,
        isConnected,
        lastSyncDate,
        imapServer,
        imapPort,
        username,
        encryptedPassword,
        useSsl,
      ];

  /// Helper method to get default IMAP configuration for known providers
  static Map<String, dynamic> getDefaultImapConfig(EmailProvider provider) {
    switch (provider) {
      case EmailProvider.gmail:
        return {
          'imapServer': 'imap.gmail.com',
          'imapPort': 993,
          'useSsl': true,
        };
      case EmailProvider.outlook:
        return {
          'imapServer': 'outlook.office365.com',
          'imapPort': 993,
          'useSsl': true,
        };
      case EmailProvider.yahoo:
        return {
          'imapServer': 'imap.mail.yahoo.com',
          'imapPort': 993,
          'useSsl': true,
        };
      case EmailProvider.icloud:
        return {
          'imapServer': 'imap.mail.me.com',
          'imapPort': 993,
          'useSsl': true,
        };
      case EmailProvider.other:
        return {
          'imapServer': '',
          'imapPort': 993,
          'useSsl': true,
        };
    }
  }

  /// Detect provider from email address
  static EmailProvider detectProvider(String email) {
    final domain = email.toLowerCase().split('@').last;

    if (domain.contains('gmail')) {
      return EmailProvider.gmail;
    } else if (domain.contains('outlook') ||
        domain.contains('hotmail') ||
        domain.contains('live')) {
      return EmailProvider.outlook;
    } else if (domain.contains('yahoo')) {
      return EmailProvider.yahoo;
    } else if (domain.contains('icloud') || domain.contains('me.com')) {
      return EmailProvider.icloud;
    }

    return EmailProvider.other;
  }
}
