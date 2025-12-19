import 'dart:io';

import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

import 'common/common.dart';

class AppTheme {
  AppTheme._();

  static const Color _d1 = Color(0xFF011A1A); // gradient
  static const Color _d2 = Color(0xFF01403A); // gradient
  static const Color _d3 = Color(0xFF04BFAD); // primary
  static const Color _d4 = Color(0xFF9AEBA3); // secondary

  static const Color _l1 = Color(0xFFC2EDF2); // gradient
  static const Color _l2 = Color(0xFF7AB8BF); // gradient
  static const Color _l3 = Color(0xFF3E848C); // primary
  static const Color _l4 = Color(0xFF025159); // secondary

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
      seedColor: _d3,
      primary: _d3,
      secondary: _d4,

      // Background gradient and divider line
      tertiaryContainer: _d2,
      onTertiaryFixedVariant: _d1,
      onTertiaryContainer: lighten(_d2),
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
      seedColor: _l3,
      primary: _l3,
      secondary: _l4,

      // Background gradient and divider line
      tertiaryContainer: _l1,
      onTertiaryFixedVariant: _l2,
      onTertiaryContainer: darken(_l2),
    ),
    appBarTheme: AppBarTheme(backgroundColor: Colors.transparent, elevation: 0, scrolledUnderElevation: 0, centerTitle: false, toolbarHeight: 48),
    navigationRailTheme: NavigationRailThemeData(backgroundColor: Colors.transparent),
    pageTransitionsTheme: transitions,
  );

  static TrinaGridConfiguration trinaGridConfiguration(BuildContext context) => TrinaGridConfiguration(
    style: TrinaGridStyleConfig(
      rowHeight: 32,
      columnHeight: 45,
      gridBorderColor: Colors.transparent, // Theme.of(context).dividerColor,
      enableCellBorderHorizontal: false,
      enableCellBorderVertical: false,
      enableColumnBorderVertical: false,
      oddRowColor: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.1),
      activatedBorderColor: Colors.transparent, // Theme.of(context).colorScheme.primary,
      activatedColor: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
      gridBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
      rowColor: Theme.of(context).scaffoldBackgroundColor,
      cellTextStyle: Theme.of(context).textTheme.bodyMedium ?? const TextStyle(),
      columnTextStyle: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold) ?? const TextStyle(),
    ),
    columnSize: TrinaGridColumnSizeConfig(autoSizeMode: TrinaAutoSizeMode.scale),
    scrollbar: TrinaGridScrollbarConfig(isAlwaysShown: false),
  );
}
