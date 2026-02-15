import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../errors/failures.dart';

/// Social authentication credentials returned from OAuth providers.
///
/// Contains all necessary information to authenticate with the backend.
class SocialAuthCredentials {
  const SocialAuthCredentials({
    required this.provider,
    required this.idToken,
    this.accessToken,
    this.authorizationCode,
    this.email,
    this.name,
  });

  /// The OAuth provider ('google', 'apple', 'facebook')
  final String provider;

  /// The ID token or access token from the provider
  final String idToken;

  /// Optional access token (for providers that return both)
  final String? accessToken;

  /// Authorization code (specifically for Apple Sign-In)
  final String? authorizationCode;

  /// User's email from the OAuth provider
  final String? email;

  /// User's display name from the OAuth provider
  final String? name;

  /// Convert credentials to JSON for API request
  Map<String, dynamic> toJson() => {
        'provider': provider,
        'idToken': idToken,
        if (accessToken != null) 'accessToken': accessToken,
        if (authorizationCode != null) 'authorizationCode': authorizationCode,
        if (email != null) 'email': email,
        if (name != null) 'name': name,
      };

  @override
  String toString() =>
      'SocialAuthCredentials(provider: $provider, email: $email, name: $name)';
}

/// Service for handling social authentication with Google, Apple, and Facebook.
///
/// This service manages OAuth flows for all supported providers and returns
/// unified [SocialAuthCredentials] that can be sent to the backend.
class SocialAuthService {
  SocialAuthService();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  /// Sign in with Google OAuth.
  ///
  /// Returns [SocialAuthCredentials] on success or [AuthFailure] on failure.
  Future<Either<Failure, SocialAuthCredentials>> signInWithGoogle() async {
    try {
      // Start the Google sign-in flow
      final GoogleSignInAccount? account = await _googleSignIn.signIn();

      if (account == null) {
        return const Left(AuthFailure('Google sign-in was cancelled'));
      }

      // Get authentication tokens
      final GoogleSignInAuthentication auth = await account.authentication;
      final String? idToken = auth.idToken;

      if (idToken == null) {
        return const Left(AuthFailure('Failed to get Google ID token'));
      }

      return Right(SocialAuthCredentials(
        provider: 'google',
        idToken: idToken,
        accessToken: auth.accessToken,
        email: account.email,
        name: account.displayName,
      ));
    } catch (e) {
      return Left(AuthFailure('Google sign-in failed: ${e.toString()}'));
    }
  }

  /// Sign in with Apple OAuth.
  ///
  /// Only available on iOS and macOS devices.
  /// Returns [SocialAuthCredentials] on success or [AuthFailure] on failure.
  Future<Either<Failure, SocialAuthCredentials>> signInWithApple() async {
    try {
      // Check platform availability
      if (isAppleSignInAvailable == false) {
        return const Left(
          AuthFailure('Apple Sign-In is only available on iOS and macOS'),
        );
      }

      // Start Apple Sign-In flow
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Get the identity token
      final String? idToken = credential.identityToken;
      if (idToken == null) {
        return const Left(AuthFailure('Failed to get Apple ID token'));
      }

      // Build full name from given/family names (Apple only provides these on first sign-in)
      String? fullName;
      if (credential.givenName != null || credential.familyName != null) {
        fullName = [credential.givenName, credential.familyName]
            .where((n) => n != null && n.isNotEmpty)
            .join(' ');
        if (fullName.isEmpty) fullName = null;
      }

      return Right(SocialAuthCredentials(
        provider: 'apple',
        idToken: idToken,
        authorizationCode: credential.authorizationCode,
        email: credential.email,
        name: fullName,
      ));
    } catch (e) {
      final errorString = e.toString();
      // Handle user cancellation gracefully
      if (errorString.contains('canceled') ||
          errorString.contains('cancelled')) {
        return const Left(AuthFailure('Apple sign-in was cancelled'));
      }
      return Left(AuthFailure('Apple sign-in failed: $errorString'));
    }
  }

  /// Sign in with Facebook OAuth.
  ///
  /// Returns [SocialAuthCredentials] on success or [AuthFailure] on failure.
  Future<Either<Failure, SocialAuthCredentials>> signInWithFacebook() async {
    try {
      // Start Facebook login flow
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      // Handle cancellation
      if (result.status == LoginStatus.cancelled) {
        return const Left(AuthFailure('Facebook sign-in was cancelled'));
      }

      // Handle failure
      if (result.status == LoginStatus.failed) {
        return Left(
          AuthFailure(
              'Facebook sign-in failed: ${result.message ?? 'Unknown error'}'),
        );
      }

      // Get access token
      final AccessToken? accessToken = result.accessToken;
      if (accessToken == null) {
        return const Left(AuthFailure('Failed to get Facebook access token'));
      }

      // Fetch user profile data
      final userData = await FacebookAuth.instance.getUserData(
        fields: 'email,name',
      );

      return Right(SocialAuthCredentials(
        provider: 'facebook',
        idToken: accessToken.tokenString,
        email: userData['email'] as String?,
        name: userData['name'] as String?,
      ));
    } catch (e) {
      return Left(AuthFailure('Facebook sign-in failed: ${e.toString()}'));
    }
  }

  /// Sign out from all social providers.
  ///
  /// This should be called when the user logs out of the app.
  Future<void> signOutAll() async {
    try {
      // Sign out from Google
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
    } catch (_) {
      // Ignore Google sign-out errors
    }

    try {
      // Sign out from Facebook
      await FacebookAuth.instance.logOut();
    } catch (_) {
      // Ignore Facebook sign-out errors
    }

    // Note: Apple Sign-In doesn't have a sign-out method
    // The user manages this through iOS Settings
  }

  /// Check if Apple Sign-In is available on this device.
  ///
  /// Returns true only on iOS and macOS platforms.
  bool get isAppleSignInAvailable {
    // Check for iOS or macOS using defaultTargetPlatform
    return defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;
  }
}
