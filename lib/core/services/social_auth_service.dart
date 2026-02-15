import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../errors/failures.dart';
import '../utils/app_logger.dart';

/// Timeout duration for social authentication operations
const Duration _authTimeout = Duration(seconds: 60);

/// Social authentication credentials returned from OAuth providers.
class SocialAuthCredentials {
  const SocialAuthCredentials({
    required this.provider,
    required this.idToken,
    this.accessToken,
    this.authorizationCode,
    this.email,
    this.name,
    this.nonce,
  });

  final String provider;
  final String idToken;
  final String? accessToken;
  final String? authorizationCode;
  final String? email;
  final String? name;
  final String? nonce; // For Apple Sign-In verification

  Map<String, dynamic> toJson() => {
        'provider': provider,
        'idToken': idToken,
        if (accessToken != null) 'accessToken': accessToken,
        if (authorizationCode != null) 'authorizationCode': authorizationCode,
        if (email != null) 'email': email,
        if (name != null) 'name': name,
        if (nonce != null) 'nonce': nonce,
      };

  @override
  String toString() =>
      'SocialAuthCredentials(provider: $provider, email: $email, name: $name)';
}

/// Service for handling social authentication with Google, Apple, and Facebook.
class SocialAuthService {
  SocialAuthService();

  GoogleSignIn? _googleSignIn;
  bool _isDisposed = false;

  /// Lazy initialization of GoogleSignIn
  GoogleSignIn get _google {
    _googleSignIn ??= GoogleSignIn(scopes: ['email', 'profile']);
    return _googleSignIn!;
  }

  /// Generate a cryptographically secure nonce
  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  /// SHA256 hash of a string
  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Sign in with Google OAuth with timeout handling.
  Future<Either<Failure, SocialAuthCredentials>> signInWithGoogle() async {
    if (_isDisposed) {
      return const Left(AuthFailure('Service has been disposed'));
    }

    try {
      final account = await _google
          .signIn()
          .timeout(_authTimeout, onTimeout: () => null);

      if (account == null) {
        return const Left(
          AuthFailure('Google sign-in was cancelled or timed out'),
        );
      }

      final auth = await account.authentication.timeout(
        _authTimeout,
        onTimeout: () {
          throw TimeoutException('Failed to get Google authentication');
        },
      );

      final idToken = auth.idToken;
      if (idToken == null) {
        AppLogger.e('Google Sign-In: Failed to get ID token');
        return const Left(
          AuthFailure('Unable to complete Google sign-in. Please try again.'),
        );
      }

      return Right(SocialAuthCredentials(
        provider: 'google',
        idToken: idToken,
        accessToken: auth.accessToken,
        email: account.email,
        name: account.displayName,
      ),);
    } on TimeoutException {
      AppLogger.e('Google Sign-In: Timeout');
      return const Left(
        AuthFailure(
          'Sign-in timed out. Please check your connection and try again.',
        ),
      );
    } catch (e) {
      AppLogger.e('Google Sign-In error: $e');
      return const Left(
        AuthFailure('Unable to sign in with Google. Please try again.'),
      );
    }
  }

