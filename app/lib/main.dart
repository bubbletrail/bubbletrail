import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:window_manager/window_manager.dart';

import 'src/app_routes.dart';
import 'src/app_theme.dart';
import 'src/bloc/archive_bloc.dart';
import 'src/bloc/ble_download_bloc.dart';
import 'src/bloc/ble_scan_bloc.dart';
import 'src/bloc/cylinderdetails_bloc.dart';
import 'src/bloc/cylinderlist_bloc.dart';
import 'src/bloc/divelist_bloc.dart';
import 'src/bloc/preferences_bloc.dart';
import 'src/bloc/sync_bloc.dart';
import 'src/common/common.dart';
import 'src/dives/ble_scan_screen.dart';
import 'src/dives/divedetails_screen.dart';
import 'src/dives/diveedit_screen.dart';
import 'src/dives/divelist_screen.dart';
import 'src/dives/fullscreen_profile_screen.dart';
import 'src/equipment/cylinder_edit_screen.dart';
import 'src/equipment/cylinder_list_screen.dart';
import 'src/equipment/equipment_screen.dart';
import 'src/preferences/logs_screen.dart';
import 'src/preferences/preferences_screen.dart';
import 'src/preferences/syncing_screen.dart';
import 'src/preferences/units_screen.dart';
import 'src/preferences/window_preferences.dart';
import 'src/services/log_buffer.dart';
import 'src/sites/fullscreen_map_screen.dart';
import 'src/sites/sitedetail_screen.dart';
import 'src/sites/siteedit_screen.dart';
import 'src/sites/sitelist_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _initLogging();
  await WindowPreferences.initialize();
  if (Platform.isIOS || Platform.isAndroid) {
    unawaited(SystemChrome.setPreferredOrientations([.portraitUp]));
  }
  runApp(const MyApp());
}

