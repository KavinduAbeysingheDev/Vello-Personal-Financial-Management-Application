import '../models/event_model.dart';
import '../repositories/event_repository.dart';

class EventService {
  static final _repository = EventRepository();

  static Future<List<Event>> getEvents() async {
    return await _repository.fetchEvents();
  }

  static Future<void> addEvent(Event event) async {
    await _repository.insertEvent(event);
  }

  static Future<void> deleteEvent(Event event) async {
    await _repository.deleteEvent(event.id);
  }
}