  /// Sign in with Apple OAuth with nonce for security.
  Future<Either<Failure, SocialAuthCredentials>> signInWithApple() async {
    if (_isDisposed) {
      return const Left(AuthFailure('Service has been disposed'));
    }

    if (!isAppleSignInAvailable) {
      return const Left(
        AuthFailure('Apple Sign-In is only available on iOS and macOS'),
      );
    }

    try {
      // Generate nonce for security (prevents replay attacks)
      final rawNonce = _generateNonce();
      final hashedNonce = _sha256ofString(rawNonce);

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      ).timeout(_authTimeout, onTimeout: () {
        throw TimeoutException('Apple Sign-In timed out');
      },);

      final idToken = credential.identityToken;
      if (idToken == null) {
        AppLogger.e('Apple Sign-In: Failed to get ID token');
        return const Left(
          AuthFailure('Unable to complete Apple sign-in. Please try again.'),
        );
      }

      String? fullName;
      if (credential.givenName != null || credential.familyName != null) {
        fullName = [credential.givenName, credential.familyName]
            .where((n) => n != null && n.isNotEmpty)
            .join(' ');
        if (fullName.isEmpty) {
          fullName = null;
        }
      }

      return Right(SocialAuthCredentials(
        provider: 'apple',
        idToken: idToken,
        authorizationCode: credential.authorizationCode,
        email: credential.email,
        name: fullName,
        nonce: rawNonce, // Send raw nonce to backend for verification
      ),);
    } on TimeoutException {
      AppLogger.e('Apple Sign-In: Timeout');
      return const Left(
        AuthFailure(
          'Sign-in timed out. Please check your connection and try again.',
        ),
      );
    } catch (e) {
      final errorString = e.toString();
      if (errorString.contains('canceled') ||
          errorString.contains('cancelled')) {
        return const Left(AuthFailure('Apple sign-in was cancelled'));
      }
      AppLogger.e('Apple Sign-In error: $e');
      return const Left(
        AuthFailure('Unable to sign in with Apple. Please try again.'),
      );
    }
  }

  /// Sign in with Facebook OAuth with token validation.
  Future<Either<Failure, SocialAuthCredentials>> signInWithFacebook() async {
    if (_isDisposed) {
      return const Left(AuthFailure('Service has been disposed'));
    }

    try {
      // Check for existing valid token first
      final existingToken = await FacebookAuth.instance.accessToken;
      if (existingToken != null) {
        // Use existing token - let the backend validate if it's still valid
        final userData = await FacebookAuth.instance
            .getUserData(fields: 'email,name')
            .timeout(_authTimeout);

        return Right(SocialAuthCredentials(
          provider: 'facebook',
          idToken: existingToken.tokenString,
          email: userData['email'] as String?,
          name: userData['name'] as String?,
        ),);
      }

      // Perform fresh login
      final result = await FacebookAuth.instance
          .login(permissions: ['email', 'public_profile']).timeout(
        _authTimeout,
        onTimeout: () {
          return LoginResult(status: LoginStatus.failed, message: 'Timeout',);
        },
      );

      if (result.status == LoginStatus.cancelled) {
        return const Left(AuthFailure('Facebook sign-in was cancelled'));
      }

      if (result.status == LoginStatus.failed) {
        AppLogger.e('Facebook Sign-In failed: ${result.message}');
        return const Left(
          AuthFailure('Unable to sign in with Facebook. Please try again.'),
        );
      }

      final accessToken = result.accessToken;
      if (accessToken == null) {
        AppLogger.e('Facebook Sign-In: No access token');
        return const Left(
          AuthFailure(
            'Unable to complete Facebook sign-in. Please try again.',
          ),
        );
      }

      final userData = await FacebookAuth.instance
          .getUserData(fields: 'email,name')
          .timeout(_authTimeout);

      return Right(SocialAuthCredentials(
        provider: 'facebook',
        idToken: accessToken.tokenString,
        email: userData['email'] as String?,
        name: userData['name'] as String?,
      ),);
    } on TimeoutException {
      AppLogger.e('Facebook Sign-In: Timeout');
      return const Left(
        AuthFailure(
          'Sign-in timed out. Please check your connection and try again.',
        ),
      );
    } catch (e) {
      AppLogger.e('Facebook Sign-In error: $e');
      return const Left(
        AuthFailure('Unable to sign in with Facebook. Please try again.'),
      );
    }
  }

  /// Sign out from all social providers.
  Future<void> signOutAll() async {
    try {
      if (_googleSignIn != null) {
        await _googleSignIn!.signOut();
        await _googleSignIn!.disconnect();
      }
    } catch (e) {
      AppLogger.w('Google sign-out error: $e');
    }

    try {
      await FacebookAuth.instance.logOut();
    } catch (e) {
      AppLogger.w('Facebook sign-out error: $e');
    }
  }

  /// Check if Apple Sign-In is available on this device.
  bool get isAppleSignInAvailable {
    return defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;
  }

  /// Dispose the service and cleanup resources.
  void dispose() {
    _isDisposed = true;
    _googleSignIn?.disconnect();
    _googleSignIn = null;
  }
}
