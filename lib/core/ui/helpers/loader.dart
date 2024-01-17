import 'package:flutter/material.dart';
import 'package:sos_app/core/ui/styles/colors_app.dart';

class Loader extends StatelessWidget {
  const Loader({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Opacity(
        opacity: 0.7,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator.adaptive(
                backgroundColor: ColorsApp.instance.primary,
              ),
              const SizedBox(height: 10),
              Text(
                'Carregando...',
                style: TextStyle(
                  color: ColorsApp.instance.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
