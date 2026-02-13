import 'package:equatable/equatable.dart';

class IfscDetailsModel extends Equatable {

  const IfscDetailsModel({
    required this.ifsc,
    required this.bank,
    required this.branch,
    this.address,
    this.city,
    this.state,
    this.contact,
  });

  factory IfscDetailsModel.fromJson(Map<String, dynamic> json) {
    return IfscDetailsModel(
      ifsc: json['ifsc'] as String,
      bank: json['bank'] as String,
      branch: json['branch'] as String,
      address: json['address'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      contact: json['contact'] as String?,
    );
  }
  final String ifsc;
  final String bank;
  final String branch;
  final String? address;
  final String? city;
  final String? state;
  final String? contact;

  Map<String, dynamic> toJson() {
    return {
      'ifsc': ifsc,
      'bank': bank,
      'branch': branch,
      'address': address,
      'city': city,
      'state': state,
      'contact': contact,
    };
  }

  IfscDetailsModel copyWith({
    String? ifsc,
    String? bank,
    String? branch,
    String? address,
    String? city,
    String? state,
    String? contact,
  }) {
    return IfscDetailsModel(
      ifsc: ifsc ?? this.ifsc,
      bank: bank ?? this.bank,
      branch: branch ?? this.branch,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      contact: contact ?? this.contact,
    );
  }

  String get fullAddress {
    final parts = [
      if (address != null && address!.isNotEmpty) address,
      if (city != null && city!.isNotEmpty) city,
      if (state != null && state!.isNotEmpty) state,
    ];
    return parts.join(', ');
  }

  @override
  List<Object?> get props => [
        ifsc,
        bank,
        branch,
        address,
        city,
        state,
        contact,
      ];
}