void _initLogging() {
  Logger.root.level = kDebugMode ? .ALL : .INFO;

  // Initialize log buffer for in-app log viewing
  LogBuffer.instance.initialize();

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
  late final SyncBloc _syncBloc;
  late final ArchiveBloc _archiveBloc;
  late final DiveListBloc _diveListBloc;
  late final CylinderListBloc _cylinderListBloc;
  late final BleScanBloc _bleScanBloc;
  late final BleDownloadBloc _bleDownloadBloc;
  late final GoRouter _router;
  final _preferencesBloc = PreferencesBloc();

  @override
  void initState() {
    super.initState();
    _syncBloc = SyncBloc();
    _archiveBloc = ArchiveBloc(syncBloc: _syncBloc);
    _diveListBloc = DiveListBloc(_syncBloc);
    _cylinderListBloc = CylinderListBloc(_syncBloc);
    _bleScanBloc = BleScanBloc(_syncBloc);
    _bleDownloadBloc = BleDownloadBloc(_diveListBloc, _syncBloc, _bleScanBloc);
    _setupFileHandler();
    if (WindowPreferences.isSupported) {
      windowManager.addListener(this);
    }

    // The profile detail route is placed inside the outer navigation shell
    // on desktop, but outside it on mobile to maximize fullscreen
    // potential.
    final profileDetailRoute = GoRoute(
      path: AppRoutePath.divesDetailsDepthProfile,
      name: AppRouteName.divesDetailsDepthProfile,
      builder: (context, state) {
        context.read<DiveListBloc>().add(SelectDive(state.pathParameters['diveID']!));
        return _WaitForSelectedDive(child: const FullscreenProfileScreen());
      },
    );

    _router = GoRouter(
      initialLocation: '/dives',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (BuildContext context, GoRouterState state, StatefulNavigationShell shell) {
            final appBarTheme = Theme.of(context).appBarTheme;
            const destinations = [
              (icon: Icons.water_outlined, label: 'Dives'),
              (icon: Icons.location_on_outlined, label: 'Sites'),
              (icon: Icons.inventory_2_outlined, label: 'Equipment'),
              (icon: Icons.settings, label: 'Settings'),
              (icon: Icons.bluetooth, label: 'Connect'),
            ];

            final cs = Theme.of(context).colorScheme;
            final decoration = BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.bottomRight,
                colors: [cs.tertiaryContainer, cs.onTertiaryFixedVariant],
                tileMode: .mirror,
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
                    labelType: .all,
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
                      builder: (context, state) {
                        context.read<DiveListBloc>().add(const SelectNewDive());
                        return _WaitForSelectedDive(child: const DiveEditScreen());
                      },
                    ),
                    GoRoute(
                      path: AppRoutePath.divesDetails,
                      name: AppRouteName.divesDetails,
                      builder: (context, state) {
                        context.read<DiveListBloc>().add(SelectDive(state.pathParameters['diveID']!));
                        return _WaitForSelectedDive(child: const DiveDetailsScreen());
                      },
                      routes: [
                        GoRoute(
                          path: AppRoutePath.divesDetailsEdit,
                          name: AppRouteName.divesDetailsEdit,
                          builder: (context, state) {
                            context.read<DiveListBloc>().add(SelectDive(state.pathParameters['diveID']!));
                            return _WaitForSelectedDive(child: const DiveEditScreen());
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                if (!Platform.isIOS) profileDetailRoute,
                GoRoute(
                  path: AppRoutePath.sitesDetailsMap,
                  name: AppRouteName.sitesDetailsMap,
                  builder: (context, state) {
                    context.read<DiveListBloc>().add(SelectSite(state.pathParameters['siteID']!));
                    return _WaitForSelectedSite(child: const FullscreenMapScreen());
                  },
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
                      builder: (context, state) {
                        context.read<DiveListBloc>().add(const SelectNewSite());
                        return _WaitForSelectedSite(child: const SiteEditScreen());
                      },
                    ),
                    GoRoute(
                      path: AppRoutePath.sitesDetails,
                      name: AppRouteName.sitesDetails,
                      builder: (context, state) {
                        context.read<DiveListBloc>().add(SelectSite(state.pathParameters['siteID']!));
                        return _WaitForSelectedSite(child: const SiteDetailScreen());
                      },
                      routes: [
                        GoRoute(
                          path: AppRoutePath.sitesDetailsEdit,
                          name: AppRouteName.sitesDetailsEdit,
                          builder: (context, state) {
                            context.read<DiveListBloc>().add(SelectSite(state.pathParameters['siteID']!));
                            return _WaitForSelectedSite(child: const SiteEditScreen());
                          },
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
                            create: (context) => CylinderDetailsBloc(_syncBloc)..add(const NewCylinderEvent()),
                            child: DetailsAvailable<CylinderDetailsBloc, CylinderDetailsState>(child: CylinderEditScreen()),
                          ),
                        ),
                        GoRoute(
                          path: AppRoutePath.cylindersDetails,
                          name: AppRouteName.cylindersDetails,
                          builder: (context, state) => BlocProvider(
                            create: (context) => CylinderDetailsBloc(_syncBloc)..add(LoadCylinderDetails(state.pathParameters['cylinderID']!)),
                            child: DetailsAvailable<CylinderDetailsBloc, CylinderDetailsState>(child: CylinderEditScreen()),
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
                  path: AppRoutePath.preferences,
                  name: AppRouteName.preferences,
                  builder: (context, state) => const PreferencesScreen(),
                  routes: <RouteBase>[
                    GoRoute(path: AppRoutePath.units, name: AppRouteName.units, builder: (context, state) => const UnitsScreen()),
                    GoRoute(path: AppRoutePath.syncing, name: AppRouteName.syncing, builder: (context, state) => const SyncingScreen()),
                    GoRoute(path: AppRoutePath.logs, name: AppRouteName.logs, builder: (context, state) => const LogsScreen()),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: <RouteBase>[GoRoute(path: AppRoutePath.connect, name: AppRouteName.connect, builder: (context, state) => BleScanScreen())],
            ),
          ],
        ),
        if (Platform.isIOS) profileDetailRoute,
      ],
    );
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
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _syncBloc),
        BlocProvider.value(value: _archiveBloc),
        BlocProvider.value(value: _diveListBloc),
        BlocProvider.value(value: _cylinderListBloc),
        BlocProvider.value(value: _preferencesBloc),
        BlocProvider.value(value: _bleScanBloc),
        BlocProvider.value(value: _bleDownloadBloc),
      ],
      child: BlocListener<PreferencesBloc, PreferencesState>(
        listener: (context, state) {
          // Update sync config when preferences change
          context.read<SyncBloc>().add(UpdateSyncConfig(provider: state.preferences.syncProvider, s3Config: state.preferences.s3Config));
        },
        child: BlocBuilder<PreferencesBloc, PreferencesState>(
          builder: (context, state) {
            final themeMode = state.preferences.themeMode;
            return MaterialApp.router(
              title: 'Bubbletrail',
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeMode,
              debugShowCheckedModeBanner: false,
              routerConfig: _router,
              localizationsDelegates: const [GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
            );
          },
        ),
      ),
    );
  }
}

/// Helper widget that waits for selectedDive to be available
class _WaitForSelectedDive extends StatelessWidget {
  final Widget child;

  const _WaitForSelectedDive({required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DiveListBloc, DiveListState>(
      builder: (context, state) {
        if (state is DiveListLoaded && state.selectedDive != null) {
          return child;
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

/// Helper widget that waits for selectedSite to be available
class _WaitForSelectedSite extends StatelessWidget {
  final Widget child;

  const _WaitForSelectedSite({required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DiveListBloc, DiveListState>(
      builder: (context, state) {
        if (state is DiveListLoaded && state.selectedSite != null) {
          return child;
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
