import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:window_manager/window_manager.dart';

import 'src/app_routes.dart';
import 'src/preferences/window_preferences.dart';
import 'src/bloc/ble_bloc.dart';
import 'src/bloc/cylinderdetails_bloc.dart';
import 'src/bloc/cylinderlist_bloc.dart';
import 'src/bloc/divedetails_bloc.dart';
import 'src/bloc/divelist_bloc.dart';
import 'src/bloc/sitedetails_bloc.dart';
import 'src/bloc/preferences_bloc.dart';
import 'src/common/common.dart';
import 'src/dives/ble_scan_screen.dart';
import 'src/dives/divedetails_screen.dart';
import 'src/dives/diveedit_screen.dart';
import 'src/dives/divelist_screen.dart';
import 'src/equipment/cylinder_edit_screen.dart';
import 'src/equipment/cylinder_list_screen.dart';
import 'src/equipment/equipment_screen.dart';
import 'src/preferences/preferences_screen.dart';
import 'src/sites/sitedetail_screen.dart';
import 'src/sites/siteedit_screen.dart';
import 'src/sites/sitelist_screen.dart';
import 'src/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _initLogging();
  await WindowPreferences.initialize();
  Intl.defaultLocale = 'sv_SE'; // XXX
  runApp(const MyApp());
}

