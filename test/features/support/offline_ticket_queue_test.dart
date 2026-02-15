import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spendex/features/support/data/datasources/offline_ticket_queue.dart';
import 'package:spendex/features/support/data/models/ticket_model.dart';

void main() {
  group('OfflineTicketQueue', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('instance should be singleton', () {
      final instance1 = OfflineTicketQueue.instance;
      final instance2 = OfflineTicketQueue.instance;
      expect(identical(instance1, instance2), isTrue);
    });

    test('should enqueue a ticket', () async {
      final ticket = Ticket(
        id: 'test_1',
        subject: 'Test Subject',
        description: 'Test Description',
        category: TicketCategory.bugReport,
        priority: TicketPriority.medium,
        status: TicketStatus.open,
        createdAt: DateTime.now(),
      );
      
      await OfflineTicketQueue.instance.enqueue(ticket);
      final queue = await OfflineTicketQueue.instance.getQueue();
      
      expect(queue.length, 1);
      expect(queue.first.id, 'test_1');
      expect(queue.first.subject, 'Test Subject');
    });

    test('should dequeue a ticket', () async {
      // Clear queue first
      await OfflineTicketQueue.instance.clearQueue();
      
      final ticket = Ticket(
        id: 'test_2',
        subject: 'Test Subject',
        description: 'Test Description',
        category: TicketCategory.billingIssue,
        priority: TicketPriority.high,
        status: TicketStatus.open,
        createdAt: DateTime.now(),
      );
      
      await OfflineTicketQueue.instance.enqueue(ticket);
      await OfflineTicketQueue.instance.dequeue('test_2');
      final queue = await OfflineTicketQueue.instance.getQueue();
      
      expect(queue.length, 0);
    });

    test('hasPendingTickets should return false when queue is empty', () async {
      await OfflineTicketQueue.instance.clearQueue();
      expect(await OfflineTicketQueue.instance.hasPendingTickets(), isFalse);
    });

    test('hasPendingTickets should return true when queue has tickets', () async {
      await OfflineTicketQueue.instance.clearQueue();
      
      final ticket = Ticket(
        id: 'test_3',
        subject: 'Test',
        description: 'Test',
        category: TicketCategory.generalQuestion,
        priority: TicketPriority.low,
        status: TicketStatus.open,
        createdAt: DateTime.now(),
      );
      
      await OfflineTicketQueue.instance.enqueue(ticket);
      expect(await OfflineTicketQueue.instance.hasPendingTickets(), isTrue);
    });

    test('pendingCount should return correct count', () async {
      await OfflineTicketQueue.instance.clearQueue();
      
      expect(await OfflineTicketQueue.instance.pendingCount(), 0);
      
      final ticket1 = Ticket(
        id: 'test_4',
        subject: 'Test 1',
        description: 'Test',
        category: TicketCategory.featureRequest,
        priority: TicketPriority.low,
        status: TicketStatus.open,
        createdAt: DateTime.now(),
      );
      
      final ticket2 = Ticket(
        id: 'test_5',
        subject: 'Test 2',
        description: 'Test',
        category: TicketCategory.accountSecurity,
        priority: TicketPriority.high,
        status: TicketStatus.open,
        createdAt: DateTime.now(),
      );
      
      await OfflineTicketQueue.instance.enqueue(ticket1);
      await OfflineTicketQueue.instance.enqueue(ticket2);
      
      expect(await OfflineTicketQueue.instance.pendingCount(), 2);
    });

    test('clearQueue should remove all tickets', () async {
      final ticket = Ticket(
        id: 'test_6',
        subject: 'Test',
        description: 'Test',
        category: TicketCategory.bugReport,
        priority: TicketPriority.medium,
        status: TicketStatus.open,
        createdAt: DateTime.now(),
      );
      
      await OfflineTicketQueue.instance.enqueue(ticket);
      await OfflineTicketQueue.instance.clearQueue();
      
      expect(await OfflineTicketQueue.instance.hasPendingTickets(), isFalse);
      expect(await OfflineTicketQueue.instance.pendingCount(), 0);
    });

    test('syncPendingTickets should sync all tickets successfully', () async {
      await OfflineTicketQueue.instance.clearQueue();
      
      final ticket = Ticket(
        id: 'test_7',
        subject: 'Sync Test',
        description: 'Test',
        category: TicketCategory.bugReport,
        priority: TicketPriority.medium,
        status: TicketStatus.open,
        createdAt: DateTime.now(),
      );
      
      await OfflineTicketQueue.instance.enqueue(ticket);
      
      final syncedIds = await OfflineTicketQueue.instance.syncPendingTickets(
        syncFunction: (ticket) async => true,
      );
      
      expect(syncedIds, contains('test_7'));
      expect(await OfflineTicketQueue.instance.pendingCount(), 0);
    });

    test('syncPendingTickets should handle failed syncs', () async {
      await OfflineTicketQueue.instance.clearQueue();
      
      final ticket = Ticket(
        id: 'test_8',
        subject: 'Failed Sync Test',
        description: 'Test',
        category: TicketCategory.bugReport,
        priority: TicketPriority.medium,
        status: TicketStatus.open,
        createdAt: DateTime.now(),
      );
      
      await OfflineTicketQueue.instance.enqueue(ticket);
      
      final syncedIds = await OfflineTicketQueue.instance.syncPendingTickets(
        syncFunction: (ticket) async => false,
      );
      
      expect(syncedIds, isEmpty);
      expect(await OfflineTicketQueue.instance.pendingCount(), 1);
    });
  });
}
