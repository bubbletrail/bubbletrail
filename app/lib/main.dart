import 'package:divepath/src/divelist/divedetail_widget.dart';
import 'package:divepath/src/divelist/diveedit_widget.dart';
import 'package:divepath/src/divelist/divelist_widget.dart';
import 'package:divepath/src/divelist/divesitedetail_widget.dart';
import 'package:divepath/src/divelist/divesitelist_widget.dart';
import 'package:divepath/src/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'src/divelist/divelist_bloc.dart';

void main() {
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
          builder: (BuildContext context, GoRouterState state, StatefulNavigationShell shell) => Scaffold(
            body: SafeArea(
              child: Row(
                children: [
                  NavigationRail(
                    backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
                    labelType: NavigationRailLabelType.all,
                    selectedIndex: shell.currentIndex,
                    onDestinationSelected: (n) => shell.goBranch(n),
                    leading: SizedBox(height: 42),
                    destinations: const [
                      NavigationRailDestination(icon: Icon(Icons.waves), label: Text('Dives')),
                      NavigationRailDestination(icon: Icon(Icons.place), label: Text('Sites')),
                    ],
                  ),
                  Expanded(child: shell),
                ],
              ),
            ),
          ),
          branches: [
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: '/dives',
                  builder: (BuildContext context, GoRouterState state) => const DiveListScreen(),
                  routes: [
                    GoRoute(
                      path: ':diveID',
                      builder: (context, state) => DiveDetailScreen(diveID: state.pathParameters['diveID']!),
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
      ),
    );
  }
}