void _initLogging() {
  Logger.root.level = kDebugMode ? Level.ALL : Level.INFO;
  Logger.root.onRecord.listen((record) {
    debugPrint('${record.level.name}: ${record.loggerName}: ${record.message}');
    if (record.error != null) {
      debugPrint('Error: ${record.error}');
    }
    if (record.stackTrace != null) {
      debugPrint('${record.stackTrace}');
    }
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WindowListener {
  static const _channel = MethodChannel('app.bubbletrail.app/file_handler');
  final _diveListBloc = DiveListBloc();
  final _cylinderListBloc = CylinderListBloc();
  final _preferencesBloc = PreferencesBloc();

  @override
  void initState() {
    super.initState();
    _setupFileHandler();
    if (WindowPreferences.isSupported) {
      windowManager.addListener(this);
    }
  }

  @override
  void dispose() {
    if (WindowPreferences.isSupported) {
      windowManager.removeListener(this);
    }
    super.dispose();
  }

  @override
  void onWindowResized() => WindowPreferences.save();

  @override
  void onWindowMoved() => WindowPreferences.save();

  @override
  void onWindowMaximize() => WindowPreferences.save();

  @override
  void onWindowUnmaximize() => WindowPreferences.save();

  void _setupFileHandler() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'fileReceived') {
        final filePath = call.arguments as String;
        _diveListBloc.add(ImportDives(filePath));
      }
    });

    _channel
        .invokeMethod<String>('getInitialFile')
        .then((filePath) {
          if (filePath != null) {
            _diveListBloc.add(ImportDives(filePath));
          }
        })
        .onError((_, _) {
          // Ignore unimplemented error on macOS etc
        });
  }

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: '/dives',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (BuildContext context, GoRouterState state, StatefulNavigationShell shell) {
            final appBarTheme = Theme.of(context).appBarTheme;
            const destinations = [
              (icon: Icons.waves, label: 'Dives'),
              (icon: Icons.place, label: 'Sites'),
              (icon: Icons.settings, label: 'Equipment'),
              (icon: Icons.bluetooth, label: 'Connect'),
            ];

            final cs = Theme.of(context).colorScheme;
            final decoration = BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [cs.tertiaryContainer, cs.onTertiaryFixedVariant],
                tileMode: TileMode.mirror,
              ),
            );

            if (Platform.isIOS) {
              return Container(
                decoration: decoration,
                child: SafeArea(
                  child: Scaffold(
                    backgroundColor: Colors.transparent,
                    body: shell,
                    bottomNavigationBar: NavigationBar(
                      backgroundColor: Colors.transparent,
                      selectedIndex: shell.currentIndex,
                      onDestinationSelected: (n) => shell.goBranch(n),
                      destinations: [for (final d in destinations) NavigationDestination(icon: Icon(d.icon), label: d.label)],
                    ),
                  ),
                ),
              );
            }

            return Container(
              decoration: decoration,
              child: Row(
                children: [
                  NavigationRail(
                    backgroundColor: Colors.transparent,
                    labelType: NavigationRailLabelType.all,
                    selectedIndex: shell.currentIndex,
                    onDestinationSelected: (n) => shell.goBranch(n),
                    leading: SizedBox(height: (appBarTheme.toolbarHeight ?? 48) - 8),
                    destinations: [for (final d in destinations) NavigationRailDestination(icon: Icon(d.icon), label: Text(d.label))],
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
                  path: AppRoutePath.dives,
                  name: AppRouteName.dives,
                  builder: (BuildContext context, GoRouterState state) => const DiveListScreen(),
                  routes: [
                    GoRoute(
                      path: AppRoutePath.divesNew,
                      name: AppRouteName.divesNew,
                      builder: (context, state) => BlocProvider.value(
                        value: DiveDetailsBloc()..add(NewDiveEvent()),
                        child: DetailsAvailable<DiveDetailsBloc, DiveDetailsState>(child: DiveEditScreen()),
                      ),
                    ),
                    GoRoute(
                      path: AppRoutePath.divesDetails,
                      name: AppRouteName.divesDetails,
                      builder: (context, state) => BlocProvider(
                        create: (context) => DiveDetailsBloc(),
                        child: Builder(
                          builder: (context) {
                            context.read<DiveDetailsBloc>().add(LoadDiveDetails(state.pathParameters['diveID']!));
                            return DetailsAvailable<DiveDetailsBloc, DiveDetailsState>(child: DiveDetailsScreen());
                          },
                        ),
                      ),
                      routes: [
                        GoRoute(
                          path: AppRoutePath.divesDetailsEdit,
                          name: AppRouteName.divesDetailsEdit,
                          builder: (context, state) => BlocProvider.value(
                            value: DiveDetailsBloc()..add(LoadDiveDetails(state.pathParameters['diveID']!)),
                            child: DetailsAvailable<DiveDetailsBloc, DiveDetailsState>(child: DiveEditScreen()),
                          ),
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
                  path: AppRoutePath.sites,
                  name: AppRouteName.sites,
                  builder: (context, state) => const SiteListScreen(),
                  routes: <RouteBase>[
                    GoRoute(
                      path: AppRoutePath.sitesNew,
                      name: AppRouteName.sitesNew,
                      builder: (context, state) => BlocProvider(
                        create: (context) => SiteDetailsBloc()..add(const NewSiteEvent()),
                        child: DetailsAvailable<SiteDetailsBloc, SiteDetailsState>(child: SiteEditScreen()),
                      ),
                    ),
                    GoRoute(
                      path: AppRoutePath.sitesDetails,
                      name: AppRouteName.sitesDetails,
                      builder: (context, state) => SiteDetailScreen(siteID: state.pathParameters['siteID']!),
                      routes: [
                        GoRoute(
                          path: AppRoutePath.sitesDetailsEdit,
                          name: AppRouteName.sitesDetailsEdit,
                          builder: (context, state) => BlocProvider(
                            create: (context) => SiteDetailsBloc()..add(LoadSiteDetails(state.pathParameters['siteID']!)),
                            child: DetailsAvailable<SiteDetailsBloc, SiteDetailsState>(child: SiteEditScreen()),
                          ),
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
                  path: AppRoutePath.equipment,
                  name: AppRouteName.equipment,
                  builder: (context, state) => const EquipmentScreen(),
                  routes: <RouteBase>[
                    GoRoute(
                      path: AppRoutePath.cylinders,
                      name: AppRouteName.cylinders,
                      builder: (context, state) => const CylinderListScreen(),
                      routes: <RouteBase>[
                        GoRoute(
                          path: AppRoutePath.cylindersNew,
                          name: AppRouteName.cylindersNew,
                          builder: (context, state) => BlocProvider(
                            create: (context) => CylinderDetailsBloc()..add(const NewCylinderEvent()),
                            child: DetailsAvailable<CylinderDetailsBloc, CylinderDetailsState>(child: CylinderEditScreen()),
                          ),
                        ),
                        GoRoute(
                          path: AppRoutePath.cylindersDetails,
                          name: AppRouteName.cylindersDetails,
                          builder: (context, state) => BlocProvider(
                            create: (context) => CylinderDetailsBloc()..add(LoadCylinderDetails(state.pathParameters['cylinderID']!)),
                            child: DetailsAvailable<CylinderDetailsBloc, CylinderDetailsState>(child: CylinderEditScreen()),
                          ),
                        ),
                      ],
                    ),
                    GoRoute(path: AppRoutePath.settings, name: AppRouteName.settings, builder: (context, state) => const PreferencesScreen()),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: <RouteBase>[GoRoute(path: AppRoutePath.connect, name: AppRouteName.connect, builder: (context, state) => BleScanScreen())],
            ),
          ],
        ),
      ],
    );
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _diveListBloc),
        BlocProvider.value(value: _cylinderListBloc),
        BlocProvider.value(value: _preferencesBloc),
        BlocProvider(create: (context) => BleBloc(_diveListBloc)..add(const BleStarted())),
      ],
      child: BlocBuilder<PreferencesBloc, PreferencesState>(
        builder: (context, state) {
          final themeMode = state.preferences.themeMode;
          return MaterialApp.router(
            title: 'Bubbletrail',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            debugShowCheckedModeBanner: false,
            routerConfig: router,
            localizationsDelegates: const [GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
          );
        },
      ),
    );
  }
}
