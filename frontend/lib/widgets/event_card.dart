import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/event_model.dart';

class EventCard extends StatelessWidget {
  final Event event;

  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('MMM d, yyyy').format(event.eventDate);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      child: ListTile(
        title: Text(event.title),
        subtitle: Text('$formattedDate • LKR ${event.spentAmount} of LKR ${event.budgetAmount}'),
      ),
    );
  }
}
