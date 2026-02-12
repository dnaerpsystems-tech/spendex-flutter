import 'package:equatable/equatable.dart';

import '../../../../core/constants/app_constants.dart';

/// User Model
class UserModel extends Equatable {
  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.status,
    required this.preferences,
    required this.tenantId,
    required this.createdAt,
    required this.updatedAt,
    this.phone,
    this.avatarUrl,
    this.emailVerifiedAt,
    this.lastLoginAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      role: UserRole.values.firstWhere(
        (e) => e.value == json['role'],
        orElse: () => UserRole.member,
      ),
      status: UserStatus.values.firstWhere(
        (e) => e.value == json['status'],
        orElse: () => UserStatus.active,
      ),
      preferences: json['preferences'] != null
          ? UserPreferences.fromJson(json['preferences'] as Map<String, dynamic>)
          : const UserPreferences(),
      tenantId: json['tenantId'] as String,
      emailVerifiedAt: json['emailVerifiedAt'] != null
          ? DateTime.parse(json['emailVerifiedAt'] as String)
          : null,
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'] as String)
          : null,
      // API may not return these fields, use current time as default
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  final String id;
  final String email;
  final String name;
  final String? phone;
  final String? avatarUrl;
  final UserRole role;
  final UserStatus status;
  final UserPreferences preferences;
  final String tenantId;
  final DateTime? emailVerifiedAt;
  final DateTime? lastLoginAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'avatarUrl': avatarUrl,
      'role': role.value,
      'status': status.value,
      'preferences': preferences.toJson(),
      'tenantId': tenantId,
      'emailVerifiedAt': emailVerifiedAt?.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    String? avatarUrl,
    UserRole? role,
    UserStatus? status,
    UserPreferences? preferences,
    String? tenantId,
    DateTime? emailVerifiedAt,
    DateTime? lastLoginAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      status: status ?? this.status,
      preferences: preferences ?? this.preferences,
      tenantId: tenantId ?? this.tenantId,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isEmailVerified => emailVerifiedAt != null;
  bool get isOwner => role == UserRole.owner;
  bool get isAdmin => role == UserRole.admin || role == UserRole.owner;
  bool get canManage => role != UserRole.viewer;

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        phone,
        avatarUrl,
        role,
        status,
        preferences,
        tenantId,
        emailVerifiedAt,
        lastLoginAt,
        createdAt,
        updatedAt,
      ];
}

/// User Preferences
class UserPreferences extends Equatable {
  const UserPreferences({
    this.theme = 'system',
    this.notifications = true,
    this.currency = 'INR',
    this.locale = 'en',
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      theme: json['theme'] as String? ?? 'system',
      notifications: json['notifications'] as bool? ?? true,
      currency: json['currency'] as String? ?? 'INR',
      locale: json['locale'] as String? ?? 'en',
    );
  }

  final String theme;
  final bool notifications;
  final String currency;
  final String locale;

  Map<String, dynamic> toJson() {
    return {
      'theme': theme,
      'notifications': notifications,
      'currency': currency,
      'locale': locale,
    };
  }

  UserPreferences copyWith({
    String? theme,
    bool? notifications,
    String? currency,
    String? locale,
  }) {
    return UserPreferences(
      theme: theme ?? this.theme,
      notifications: notifications ?? this.notifications,
      currency: currency ?? this.currency,
      locale: locale ?? this.locale,
    );
  }

  @override
  List<Object?> get props => [theme, notifications, currency, locale];
}

/// Auth Response
class AuthResponse {
  const AuthResponse({
    required this.accessToken,
    required this.user,
    this.refreshToken,
    this.expiresAt,
    this.expiresIn,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    // Handle both expiresAt (string) and expiresIn (int) formats
    DateTime? expiresAt;
    int? expiresIn;

    if (json['expiresAt'] != null) {
      expiresAt = DateTime.parse(json['expiresAt'] as String);
    }
    if (json['expiresIn'] != null) {
      expiresIn = json['expiresIn'] as int;
    }

    return AuthResponse(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String?,
      expiresAt: expiresAt,
      expiresIn: expiresIn,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  final String accessToken;
  final String? refreshToken;
  final DateTime? expiresAt;
  final int? expiresIn;
  final UserModel user;

  /// Get token expiry time (handles both formats)
  DateTime get tokenExpiry {
    if (expiresAt != null) return expiresAt!;
    if (expiresIn != null) {
      return DateTime.now().add(Duration(seconds: expiresIn!));
    }
    // Default to 1 hour if neither is provided
    return DateTime.now().add(const Duration(hours: 1));
  }
}

/// Register Request
class RegisterRequest {
  const RegisterRequest({
    required this.email,
    required this.password,
    required this.name,
    this.phone,
  });

  final String email;
  final String password;
  final String name;
  final String? phone;

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'name': name,
      if (phone != null) 'phone': phone,
    };
  }
}

/// Login Request
class LoginRequest {
  const LoginRequest({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

/// OTP Verification Request
class OtpVerificationRequest {
  const OtpVerificationRequest({
    required this.email,
    required this.otp,
  });

  final String email;
  final String otp;

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'otp': otp,
    };
  }
}

/// Reset Password Request
class ResetPasswordRequest {
  const ResetPasswordRequest({
    required this.token,
    required this.password,
  });

  final String token;
  final String password;

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'password': password,
    };
  }
}
