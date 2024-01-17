
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sos_app/core/services/notifications/firebase_messaging_service.dart';
import 'package:sos_app/core/services/notifications/notification_service.dart';
import 'package:sos_app/pages/homePage/home_page.dart';

class LoadNotifications extends StatefulWidget {
  const LoadNotifications({super.key});

  @override
  State<LoadNotifications> createState() => _LoadNotificationsState();
}

class _LoadNotificationsState extends State<LoadNotifications> {
  late bool isRecentlyOpened;
  @override
  void initState() {
    super.initState();
    initializeFirebaseMessaging();
    checkNotifications();
  }

  @override
  void dispose() {
    super.dispose();
  }

  initializeFirebaseMessaging() async {
    await Provider.of<FirebaseMessagingService>(context, listen: false)
        .initialize();
  }

  checkNotifications() async {
    await Provider.of<NotificationService>(context, listen: false)
        .checkForNotifications(context);
  }

  @override
  Widget build(BuildContext context) {
    return const HomePage(setRoutePage: 0, isPeople: true,);
  }
}
