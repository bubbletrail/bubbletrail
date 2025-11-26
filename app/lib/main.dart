import 'package:divepath/src/divelist/divedetail_widget.dart';
import 'package:divepath/src/divelist/diveedit_widget.dart';
import 'package:divepath/src/divelist/divelist_widget.dart';
import 'package:divepath/src/divelist/divesitedetail_widget.dart';
import 'package:divepath/src/divelist/divesitelist_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'src/divelist/divelist_bloc.dart';

void main() {
  runApp(const MyApp());
}

final _router = GoRouter(
  initialLocation: '/dives',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (BuildContext context, GoRouterState state, StatefulNavigationShell shell) => Scaffold(
        body: shell,
        bottomNavigationBar: NavigationBar(
          selectedIndex: shell.currentIndex,
          onDestinationSelected: (n) => shell.goBranch(n),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.waves), label: 'Dives'),
            NavigationDestination(icon: Icon(Icons.place), label: 'Sites'),
          ],
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DiveListBloc(),
      child: MaterialApp.router(
        title: 'Divepath',
        theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue), useMaterial3: true),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark, primary: Colors.lightBlue, secondary: Colors.lightBlueAccent),
          useMaterial3: true,
        ),
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        routerConfig: _router,
      ),
    );
  }
}
