import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../data/models/imported_statement_model.dart';
import '../../data/models/parsed_transaction_model.dart';

abstract class PdfImportRepository {
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
