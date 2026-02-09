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
}
