import 'package:flutter/material.dart';

import '../styles/app_styles.dart';
import '../styles/colors_app.dart';
import '../styles/text_styles.dart';

class ThemeConfig {
  ThemeConfig._();
  static final _defaultInputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide(color: ColorsApp.instance.previewText));
  static final _disabledInputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(15),
    borderSide: BorderSide(color: ColorsApp.instance.previewText),
  );

  static final theme = ThemeData(
      primaryColor: ColorsApp.instance.primary,
      colorScheme: ColorScheme.fromSeed(
          seedColor: ColorsApp.instance.primary,
          primary: ColorsApp.instance.primary,
          secondary: ColorsApp.instance.secondary),
      elevatedButtonTheme:
          ElevatedButtonThemeData(style: AppStyles.instance.primaryButton),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: Colors.white,
        filled: true,
        isDense: true,
        contentPadding: const EdgeInsets.all(12),
        border: _defaultInputBorder,
        enabledBorder: _defaultInputBorder,
        disabledBorder: _disabledInputBorder,
        focusedBorder: _defaultInputBorder,
        labelStyle: TextStyles.instance.textRegular
            .copyWith(color: ColorsApp.instance.previewText),
        errorStyle:
            TextStyles.instance.textRegular.copyWith(color: Colors.redAccent),
      ),
      appBarTheme: AppBarTheme(
        iconTheme: IconThemeData(
          color: ColorsApp.instance.secondary,
          size: 28,
        ),
        backgroundColor: ColorsApp.instance.background,
        elevation: 0,
        titleTextStyle: TextStyles.instance.textTitle,
        titleSpacing: 15,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: ColorsApp.instance.primary,
        unselectedItemColor: ColorsApp.instance.accent,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      scaffoldBackgroundColor: ColorsApp.instance.background,
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.all(ColorsApp.instance.primary),
        
      )
      );
}
