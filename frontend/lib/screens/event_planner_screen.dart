import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../features/events/event_dialog.dart';
import '../models/app_models.dart';
import '../models/event_model.dart';
import '../repositories/event_repository.dart';
import '../services/app_provider.dart';
import 'setting_screen_backend.dart';

class EventPlannerScreen extends StatefulWidget {
  const EventPlannerScreen({super.key});

  @override
  State<EventPlannerScreen> createState() => _EventPlannerScreenState();
}

class _EventPlannerScreenState extends State<EventPlannerScreen> {
  List<Event> _events = [];
  bool _isLoading = true;
  String? _errorMessage;
  final _dateFormat = DateFormat('MMM d, yyyy');
  final _repo = EventRepository();

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final events = await _repo.fetchEvents();
      if (!mounted) return;
      setState(() => _events = events);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Could not load events. Please try again.\n$e';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<SettingsProvider>(context).isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF111827) : const Color(0xFFF9FAFB),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(10, 12, 10, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Event Planner',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : const Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Plan and budget for festivals, parties, and special occasions',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: _onAddEvent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006D5B),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text(
                    'New Event',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _buildContent(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(bool isDark) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 60),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return _stateCard(
        isDark: isDark,
        title: 'Something went wrong',
        subtitle: _errorMessage!,
        buttonLabel: 'Retry',
        onTap: _loadEvents,
      );
    }

    if (_events.isEmpty) {
      return _stateCard(
        isDark: isDark,
        title: 'No events yet',
        subtitle: 'Create your first event to start planning your budget.',
        buttonLabel: 'Create Event',
        onTap: _onAddEvent,
      );
    }

    return Column(
      children: _events.map((event) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Dismissible(
            key: ValueKey(event.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                color: Colors.red.shade400,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            confirmDismiss: (_) => _confirmDelete(event),
            onDismissed: (_) => _deleteEvent(event),
            child: _eventCard(event, isDark),
          ),
        );
      }).toList(),
    );
  }

  Widget _stateCard({
    required bool isDark,
    required String title,
    required String subtitle,
    required String buttonLabel,
    required Future<void> Function() onTap,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => onTap(),
            child: Text(buttonLabel),
          ),
        ],
      ),
    );
  }

  Widget _eventCard(Event event, bool isDark) {
    final remaining = event.budgetAmount - event.spentAmount;
    final isOverBudget = remaining < 0;
    final statusText = isOverBudget
        ? '\$${remaining.abs().toStringAsFixed(2)} over budget'
        : '\$${remaining.toStringAsFixed(2)} left';

    final rawProgress = event.budgetAmount <= 0 ? 0.0 : (event.spentAmount / event.budgetAmount);
    final progress = rawProgress.clamp(0.0, 1.0);

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => _onEditEvent(event),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F2937) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF111827) : const Color(0xFFE9EDFF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(event.icon, color: event.iconColor, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white : const Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _dateFormat.format(event.eventDate),
                        style: TextStyle(
                          fontSize: 11.5,
                          color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.edit_outlined,
                    color: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF4B5563),
                    size: 20,
                  ),
                  onPressed: () => _onEditEvent(event),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              statusText,
              style: TextStyle(
                color: isOverBudget ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'Spent',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                  ),
                ),
                const Spacer(),
                Text(
                  '\$${event.spentAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white : const Color(0xFF111827),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 14,
                backgroundColor: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                valueColor: AlwaysStoppedAnimation<Color>(
                  isOverBudget ? const Color(0xFFEF4444) : const Color(0xFF00C853),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Budget',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                  ),
                ),
                const Spacer(),
                Text(
                  '\$${event.budgetAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white : const Color(0xFF111827),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onAddEvent() async {
    final result = await showEventDialog(context);
    if (result == null) return;

    final newEvent = Event(
      id: const Uuid().v4(),
      title: result.title,
      eventDate: result.eventDate,
      spentAmount: result.spentAmount,
      budgetAmount: result.budgetAmount,
      icon: Icons.event,
      iconColor: const Color(0xFF006D5B),
    );

    try {
      await _repo.insertEvent(newEvent);

      var autoAddFailed = false;
      if (result.autoAddToExpenses && result.spentAmount > 0) {
        final newTx = AppTransaction(
          id: const Uuid().v4(),
          title: result.title,
          category: 'Events',
          amount: result.spentAmount,
          date: DateTime.now(),
          type: TransactionType.expense,
          icon: Icons.event,
          sourceType: 'event_auto',
        );

        if (mounted) {
          try {
            await Provider.of<AppProvider>(context, listen: false).addTransaction(newTx);
          } catch (_) {
            autoAddFailed = true;
          }
        }
      }

      await _loadEvents();
      if (autoAddFailed && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event created, but auto-add to expenses failed.'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not create event. $e')),
      );
    }
  }

  Future<void> _onEditEvent(Event event) async {
    final result = await showEventDialog(context, initialEvent: event);
    if (result == null) return;

    final updatedEvent = Event(
      id: event.id,
      userId: event.userId,
      title: result.title,
      eventDate: result.eventDate,
      spentAmount: result.spentAmount,
      budgetAmount: result.budgetAmount,
      icon: event.icon,
      iconColor: event.iconColor,
    );

    try {
      await _repo.upsertEvent(updatedEvent);
      await _loadEvents();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${updatedEvent.title} updated')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update event. $e')),
      );
    }
  }

  Future<bool> _confirmDelete(Event event) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete event?'),
        content: Text('Are you sure you want to delete "${event.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    return shouldDelete ?? false;
  }

  Future<void> _deleteEvent(Event event) async {
    try {
      await _repo.deleteEvent(event.id);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${event.title} deleted'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () async {
              await _repo.insertEvent(event);
              await _loadEvents();
            },
          ),
        ),
      );

      await _loadEvents();
    } catch (e) {
      if (!mounted) return;
      await _loadEvents();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not delete event. $e')),
      );
    }
  }
}
