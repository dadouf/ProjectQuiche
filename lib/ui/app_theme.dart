import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const colorScheme = ColorScheme(
    // Keep primary synced with Android (values/colors.xml) and iOS (LaunchScreen.storyboard)
    primary: AppColors.cardinal,
    primaryVariant: AppColors.cardinal,
    secondary: AppColors.cardinal,
    secondaryVariant: AppColors.cardinal,
    surface: AppColors.roseWhite,
    background: AppColors.dawnPink,
    error: AppColors.orangeSoda,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: AppColors.thunder,
    onBackground: AppColors.thunder,
    onError: AppColors.thunder,
    brightness: Brightness.light,
  );

  static final boldColorScheme = colorScheme.copyWith(
    background: colorScheme.primary,
    onBackground: colorScheme.onPrimary,
    primary: colorScheme.background,
    onPrimary: colorScheme.onBackground,
    brightness: Brightness.dark,
  );
}

class AppColors {
  const AppColors._();

  //
  // Named colors
  //

  static const cardinal = Color(0xFFB71540);
  static const orangeSoda = Color(0xFFF85A33);
  static const thunder = Color(0xFF3A2E39);
  static const roseWhite = Color(0xFFFFFAFA);
  static const dawnPink = Color(0xFFF4EDEA);

  //
  // Used colors
  //

  static const disabledNavIcon = Color(0x80FFFFFF);

  static const selectedBackgroundOnDark = Color(0x40FFFFFF);
  static const selectedBorderOnDark = Color(0x50FFFFFF);

  static const hintOnLight = Color(0x60000000);
}

extension ColorSchemeToTheme on ColorScheme {
  ThemeData toTheme() {
    ThemeData baseTheme = this.brightness == Brightness.light
        ? ThemeData.light()
        : ThemeData.dark();

    return baseTheme.copyWith(
      colorScheme: this,
      primaryColor: this.primary,
      accentColor: this.primary,
      indicatorColor: this.secondary,
      scaffoldBackgroundColor: this.background,
      snackBarTheme: baseTheme.snackBarTheme.copyWith(
        contentTextStyle: TextStyle(color: Colors.white),
      ),
      toggleableActiveColor: this.primary, // Checkbox...
    );
  }
}

// const darkLiverHorses = Color(0xFF564138);
// const myrtleGreen = Color(0xFF38726C);
// const sunglow = Color(0xFFFFC914);
// const lightPeriwinkle = Color(0xFFC7CCDB);
// const snow = Color(0xFFFCF7F8);
// var myColorScheme = ColorScheme(
//   primary: myrtleGreen,
//   primaryVariant: myrtleGreen,
//   secondary: sunglow,
//   secondaryVariant: sunglow,
//   surface: lightPeriwinkle,
//   background: snow,
//   error: Colors.red,
//   onPrimary: Colors.white,
//   onSecondary: Colors.black,
//   onSurface: Colors.black,
//   onBackground: Colors.black,
//   onError: Colors.black,
//   brightness: Brightness.light,
// );

// const usafaBlue = Color(0xFF26547C);
// const maximumBlueGreen = Color(0xFF62BEC1);
// const roseMadder = Color(0xFFDF2935);
// const lavenderBlush = Color(0xFFEEE5E9);
// const lavenderBlushDarker = Color(0xFFE6DCDF);
// const darkSienna = Color(0xFF32161F);
//
// var myColorScheme = ColorScheme(
//   primary: usafaBlue,
//   primaryVariant: usafaBlue,
//   secondary: maximumBlueGreen,
//   secondaryVariant: maximumBlueGreen,
//   surface: lavenderBlushDarker,
//   background: lavenderBlush,
//   error: roseMadder,
//   onPrimary: Colors.white,
//   onSecondary: Colors.black,
//   onSurface: Colors.black,
//   onBackground: darkSienna,
//   onError: Colors.black,
//   brightness: Brightness.light,
// );
