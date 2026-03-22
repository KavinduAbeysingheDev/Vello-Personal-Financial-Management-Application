import 'package:flutter/material.dart';
import '../models/event_model.dart';
import 'database_helper.dart';

class EventService {
  static Future<List<Event>> getEvents() async {
    return await DatabaseHelper.instance.readAllEvents();
  }

  static Future<void> addEvent(Event event) async {
    await DatabaseHelper.instance.createEvent(event);
  }

  static Future<void> deleteEvent(Event event) async {
    if (event.id != null) {
      await DatabaseHelper.instance.deleteEvent(event.id!);
    }
  }
}