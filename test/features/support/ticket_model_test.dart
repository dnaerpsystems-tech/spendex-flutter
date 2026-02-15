import 'package:flutter_test/flutter_test.dart';
import 'package:spendex/features/support/data/models/ticket_model.dart';

void main() {
  group('TicketModel', () {
    group('Ticket', () {
      test('fromJson should parse correctly', () {
        final json = {
          'id': 'ticket_1',
          'subject': 'Test Subject',
          'description': 'Test Description',
          'category': 'bugReport',
          'priority': 'high',
          'status': 'open',
          'createdAt': '2026-02-15T00:00:00.000Z',
          'updatedAt': '2026-02-15T00:00:00.000Z',
        };
        
        final ticket = Ticket.fromJson(json);
        
        expect(ticket.id, 'ticket_1');
        expect(ticket.subject, 'Test Subject');
        expect(ticket.description, 'Test Description');
        expect(ticket.category, TicketCategory.bugReport);
        expect(ticket.priority, TicketPriority.high);
        expect(ticket.status, TicketStatus.open);
        expect(ticket.createdAt.year, 2026);
      });

      test('fromJson should use default values for unknown enums', () {
        final json = {
          'id': 'ticket_2',
          'subject': 'Test',
          'description': 'Test',
          'category': 'unknown_category',
          'priority': 'unknown_priority',
          'status': 'unknown_status',
          'createdAt': '2026-02-15T00:00:00.000Z',
        };
        
        final ticket = Ticket.fromJson(json);
        
        expect(ticket.category, TicketCategory.generalQuestion);
        expect(ticket.priority, TicketPriority.medium);
        expect(ticket.status, TicketStatus.open);
      });

      test('toJson should serialize correctly', () {
        final ticket = Ticket(
          id: 'ticket_3',
          subject: 'Subject',
          description: 'Description',
          category: TicketCategory.billingIssue,
          priority: TicketPriority.medium,
          status: TicketStatus.inProgress,
          createdAt: DateTime(2026, 2, 15),
          updatedAt: DateTime(2026, 2, 16),
        );
        
        final json = ticket.toJson();
        
        expect(json['id'], 'ticket_3');
        expect(json['subject'], 'Subject');
        expect(json['description'], 'Description');
        expect(json['category'], 'billingIssue');
        expect(json['priority'], 'medium');
        expect(json['status'], 'inProgress');
      });

      test('toJson should not include null updatedAt', () {
        final ticket = Ticket(
          id: 'ticket_4',
          subject: 'Subject',
          description: 'Description',
          category: TicketCategory.bugReport,
          priority: TicketPriority.low,
          status: TicketStatus.open,
          createdAt: DateTime(2026, 2, 15),
        );
        
        final json = ticket.toJson();
        
        expect(json.containsKey('updatedAt'), isFalse);
      });

      test('copyWith should create new instance with updated fields', () {
        final original = Ticket(
          id: 'ticket_5',
          subject: 'Original',
          description: 'Original',
          category: TicketCategory.generalQuestion,
          priority: TicketPriority.low,
          status: TicketStatus.open,
          createdAt: DateTime.now(),
        );
        
        final updated = original.copyWith(
          subject: 'Updated',
          status: TicketStatus.resolved,
        );
        
        expect(updated.id, original.id);
        expect(updated.subject, 'Updated');
        expect(updated.status, TicketStatus.resolved);
        expect(updated.description, original.description);
        expect(updated.category, original.category);
        expect(updated.priority, original.priority);
      });

      test('copyWith should preserve all original values when no params', () {
        final original = Ticket(
          id: 'ticket_6',
          subject: 'Subject',
          description: 'Description',
          category: TicketCategory.featureRequest,
          priority: TicketPriority.urgent,
          status: TicketStatus.closed,
          createdAt: DateTime(2026, 2, 15),
          userEmail: 'test@example.com',
          userName: 'Test User',
          deviceInfo: 'iPhone 15',
          appVersion: '1.0.0',
        );
        
        final copy = original.copyWith();
        
        expect(copy, equals(original));
      });

      test('props should include all fields for equality', () {
        final ticket1 = Ticket(
          id: 'ticket_7',
          subject: 'Subject',
          description: 'Description',
          category: TicketCategory.bugReport,
          priority: TicketPriority.high,
          status: TicketStatus.open,
          createdAt: DateTime(2026, 2, 15),
        );
        
        final ticket2 = Ticket(
          id: 'ticket_7',
          subject: 'Subject',
          description: 'Description',
          category: TicketCategory.bugReport,
          priority: TicketPriority.high,
          status: TicketStatus.open,
          createdAt: DateTime(2026, 2, 15),
        );
        
        expect(ticket1, equals(ticket2));
      });

      test('should include messages when present', () {
        final messages = [
          TicketMessage(
            id: 'msg_1',
            content: 'Hello',
            isFromSupport: false,
            createdAt: DateTime.now(),
          ),
        ];
        
        final ticket = Ticket(
          id: 'ticket_8',
          subject: 'Subject',
          description: 'Description',
          category: TicketCategory.bugReport,
          priority: TicketPriority.high,
          status: TicketStatus.open,
          createdAt: DateTime.now(),
          messages: messages,
        );
        
        expect(ticket.messages.length, 1);
        expect(ticket.messages.first.content, 'Hello');
      });
    });

    group('TicketMessage', () {
      test('fromJson should parse correctly', () {
        final json = {
          'id': 'msg_1',
          'content': 'Test message',
          'isFromSupport': true,
          'createdAt': '2026-02-15T12:00:00.000Z',
        };
        
        final message = TicketMessage.fromJson(json);
        
        expect(message.id, 'msg_1');
        expect(message.content, 'Test message');
        expect(message.isFromSupport, isTrue);
      });

      test('fromJson should default isFromSupport to false', () {
        final json = {
          'id': 'msg_2',
          'content': 'Test message',
          'createdAt': '2026-02-15T12:00:00.000Z',
        };
        
        final message = TicketMessage.fromJson(json);
        
        expect(message.isFromSupport, isFalse);
      });

      test('toJson should serialize correctly', () {
        final message = TicketMessage(
          id: 'msg_3',
          content: 'Test content',
          isFromSupport: true,
          createdAt: DateTime(2026, 2, 15, 12, 0),
        );
        
        final json = message.toJson();
        
        expect(json['id'], 'msg_3');
        expect(json['content'], 'Test content');
        expect(json['isFromSupport'], isTrue);
        expect(json['createdAt'], contains('2026-02-15'));
      });
    });

    group('TicketCategory', () {
      test('label getter should return correct labels', () {
        expect(TicketCategory.bugReport.label, 'Bug Report');
        expect(TicketCategory.featureRequest.label, 'Feature Request');
        expect(TicketCategory.billingIssue.label, 'Billing Issue');
        expect(TicketCategory.accountSecurity.label, 'Account & Security');
        expect(TicketCategory.generalQuestion.label, 'General Question');
      });

      test('emoji getter should return correct emojis', () {
        expect(TicketCategory.bugReport.emoji, '🐛');
        expect(TicketCategory.featureRequest.emoji, '✨');
        expect(TicketCategory.billingIssue.emoji, '💳');
        expect(TicketCategory.accountSecurity.emoji, '🔐');
        expect(TicketCategory.generalQuestion.emoji, '❓');
      });

      test('color getter should return valid colors', () {
        for (final category in TicketCategory.values) {
          expect(category.color, isNotNull);
          expect(category.color.value, isNonZero);
        }
      });
    });

    group('TicketPriority', () {
      test('label getter should return correct labels', () {
        expect(TicketPriority.low.label, 'Low');
        expect(TicketPriority.medium.label, 'Medium');
        expect(TicketPriority.high.label, 'High');
        expect(TicketPriority.urgent.label, 'Urgent');
      });

      test('color getter should return valid colors', () {
        for (final priority in TicketPriority.values) {
          expect(priority.color, isNotNull);
          expect(priority.color.value, isNonZero);
        }
      });

      test('icon getter should return valid icons', () {
        for (final priority in TicketPriority.values) {
          expect(priority.icon, isNotNull);
        }
      });
    });

    group('TicketStatus', () {
      test('label getter should return correct labels', () {
        expect(TicketStatus.open.label, 'Open');
        expect(TicketStatus.inProgress.label, 'In Progress');
        expect(TicketStatus.resolved.label, 'Resolved');
        expect(TicketStatus.closed.label, 'Closed');
      });

      test('color getter should return valid colors', () {
        for (final status in TicketStatus.values) {
          expect(status.color, isNotNull);
          expect(status.color.value, isNonZero);
        }
      });
    });

    group('CreateTicketRequest', () {
      test('toJson should serialize correctly', () {
        const request = CreateTicketRequest(
          subject: 'Test Subject',
          description: 'Test Description',
          category: TicketCategory.bugReport,
          priority: TicketPriority.high,
        );
        
        final json = request.toJson();
        
        expect(json['subject'], 'Test Subject');
        expect(json['description'], 'Test Description');
        expect(json['category'], 'bugReport');
        expect(json['priority'], 'high');
      });

      test('toJson should include optional fields when provided', () {
        const request = CreateTicketRequest(
          subject: 'Test',
          description: 'Test',
          category: TicketCategory.bugReport,
          priority: TicketPriority.medium,
          deviceInfo: 'iPhone 15 Pro',
          appVersion: '2.0.0',
        );
        
        final json = request.toJson();
        
        expect(json['deviceInfo'], 'iPhone 15 Pro');
        expect(json['appVersion'], '2.0.0');
      });

      test('toJson should not include null optional fields', () {
        const request = CreateTicketRequest(
          subject: 'Test',
          description: 'Test',
          category: TicketCategory.bugReport,
          priority: TicketPriority.medium,
        );
        
        final json = request.toJson();
        
        expect(json.containsKey('deviceInfo'), isFalse);
        expect(json.containsKey('appVersion'), isFalse);
      });
    });
  });
}
