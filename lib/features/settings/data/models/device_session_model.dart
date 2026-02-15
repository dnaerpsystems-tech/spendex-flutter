import 'package:equatable/equatable.dart';

/// Model for device session information
class DeviceSessionModel extends Equatable {
  const DeviceSessionModel({
    required this.id,
    required this.deviceName,
    required this.deviceType,
    required this.os,
    required this.lastActive,
    required this.isCurrent,
    required this.createdAt,
    this.browser,
    this.ipAddress,
    this.location,
  });

  factory DeviceSessionModel.fromJson(Map<String, dynamic> json) {
    return DeviceSessionModel(
      id: json['id'] as String,
      deviceName: json['deviceName'] as String,
      deviceType: json['deviceType'] as String,
      os: json['os'] as String,
      browser: json['browser'] as String?,
      lastActive: DateTime.parse(json['lastActive'] as String),
      isCurrent: json['isCurrent'] as bool? ?? false,
      ipAddress: json['ipAddress'] as String?,
      location: json['location'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  final String id;
  final String deviceName;
  final String deviceType; // 'mobile', 'tablet', 'desktop', 'web'
  final String os;
  final String? browser;
  final DateTime lastActive;
  final bool isCurrent;
  final String? ipAddress;
  final String? location;
  final DateTime createdAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'deviceName': deviceName,
      'deviceType': deviceType,
      'os': os,
      'browser': browser,
      'lastActive': lastActive.toIso8601String(),
      'isCurrent': isCurrent,
      'ipAddress': ipAddress,
      'location': location,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        deviceName,
        deviceType,
        os,
        browser,
        lastActive,
        isCurrent,
        ipAddress,
        location,
        createdAt,
      ];
}
