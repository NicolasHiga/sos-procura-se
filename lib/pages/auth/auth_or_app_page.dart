import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sos_app/core/services/auth/auth_service.dart';
import 'package:sos_app/core/services/user/user_store.dart';
import 'package:sos_app/core/ui/helpers/error_page.dart';
import 'package:sos_app/models/sos_user.dart';
import 'package:sos_app/pages/auth/load_notifications.dart';
import 'package:sos_app/pages/auth/login_page/login_page.dart';
import 'package:sos_app/core/ui/helpers/loader.dart';

class AuthOrAppPage extends StatelessWidget {
  const AuthOrAppPage({super.key});

  Future<void> init(BuildContext context) async {
    await Firebase.initializeApp();
  }

  @override
  Widget build(BuildContext context) {
    final userStore = Provider.of<UserStore>(context, listen: false);


    return FutureBuilder(
      future: init(context),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Loader();
        } else {
          return StreamBuilder<SOSUser?>(
            stream: AuthService().userChanges,
            builder: (ctx, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Loader();
              } else {
                if (snapshot.hasData) {
                  return FutureBuilder<void>(
                    future: userStore.fetchUserData(snapshot.data!.id, context),
                    builder:
                        (BuildContext context, AsyncSnapshot<void> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Loader(); // Mostra um loading spinner enquanto aguarda
                      } else {
                        if (snapshot.error != null) {
                          // Se tiver um erro, retorna para página de erro
                          return const ErrorPage();
                        } else {
                          // Quando a Future for concluída, retorna a HomePage
                          return const LoadNotifications();
                        }
                      }
                    },
                  );
                } else {
                  return const LoginPage();
                }
              }
            },
          );
        }
      },
    );
  }
}
