import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';

import '../app_metadata.dart';
import '../app_routes.dart';
import 'archive_bloc.dart';
import '../dives_sites/dive_list_bloc.dart';
import 'preferences_bloc.dart';
import 'sync_bloc.dart';
import '../common/common.dart';
import '../services/log_buffer.dart';
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
              body: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _SectionColumn(
                    title: 'Syncing',
                    children: [
                      Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        children: [
                          FilledButton.icon(
                            icon: const Icon(Icons.sync, size: 16),
                            label: const Text('Sync now'),
                            onPressed: prefs.syncProvider == .none || !prefs.s3Config.isConfigured || syncState.syncing
                                ? null
                                : () => context.read<SyncBloc>().add(const SyncEvent.startSyncing()),
                          ),
                          OutlinedButton.icon(
                            icon: Icon(Icons.cloud_sync),
                            label: Text('Edit sync settings'),
                            onPressed: () => context.goNamed(AppRouteName.syncing),
                          ),
                        ],
                      ),
                      if (prefs.syncProvider != .none && prefs.s3Config.isConfigured) SyncStatusTile(state: syncState),
                    ],
                  ),
                  if (platformIsDesktop) _SectionColumn(title: 'Import & export', children: [_ImportExportButtons()]),
                  _SectionColumn(
                    title: 'Preferences',
                    children: [
                      SegmentedButton<ThemeMode>(
                        showSelectedIcon: true,
                        segments: const [
                          ButtonSegment(value: ThemeMode.system, label: Text('System'), icon: Icon(Icons.brightness_auto)),
                          ButtonSegment(value: ThemeMode.light, label: Text('Light'), icon: Icon(Icons.light_mode)),
                          ButtonSegment(value: ThemeMode.dark, label: Text('Dark'), icon: Icon(Icons.dark_mode)),
                        ],
                        selected: {prefs.themeMode},
                        onSelectionChanged: (value) {
                          context.read<PreferencesBloc>().add(PreferencesEvent.updateThemeMode(value.first));
                        },
                      ),
                      Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        children: [
                          OutlinedButton.icon(icon: Icon(Icons.straighten), label: Text('Edit units'), onPressed: () => context.goNamed(AppRouteName.units)),
                          OutlinedButton.icon(
                            icon: Icon(Icons.scuba_diving),
                            label: Text('Dive preferences'),
                            onPressed: () => context.goNamed(AppRouteName.divePreferences),
                          ),
                        ],
                      ),
                    ],
                  ),
                  _SectionColumn(
                    title: 'Maintenance',
                    children: [
                      Row(
                        children: [
                          OutlinedButton.icon(
                            onPressed: () => _resetDatabase(context),
                            style: OutlinedButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
                            icon: Icon(Icons.delete_forever_outlined),
                            label: Text('Reset database'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _LogPreview(onTap: () => context.goNamed(AppRouteName.logs)),
                  const SizedBox(height: 24),
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
            );
          },
        );
      },
    );
  }

  Future<void> _resetDatabase(BuildContext context) async {
    final confirmed = await showConfirmationDialog(
      context: context,
      title: 'Reset database',
      message:
          'This will remove all dives, sites, etc. in Bubbletrail and revert to an empty state. '
          'Syncing will be disabled, but synced data remains untouched in the cloud. Continue?',
      cancelText: 'Cancel',
      confirmText: 'Reset database',
      isDestructive: true,
    );
    if (confirmed != true || !context.mounted) return;

    context.read<PreferencesBloc>().add(PreferencesEvent.resetDatabase());
  }
}

class _SectionColumn extends StatelessWidget {
  const _SectionColumn({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        spacing: 8,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[PreferencesSectionHeader(title: title)] + children,
      ),
    );
  }
}

class _LogPreview extends StatefulWidget {
  final VoidCallback onTap;

  const _LogPreview({required this.onTap});

  @override
  State<_LogPreview> createState() => _LogPreviewState();
}

class _LogPreviewState extends State<_LogPreview> {
  static const int _maxLines = 10;
  late List<LogRecord> _records;
  StreamSubscription<List<LogRecord>>? _subscription;

