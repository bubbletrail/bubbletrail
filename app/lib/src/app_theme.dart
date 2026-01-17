import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

import 'app_metadata.dart';
import 'common/common.dart';

class AppTheme {
  AppTheme._();

  // Dark theme is murky green Scandinavian water

  static const Color _d1 = Color(0xFF011A1A); // gradient
  static const Color _d2 = Color(0xFF01403A); // gradient
  static const Color _d3 = Color(0xFF04BFAD); // primary
  static const Color _d4 = Color(0xFF9AEBA3); // secondary

  // Light theme is bright turquoise tropical beach

  static const Color _l1 = Color(0xFFC4E9F4); // gradient
  static final Color _l2 = lighten(_l3); // gradient
  static const Color _l3 = Color(0xFF339CCC); // primary
  static const Color _l4 = Color(0xFF096688); // secondary

  static final density = platformIsMobile ? VisualDensity.standard : VisualDensity.compact;

  static const transitions = PageTransitionsTheme(
    builders: <TargetPlatform, PageTransitionsBuilder>{
      .android: FadeForwardsPageTransitionsBuilder(backgroundColor: Colors.transparent),
      .iOS: FadeForwardsPageTransitionsBuilder(backgroundColor: Colors.transparent),
      .linux: FadeForwardsPageTransitionsBuilder(backgroundColor: Colors.transparent),
      .macOS: FadeForwardsPageTransitionsBuilder(backgroundColor: Colors.transparent),
      .windows: FadeForwardsPageTransitionsBuilder(backgroundColor: Colors.transparent),
    },
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    visualDensity: density,
    colorScheme: ColorScheme.fromSeed(
      brightness: .dark,
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
      brightness: .light,
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
      columnTextStyle: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: .bold) ?? const TextStyle(),
    ),
    columnSize: TrinaGridColumnSizeConfig(autoSizeMode: .scale),
    scrollbar: TrinaGridScrollbarConfig(isAlwaysShown: false),
  );
}
