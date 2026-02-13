import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/pdf_import_repository.dart';
import '../datasources/pdf_import_remote_datasource.dart';
import '../models/imported_statement_model.dart';
import '../models/parsed_transaction_model.dart';

class PdfImportRepositoryImpl implements PdfImportRepository {

  PdfImportRepositoryImpl(this._remoteDataSource);
  final PdfImportRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, ImportedStatementModel>> uploadPdf(File file) async {
    try {
      return await _remoteDataSource.uploadPdf(file);
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ImportedStatementModel>> uploadCsv(
    File file,
    Map<String, String> columnMapping,
  ) async {
    try {
      return await _remoteDataSource.uploadCsv(file, columnMapping);
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ParsedTransactionModel>>> getParseResults(
    String importId,
  ) async {
    try {
      return await _remoteDataSource.getParseResults(importId);
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> confirmImport(
    String importId,
    List<ParsedTransactionModel> transactions,
  ) async {
    try {
      return await _remoteDataSource.confirmImport(importId, transactions);
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ImportedStatementModel>>> getImportHistory() async {
    try {
      return await _remoteDataSource.getImportHistory();
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteImport(String importId) async {
    try {
      return await _remoteDataSource.deleteImport(importId);
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
