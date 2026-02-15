import 'package:equatable/equatable.dart';

/// Model for security activity logs
class SecurityLogModel extends Equatable {
  const SecurityLogModel({
    required this.id,
    required this.action,
    required this.description,
    required this.timestamp,
    required this.status,
    this.deviceName,
    this.ipAddress,
    this.location,
  });

  factory SecurityLogModel.fromJson(Map<String, dynamic> json) {
    return SecurityLogModel(
      id: json['id'] as String,
      action: json['action'] as String,
      description: json['description'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      deviceName: json['deviceName'] as String?,
      ipAddress: json['ipAddress'] as String?,
      location: json['location'] as String?,
      status: json['status'] as String,
    );
  }

  final String id;
  final String action; // 'login', 'logout', 'password_change', 'pin_set', etc.
  final String description;
  final DateTime timestamp;
  final String? deviceName;
  final String? ipAddress;
  final String? location;
  final String status; // 'success', 'failed', 'warning'

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'action': action,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'deviceName': deviceName,
      'ipAddress': ipAddress,
      'location': location,
      'status': status,
    };
  }

  @override
  List<Object?> get props => [
        id,
        action,
        description,
        timestamp,
        deviceName,
        ipAddress,
        location,
        status,
      ];
}
