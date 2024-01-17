import 'package:flutter/material.dart';
import 'package:sos_app/core/ui/helpers/error_page.dart';
import 'package:sos_app/pages/Chat/milo_chat.dart';
import 'package:sos_app/pages/auth/auth_or_app_page.dart';
import 'package:sos_app/pages/auth/forgot_pw_page.dart';
import 'package:sos_app/pages/auth/load_notifications.dart';
import 'package:sos_app/pages/auth/login_page/login_page.dart';
import 'package:sos_app/pages/auth/register_page/register_page.dart';
import 'package:sos_app/pages/homePage/home_page.dart';

class Routes {
  static Map<String, Widget Function(BuildContext)> list =
      <String, WidgetBuilder>{
    '/': (context) => const AuthOrAppPage(),
    '/auth/login': (context) => const LoginPage(),
    '/auth/register': (context) => const RegisterPage(),
    '/auth/forgotPassword': (context) => const ForgotPwPage(),
    '/auth/loadNotification': (context) => const LoadNotifications(),
    '/home/missingPeople': (context) => const HomePage(setRoutePage: 0, isPeople: true),
    '/home/missingPets': (context) => const HomePage(setRoutePage: 0, isPeople: false),
    '/home/lostPeople': (context) => const HomePage(setRoutePage: 1, isPeople: true),
    '/home/lostPets': (context) => const HomePage(setRoutePage: 1, isPeople: false),
    '/home/milo': (context) => const HomePage(setRoutePage: 2, isPeople: true),
    '/home/profile': (context) => const HomePage(setRoutePage: 3, isPeople: true),
    '/home/milo/chat': (context) => const MiloChat(),
    '/errorPage': (context) => const ErrorPage(),
  };

  static String initial = '/';

  static GlobalKey<NavigatorState>? navigatorKey = GlobalKey<NavigatorState>();
}
