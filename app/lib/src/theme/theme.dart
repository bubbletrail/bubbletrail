import 'dart:io';

import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color _primaryColor = Color(0xFF0099CC);
  static const Color _secondaryColor = Color(0xFF99DD55);
  static const Color _darkSecondaryBackground = _primaryColor; // Color(0xFF3366BB);
  // static const Color _lightSecondaryBackground = Color(0xFF80C0FF);

  static const Color _darkBackgroundGradientTop = Color(0xFF001020);
  static const Color _darkBackgroundGradientBottom = Color(0xFF204060);
  static const Color _darkBackgroundGradientDivider = Color(0xFF305070);

  static const Color _lightBackgroundGradientTop = Color(0xFFA0F0FF);
  static const Color _lightBackgroundGradientBottom = Color(0xFF80B0F0);
  static const Color _lightBackgroundGradientDivider = Color(0xFF4080C0);

  static final density = Platform.isAndroid || Platform.isIOS ? VisualDensity.standard : VisualDensity.compact;

  static const transitions = PageTransitionsTheme(
    builders: <TargetPlatform, PageTransitionsBuilder>{
      TargetPlatform.android: FadeForwardsPageTransitionsBuilder(backgroundColor: Colors.transparent),
      TargetPlatform.iOS: FadeForwardsPageTransitionsBuilder(backgroundColor: Colors.transparent),
      TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(backgroundColor: Colors.transparent),
      TargetPlatform.macOS: FadeForwardsPageTransitionsBuilder(backgroundColor: Colors.transparent),
      TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(backgroundColor: Colors.transparent),
    },
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    visualDensity: density,
    colorScheme: ColorScheme.fromSeed(
      brightness: Brightness.dark,
      seedColor: AppTheme._primaryColor,
      primary: AppTheme._primaryColor,
      secondary: AppTheme._secondaryColor,
      secondaryContainer: _darkSecondaryBackground,
      tertiaryContainer: _darkBackgroundGradientTop,
      onTertiaryContainer: _darkBackgroundGradientDivider,
      onTertiaryFixedVariant: _darkBackgroundGradientBottom,
    ),
    appBarTheme: AppBarTheme(backgroundColor: Colors.transparent, elevation: 0, scrolledUnderElevation: 0, centerTitle: false, toolbarHeight: 48),
    navigationRailTheme: NavigationRailThemeData(backgroundColor: Colors.transparent),
    pageTransitionsTheme: transitions,
  );

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    visualDensity: density,
    colorScheme: ColorScheme.fromSeed(
      brightness: Brightness.light,
      seedColor: AppTheme._primaryColor,
      primary: AppTheme._primaryColor,
      secondary: AppTheme._secondaryColor,
      tertiaryContainer: _lightBackgroundGradientTop,
      onTertiaryContainer: _lightBackgroundGradientDivider,
      onTertiaryFixedVariant: _lightBackgroundGradientBottom,
    ),
    appBarTheme: AppBarTheme(backgroundColor: Colors.transparent, elevation: 0, scrolledUnderElevation: 0, centerTitle: false, toolbarHeight: 48),
    navigationRailTheme: NavigationRailThemeData(backgroundColor: Colors.transparent),
    pageTransitionsTheme: transitions,
  );
}
