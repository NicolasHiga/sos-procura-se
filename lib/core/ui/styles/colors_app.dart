import 'package:flutter/material.dart';

class ColorsApp {
  static ColorsApp? _instance;

  ColorsApp._();

  static ColorsApp get instance {
    _instance ??= ColorsApp._();
    return _instance!;
  }

  Color get primary => const Color.fromARGB(255, 255, 22, 22);
  Color get secondary => const Color.fromARGB(255, 177, 177, 177);
  Color get accent => const Color.fromARGB(255, 148, 148, 148);
  Color get background => const Color.fromARGB(255, 241, 241, 241);
  Color get previewText => const Color.fromARGB(255, 113, 113, 113);
}

extension ColorsAppExtensions on BuildContext {
  ColorsApp get colors => ColorsApp.instance;
}