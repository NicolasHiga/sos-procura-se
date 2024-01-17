import 'package:sos_app/core/ui/styles/text_styles.dart';
import 'package:flutter/material.dart';

class AppStyles {
  static AppStyles? _instance;
  
  AppStyles._();

  static AppStyles get instance{
    _instance??=  AppStyles._();
    return _instance!;
   }

   ButtonStyle get primaryButton => ElevatedButton.styleFrom(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15)
    ),
    elevation: 0,
    textStyle: TextStyles.instance.textButtonLabel,
   );
}

extension AppStylesExtensions on BuildContext {
  AppStyles get appStyles => AppStyles.instance;
}