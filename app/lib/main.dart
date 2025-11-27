import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'src/bloc/divelist_bloc.dart';
import 'src/dives/divedetails_screen.dart';
import 'src/dives/diveedit_screen.dart';
import 'src/dives/divelist_screen.dart';
import 'src/sites/divesitedetail_widget.dart';
import 'src/sites/divesitelist_screen.dart';
import 'src/theme/theme.dart';

void main() {
  Intl.defaultLocale = 'sv_SE'; // XXX
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: '/dives',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (BuildContext context, GoRouterState state, StatefulNavigationShell shell) {
            final appBarTheme = Theme.of(context).appBarTheme;

            return Scaffold(
              body: Row(
                children: [
                  NavigationRail(
                    backgroundColor: appBarTheme.backgroundColor,
                    labelType: NavigationRailLabelType.all,
                    selectedIndex: shell.currentIndex,
                    onDestinationSelected: (n) => shell.goBranch(n),
                    leading: SizedBox(height: (appBarTheme.toolbarHeight ?? 48) - 8),
                    destinations: const [
                      NavigationRailDestination(icon: Icon(Icons.waves), label: Text('Dives')),
                      NavigationRailDestination(icon: Icon(Icons.place), label: Text('Sites')),
                    ],
                  ),
                  Expanded(child: shell),
                ],
              ),
            );
          },
          branches: [
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: '/dives',
                  builder: (BuildContext context, GoRouterState state) => const DiveListScreen(),
                  routes: [
                    GoRoute(path: 'new', builder: (context, state) => DiveEditScreen(diveID: null)),
                    GoRoute(
                      path: ':diveID',
                      builder: (context, state) => DiveDetailsScreen(diveID: state.pathParameters['diveID']!),
                      routes: [
                        GoRoute(
                          path: 'edit',
                          builder: (context, state) => DiveEditScreen(diveID: state.pathParameters['diveID']!),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: '/sites',
                  builder: (context, state) => const DiveSiteListScreen(),
                  routes: <RouteBase>[
                    GoRoute(
                      path: ':siteID',
                      builder: (context, state) => DiveSiteDetailScreen(siteID: state.pathParameters['siteID']!),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
    return BlocProvider(
      create: (context) => DiveListBloc(),
      child: MaterialApp.router(
        title: 'Divepath',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        routerConfig: router,
        localizationsDelegates: const [GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
      ),
    );
  }
}
