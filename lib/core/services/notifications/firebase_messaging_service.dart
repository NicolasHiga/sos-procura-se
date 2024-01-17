import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:sos_app/core/config/routes.dart';
import 'package:sos_app/core/services/auth/auth_service.dart';
import 'package:sos_app/core/services/notifications/notification_service.dart';

class FirebaseMessagingService {
  final NotificationService _notificationService;

  FirebaseMessagingService(this._notificationService);

  Future<void> initialize() async {
    // Para o app que esteja aberto
    await FirebaseMessaging.instance.requestPermission();
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      badge: true,
      sound: true,
      alert: true,
    );
    // Cria um token para o usuário
    getDeviceFirebaseToken();
    _handleInitialMessage();
    _onMessage();
    _onMessageOpenedApp();
  }

  getDeviceFirebaseToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    log("TOKEN: $token");
    AuthService().checkToken(token!);
  }

  _handleInitialMessage() {
    // Obtenha a última mensagem recebida quando o aplicativo estava fechado
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        // Lidar com a mensagem inicial
        _goToPageAfterMessage(message);
      }
    });
  }

  _onMessage() {
    FirebaseMessaging.onMessage.listen((message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        _notificationService.showLocalNotification(CustomNotification(
          id: android.hashCode,
          title: notification.title!,
          body: notification.body!,
          payload: message.data['route'] ?? '',
        ));
      }
    });
  }

  _onMessageOpenedApp() {
    FirebaseMessaging.onMessageOpenedApp.listen(_goToPageAfterMessage);
  }

  _goToPageAfterMessage(message) {
    final String route = message.data['route'] ?? '';
    
    if(route.isNotEmpty) {
      Routes.navigatorKey?.currentState?.pushReplacementNamed(route);
    }
  }
}