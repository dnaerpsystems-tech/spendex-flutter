import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../models/imported_statement_model.dart';
import '../models/parsed_transaction_model.dart';

abstract class PdfImportRemoteDataSource {
  Future<Either<Failure, ImportedStatementModel>> uploadPdf(File file);

  Future<Either<Failure, ImportedStatementModel>> uploadCsv(
    File file,
    Map<String, String> columnMapping,
  );

  Future<Either<Failure, List<ParsedTransactionModel>>> getParseResults(
    String importId,
  );

  Future<Either<Failure, bool>> confirmImport(
    String importId,
    List<ParsedTransactionModel> transactions,
  );

  Future<Either<Failure, List<ImportedStatementModel>>> getImportHistory();

  Future<Either<Failure, bool>> deleteImport(String importId);
}

class PdfImportRemoteDataSourceImpl implements PdfImportRemoteDataSource {
  PdfImportRemoteDataSourceImpl(this._apiClient);
  final ApiClient _apiClient;

  @override
  Future<Either<Failure, ImportedStatementModel>> uploadPdf(File file) async {
    return _apiClient.uploadFile<ImportedStatementModel>(
      '/import/pdf',
      file: file,
      fieldName: 'file',
      fromJson: (json) => ImportedStatementModel.fromJson(
        json! as Map<String, dynamic>,
      ),
    );
  }

  @override
  Future<Either<Failure, ImportedStatementModel>> uploadCsv(
    File file,
    Map<String, String> columnMapping,
  ) async {
    return _apiClient.uploadFile<ImportedStatementModel>(
      '/import/csv',
      file: file,
      fieldName: 'file',
      additionalData: {'columnMapping': columnMapping},
      fromJson: (json) => ImportedStatementModel.fromJson(
        json! as Map<String, dynamic>,
      ),
    );
  }

  @override
  Future<Either<Failure, List<ParsedTransactionModel>>> getParseResults(
    String importId,
  ) async {
    return _apiClient.get<List<ParsedTransactionModel>>(
      '/import/$importId/results',
      fromJson: (json) {
        final list = json! as List<dynamic>;
        return list
            .map(
              (e) => ParsedTransactionModel.fromJson(
                e as Map<String, dynamic>,
              ),
            )
            .toList();
      },
    );
  }

  @override
  Future<Either<Failure, bool>> confirmImport(
    String importId,
    List<ParsedTransactionModel> transactions,
  ) async {
    final result = await _apiClient.post<bool>(
      '/import/$importId/confirm',
      data: {
        'transactions': transactions.map((t) => t.toJson()).toList(),
      },
      fromJson: (json) {
        if (json is bool) {
          return json;
        }
        if (json is Map<String, dynamic>) {
          return json['success'] as bool? ?? false;
        }
        return false;
      },
    );
    return result;
  }

  @override
  Future<Either<Failure, List<ImportedStatementModel>>> getImportHistory() async {
    return _apiClient.get<List<ImportedStatementModel>>(
      '/import/history',
      fromJson: (json) {
        final list = json! as List<dynamic>;
        return list
            .map(
              (e) => ImportedStatementModel.fromJson(
                e as Map<String, dynamic>,
              ),
            )
            .toList();
      },
    );
  }

  @override
  Future<Either<Failure, bool>> deleteImport(String importId) async {
    final result = await _apiClient.delete<bool>(
      '/import/$importId',
      fromJson: (json) {
        if (json is bool) {
          return json;
        }
        if (json is Map<String, dynamic>) {
          return json['success'] as bool? ?? false;
        }
        return true;
      },
    );
    return result;
  }
}
