import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';
import '../../data/models/ifsc_details_model.dart';
import '../../domain/repositories/india_utils_repository.dart';

/// Provider for India Utils repository
final indiaUtilsRepositoryProvider = Provider<IndiaUtilsRepository>((ref) {
  return getIt<IndiaUtilsRepository>();
});

/// Provider for IFSC lookup
/// Returns IfscDetailsModel for a given IFSC code
final ifscLookupProvider = FutureProvider.family<IfscDetailsModel?, String>((ref, ifscCode) async {
  if (ifscCode.isEmpty || ifscCode.length != 11) {
    return null;
  }

  final repository = ref.watch(indiaUtilsRepositoryProvider);
  final result = await repository.lookupIfsc(ifscCode.toUpperCase());

  return result.fold(
    (failure) => null,
    (details) => details,
  );
});

/// Provider for UPI validation
/// Returns true if UPI ID is valid
final upiValidationProvider = FutureProvider.family<bool, String>((ref, upiId) async {
  if (upiId.isEmpty || !upiId.contains('@')) {
    return false;
  }

  final repository = ref.watch(indiaUtilsRepositoryProvider);
  final result = await repository.validateUpi(upiId);

  return result.fold(
    (failure) => false,
    (isValid) => isValid,
  );
});

/// Provider for payment methods
/// Returns list of available payment methods
final paymentMethodsProvider = FutureProvider<List<PaymentMethod>>((ref) async {
  final repository = ref.watch(indiaUtilsRepositoryProvider);
  final result = await repository.getPaymentMethods();

  return result.fold(
    (failure) => [],
    (methods) => methods,
  );
});

/// Extension for PaymentMethod enum
extension PaymentMethodExtension on PaymentMethod {
  String get label {
    switch (this) {
      case PaymentMethod.upi:
        return 'UPI';
      case PaymentMethod.neft:
        return 'NEFT';
      case PaymentMethod.rtgs:
        return 'RTGS';
      case PaymentMethod.imps:
        return 'IMPS';
      case PaymentMethod.card:
        return 'Card';
      case PaymentMethod.netbanking:
        return 'Net Banking';
      case PaymentMethod.cash:
        return 'Cash';
    }
  }

  String get description {
    switch (this) {
      case PaymentMethod.upi:
        return 'Instant payment via UPI apps';
      case PaymentMethod.neft:
        return 'National Electronic Funds Transfer';
      case PaymentMethod.rtgs:
        return 'Real Time Gross Settlement';
      case PaymentMethod.imps:
        return 'Immediate Payment Service';
      case PaymentMethod.card:
        return 'Credit/Debit Card';
      case PaymentMethod.netbanking:
        return 'Internet Banking';
      case PaymentMethod.cash:
        return 'Cash Payment';
    }
  }
}
