import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../app_metadata.dart';
import '../app_routes.dart';
import '../bloc/preferences_bloc.dart';
import '../bloc/sync_bloc.dart';
import '../common/common.dart';
import 'preferences.dart';
import 'preferences_widgets.dart';

class PreferencesScreen extends StatelessWidget {
  const PreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SyncBloc, SyncState>(
      builder: (context, syncState) {
        return BlocBuilder<PreferencesBloc, PreferencesState>(
          builder: (context, prefsState) {
            final prefs = prefsState.preferences;
            return ScreenScaffold(
              title: const Text('Preferences'),
              floatingActionButton: FloatingActionButton.extended(
                onPressed: syncState.syncing || prefs.syncProvider == SyncProviderKind.none ? null : () => context.read<SyncBloc>().add(const StartSyncing()),
                label: Text(syncState.syncing ? 'Syncing...' : 'Sync'),
                icon: syncState.syncing ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.sync),
              ),
              body: Stack(
                children: [
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      PreferencesCategoryCard(icon: Icons.scuba_diving, title: 'Cylinders', onTap: () => context.goNamed(AppRouteName.cylinders)),
                      PreferencesCategoryCard(icon: Icons.straighten, title: 'Units', onTap: () => context.goNamed(AppRouteName.units)),
                      PreferencesCategoryCard(icon: Icons.cloud_sync, title: 'Syncing', onTap: () => context.goNamed(AppRouteName.syncing)),
                      const SizedBox(height: 24),
                      const PreferencesSectionHeader(title: 'Appearance'),
                      PreferencesTile(
                        title: 'Theme',
                        trailing: SegmentedButton<ThemeMode>(
                          showSelectedIcon: true,
                          segments: const [
                            ButtonSegment(value: ThemeMode.system, label: Text('System'), icon: Icon(null)),
                            ButtonSegment(value: ThemeMode.light, label: Text('Light'), icon: Icon(null)),
                            ButtonSegment(value: ThemeMode.dark, label: Text('Dark'), icon: Icon(null)),
                          ],
                          selected: {prefs.themeMode},
                          onSelectionChanged: (value) {
                            context.read<PreferencesBloc>().add(UpdateThemeMode(value.first));
                          },
                        ),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SyncStatusTile(state: syncState),
                        const SizedBox(height: 8),
                        Text(
                          'Bubbletrail $appVer ($gitVer)',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)),
                        ),
                        DateTimeText(
                          buildTime,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
