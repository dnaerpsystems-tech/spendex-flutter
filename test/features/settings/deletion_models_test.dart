import 'package:flutter_test/flutter_test.dart';
import 'package:spendex/features/settings/data/models/deletion_models.dart';

void main() {
  group('DeletionModels', () {
    group('VerifyPasswordRequest', () {
      test('toJson should serialize correctly', () {
        const request = VerifyPasswordRequest(password: 'test123');
        final json = request.toJson();
        
        expect(json['password'], 'test123');
      });

      test('toJson should handle special characters in password', () {
        const request = VerifyPasswordRequest(password: r'p@955w0rd!#%^&*');
        final json = request.toJson();
        
        expect(json['password'], r'p@955w0rd!#%^&*');
      });
    });

    group('VerifyPasswordResponse', () {
      test('fromJson should parse correctly when verified', () {
        final json = {
          'verified': true,
          'verificationToken': 'token123',
          'expiresAt': '2026-02-20T00:00:00.000Z',
        };
        
        final response = VerifyPasswordResponse.fromJson(json);
        
        expect(response.verified, isTrue);
        expect(response.verificationToken, 'token123');
        expect(response.expiresAt, isNotNull);
        expect(response.expiresAt?.year, 2026);
        expect(response.expiresAt?.month, 2);
        expect(response.expiresAt?.day, 20);
      });

      test('fromJson should parse correctly when not verified', () {
        final json = {
          'verified': false,
        };
        
        final response = VerifyPasswordResponse.fromJson(json);
        
        expect(response.verified, isFalse);
        expect(response.verificationToken, isNull);
        expect(response.expiresAt, isNull);
      });

      test('fromJson should handle missing verified field', () {
        final json = <String, dynamic>{};
        
        final response = VerifyPasswordResponse.fromJson(json);
        
        expect(response.verified, isFalse);
      });

      test('props should include all fields', () {
        const response = VerifyPasswordResponse(
          verified: true,
          verificationToken: 'token',
          expiresAt: null,
        );
        
        expect(response.props, contains(true));
        expect(response.props, contains('token'));
      });
    });

    group('DeleteAccountRequest', () {
      test('toJson should include all required fields', () {
        const request = DeleteAccountRequest(
          verificationToken: 'token123',
          confirmationText: 'DELETE',
        );
        final json = request.toJson();
        
        expect(json['verificationToken'], 'token123');
        expect(json['confirmationText'], 'DELETE');
        expect(json['cancelSubscription'], isTrue);
      });

      test('toJson should include optional reason when provided', () {
        const request = DeleteAccountRequest(
          verificationToken: 'token123',
          confirmationText: 'DELETE',
          reason: 'Testing deletion',
        );
        final json = request.toJson();
        
        expect(json['reason'], 'Testing deletion');
      });

      test('toJson should not include reason when null', () {
        const request = DeleteAccountRequest(
          verificationToken: 'token123',
          confirmationText: 'DELETE',
        );
        final json = request.toJson();
        
        expect(json.containsKey('reason'), isFalse);
      });

      test('toJson should respect cancelSubscription flag', () {
        const request = DeleteAccountRequest(
          verificationToken: 'token123',
          confirmationText: 'DELETE',
          cancelSubscription: false,
        );
        final json = request.toJson();
        
        expect(json['cancelSubscription'], isFalse);
      });
    });

    group('DeleteAccountResponse', () {
      test('fromJson should parse success response', () {
        final json = {
          'success': true,
          'message': 'Account deletion scheduled',
          'scheduled_deletion_date': '2026-03-01T00:00:00.000Z',
          'can_recover': true,
        };
        
        final response = DeleteAccountResponse.fromJson(json);
        
        expect(response.success, isTrue);
        expect(response.message, 'Account deletion scheduled');
        expect(response.scheduledDeletionDate?.year, 2026);
        expect(response.canRecover, isTrue);
      });

      test('fromJson should handle failure response', () {
        final json = {
          'success': false,
          'message': 'Verification failed',
        };
        
        final response = DeleteAccountResponse.fromJson(json);
        
        expect(response.success, isFalse);
        expect(response.message, 'Verification failed');
        expect(response.scheduledDeletionDate, isNull);
      });

      test('fromJson should default success to false when missing', () {
        final json = <String, dynamic>{};
        
        final response = DeleteAccountResponse.fromJson(json);
        
        expect(response.success, isFalse);
        expect(response.canRecover, isTrue);
      });
    });

    group('ActiveSubscriptionInfo', () {
      test('fromJson should parse subscription info', () {
        final json = {
          'hasActiveSubscription': true,
          'planName': 'Premium',
          'expiryDate': '2026-12-31',
          'amountPaid': 999.0,
          'billingCycle': 'yearly',
          'subscriptionId': 'sub_123',
          'status': 'active',
        };
        
        final info = ActiveSubscriptionInfo.fromJson(json);
        
        expect(info.hasActiveSubscription, isTrue);
        expect(info.planName, 'Premium');
        expect(info.amountPaid, 999.0);
        expect(info.billingCycle, 'yearly');
      });

      test('formattedAmount should format correctly', () {
        const info = ActiveSubscriptionInfo(
          hasActiveSubscription: true,
          amountPaid: 199.99,
        );
        
        expect(info.formattedAmount, '₹199.99');
      });

      test('formattedAmount should return N/A when null', () {
        const info = ActiveSubscriptionInfo(
          hasActiveSubscription: false,
        );
        
        expect(info.formattedAmount, 'N/A');
      });

      test('formattedBillingCycle should format monthly', () {
        const info = ActiveSubscriptionInfo(
          hasActiveSubscription: true,
          billingCycle: 'monthly',
        );
        
        expect(info.formattedBillingCycle, 'Monthly');
      });

      test('formattedBillingCycle should format yearly', () {
        const info = ActiveSubscriptionInfo(
          hasActiveSubscription: true,
          billingCycle: 'yearly',
        );
        
        expect(info.formattedBillingCycle, 'Yearly');
      });

      test('formattedBillingCycle should format annual', () {
        const info = ActiveSubscriptionInfo(
          hasActiveSubscription: true,
          billingCycle: 'annual',
        );
        
        expect(info.formattedBillingCycle, 'Yearly');
      });

      test('formattedBillingCycle should format quarterly', () {
        const info = ActiveSubscriptionInfo(
          hasActiveSubscription: true,
          billingCycle: 'quarterly',
        );
        
        expect(info.formattedBillingCycle, 'Quarterly');
      });

      test('none constant should have no subscription', () {
        expect(ActiveSubscriptionInfo.none.hasActiveSubscription, isFalse);
      });
    });

    group('DeletionState', () {
      test('isLoading should be true for loading states', () {
        expect(DeletionState.checkingSubscription.isLoading, isTrue);
        expect(DeletionState.verifyingPassword.isLoading, isTrue);
        expect(DeletionState.deleting.isLoading, isTrue);
      });

      test('isLoading should be false for non-loading states', () {
        expect(DeletionState.idle.isLoading, isFalse);
        expect(DeletionState.confirming.isLoading, isFalse);
        expect(DeletionState.success.isLoading, isFalse);
        expect(DeletionState.error.isLoading, isFalse);
      });

      test('isIdle should be true only for idle state', () {
        expect(DeletionState.idle.isIdle, isTrue);
        expect(DeletionState.deleting.isIdle, isFalse);
      });

      test('isSuccess should be true only for success state', () {
        expect(DeletionState.success.isSuccess, isTrue);
        expect(DeletionState.error.isSuccess, isFalse);
      });

      test('isError should be true only for error state', () {
        expect(DeletionState.error.isError, isTrue);
        expect(DeletionState.success.isError, isFalse);
      });

      test('message getter should return appropriate messages', () {
        expect(DeletionState.idle.message, 'Ready');
        expect(DeletionState.checkingSubscription.message, contains('subscription'));
        expect(DeletionState.verifyingPassword.message, contains('identity'));
        expect(DeletionState.confirming.message, contains('confirmation'));
        expect(DeletionState.deleting.message, contains('Deleting'));
        expect(DeletionState.success.message, contains('successfully'));
        expect(DeletionState.error.message, contains('Failed'));
      });
    });

    group('DeletionReason', () {
      test('should have correct number of values', () {
        expect(DeletionReason.values.length, 6);
      });

      test('notUseful should have correct label', () {
        expect(DeletionReason.notUseful.label, 'Not useful for me');
      });

      test('tooExpensive should have correct label', () {
        expect(DeletionReason.tooExpensive.label, 'Too expensive');
      });

      test('foundBetter should have correct label', () {
        expect(DeletionReason.foundBetter.label, 'Found a better alternative');
      });

      test('privacyConcerns should have correct label', () {
        expect(DeletionReason.privacyConcerns.label, 'Privacy concerns');
      });

      test('technicalIssues should have correct label', () {
        expect(DeletionReason.technicalIssues.label, 'Technical issues');
      });

      test('other should have correct label', () {
        expect(DeletionReason.other.label, 'Other');
      });
    });
  });
}
