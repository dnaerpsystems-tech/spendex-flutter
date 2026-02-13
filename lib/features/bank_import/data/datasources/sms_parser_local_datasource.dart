import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/storage/secure_storage.dart';
import '../models/sms_message_model.dart';

abstract class SmsParserLocalDataSource {
  Future<Either<Failure, bool>> checkPermissions();

  Future<Either<Failure, bool>> requestPermissions();

  Future<Either<Failure, List<SmsMessageModel>>> readSmsMessages(
    DateTime startDate,
    DateTime endDate,
  );

  Future<Either<Failure, bool>> getTrackingStatus();

  Future<Either<Failure, bool>> setTrackingStatus(bool enabled);
}

class SmsParserLocalDataSourceImpl implements SmsParserLocalDataSource {

  SmsParserLocalDataSourceImpl(this._secureStorage);
  final SecureStorageService _secureStorage;
  final SmsQuery _smsQuery = SmsQuery();
  static const String _trackingStatusKey = 'sms_tracking_enabled';

  @override
  Future<Either<Failure, bool>> checkPermissions() async {
    try {
      if (!Platform.isAndroid) {
        return const Left(
          ValidationFailure(
            'SMS permissions are only available on Android',
            code: 'PLATFORM_NOT_SUPPORTED',
          ),
        );
      }

      final status = await Permission.sms.status;
      return Right(status.isGranted);
    } catch (e) {
      return Left(UnexpectedFailure('Failed to check SMS permission: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> requestPermissions() async {
    try {
      if (!Platform.isAndroid) {
        return const Left(
          ValidationFailure(
            'SMS permissions are only available on Android',
            code: 'PLATFORM_NOT_SUPPORTED',
          ),
        );
      }

      final status = await Permission.sms.request();

      if (status.isPermanentlyDenied) {
        return const Left(
          AuthFailure(
            'SMS permission permanently denied. Please enable it in app settings.',
            code: 'PERMISSION_PERMANENTLY_DENIED',
          ),
        );
      }

      return Right(status.isGranted);
    } catch (e) {
      return Left(UnexpectedFailure('Failed to request SMS permission: $e'));
    }
  }

  @override
  Future<Either<Failure, List<SmsMessageModel>>> readSmsMessages(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      if (!Platform.isAndroid) {
        return const Left(
          ValidationFailure(
            'SMS reading is only available on Android',
            code: 'PLATFORM_NOT_SUPPORTED',
          ),
        );
      }

      // Check permission first
      final hasPermission = await Permission.sms.isGranted;
      if (!hasPermission) {
        return const Left(
          AuthFailure(
            'SMS permission is required to read messages',
            code: 'PERMISSION_DENIED',
          ),
        );
      }

      // Query SMS messages from inbox
      final messages = await _smsQuery.querySms(
        kinds: [SmsQueryKind.inbox],
        start: 0,
        count: 10000, // Read up to 10,000 messages
      );

      // Filter by date range and convert to SmsMessageModel
      final filteredMessages = messages
          .where((sms) {
            if (sms.date == null) return false;
            final smsDate = sms.date!;
            return smsDate.isAfter(startDate) &&
                smsDate.isBefore(endDate.add(const Duration(days: 1)));
          })
          .map(
            (sms) => SmsMessageModel(
              id: sms.id.toString(),
              sender: sms.address ?? 'Unknown',
              body: sms.body ?? '',
              date: sms.date ?? DateTime.now(),
              parseStatus: ParseStatus.unparsed,
              bankName: '', // Will be identified during parsing
            ),
          )
          .toList();

      return Right(filteredMessages);
    } catch (e) {
      return Left(UnexpectedFailure('Failed to read SMS messages: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> getTrackingStatus() async {
    try {
      final status = await _secureStorage.read(_trackingStatusKey);
      return Right(status == 'true');
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> setTrackingStatus(bool enabled) async {
    try {
      await _secureStorage.save(_trackingStatusKey, enabled.toString());
      return Right(enabled);
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
