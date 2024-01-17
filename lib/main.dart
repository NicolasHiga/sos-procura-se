import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sos_app/core/services/chat/chat_provider.dart';
import 'package:sos_app/core/services/notifications/firebase_messaging_service.dart';
import 'package:sos_app/core/services/notifications/notification_service.dart';
import 'package:sos_app/core/services/user/user_state.dart';
import 'package:sos_app/core/services/user/user_store.dart';
import 'package:sos_app/pages/sos_app.dart';

import 'core/config/env.dart';

void main() async {
  await Env.instance.load();
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserState()),
        ChangeNotifierProvider(create: (_) => UserStore()),
        ChangeNotifierProvider(create: (context) => ConversationProvider()),
        Provider<NotificationService>(
            create: (context) => NotificationService(context)),
        Provider<FirebaseMessagingService>(
          create: (context) =>
              FirebaseMessagingService(context.read<NotificationService>()),
        )
      ],
      child: const SOSApp(),
    ),
  );
}