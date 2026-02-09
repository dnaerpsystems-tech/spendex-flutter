import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

/// Auth Repository Implementation
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final SecureStorageService _secureStorage;

  AuthRepositoryImpl(this._remoteDataSource, this._secureStorage);

  @override
  Future<Either<Failure, AuthResponse>> login(
    String email,
    String password,
  ) async {
    final result = await _remoteDataSource.login(
      LoginRequest(email: email, password: password),
    );

    return result.fold(
      (failure) => Left(failure),
      (response) async {
        await _secureStorage.saveTokens(
          response.accessToken,
          response.refreshToken,
        );
        return Right(response);
      },
    );
  }

  @override
  Future<Either<Failure, bool>> register(
    String email,
    String password,
    String name,
    String? phone,
  ) async {
    final result = await _remoteDataSource.register(
      RegisterRequest(
        email: email,
        password: password,
        name: name,
        phone: phone,
      ),
    );

    return result.fold(
      (failure) => Left(failure),
      (_) => const Right(true),
    );
  }

  @override
  Future<Either<Failure, AuthResponse>> verifyOtp(
    String email,
    String otp,
  ) async {
    final result = await _remoteDataSource.verifyOtp(
      OtpVerificationRequest(email: email, otp: otp),
    );

    return result.fold(
      (failure) => Left(failure),
      (response) async {
        await _secureStorage.saveTokens(
          response.accessToken,
          response.refreshToken,
        );
        return Right(response);
      },
    );
  }

  @override
  Future<Either<Failure, bool>> sendOtp(String email, String purpose) async {
    final result = await _remoteDataSource.sendOtp(email, purpose);

    return result.fold(
      (failure) => Left(failure),
      (_) => const Right(true),
    );
  }

  @override
  Future<Either<Failure, bool>> forgotPassword(String email) async {
    final result = await _remoteDataSource.forgotPassword(email);

    return result.fold(
      (failure) => Left(failure),
      (_) => const Right(true),
    );
  }

  @override
  Future<Either<Failure, bool>> resetPassword(
    String token,
    String password,
  ) async {
    final result = await _remoteDataSource.resetPassword(
      ResetPasswordRequest(token: token, password: password),
    );

    return result.fold(
      (failure) => Left(failure),
      (_) => const Right(true),
    );
  }

  @override
  Future<Either<Failure, UserModel>> getCurrentUser() async {
    return _remoteDataSource.getCurrentUser();
  }

  @override
  Future<Either<Failure, AuthResponse>> refreshToken() async {
    final refreshToken = await _secureStorage.getRefreshToken();

    if (refreshToken == null) {
      return const Left(AuthFailure('No refresh token available'));
    }

    final result = await _remoteDataSource.refreshToken(refreshToken);

    return result.fold(
      (failure) => Left(failure),
      (response) async {
        await _secureStorage.saveTokens(
          response.accessToken,
          response.refreshToken,
        );
        return Right(response);
      },
    );
  }

  @override
  Future<Either<Failure, void>> logout() async {
    final result = await _remoteDataSource.logout();
    await _secureStorage.clearTokens();
    return result;
  }

  @override
  Future<bool> isAuthenticated() async {
    return _secureStorage.isAuthenticated();
  }
}
