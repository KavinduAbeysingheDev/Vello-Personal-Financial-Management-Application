import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

const String _taskName = 'vello_transaction_reminder_task';
const String _uniqueTaskName = 'vello_transaction_reminder_unique_task';
const int _notificationId = 6001;

@pragma('vm:entry-point')
void reminderCallbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();

    final notifications = FlutterLocalNotificationsPlugin();
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await notifications.initialize(initSettings);

    const androidDetails = AndroidNotificationDetails(
      'vello_reminder_channel',
      'Vello Reminders',
      channelDescription: 'Transaction reminder notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);
    await notifications.show(
      _notificationId,
      'Vello',
      'Reminder: add a new transaction.',
      details,
    );

    return Future.value(true);
  });
}

class ReminderService {
  ReminderService._();
  static final ReminderService instance = ReminderService._();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    if (!Platform.isAndroid) return;

    WidgetsFlutterBinding.ensureInitialized();
    await Workmanager().initialize(reminderCallbackDispatcher, isInDebugMode: false);

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidInit);
    await _notifications.initialize(settings);

    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('reminder') ?? false;
    if (enabled) {
      await _registerReminderTask();
    } else {
      await _cancelReminderTask();
    }
  }

  Future<bool> setReminderEnabled(bool enabled) async {
    if (!Platform.isAndroid) return enabled;
    if (!_initialized) {
      await initialize();
    }

    if (enabled) {
      final granted = await _requestNotificationPermission();
      if (!granted) {
        await _cancelReminderTask();
        return false;
      }
      await _registerReminderTask();
      return true;
    }

    await _cancelReminderTask();
    return false;
  }

  Future<bool> _requestNotificationPermission() async {
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin == null) return false;

    final granted = await androidPlugin.requestNotificationsPermission();
    return granted ?? false;
  }

  Future<void> _registerReminderTask() async {
    await Workmanager().registerPeriodicTask(
      _uniqueTaskName,
      _taskName,
      frequency: const Duration(hours: 6),
      initialDelay: const Duration(hours: 6),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
      constraints: Constraints(
        networkType: NetworkType.notRequired,
      ),
    );
  }

  Future<void> _cancelReminderTask() async {
    await Workmanager().cancelByUniqueName(_uniqueTaskName);
    await _notifications.cancel(_notificationId);
  }
}
