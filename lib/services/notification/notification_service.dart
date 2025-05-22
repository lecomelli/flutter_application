import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;
  
  static Future<void> initialize() async {
    if (_initialized) return;
    
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
    
    _initialized = true;
  }
  
  static Future<bool> requestPermissions() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    final iosPlugin = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    
    bool granted = true;
    
    if (androidPlugin != null) {
      granted = await androidPlugin.requestNotificationsPermission() ?? false;
    }
    
    if (iosPlugin != null) {
      granted = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      ) ?? false;
    }
    
    return granted;
  }
  
  // Schedule a reminder notification
  static Future<void> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'reminders',
      'Lembretes de Contato',
      channelDescription: 'Lembretes para manter contato com pessoas',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
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
    
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
  
  // Schedule recurring reminder
  static Future<void> scheduleRecurringReminder({
    required int id,
    required String title,
    required String body,
    required DateTime firstDate,
    required int intervalDays,
    String? payload,
  }) async {
    // Schedule multiple notifications for the next year
    final now = DateTime.now();
    var nextDate = firstDate;
    int notificationId = id;
    
    while (nextDate.isBefore(now.add(const Duration(days: 365)))) {
      if (nextDate.isAfter(now)) {
        await scheduleReminder(
          id: notificationId,
          title: title,
          body: body,
          scheduledDate: nextDate,
          payload: payload,
        );
      }
      nextDate = nextDate.add(Duration(days: intervalDays));
      notificationId++;
    }
  }
  
  // Cancel notification
  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }
  
  // Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
  
  // Get pending notifications
  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
  
  // Show immediate notification
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'general',
      'Notificações Gerais',
      channelDescription: 'Notificações gerais do app',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
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
    
    await _notifications.show(id, title, body, details, payload: payload);
  }
  
  // Handle notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      // Handle navigation based on payload
      // This will be implemented with router navigation
      print('Notification tapped with payload: $payload');
    }
  }
  
  // Utility methods for reminder notifications
  static String generateReminderTitle(String contactName) {
    return 'Lembrete: $contactName';
  }
  
  static String generateReminderBody(String contactName, int daysSince) {
    if (daysSince <= 0) {
      return 'Que tal entrar em contato com $contactName?';
    } else if (daysSince == 1) {
      return 'Faz 1 dia que você não fala com $contactName';
    } else if (daysSince <= 7) {
      return 'Faz $daysSince dias que você não fala com $contactName';
    } else if (daysSince <= 30) {
      final weeks = (daysSince / 7).round();
      return 'Faz ${weeks == 1 ? '1 semana' : '$weeks semanas'} que você não fala com $contactName';
    } else {
      final months = (daysSince / 30).round();
      return 'Faz ${months == 1 ? '1 mês' : '$months meses'} que você não fala com $contactName';
    }
  }
}