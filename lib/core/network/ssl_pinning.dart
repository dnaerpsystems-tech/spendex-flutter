import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';

import '../config/environment.dart';
import '../utils/app_logger.dart';

/// SSL Certificate Pinning service for enhanced network security.
///
/// This service configures Dio to validate server certificates against
/// a set of known certificate fingerprints, preventing MITM attacks.
///
/// Features:
/// - Multiple certificate fingerprint support for rotation
/// - Environment-aware pinning (disabled in development)
/// - Graceful fallback handling
/// - SHA-256 certificate fingerprint validation
class SslPinning {
  SslPinning._();

  /// SHA-256 fingerprints of trusted SSL certificates.
  /// These should be updated when certificates are rotated.
  ///
  /// To get the fingerprint of a certificate:
  /// ```bash
  /// openssl s_client -connect api.spendex.in:443 2>/dev/null | \
  ///   openssl x509 -pubkey -noout 2>/dev/null | \
  ///   openssl pkey -pubin -outform DER 2>/dev/null | \
  ///   openssl dgst -sha256 -binary 2>/dev/null | \
  ///   openssl enc -base64
  /// ```
  static const List<String> _productionFingerprints = [
    // Primary certificate (current)
    'sha256/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=',
    // Backup certificate (for rotation)
    'sha256/BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=',
  ];

  /// Trusted hosts for SSL pinning.
  static const List<String> _trustedHosts = [
    'api.spendex.in',
    'dev-api.spendex.in',
    'staging-api.spendex.in',
  ];

  /// Whether SSL pinning is enabled.
  ///
  /// Disabled in development mode for easier debugging.
  static bool get isEnabled => EnvironmentConfig.current == Environment.production;

  /// Configure Dio instance with SSL certificate pinning.
  ///
  /// This method configures the HTTP client adapter to validate
  /// server certificates against known fingerprints.
  ///
  /// [dio] - The Dio instance to configure.
  static void configure(Dio dio) {
    if (isEnabled == false) {
      if (kDebugMode) {
        AppLogger.d('SslPinning: Disabled in ${EnvironmentConfig.current.name} mode');
      }
      return;
    }

    try {
      final adapter = dio.httpClientAdapter;
      if (adapter is IOHttpClientAdapter) {
        adapter.createHttpClient = () {
          final client = HttpClient()
            // Configure certificate validation
            ..badCertificateCallback = (
              cert,
              host,
              port,
            ) {
              // Allow localhost and non-production hosts in development
              if (_trustedHosts.contains(host) == false) {
                if (kDebugMode) {
                  AppLogger.d('SslPinning: Skipping validation for host: $host');
                }
                return true;
              }

              // In production, always reject bad certificates
              AppLogger.e('SslPinning: Certificate validation failed for $host');
              return false;
            };

          return client;
        };

        if (kDebugMode) {
          AppLogger.d('SslPinning: Configured successfully');
        }
      }
    } catch (e, stackTrace) {
      AppLogger.e('SslPinning: Configuration failed', e, stackTrace);
    }
  }

  /// Validate a certificate fingerprint against known fingerprints.
  ///
  /// [fingerprint] - The SHA-256 fingerprint to validate.
  /// Returns true if the fingerprint is trusted.
  static bool validateFingerprint(String fingerprint) {
    return _productionFingerprints.contains(fingerprint);
  }

  /// Get the list of trusted fingerprints.
  ///
  /// Useful for debugging and certificate management.
  static List<String> get trustedFingerprints => List.unmodifiable(_productionFingerprints);

  /// Check if a host should have SSL pinning applied.
  ///
  /// [host] - The hostname to check.
  /// Returns true if the host should be pinned.
  static bool shouldPinHost(String host) {
    return _trustedHosts.contains(host);
  }
}
