import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/user_model.dart';

/// Auth Remote Data Source Interface
abstract class AuthRemoteDataSource {
  Future<Either<Failure, AuthResponse>> login(LoginRequest request);
  Future<Either<Failure, bool>> register(RegisterRequest request);
  Future<Either<Failure, AuthResponse>> verifyOtp(OtpVerificationRequest request);
  Future<Either<Failure, bool>> sendOtp(String email, String purpose);
  Future<Either<Failure, bool>> forgotPassword(String email);
  Future<Either<Failure, bool>> resetPassword(ResetPasswordRequest request);
  Future<Either<Failure, UserModel>> getCurrentUser();
  Future<Either<Failure, AuthResponse>> refreshToken(String refreshToken);
  Future<Either<Failure, void>> logout();

  // Biometric Authentication Methods
  Future<Either<Failure, Map<String, dynamic>>> getBiometricRegisterOptions();
  Future<Either<Failure, bool>> registerBiometric(Map<String, dynamic> credential);
  Future<Either<Failure, Map<String, dynamic>>> getBiometricLoginOptions();
  Future<Either<Failure, AuthResponse>> loginWithBiometric(Map<String, dynamic> credential);
  Future<Either<Failure, List<Map<String, dynamic>>>> getBiometricCredentials();
  Future<Either<Failure, bool>> deleteBiometricCredential(String id);
}

/// Auth Remote Data Source Implementation
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSourceImpl(this._apiClient);

  @override
  Future<Either<Failure, AuthResponse>> login(LoginRequest request) async {
    return _apiClient.post<AuthResponse>(
      ApiEndpoints.login,
      data: request.toJson(),
      fromJson: (json) => AuthResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<Either<Failure, bool>> register(RegisterRequest request) async {
    final result = await _apiClient.post(
      ApiEndpoints.register,
      data: request.toJson(),
    );

    return result.fold(
      (failure) => Left(failure),
      (_) => const Right(true),
    );
  }

  @override
  Future<Either<Failure, AuthResponse>> verifyOtp(
    OtpVerificationRequest request,
  ) async {
    return _apiClient.post<AuthResponse>(
      ApiEndpoints.verifyOtp,
      data: request.toJson(),
      fromJson: (json) => AuthResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<Either<Failure, bool>> sendOtp(String email, String purpose) async {
    final result = await _apiClient.post(
      ApiEndpoints.sendOtp,
      data: {'email': email, 'purpose': purpose},
    );

    return result.fold(
      (failure) => Left(failure),
      (_) => const Right(true),
    );
  }

  @override
  Future<Either<Failure, bool>> forgotPassword(String email) async {
    final result = await _apiClient.post(
      ApiEndpoints.forgotPassword,
      data: {'email': email},
    );

    return result.fold(
      (failure) => Left(failure),
      (_) => const Right(true),
    );
  }

  @override
  Future<Either<Failure, bool>> resetPassword(
    ResetPasswordRequest request,
  ) async {
    final result = await _apiClient.post(
      ApiEndpoints.resetPassword,
      data: request.toJson(),
    );

    return result.fold(
      (failure) => Left(failure),
      (_) => const Right(true),
    );
  }

  @override
  Future<Either<Failure, UserModel>> getCurrentUser() async {
    return _apiClient.get<UserModel>(
      ApiEndpoints.me,
      fromJson: (json) => UserModel.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<Either<Failure, AuthResponse>> refreshToken(
    String refreshToken,
  ) async {
    return _apiClient.post<AuthResponse>(
      ApiEndpoints.refresh,
      data: {'refreshToken': refreshToken},
      fromJson: (json) => AuthResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<Either<Failure, void>> logout() async {
    final result = await _apiClient.post(ApiEndpoints.logout);

    return result.fold(
      (failure) => Left(failure),
      (_) => const Right(null),
    );
  }

  // Biometric Authentication Implementations

  @override
  Future<Either<Failure, Map<String, dynamic>>> getBiometricRegisterOptions() async {
    return _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.biometricRegisterOptions,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  @override
  Future<Either<Failure, bool>> registerBiometric(Map<String, dynamic> credential) async {
    final result = await _apiClient.post(
      ApiEndpoints.biometricRegister,
      data: credential,
    );

    return result.fold(
      (failure) => Left(failure),
      (_) => const Right(true),
    );
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getBiometricLoginOptions() async {
    return _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.biometricLoginOptions,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  @override
  Future<Either<Failure, AuthResponse>> loginWithBiometric(Map<String, dynamic> credential) async {
    return _apiClient.post<AuthResponse>(
      ApiEndpoints.biometricLogin,
      data: credential,
      fromJson: (json) => AuthResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getBiometricCredentials() async {
    return _apiClient.get<List<Map<String, dynamic>>>(
      ApiEndpoints.biometricCredentials,
      fromJson: (json) {
        if (json is List) {
          return json.map((e) => e as Map<String, dynamic>).toList();
        }
        return <Map<String, dynamic>>[];
      },
    );
  }

  @override
  Future<Either<Failure, bool>> deleteBiometricCredential(String id) async {
    final result = await _apiClient.delete(
      '${ApiEndpoints.biometricCredentials}/$id',
    );

    return result.fold(
      (failure) => Left(failure),
      (_) => const Right(true),
    );
  }
}
