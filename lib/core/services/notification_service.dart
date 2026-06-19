import 'dart:math';
import 'dart:typed_data';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:hive/hive.dart';
import 'package:kal_rasol_allah/core/routes/approuter.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  static const String _boxName = 'notification_box';

  // Hive preference keys
  static const String kMasterEnabled = 'master_enabled';
  static const String kSoundEnabled = 'sound_enabled';
  static const String kVibrationEnabled = 'vibration_enabled';

  static const String kMorningEnabled = 'morning_enabled';
  static const String kMorningStartHour = 'morning_start_hour';
  static const String kMorningStartMinute = 'morning_start_minute';
  static const String kMorningEndHour = 'morning_end_hour';
  static const String kMorningEndMinute = 'morning_end_minute';

  static const String kEveningEnabled = 'evening_enabled';
  static const String kEveningStartHour = 'evening_start_hour';
  static const String kEveningStartMinute = 'evening_start_minute';
  static const String kEveningEndHour = 'evening_end_hour';
  static const String kEveningEndMinute = 'evening_end_minute';

  static const String kDhikrEnabled = 'dhikr_enabled';
  static const String kDhikrCount = 'dhikr_count';
  static const String kDhikrQuietStartHour = 'dhikr_quiet_start_hour';
  static const String kDhikrQuietStartMinute = 'dhikr_quiet_start_minute';
  static const String kDhikrQuietEndHour = 'dhikr_quiet_end_hour';
  static const String kDhikrQuietEndMinute = 'dhikr_quiet_end_minute';

  // Constants
  static const int morningNotifId = 100;
  static const int eveningNotifId = 200;
  static const int dhikrNotifBaseId = 300;

  // Data lists
  final List<Map<String, String>> _morningMessages = [
    {'title': '🌤️ لا تنسَ أذكار الصباح', 'body': 'أصبحنا وأصبح الملك لله والحمد لله...'},
    {'title': '☀️ ابدأ يومك بذكر الله', 'body': 'ابدأ يومك براحة القلب وذكر الله'},
    {'title': '🤍 حصّن يومك بالأذكار', 'body': 'دقيقة أذكار قد تغيّر يومك بالكامل'},
    {'title': '📖 وقت أذكار الصباح', 'body': 'اذكر الله ليطمئن قلبك وسلّم له أمرك'},
  ];

  final List<Map<String, String>> _eveningMessages = [
    {'title': '🌙 لا تنسَ أذكار المساء', 'body': 'أعوذ بكلمات الله التامات من شر ما خلق'},
    {'title': '🤍 اختم يومك بذكر الله', 'body': 'اجعل آخر يومك ذكراً لله وطمأنينة لروحك'},
    {'title': '📿 مساء الطمأنينة يبدأ بالأذكار', 'body': 'راحة القلب تبدأ بالذكر والشكر'},
    {'title': '🌌 وقت أذكار المساء', 'body': 'اذكر الله قبل نومك ونم قرير العين'},
  ];

  final List<String> _dhikrBodies = [
    'سبحان الله 🤍',
    'استغفر الله العظيم',
    'لا إله إلا الله وحده لا شريك له',
    'صلِّ على النبي ﷺ',
    'الحمد لله حمداً كثيراً',
    'الله أكبر كبيراً',
    '🤍 الله يراك الآن فاذكره في ملأ يذكرك',
    '🌿 ذكر الله يطمئن القلب ويزيل الكرب',
    '📖 لا تنسَ وردك اليومي من السنن النبوية',
    '✨ دقيقة ذكر لله خير من ساعات غفلة',
    '🕊️ استغفار واحد بيقين قد يغيّر يومك وحياتك',
    'ﷺ هل صليت على النبي اليوم؟ صلِّ عليه وتفاءل',
  ];

  // ==========================================
  // Initialize Service
  // ==========================================
  Future<void> init() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final payload = response.payload;
        if (payload != null && payload.isNotEmpty) {
          handleNotificationTap(payload);
        }
      },
    );

    // Initial default settings and dynamic rescheduling
    _initDefaultPreferences();
    await rescheduleAll();
  }

  // ==========================================
  // Handle Notification Action Taps
  // ==========================================
  static void handleNotificationTap(String payload) {
    if (payload == 'morning_athkar') {
      Approuter.navigatorKey.currentState?.pushNamed(
        Approuter.azkarScreen,
        arguments: 'أذكار الصباح',
      );
    } else if (payload == 'evening_athkar') {
      Approuter.navigatorKey.currentState?.pushNamed(
        Approuter.azkarScreen,
        arguments: 'أذكار المساء',
      );
    } else if (payload == 'random_dhikr') {
      Approuter.navigatorKey.currentState?.pushNamed(
        Approuter.sebhaScreen,
      );
    }
  }

  // ==========================================
  // Default values initialization
  // ==========================================
  void _initDefaultPreferences() {
    final box = Hive.box(_boxName);
    if (box.get(kMasterEnabled) == null) box.put(kMasterEnabled, true);
    if (box.get(kSoundEnabled) == null) box.put(kSoundEnabled, true);
    if (box.get(kVibrationEnabled) == null) box.put(kVibrationEnabled, true);

    if (box.get(kMorningEnabled) == null) box.put(kMorningEnabled, true);
    if (box.get(kMorningStartHour) == null) box.put(kMorningStartHour, 6);
    if (box.get(kMorningStartMinute) == null) box.put(kMorningStartMinute, 0);
    if (box.get(kMorningEndHour) == null) box.put(kMorningEndHour, 10);
    if (box.get(kMorningEndMinute) == null) box.put(kMorningEndMinute, 0);

    if (box.get(kEveningEnabled) == null) box.put(kEveningEnabled, true);
    if (box.get(kEveningStartHour) == null) box.put(kEveningStartHour, 17);
    if (box.get(kEveningStartMinute) == null) box.put(kEveningStartMinute, 0);
    if (box.get(kEveningEndHour) == null) box.put(kEveningEndHour, 22);
    if (box.get(kEveningEndMinute) == null) box.put(kEveningEndMinute, 0);

    if (box.get(kDhikrEnabled) == null) box.put(kDhikrEnabled, true);
    if (box.get(kDhikrCount) == null) box.put(kDhikrCount, 3);
    if (box.get(kDhikrQuietStartHour) == null) box.put(kDhikrQuietStartHour, 23);
    if (box.get(kDhikrQuietStartMinute) == null) box.put(kDhikrQuietStartMinute, 0);
    if (box.get(kDhikrQuietEndHour) == null) box.put(kDhikrQuietEndHour, 8);
    if (box.get(kDhikrQuietEndMinute) == null) box.put(kDhikrQuietEndMinute, 0);
  }

  // ==========================================
  // Schedule or Reschedule everything
  // ==========================================
  Future<void> rescheduleAll() async {
    // 1. Cancel everything first to avoid duplicate notifications
    await _plugin.cancelAll();

    final box = Hive.box(_boxName);
    final master = box.get(kMasterEnabled, defaultValue: true) as bool;
    if (!master) return;

    final sound = box.get(kSoundEnabled, defaultValue: true) as bool;
    final vibration = box.get(kVibrationEnabled, defaultValue: true) as bool;

    final androidDetails = AndroidNotificationDetails(
      'islamic_notifications_channel',
      'التذكيرات الإسلامية الذكية',
      channelDescription: 'تذكير يومي عشوائي بأذكار الصباح والمساء والسنن النبوية',
      importance: Importance.high,
      priority: Priority.high,
      playSound: sound,
      enableVibration: vibration,
      vibrationPattern: vibration ? Int64List.fromList([0, 500, 200, 500]) : null,
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: sound,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final now = tz.TZDateTime.now(tz.local);
    final random = Random();

    // 2. Schedule Morning Athkar
    final morningEnabled = box.get(kMorningEnabled, defaultValue: true) as bool;
    if (morningEnabled) {
      final startH = box.get(kMorningStartHour, defaultValue: 6) as int;
      final startM = box.get(kMorningStartMinute, defaultValue: 0) as int;
      final endH = box.get(kMorningEndHour, defaultValue: 10) as int;
      final endM = box.get(kMorningEndMinute, defaultValue: 0) as int;

      final randomTimeToday = _generateRandomTimeWithinRange(startH, startM, endH, endM, now, random);
      var scheduledTime = randomTimeToday;
      if (scheduledTime.isBefore(now)) {
        // If today's slot has passed, schedule for tomorrow
        final tomorrow = now.add(const Duration(days: 1));
        scheduledTime = _generateRandomTimeWithinRange(startH, startM, endH, endM, tomorrow, random);
      }

      final msg = _morningMessages[random.nextInt(_morningMessages.length)];
      await _plugin.zonedSchedule(
        morningNotifId,
        msg['title'],
        msg['body'],
        scheduledTime,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'morning_athkar',
      );
    }

    // 3. Schedule Evening Athkar
    final eveningEnabled = box.get(kEveningEnabled, defaultValue: true) as bool;
    if (eveningEnabled) {
      final startH = box.get(kEveningStartHour, defaultValue: 17) as int;
      final startM = box.get(kEveningStartMinute, defaultValue: 0) as int;
      final endH = box.get(kEveningEndHour, defaultValue: 22) as int;
      final endM = box.get(kEveningEndMinute, defaultValue: 0) as int;

      final randomTimeToday = _generateRandomTimeWithinRange(startH, startM, endH, endM, now, random);
      var scheduledTime = randomTimeToday;
      if (scheduledTime.isBefore(now)) {
        final tomorrow = now.add(const Duration(days: 1));
        scheduledTime = _generateRandomTimeWithinRange(startH, startM, endH, endM, tomorrow, random);
      }

      final msg = _eveningMessages[random.nextInt(_eveningMessages.length)];
      await _plugin.zonedSchedule(
        eveningNotifId,
        msg['title'],
        msg['body'],
        scheduledTime,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'evening_athkar',
      );
    }

    // 4. Schedule Random Dhikr Notifications
    final dhikrEnabled = box.get(kDhikrEnabled, defaultValue: true) as bool;
    if (dhikrEnabled) {
      final dhikrCount = box.get(kDhikrCount, defaultValue: 3) as int;
      final quietStartH = box.get(kDhikrQuietStartHour, defaultValue: 23) as int;
      final quietEndH = box.get(kDhikrQuietEndHour, defaultValue: 8) as int;

      // Active interval calculation (e.g. 8:00 AM to 11:00 PM)
      // Active period = 24 - (quiet hours duration)
      // We will partition active period into dhikrCount intervals and place a random dhikr in each.
      final activeStartHour = quietEndH;
      final activeEndHour = quietStartH;
      
      int totalActiveMinutes = 0;
      if (activeEndHour > activeStartHour) {
        totalActiveMinutes = (activeEndHour - activeStartHour) * 60;
      } else {
        totalActiveMinutes = ((24 - activeStartHour) + activeEndHour) * 60;
      }

      if (totalActiveMinutes > 60) {
        final intervalMinutes = totalActiveMinutes ~/ dhikrCount;

        for (int i = 0; i < dhikrCount; i++) {
          final startOffset = i * intervalMinutes;
          final endOffset = (i + 1) * intervalMinutes;
          final randomOffset = startOffset + random.nextInt(endOffset - startOffset - 10).clamp(0, intervalMinutes);

          // Construct scheduled time
          var scheduledTime = tz.TZDateTime(
            tz.local,
            now.year,
            now.month,
            now.day,
            activeStartHour,
            0,
          ).add(Duration(minutes: randomOffset));

          if (scheduledTime.isBefore(now)) {
            // Schedule for tomorrow at same interval offset
            final tomorrow = now.add(const Duration(days: 1));
            scheduledTime = tz.TZDateTime(
              tz.local,
              tomorrow.year,
              tomorrow.month,
              tomorrow.day,
              activeStartHour,
              0,
            ).add(Duration(minutes: randomOffset));
          }

          final body = _dhikrBodies[random.nextInt(_dhikrBodies.length)];
          final title = body.contains('ﷺ') ? 'ﷺ صلِّ على الحبيب' : '📿 ذكرى وطمأنينة';

          await _plugin.zonedSchedule(
            dhikrNotifBaseId + i,
            title,
            body,
            scheduledTime,
            details,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
            payload: 'random_dhikr',
          );
        }
      }
    }
  }

  // ==========================================
  // Helper to generate a random TZDateTime within a time range of a target date
  // ==========================================
  tz.TZDateTime _generateRandomTimeWithinRange(
    int startHour,
    int startMinute,
    int endHour,
    int endMinute,
    tz.TZDateTime targetDate,
    Random random,
  ) {
    final startVal = startHour * 60 + startMinute;
    final endVal = endHour * 60 + endMinute;

    int randomMinutesOffset = 0;
    if (endVal > startVal) {
      randomMinutesOffset = startVal + random.nextInt(endVal - startVal);
    } else {
      // Handles wrapping past midnight (e.g. 10 PM to 2 AM)
      final diff = (24 * 60 - startVal) + endVal;
      randomMinutesOffset = (startVal + random.nextInt(diff)) % (24 * 60);
    }

    final hour = randomMinutesOffset ~/ 60;
    final minute = randomMinutesOffset % 60;

    return tz.TZDateTime(
      tz.local,
      targetDate.year,
      targetDate.month,
      targetDate.day,
      hour,
      minute,
    );
  }

  // ==========================================
  // Hive settings wrappers
  // ==========================================
  bool getBoolSetting(String key, {bool defaultValue = true}) {
    return Hive.box(_boxName).get(key, defaultValue: defaultValue) as bool;
  }

  Future<void> setBoolSetting(String key, bool value) async {
    await Hive.box(_boxName).put(key, value);
    await rescheduleAll();
  }

  int getIntSetting(String key, {int defaultValue = 0}) {
    return Hive.box(_boxName).get(key, defaultValue: defaultValue) as int;
  }

  Future<void> setIntSetting(String key, int value) async {
    await Hive.box(_boxName).put(key, value);
    await rescheduleAll();
  }

  // ==========================================
  // Show Immediate Test Notification
  // ==========================================
  Future<void> showImmediateTestNotification() async {
    final sound = getBoolSetting(kSoundEnabled, defaultValue: true);
    final vibration = getBoolSetting(kVibrationEnabled, defaultValue: true);

    final androidDetails = AndroidNotificationDetails(
      'islamic_notifications_channel',
      'التذكيرات الإسلامية الذكية',
      channelDescription: 'قناة اختبار الإشعارات الفورية',
      importance: Importance.max,
      priority: Priority.high,
      playSound: sound,
      enableVibration: vibration,
      vibrationPattern: vibration ? Int64List.fromList([0, 500, 200, 500]) : null,
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: sound,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      999,
      '🧪 إشعار تجريبي فوري',
      'ما شاء الله! نظام الإشعارات والتذكيرات الذكية يعمل بكفاءة تامة 🌿',
      details,
      payload: 'random_dhikr',
    );
  }

  // ==========================================
  // Request Notifications Permission
  // ==========================================
  Future<void> requestPermission() async {
    final androidImplementation = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidImplementation?.requestNotificationsPermission();
    await androidImplementation?.requestExactAlarmsPermission();
  }
}
