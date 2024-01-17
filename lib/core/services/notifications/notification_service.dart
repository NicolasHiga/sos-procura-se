import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sos_app/core/config/routes.dart';

class CustomNotification {
  final int id;
  final String title;
  final String body;
  final String? payload;
  final RemoteMessage? remoteMessage;

  CustomNotification({
    required this.id,
    required this.title,
    required this.body,
    this.payload,
    this.remoteMessage,
  });
}

class NotificationService {
  late FlutterLocalNotificationsPlugin localNotificationsPlugin;
  late AndroidNotificationDetails androidDetails;
  late IOSNotificationDetails iosNotificationDetails;
  late IOSInitializationSettings iosSettings;

  NotificationService(BuildContext context) {
    localNotificationsPlugin = FlutterLocalNotificationsPlugin();
    _setupAndroidDetails();
    _setupIOSDetails();
    _setupNotifications(context);
  }

  _setupAndroidDetails() {
    androidDetails = const AndroidNotificationDetails(
      'lembretes_notifications_details',
      'Lembretes',
      channelDescription: 'Este canal é para lembretes!',
      importance: Importance.max,
      priority: Priority.max,
      enableVibration: true,
      icon: '@drawable/ic_launcher_foreground',
    );
  }

  _setupIOSDetails() {
    iosNotificationDetails = const IOSNotificationDetails(
      presentSound: true,
      presentAlert: true,
      presentBadge: true,
    );
  }

  _setupNotifications(BuildContext context) async {
    await _initializeNotifications(context);
  }

  _initializeNotifications(BuildContext context) async {
    const android =
        AndroidInitializationSettings('@drawable/ic_launcher_foreground');
    IOSInitializationSettings ios = IOSInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: (id, title, body, payload) async {
        _onSelectNotification(context, payload);
      },
    );
    // Fazer: macOs, iOS, Linux...
    await localNotificationsPlugin.initialize(
      InitializationSettings(
        android: android,
        iOS: ios,
      ),
      onSelectNotification: (payload) {
        _onSelectNotification(context, payload);
      },
    );
  }

  _onSelectNotification(BuildContext context, String? payload) {
    if (payload != null && payload.isNotEmpty) {
      Navigator.of(Routes.navigatorKey!.currentContext!)
          .pushReplacementNamed(payload);
    }
  }

  showLocalNotification(CustomNotification notification) {
    localNotificationsPlugin.show(
      notification.id,
      notification.title,
      notification.body,
      NotificationDetails(
        android: androidDetails,
        iOS: iosNotificationDetails,
      ),
      payload: notification.payload,
    );
  }

  checkForNotifications(BuildContext context) async {
    final details =
        await localNotificationsPlugin.getNotificationAppLaunchDetails();
    if (details != null && details.didNotificationLaunchApp) {
      // ignore: use_build_context_synchronously
      _onSelectNotification(context, details.payload);
    }
  }
}
