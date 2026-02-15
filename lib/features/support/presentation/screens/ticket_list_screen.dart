import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme.dart';
import '../../data/models/ticket_model.dart';
import '../../data/datasources/support_local_datasource.dart';

/// Ticket List Screen
///
/// Shows all submitted tickets with:
/// - List of ticket cards
/// - Status badges (color coded)
/// - Tap to view detail
/// - Empty state when no tickets
class TicketListScreen extends ConsumerStatefulWidget {
  const TicketListScreen({super.key});

  @override
  ConsumerState<TicketListScreen> createState() => _TicketListScreenState();
}

class _TicketListScreenState extends ConsumerState<TicketListScreen> {
  List<Ticket> _tickets = [];
  bool _isLoading = true;
  TicketStatus? _filterStatus;

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  Future<void> _loadTickets() async {
    setState(() => _isLoading = true);
    try {
      final tickets = await SupportLocalDataSource.instance.getTickets();
      if (mounted) {
        setState(() {
          _tickets = tickets;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading tickets: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: SpendexColors.expense,
          ),
        );
      }
    }
  }

  List<Ticket> get _filteredTickets {
    if (_filterStatus == null) return _tickets;
    return _tickets.where((t) => t.status == _filterStatus).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? SpendexColors.darkBackground : SpendexColors.lightBackground;
    final cardColor = isDark ? SpendexColors.darkCard : SpendexColors.lightCard;
    final textColor =
        isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary;
    final secondaryTextColor = isDark
        ? SpendexColors.darkTextSecondary
        : SpendexColors.lightTextSecondary;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('My Tickets'),
        centerTitle: true,
        actions: [
          PopupMenuButton<TicketStatus?>(
            icon: Icon(
              Iconsax.filter,
              color: _filterStatus != null ? SpendexColors.primary : null,
            ),
            tooltip: 'Filter',
            onSelected: (status) {
              setState(() => _filterStatus = status);
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: null,
                child: Row(
                  children: [
                    Icon(
                      Iconsax.tick_circle,
                      color: _filterStatus == null
                          ? SpendexColors.primary
                          : secondaryTextColor,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    const Text('All'),
                  ],
                ),
              ),
              ...TicketStatus.values.map(
                (status) => PopupMenuItem(
                  value: status,
                  child: Row(
                    children: [
                      Icon(
                        Iconsax.tick_circle,
                        color: _filterStatus == status
                            ? SpendexColors.primary
                            : secondaryTextColor,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(status.label),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.push(AppRoutes.createTicket);
          _loadTickets(); // Refresh after creating ticket
        },
        backgroundColor: SpendexColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Iconsax.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadTickets,
              child: _filteredTickets.isEmpty
                  ? _buildEmptyState(textColor, secondaryTextColor)
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredTickets.length,
                      itemBuilder: (context, index) {
                        final ticket = _filteredTickets[index];
                        return _buildTicketCard(
                          ticket,
                          isDark,
                          cardColor,
                          textColor,
                          secondaryTextColor,
                        );
                      },
                    ),
            ),
    );
  }

  Widget _buildEmptyState(Color textColor, Color secondaryTextColor) {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Iconsax.ticket,
                size: 80,
                color: secondaryTextColor,
              ),
              const SizedBox(height: 24),
              Text(
                _filterStatus != null
                    ? 'No ${_filterStatus!.label.toLowerCase()} tickets'
                    : 'No tickets yet',
                style: SpendexTheme.headlineMedium.copyWith(
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _filterStatus != null
                    ? 'Try clearing the filter to see all tickets'
                    : 'Create your first support ticket to get help',
                style: SpendexTheme.bodyMedium.copyWith(
                  color: secondaryTextColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              if (_filterStatus != null)
                TextButton(
                  onPressed: () => setState(() => _filterStatus = null),
                  child: const Text('Clear Filter'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTicketCard(
    Ticket ticket,
    bool isDark,
    Color cardColor,
    Color textColor,
    Color secondaryTextColor,
  ) {
    return GestureDetector(
      onTap: () async {
        await context.push('${AppRoutes.ticketDetail}/${ticket.id}');
        _loadTickets(); // Refresh after viewing
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: ticket.category.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    ticket.category.emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ticket.subject,
                        style: SpendexTheme.titleMedium.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ticket.category.label,
                        style: SpendexTheme.bodySmall.copyWith(
                          color: secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Iconsax.arrow_right_3,
                  color: secondaryTextColor,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              ticket.description,
              style: SpendexTheme.bodySmall.copyWith(
                color: secondaryTextColor,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStatusBadge(ticket.status),
                const SizedBox(width: 8),
                _buildPriorityBadge(ticket.priority),
                const Spacer(),
                Text(
                  _formatDate(ticket.createdAt),
                  style: SpendexTheme.bodySmall.copyWith(
                    color: secondaryTextColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(TicketStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: status.color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: status.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status.label,
            style: SpendexTheme.bodySmall.copyWith(
              color: status.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityBadge(TicketPriority priority) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: priority.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            priority.icon,
            size: 12,
            color: priority.color,
          ),
          const SizedBox(width: 4),
          Text(
            priority.label,
            style: SpendexTheme.bodySmall.copyWith(
              color: priority.color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays == 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
