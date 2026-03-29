import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/event_model.dart';
import 'event_form_validator.dart';

class EventDialogResult {
  final String title;
  final double budgetAmount;
  final double spentAmount;
  final DateTime eventDate;
  final bool autoAddToExpenses;

  const EventDialogResult({
    required this.title,
    required this.budgetAmount,
    required this.spentAmount,
    required this.eventDate,
    required this.autoAddToExpenses,
  });
}

Future<EventDialogResult?> showEventDialog(
  BuildContext context, {
  Event? initialEvent,
}) {
  return showDialog<EventDialogResult>(
    context: context,
    builder: (dialogContext) => _EventDialog(initialEvent: initialEvent),
  );
}

class _EventDialog extends StatefulWidget {
  final Event? initialEvent;

  const _EventDialog({this.initialEvent});

  @override
  State<_EventDialog> createState() => _EventDialogState();
}

class _EventDialogState extends State<_EventDialog> {
  final _titleController = TextEditingController();
  final _budgetController = TextEditingController();
  final _spentController = TextEditingController();
  final _dateFmt = DateFormat('MMM d, yyyy');

  DateTime? _selectedDate;
  bool _autoAddToExpenses = false;
  String? _titleError;
  String? _budgetError;
  String? _spentError;
  String? _dateError;

  bool get _isEdit => widget.initialEvent != null;

  @override
  void initState() {
    super.initState();
    final event = widget.initialEvent;
    if (event != null) {
      _titleController.text = event.title;
      _budgetController.text = event.budgetAmount.toStringAsFixed(2);
      _spentController.text = event.spentAmount.toStringAsFixed(2);
      _selectedDate = event.eventDate;
    } else {
      _selectedDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _budgetController.dispose();
    _spentController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial = _selectedDate ?? now;
    final selected = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 10),
    );

    if (selected != null) {
      setState(() {
        _selectedDate = selected;
        _dateError = null;
      });
    }
  }

  bool _validate() {
    final title = _titleController.text;
    final budget = EventFormValidator.parseAmount(_budgetController.text);
    final spent = EventFormValidator.parseAmount(_spentController.text) ?? 0.0;

    setState(() {
      _titleError = EventFormValidator.validateTitle(title);
      _budgetError = EventFormValidator.validateBudget(budget);
      _spentError = EventFormValidator.validateSpent(spent);
      _dateError = _selectedDate == null ? 'Date is required' : null;
    });

    return _titleError == null &&
        _budgetError == null &&
        _spentError == null &&
        _dateError == null;
  }

  void _submit() {
    if (!_validate()) return;

    Navigator.of(context).pop(
      EventDialogResult(
        title: _titleController.text.trim(),
        budgetAmount: EventFormValidator.parseAmount(_budgetController.text)!,
        spentAmount: EventFormValidator.parseAmount(_spentController.text) ?? 0.0,
        eventDate: _selectedDate!,
        autoAddToExpenses: !_isEdit && _autoAddToExpenses,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(_isEdit ? 'Edit Event' : 'New Event'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Event Title',
                errorText: _titleError,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _budgetController,
              decoration: InputDecoration(
                labelText: 'Budget Amount (\$)',
                errorText: _budgetError,
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _spentController,
              decoration: InputDecoration(
                labelText: 'Spent Amount (\$)',
                hintText: '0.00',
                errorText: _spentError,
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Event Date',
                  errorText: _dateError,
                  border: const OutlineInputBorder(),
                ),
                child: Text(
                  _selectedDate == null
                      ? 'Select a date'
                      : _dateFmt.format(_selectedDate!),
                ),
              ),
            ),
            if (!_isEdit) ...[
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Auto-add to Expenses'),
                subtitle: const Text('Add spent amount to expenses'),
                activeThumbColor: const Color(0xFF006D5B),
                value: _autoAddToExpenses,
                onChanged: (val) => setState(() => _autoAddToExpenses = val),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        OutlinedButton(
          onPressed: _submit,
          child: Text(_isEdit ? 'Update' : 'Add'),
        ),
      ],
    );
  }
}
