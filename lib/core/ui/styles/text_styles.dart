import "package:flutter/material.dart";

class TextStyles {
  static TextStyles? _instance;

  TextStyles._();

  static TextStyles get instance {
    _instance ??= TextStyles._();
    return _instance!;
  }

  String get font => 'Inter';

  TextStyle get textThin => TextStyle(
        fontWeight: FontWeight.w100,
        fontFamily: font,
      );

  TextStyle get textExtraLigth => TextStyle(
        fontWeight: FontWeight.w200,
        fontFamily: font,
      );

  TextStyle get textLight => TextStyle(
        fontWeight: FontWeight.w300,
        fontFamily: font,
      );

  TextStyle get textRegular => TextStyle(
        fontWeight: FontWeight.normal,
        fontFamily: font,
      );

  TextStyle get textMedium => TextStyle(
        fontWeight: FontWeight.w500,
        fontFamily: font,
      );

  TextStyle get textSemiBold => TextStyle(
        fontWeight: FontWeight.w600,
        fontFamily: font,
      );

  TextStyle get textBold => TextStyle(
        fontWeight: FontWeight.bold,
        fontFamily: font,
      );

  TextStyle get textExtraBold => TextStyle(
        fontWeight: FontWeight.w800,
        fontFamily: font,
      );

  TextStyle get textBlack => TextStyle(
        fontWeight: FontWeight.w900,
        fontFamily: font,
      );

  TextStyle get textButtonLabel => textExtraBold.copyWith(
        fontSize: 18,
        color: Colors.white,
      );

  TextStyle get textTitle => textBold.copyWith(
        fontSize: 24,
        color: Colors.black,
      );

  TextStyle get textInput => textRegular.copyWith(
        fontSize: 16,
      );
}

extension TextStylesExtensions on BuildContext {
  TextStyles get textStyles => TextStyles.instance;
}
