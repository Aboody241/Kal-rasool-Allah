import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:hive/hive.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _boxName = 'notification_box';
  static const String _kEnabled = 'notif_enabled';
  static const String _kHour = 'notif_hour';
  static const String _kMinute = 'notif_minute';
  static const int _notifId = 1001;

  // =====================
  // Init
  // =====================
  Future<void> init() async {
    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings);

    // Re-schedule on init if was enabled before
    await _restoreScheduleIfNeeded();
  }

  // =====================
  // Schedule daily notification
  // =====================
  Future<void> scheduleDailyNotification(TimeOfDay time) async {
    // Save preference
    final box = Hive.box(_boxName);
    await box.put(_kEnabled, true);
    await box.put(_kHour, time.hour);
    await box.put(_kMinute, time.minute);

    await _plugin.cancel(_notifId);

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // If the time already passed today, schedule for tomorrow
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      'daily_reminder_channel',
      'التذكير اليومي',
      channelDescription: 'تذكير يومي بسُنّة اليوم',
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(''),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.zonedSchedule(
      _notifId,
      'قال رسول الله ﷺ',
      'لا تنسَ سُنّتك اليومية 🌿',
      scheduled,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // repeat daily
    );
  }

  // =====================
  // Cancel notifications
  // =====================
  Future<void> cancelNotifications() async {
    final box = Hive.box(_boxName);
    await box.put(_kEnabled, false);
    await _plugin.cancel(_notifId);
  }

  // =====================
  // Restore on app restart
  // =====================
  Future<void> _restoreScheduleIfNeeded() async {
    final box = Hive.box(_boxName);
    final isEnabled = box.get(_kEnabled, defaultValue: false) as bool;
    if (!isEnabled) return;

    final hour = box.get(_kHour, defaultValue: 9) as int;
    final minute = box.get(_kMinute, defaultValue: 0) as int;
    await scheduleDailyNotification(TimeOfDay(hour: hour, minute: minute));
  }

  // =====================
  // Load saved settings
  // =====================
  bool getSavedEnabled() {
    final box = Hive.box(_boxName);
    return box.get(_kEnabled, defaultValue: false) as bool;
  }

  TimeOfDay getSavedTime() {
    final box = Hive.box(_boxName);
    final hour = box.get(_kHour, defaultValue: 9) as int;
    final minute = box.get(_kMinute, defaultValue: 0) as int;
    return TimeOfDay(hour: hour, minute: minute);
  }

  // =====================
  // Request Permissions (Android 13+)
  // =====================
  Future<void> requestPermission() async {
    final androidImplementation =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidImplementation?.requestNotificationsPermission();
    await androidImplementation?.requestExactAlarmsPermission();
  }
}
