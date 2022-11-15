import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart';

class Notifications {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  Notifications();

  Future<bool?> initialize() async => _notificationsPlugin.initialize(
        InitializationSettings(
          macOS: _initializeDarwinSettings(),
          iOS: _initializeDarwinSettings(),
        ),
      );

  Future<NotificationAppLaunchDetails?> getAppLaunchDetails() =>
      _notificationsPlugin.getNotificationAppLaunchDetails();

  Future<bool?> requestIOSPermissions() async => _notificationsPlugin
      .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );

  DarwinInitializationSettings _initializeDarwinSettings() =>
      DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
        notificationCategories: [
          DarwinNotificationCategory(
            'planners',
            actions: <DarwinNotificationAction>[
              DarwinNotificationAction.plain(
                'plan',
                'Plan Outfit',
                options: {
                  DarwinNotificationActionOption.foreground,
                },
              ),
            ],
            options: <DarwinNotificationCategoryOption>{
              DarwinNotificationCategoryOption.allowAnnouncement,
              DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
            },
          ),
        ],
      );

  Future<void> clearAllNotifications() => _notificationsPlugin.cancelAll();

  Future<void> scheduleReminders(
    String title,
    String body,
    NotificationDetails details,
    TZDateTime time, {
    String? payload,
    DateTimeComponents? components,
  }) =>
      _notificationsPlugin.zonedSchedule(
        0,
        title,
        body,
        time,
        details,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidAllowWhileIdle: true,
        matchDateTimeComponents: components,
      );
}
