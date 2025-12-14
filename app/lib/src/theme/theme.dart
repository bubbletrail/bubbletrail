import 'dart:io';

import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color _primaryColor = Color(0xFF0099CC);
  static const Color _secondaryColor = Color(0xFF99DD55);
  static const Color _darkSecondaryBackground = _primaryColor; // Color(0xFF3366BB);
  static const Color _lightSecondaryBackground = Color(0xFF80C0FF);

  static final density = Platform.isAndroid || Platform.isIOS ? VisualDensity.standard : VisualDensity.compact;

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    visualDensity: density,
    colorScheme: ColorScheme.fromSeed(
      brightness: Brightness.dark,
      seedColor: AppTheme._primaryColor,
      primary: AppTheme._primaryColor,
      secondary: AppTheme._secondaryColor,
      secondaryContainer: _darkSecondaryBackground,
    ),
    appBarTheme: AppBarTheme(backgroundColor: _darkSecondaryBackground, elevation: 0, scrolledUnderElevation: 0, centerTitle: false, toolbarHeight: 48),
  );

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    visualDensity: density,
    colorScheme: ColorScheme.fromSeed(
      brightness: Brightness.light,
      seedColor: AppTheme._primaryColor,
      primary: AppTheme._primaryColor,
      secondary: AppTheme._secondaryColor,
    ),
    appBarTheme: AppBarTheme(backgroundColor: _lightSecondaryBackground, elevation: 0, scrolledUnderElevation: 0, centerTitle: false, toolbarHeight: 48),
  );
}
