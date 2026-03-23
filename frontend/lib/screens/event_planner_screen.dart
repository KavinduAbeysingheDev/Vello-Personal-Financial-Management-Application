import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../widgets/vello_top_bar.dart';
import '../services/event_service.dart';
import '../models/event_model.dart';
import '../models/app_models.dart';
import '../services/app_provider.dart';
import '../widgets/vello_drawer.dart';

class EventPlannerScreen extends StatefulWidget {
  const EventPlannerScreen({super.key});

  @override
  State<EventPlannerScreen> createState() => _EventPlannerScreenState();
}

class _EventPlannerScreenState extends State<EventPlannerScreen> {
  List<Event> _events = [];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final events = await EventService.getEvents();
    setState(() {
      _events = events;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const VelloTopBar(),
      endDrawer: const VelloDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(10, 12, 10, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Event Planner",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "Plan and budget for festivals, parties, and special occasions",
                        style: TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () => _showAddEventDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006D5B),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text(
                    "New Event",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ..._events.map((event) {
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
                  onDismissed: (direction) async {
                    await EventService.deleteEvent(event);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${event.title} deleted')),
                    );
                    await _loadEvents();
                  },
                  child: EventPlannerBudgetCard(
                    title: event.title,
                    date: event.date,
                    icon: event.icon,
                    iconColor: event.iconColor,
                    spentAmount: event.spentAmount,
                    budgetAmount: event.budgetAmount,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showAddEventDialog(BuildContext context) {
    final titleController = TextEditingController();
    final budgetController = TextEditingController();
    final spentController = TextEditingController();
    bool autoAddToExpenses = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFFF5F3F8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text(
            "New Event",
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: "Event Title",
                    labelStyle: TextStyle(fontSize: 13, color: Colors.black54),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black26),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF6750A4), width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: budgetController,
                  decoration: const InputDecoration(
                    labelText: "Budget Amount (\$)",
                    labelStyle: TextStyle(fontSize: 13, color: Colors.black54),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black26),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF6750A4), width: 2),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: spentController,
                  decoration: const InputDecoration(
                    labelText: "Spent Amount (\$)",
                    labelStyle: TextStyle(fontSize: 13, color: Colors.black54),
                    hintText: "0.00",
                    hintStyle: TextStyle(fontSize: 13, color: Colors.black26),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black26),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF6750A4), width: 2),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    "Auto-add to Expenses",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  subtitle: const Text(
                    "Adds this event's spent amount to your expense list",
                    style: TextStyle(fontSize: 11, color: Colors.black45),
                  ),
                  activeColor: const Color(0xFF006D5B),
                  value: autoAddToExpenses,
                  onChanged: (val) => setDialogState(() => autoAddToExpenses = val),
                ),
              ],
            ),
          ),
          actionsPadding: const EdgeInsets.only(right: 24, bottom: 20),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Cancel", style: TextStyle(color: Color(0xFF6750A4))),
            ),
            OutlinedButton(
              onPressed: () async {
                final title = titleController.text.isNotEmpty ? titleController.text : "New Event";
                final budget = double.tryParse(budgetController.text) ?? 0.0;
                final spent = double.tryParse(spentController.text) ?? 0.0;

                final newEvent = Event(
                  id: const Uuid().v4(),
                  title: title,
                  date: "Upcoming",
                  spentAmount: spent,
                  budgetAmount: budget,
                  icon: Icons.event,
                  iconColor: const Color(0xFF006D5B),
                );
                await EventService.addEvent(newEvent);

                // Auto-add to expenses if toggled on
                if (autoAddToExpenses && spent > 0) {
                  final newTx = AppTransaction(
                    id: const Uuid().v4(),
                    title: title,
                    category: 'Events',
                    amount: spent,
                    date: DateTime.now(),
                    type: TransactionType.expense,
                    icon: Icons.event,
                  );
                  if (context.mounted) {
                    Provider.of<AppProvider>(context, listen: false).addTransaction(newTx);
                  }
                }

                await _loadEvents();
                if (context.mounted) Navigator.pop(dialogContext);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF6750A4),
                side: const BorderSide(color: Color(0xFFE8DEF8)),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              child: const Text("Add"),
            ),
          ],
        ),
      ),
    );
  }
}

class EventPlannerBudgetCard extends StatelessWidget {
  final String title;
  final String date;
  final IconData icon;
  final Color iconColor;
  final double spentAmount;
  final double budgetAmount;

  const EventPlannerBudgetCard({
    super.key,
    required this.title,
    required this.date,
    required this.icon,
    required this.iconColor,
    required this.spentAmount,
    required this.budgetAmount,
  });

  @override
  Widget build(BuildContext context) {
    final double leftAmount = budgetAmount - spentAmount;
    final double progress = budgetAmount == 0
        ? 0
        : (spentAmount / budgetAmount);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
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
                  color: const Color(0xFFE9EDFF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      date,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),

              Text(
                "\$${leftAmount.toStringAsFixed(2)} left",
                style: const TextStyle(
                  color: Color(0xFF16A34A),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              const Text(
                "Spent",
                style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
              ),
              const Spacer(),
              Text(
                "\$${spentAmount.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF111827),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 14, // Figma thick progress bar
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF00C853), // Figma vibrance
              ),
            ),
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              const Text(
                "Budget",
                style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
              ),
              const Spacer(),
              Text(
                "\$${budgetAmount.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF111827),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
