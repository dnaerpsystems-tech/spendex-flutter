import 'package:equatable/equatable.dart';

enum ImportStatus {
  pending,
  processing,
  completed,
  failed,
}

enum FileType {
  pdf,
  csv,
}

class ImportedStatementModel extends Equatable {
  const ImportedStatementModel({
    required this.id,
    required this.fileName,
    required this.fileType,
    required this.uploadDate,
    required this.status,
    required this.transactionCount,
    this.parsedData,
  });

  factory ImportedStatementModel.fromJson(Map<String, dynamic> json) {
    return ImportedStatementModel(
      id: json['id'] as String,
      fileName: json['fileName'] as String,
      fileType: FileType.values.firstWhere(
        (e) => e.name == json['fileType'],
        orElse: () => FileType.pdf,
      ),
      uploadDate: DateTime.parse(json['uploadDate'] as String),
      status: ImportStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ImportStatus.pending,
      ),
      transactionCount: json['transactionCount'] as int,
      parsedData: json['parsedData'] as Map<String, dynamic>?,
    );
  }
  final String id;
  final String fileName;
  final FileType fileType;
  final DateTime uploadDate;
  final ImportStatus status;
  final int transactionCount;
  final Map<String, dynamic>? parsedData;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileName': fileName,
      'fileType': fileType.name,
      'uploadDate': uploadDate.toIso8601String(),
      'status': status.name,
      'transactionCount': transactionCount,
      'parsedData': parsedData,
    };
  }

  ImportedStatementModel copyWith({
    String? id,
    String? fileName,
    FileType? fileType,
    DateTime? uploadDate,
    ImportStatus? status,
    int? transactionCount,
    Map<String, dynamic>? parsedData,
  }) {
    return ImportedStatementModel(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      fileType: fileType ?? this.fileType,
      uploadDate: uploadDate ?? this.uploadDate,
      status: status ?? this.status,
      transactionCount: transactionCount ?? this.transactionCount,
      parsedData: parsedData ?? this.parsedData,
    );
  }

  @override
  List<Object?> get props => [
        id,
        fileName,
        fileType,
        uploadDate,
        status,
        transactionCount,
        parsedData,
      ];
}
