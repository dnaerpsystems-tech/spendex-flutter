import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../data/models/user_model.dart';

/// Auth Repository Interface
abstract class AuthRepository {
  /// Login with email and password
  Future<Either<Failure, AuthResponse>> login(String email, String password);

  /// Register new user
  Future<Either<Failure, bool>> register(
    String email,
    String password,
    String name,
    String? phone,
  );

  /// Verify OTP
  Future<Either<Failure, AuthResponse>> verifyOtp(String email, String otp);

  /// Send OTP
  Future<Either<Failure, bool>> sendOtp(String email, String purpose);

  /// Forgot password
  Future<Either<Failure, bool>> forgotPassword(String email);

  /// Reset password
  Future<Either<Failure, bool>> resetPassword(String token, String password);

  /// Get current user
  Future<Either<Failure, UserModel>> getCurrentUser();

  /// Refresh token
  Future<Either<Failure, AuthResponse>> refreshToken();

  /// Logout
  Future<Either<Failure, void>> logout();

  /// Check if user is authenticated
  Future<bool> isAuthenticated();

  // Biometric Authentication Methods

  /// Get biometric register options from server
  Future<Either<Failure, Map<String, dynamic>>> getBiometricRegisterOptions();

  /// Register a biometric credential
  Future<Either<Failure, bool>> registerBiometric(Map<String, dynamic> credential);

  /// Get biometric login options from server
  Future<Either<Failure, Map<String, dynamic>>> getBiometricLoginOptions();

  /// Login with biometric credential
  Future<Either<Failure, AuthResponse>> loginWithBiometric(Map<String, dynamic> credential);

  /// Get list of registered biometric credentials
  Future<Either<Failure, List<Map<String, dynamic>>>> getBiometricCredentials();

  /// Delete a biometric credential
  Future<Either<Failure, bool>> deleteBiometricCredential(String id);

  /// Check if biometric is enabled locally
  Future<bool> isBiometricEnabled();

  /// Set biometric enabled state locally
  Future<void> setBiometricEnabled(bool enabled);
}
