// ignore_for_file: prefer_constructors_over_static_methods

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ticket_model.dart';

/// Local data source for support tickets
/// Uses SharedPreferences to store tickets locally
class SupportLocalDataSource {
  SupportLocalDataSource._();

  static SupportLocalDataSource? _instance;
  static SharedPreferences? _prefs;
  static const String _ticketsKey = 'support_tickets';

  /// Singleton instance
  static SupportLocalDataSource get instance {
    _instance ??= SupportLocalDataSource._();
    return _instance!;
  }

  /// Initialize SharedPreferences
  Future<void> _ensureInitialized() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Get all tickets sorted by creation date (newest first)
  Future<List<Ticket>> getTickets() async {
    await _ensureInitialized();
    final jsonString = _prefs!.getString(_ticketsKey);
    if (jsonString == null) {
      return [];
    }

    try {
      final jsonList = json.decode(jsonString) as List<dynamic>;
      return jsonList
          .map((e) => Ticket.fromJson(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      // If parsing fails, return empty list
      return [];
    }
  }

  /// Save a new ticket
  Future<Ticket> saveTicket(Ticket ticket) async {
    await _ensureInitialized();
    final tickets = await getTickets();
    tickets.insert(0, ticket);

    // Keep only last 50 tickets to prevent storage bloat
    final ticketsToSave = tickets.take(50).toList();

    await _prefs!.setString(
      _ticketsKey,
      json.encode(ticketsToSave.map((t) => t.toJson()).toList()),
    );

    return ticket;
  }

  /// Get a specific ticket by ID
  Future<Ticket?> getTicketById(String id) async {
    final tickets = await getTickets();
    try {
      return tickets.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Update an existing ticket
  Future<Ticket?> updateTicket(Ticket ticket) async {
    await _ensureInitialized();
    final tickets = await getTickets();
    final index = tickets.indexWhere((t) => t.id == ticket.id);

    if (index == -1) {
      return null;
    }

    tickets[index] = ticket;

    await _prefs!.setString(
      _ticketsKey,
      json.encode(tickets.map((t) => t.toJson()).toList()),
    );

    return ticket;
  }

  /// Delete a ticket by ID
  Future<void> deleteTicket(String id) async {
    await _ensureInitialized();
    final tickets = await getTickets();
    tickets.removeWhere((t) => t.id == id);

    await _prefs!.setString(
      _ticketsKey,
      json.encode(tickets.map((t) => t.toJson()).toList()),
    );
  }

  /// Clear all tickets
  Future<void> clearAll() async {
    await _ensureInitialized();
    await _prefs!.remove(_ticketsKey);
  }

  /// Get ticket count
  Future<int> getTicketCount() async {
    final tickets = await getTickets();
    return tickets.length;
  }
}
