// lib/notification_service.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = 
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings androidSettings = 
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings iosSettings = 
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);
  }

  Future<void> showHostNotification({
    required String visitorName,
    required String hostUnit,
  }) async {
    const AndroidNotificationDetails androidDetails = 
        AndroidNotificationDetails(
          'host_notifications',
          'Host Notifications',
          channelDescription: 'Notifications for host alerts',
          importance: Importance.max,
          priority: Priority.max,
          enableVibration: true,
          icon: '@mipmap/ic_launcher',
        );

    const DarwinNotificationDetails iosDetails = 
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      0,
      '👤 Visitor Arrived!',
      '$visitorName has arrived at $hostUnit',
      details,
    );
  }

  Future<void> showCheckoutNotification({
    required String visitorName,
  }) async {
    const AndroidNotificationDetails androidDetails = 
        AndroidNotificationDetails(
          'host_notifications',
          'Host Notifications',
          channelDescription: 'Notifications for host alerts',
          importance: Importance.max,
          priority: Priority.max,
        );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _notifications.show(
      1,
      '🚪 Visitor Departed',
      '$visitorName has checked out',
      details,
    );
  }
}