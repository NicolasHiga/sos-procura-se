import 'package:flutter/material.dart';
import 'package:sos_app/core/config/routes.dart';
import 'package:sos_app/core/ui/styles/colors_app.dart';
import 'package:sos_app/core/ui/styles/text_styles.dart';

class ErrorPage extends StatelessWidget {
  const ErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(15),
        color: ColorsApp.instance.background,
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Tivemos um problema :(",
                      style: TextStyles.instance.textTitle
                          .copyWith(decoration: TextDecoration.none)),
                  const SizedBox(height: 8),
                  Text('Por favor, tente novamente.',
                      style: TextStyles.instance.textSemiBold.copyWith(
                          fontSize: 16,
                          color: ColorsApp.instance.accent,
                          decoration: TextDecoration.none)),
                ],
              ),
            ),
            SizedBox(
              height: 45,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Routes.navigatorKey?.currentState?.pushReplacementNamed('/');
                },
                child: const Text(
                  'Recarregar',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
