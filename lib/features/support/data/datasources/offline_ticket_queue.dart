// ignore_for_file: prefer_constructors_over_static_methods

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ticket_model.dart';

/// Queue for managing offline support tickets that need to be synced when online.
class OfflineTicketQueue {

  OfflineTicketQueue._();
  static const String _queueKey = 'offline_ticket_queue';
  static OfflineTicketQueue? _instance;

  static OfflineTicketQueue get instance {
    _instance ??= OfflineTicketQueue._();
    return _instance!;
  }

  /// Add a ticket to the offline queue
  Future<void> enqueue(Ticket ticket) async {
    final prefs = await SharedPreferences.getInstance();
    final queue = await getQueue();

    // Mark as pending sync
    final pendingTicket = ticket.copyWith(
      status: TicketStatus.open,
    );

    queue.add(pendingTicket);

    final jsonList = queue.map((t) => t.toJson()).toList();
    await prefs.setString(_queueKey, jsonEncode(jsonList));
  }

  /// Get all tickets in the offline queue
  Future<List<Ticket>> getQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_queueKey);

    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((json) => Ticket.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Remove a ticket from the queue after successful sync
  Future<void> dequeue(String ticketId) async {
    final prefs = await SharedPreferences.getInstance();
    final queue = await getQueue();

    queue.removeWhere((t) => t.id == ticketId);

    final jsonList = queue.map((t) => t.toJson()).toList();
    await prefs.setString(_queueKey, jsonEncode(jsonList));
  }

  /// Check if there are pending tickets to sync
  Future<bool> hasPendingTickets() async {
    final queue = await getQueue();
    return queue.isNotEmpty;
  }

  /// Get count of pending tickets
  Future<int> pendingCount() async {
    final queue = await getQueue();
    return queue.length;
  }

  /// Clear all pending tickets
  Future<void> clearQueue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_queueKey);
  }

  /// Sync all pending tickets when online
  /// Returns list of successfully synced ticket IDs
  Future<List<String>> syncPendingTickets({
    required Future<bool> Function(Ticket ticket) syncFunction,
  }) async {
    final queue = await getQueue();
    final syncedIds = <String>[];

    for (final ticket in queue) {
      try {
        final success = await syncFunction(ticket);
        if (success) {
          syncedIds.add(ticket.id);
          await dequeue(ticket.id);
        }
      } catch (e) {
        // Continue with next ticket on failure
        continue;
      }
    }

    return syncedIds;
  }
}
