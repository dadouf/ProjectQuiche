import 'package:flutter/material.dart';

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
      textTheme: baseTheme.textTheme,
    );
  }
}