  @override
  void initState() {
    super.initState();
    _records = LogBuffer.instance.records;
    _subscription = LogBuffer.instance.stream.listen((records) {
      setState(() {
        _records = records;
      });
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final prefs = context.watch<PreferencesBloc>().state.preferences;
    final recentLogs = _records.length > _maxLines ? _records.sublist(_records.length - _maxLines) : _records;

    return InkWell(
      onTap: widget.onTap,
      borderRadius: .circular(8),
      child: Container(
        padding: const .all(8),
        decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5), borderRadius: .circular(8)),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            Row(
              children: [
                Text('Logs', style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                const Spacer(),
                Icon(Icons.chevron_right, size: 12, color: theme.colorScheme.onSurfaceVariant),
              ],
            ),
            const SizedBox(height: 4),
            if (recentLogs.isEmpty)
              Text('No log entries', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant))
            else
              ...recentLogs.map((record) => _LogLine(record: record, timeFormat: prefs.timeFormat)),
          ],
        ),
      ),
    );
  }
}

class _LogLine extends StatelessWidget {
  final LogRecord record;
  final TimeFormatPref timeFormat;

  const _LogLine({required this.record, required this.timeFormat});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final levelColor = getLogLevelColor(record.level, theme);
    final logLine = formatLogLine(timeFormat, record);

    return Padding(
      padding: const .symmetric(vertical: 2),
      child: Text(
        logLine,
        style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'courier', color: levelColor),
        maxLines: 1,
        overflow: .ellipsis,
      ),
    );
  }
}

class _ImportExportButtons extends StatelessWidget {
  Future<void> _showSaveDialog(BuildContext context, ArchiveState state) async {
    final archiveBloc = context.read<ArchiveBloc>();

    final result = await FilePicker.platform.saveFile(
      dialogTitle: 'Export backup',
      fileName: state.exportReadyFilename ?? 'bubbletrail.$backupFileExtension',
      type: FileType.custom,
    );

    if (result != null) {
      archiveBloc.add(ArchiveEvent.exportComplete(result));
    } else {
      archiveBloc.add(ArchiveEvent.exportCancelled());
    }
  }

  Future<void> _importBackup(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: [backupFileExtension]);
    if (result == null || result.files.single.path == null) return;

    if (!context.mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import backup'),
        content: const Text('This will replace your existing data with the backup. Your current data will be moved to a backup folder. Continue?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Import')),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    context.read<ArchiveBloc>().add(ArchiveEvent.importArchive(result.files.single.path!));
  }

  Future<void> _importDives(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['ssrf', 'xml']);
    if (result == null || result.files.single.path == null) return;
    if (!context.mounted) return;

    context.read<DiveListBloc>().add(DiveListEvent.importDives(result.files.single.path!));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Importing dives...')));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ArchiveBloc, ArchiveState>(
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${state.error}')));
        } else if (state.exportReadyPath != null && !state.exportComplete) {
          _showSaveDialog(context, state);
        } else if (state.exportComplete) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Export complete')));
        } else if (state.importComplete) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Import complete')));
        }
      },
      builder: (context, state) {
        return Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              icon: const Icon(Icons.file_upload_outlined, size: 16),
              label: const Text('Import log file'),
              onPressed: state.working ? null : () => _importDives(context),
            ),
            OutlinedButton.icon(
              icon: const Icon(Icons.file_download_outlined, size: 16),
              label: const Text('Export Subsurface file'),
              onPressed: state.working ? null : () => context.read<ArchiveBloc>().add(ArchiveEvent.exportSsrf()),
            ),
            OutlinedButton.icon(
              icon: const Icon(Icons.file_upload_outlined, size: 16),
              label: const Text('Import database backup'),
              onPressed: state.working ? null : () => _importBackup(context),
            ),
            OutlinedButton.icon(
              icon: const Icon(Icons.file_download_outlined, size: 16),
              label: const Text('Export database backup'),
              onPressed: state.working ? null : () => context.read<ArchiveBloc>().add(ArchiveEvent.exportArchive()),
            ),
            if (state.working) const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
          ],
        );
      },
    );
  }
}
