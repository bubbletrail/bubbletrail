import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';

import '../app_metadata.dart';
import '../app_routes.dart';
import '../bloc/archive_bloc.dart';
import '../bloc/preferences_bloc.dart';
import '../bloc/sync_bloc.dart';
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
                padding: const .all(16),
                children: [
                  PreferencesCategoryCard(icon: FontAwesomeIcons.bottleWater, title: 'Cylinders', onTap: () => context.goNamed(AppRouteName.cylinders)),
                  PreferencesCategoryCard(icon: FontAwesomeIcons.ruler, title: 'Units', onTap: () => context.goNamed(AppRouteName.units)),
                  PreferencesCategoryCard(icon: FontAwesomeIcons.cloudArrowUp, title: 'Syncing', onTap: () => context.goNamed(AppRouteName.syncing)),
                  const SizedBox(height: 24),
                  const PreferencesSectionHeader(title: 'Appearance'),
                  PreferencesTile(
                    title: 'Theme',
                    trailing: SegmentedButton<ThemeMode>(
                      showSelectedIcon: true,
                      segments: const [
                        ButtonSegment(value: .system, label: Text('System'), icon: Icon(null)),
                        ButtonSegment(value: .light, label: Text('Light'), icon: Icon(null)),
                        ButtonSegment(value: .dark, label: Text('Dark'), icon: Icon(null)),
                      ],
                      selected: {prefs.themeMode},
                      onSelectionChanged: (value) {
                        context.read<PreferencesBloc>().add(UpdateThemeMode(value.first));
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  const PreferencesSectionHeader(title: 'Backup'),
                  _ImportExportButtons(),
                  const SizedBox(height: 24),
                  const SizedBox(height: 8),
                  if (prefs.syncProvider != .none && prefs.s3Config.isConfigured)
                    Wrap(
                      spacing: 24,
                      runSpacing: 8,
                      children: [
                        FilledButton.icon(
                          onPressed: syncState.syncing ? null : () => context.read<SyncBloc>().add(const StartSyncing()),
                          icon: const FaIcon(FontAwesomeIcons.arrowsRotate, size: 16),
                          label: Text('Sync now'),
                        ),
                        SyncStatusTile(state: syncState),
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
                FaIcon(FontAwesomeIcons.chevronRight, size: 12, color: theme.colorScheme.onSurfaceVariant),
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
      archiveBloc.add(ExportComplete(result));
    } else {
      archiveBloc.add(ExportCancelled());
    }
  }

  Future<void> _import(BuildContext context) async {
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

    context.read<ArchiveBloc>().add(ImportArchive(result.files.single.path!));
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
            FilledButton.icon(
              onPressed: state.working ? null : () => context.read<ArchiveBloc>().add(ExportArchive()),
              icon: const FaIcon(FontAwesomeIcons.fileExport, size: 16),
              label: const Text('Export'),
            ),
            OutlinedButton.icon(
              onPressed: state.working ? null : () => _import(context),
              icon: const FaIcon(FontAwesomeIcons.fileImport, size: 16),
              label: const Text('Import'),
            ),
            if (state.working) const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
          ],
        );
      },
    );
  }
}
