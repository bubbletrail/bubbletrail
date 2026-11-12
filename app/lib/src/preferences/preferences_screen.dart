import 'dart:async';
import 'dart:io';

import 'package:btl10n/btl10n.dart';
import 'package:btsparkle/btsparkle.dart';
import 'package:file_picker/file_picker.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

import '../app_metadata.dart';
import '../app_routes.dart';
import '../common/common.dart';
import '../dives_sites/dive_list_bloc.dart';
import '../equipment/equipment_list_bloc.dart';
import '../providers/storage_provider.dart';
import '../services/log_buffer.dart';
import 'archive_bloc.dart';
import 'preferences_store.dart';
import 'preferences_widgets.dart';
import 'sync_bloc.dart';

final _log = Logger('preferences_screen.dart');

class PreferencesScreen extends StatelessWidget {
  const PreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SyncBloc, SyncState>(
      builder: (context, syncState) {
        return Consumer<PreferencesStore>(
          builder: (context, prefs, _) {
            return ScreenScaffold(
              title: Text(context.l10n.preferences),
              body: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _SectionColumn(
                    title: context.l10n.syncingSection,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          FilledButton.icon(
                            icon: const Icon(Icons.sync),
                            label: Text(context.l10n.syncNow),
                            onPressed: prefs.syncProvider == .none || !prefs.s3Config.isConfigured || syncState.syncing
                                ? null
                                : () => context.read<SyncBloc>().add(const SyncEvent.startSyncing()),
                          ),
                          OutlinedButton.icon(
                            icon: Icon(Icons.cloud_sync),
                            label: Text(context.l10n.editSyncSettings),
                            onPressed: () => context.goNamed(AppRouteName.syncing),
                          ),
                        ],
                      ),
                      if (prefs.syncProvider != .none && prefs.s3Config.isConfigured) SyncStatusTile(state: syncState),
                    ],
                  ),
                  _SectionColumn(title: context.l10n.importExport, children: [_ImportExportButtons()]),
                  _SectionColumn(
                    title: context.l10n.preferences,
                    children: [
                      SegmentedButton<ThemeMode>(
                        showSelectedIcon: true,
                        segments: [
                          ButtonSegment(value: ThemeMode.system, label: Text(context.l10n.system), icon: Icon(Icons.brightness_auto)),
                          ButtonSegment(value: ThemeMode.light, label: Text(context.l10n.light), icon: Icon(Icons.light_mode)),
                          ButtonSegment(value: ThemeMode.dark, label: Text(context.l10n.dark), icon: Icon(Icons.dark_mode)),
                        ],
                        selected: {prefs.themeMode},
                        onSelectionChanged: (value) {
                          PreferencesStore.instance.themeMode = value.first;
                        },
                      ),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          OutlinedButton.icon(
                            icon: Icon(Icons.straighten),
                            label: Text(context.l10n.editUnits),
                            onPressed: () => context.goNamed(AppRouteName.units),
                          ),
                          OutlinedButton.icon(
                            icon: Icon(Icons.scuba_diving),
                            label: Text(context.l10n.divePreferences),
                            onPressed: () => context.goNamed(AppRouteName.divePreferences),
                          ),
                        ],
                      ),
                    ],
                  ),
                  _SectionColumn(
                    title: context.l10n.maintenance,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (platformIsDesktop)
                            OutlinedButton.icon(
                              onPressed: () => BTSparkle.checkForUpdates(),
                              icon: Icon(Icons.update_outlined),
                              label: Text(context.l10n.checkForUpdates),
                            ),
                          OutlinedButton.icon(
                            onPressed: () => _renumberDives(context),
                            icon: Icon(Icons.format_list_numbered),
                            label: Text(context.l10n.renumberDives),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => _resetDatabase(context),
                            style: OutlinedButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
                            icon: Icon(Icons.delete_forever_outlined),
                            label: Text(context.l10n.resetDatabase),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _LogPreview(onTap: () => context.goNamed(AppRouteName.logs)),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: .start,
                        children: [
                          Text(
                            context.l10n.appVersion(appVer, gitVer),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)),
                          ),
                          DateTimeText(
                            buildTime,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)),
                          ),
                        ],
                      ),
                      Spacer(),
                      TextButton(
                        onPressed: () => showLicensePage(
                          context: context,
                          applicationName: context.l10n.appTitle,
                          applicationVersion: '$appVer ($gitVer)',
                          applicationIcon: Padding(
                            padding: .symmetric(vertical: 8),
                            child: Container(
                              decoration: BoxDecoration(borderRadius: .circular(8)),
                              clipBehavior: .antiAlias,
                              child: Image.asset('assets/icons/app-icon.png', width: 64),
                            ),
                          ),
                        ),
                        child: Text(
                          context.l10n.openSourceLicenses,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _renumberDives(BuildContext context) async {
    int startFrom = 1;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(context.l10n.renumberDives),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.l10n.thisWillRenumberAllDivesSequentiallyInChronologicalOrderReplacingAnyExistingDiveNumbe),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(context.l10n.startFrom),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 80,
                    child: TextFormField(
                      initialValue: '1',
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: '1'),
                      onChanged: (value) {
                        final parsed = int.tryParse(value);
                        if (parsed != null && parsed > 0) {
                          startFrom = parsed;
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: Text(context.l10n.cancel)),
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: Text(context.l10n.renumberDives)),
          ],
        ),
      ),
    );
    if (!(confirmed ?? false) || !context.mounted) return;

    context.read<DiveListBloc>().add(DiveListEvent.renumberDives(startFrom: startFrom));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.renumberingDives)));
  }

  Future<void> _resetDatabase(BuildContext context) async {
    final confirmed = await showConfirmationDialog(
      context: context,
      title: context.l10n.resetDatabase,
      message: context.l10n.resetDatabaseConfirmation,
      cancelText: context.l10n.cancel,
      confirmText: context.l10n.resetDatabase,
      isDestructive: true,
    );
    if (confirmed != true || !context.mounted) return;

    PreferencesStore.instance.syncProvider = .none;
    await StorageProvider.instance.store.reset();
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
    final prefs = context.watch<PreferencesStore>();
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
                Text(context.l10n.logs, style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                const Spacer(),
                Icon(Icons.chevron_right, size: 12, color: theme.colorScheme.onSurfaceVariant),
              ],
            ),
            const SizedBox(height: 4),
            if (recentLogs.isEmpty)
              Text(context.l10n.noLogEntries, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant))
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
  // The mobile pickers filter on system-registered file types. App-specific
  // extensions like "ssrf" and "btz" are not registered there, so matching
  // files may be hidden in the picker. On mobile we therefore accept any
  // file and rely on import format auto-detection instead. Desktop keeps
  // the extension filter.
  Future<PlatformFile?> _pickFile(List<String> extensions) {
    return FilePicker.pickFile(type: platformIsMobile ? FileType.any : FileType.custom, allowedExtensions: platformIsMobile ? null : extensions);
  }

  Future<void> _showSaveDialog(BuildContext context, ArchiveState state) async {
    final archiveBloc = context.read<ArchiveBloc>();
    final fileName = state.exportReadyFilename ?? 'bubbletrail.$backupFileExtension';

    try {
      final dialogTitle = context.l10n.exportBackup;
      final bytes = await File(state.exportReadyPath!).readAsBytes();
      // FileType.custom requires a non-empty extension list, otherwise
      // file_picker throws before showing the dialog.
      final extension = fileName.split('.').last;
      // The mobile save flows (iOS document export, Android SAF) name the
      // saved file from the fileName we pass, so it must include the
      // extension. Desktop save panels derive the extension themselves and
      // would end up with a doubled extension if we included it here.
      final name = platformIsMobile ? fileName : fileName.substring(0, fileName.length - extension.length - 1);
      final result = await FilePicker.saveFile(bytes: bytes, dialogTitle: dialogTitle, fileName: name, type: FileType.custom, allowedExtensions: [extension]);

      if (result != null) {
        // file URIs map to a filesystem path; other schemes (content etc.) are kept as-is.
        final destination = result.scheme == 'file' ? result.toFilePath() : result.toString();
        archiveBloc.add(ArchiveEvent.exportComplete(destination));
      } else {
        archiveBloc.add(ArchiveEvent.exportCancelled());
      }
    } catch (e) {
      _log.severe('failed to show save dialog', e);
      archiveBloc.add(ArchiveEvent.exportFailed(e.toString()));
    }
  }

  Future<void> _importBackup(BuildContext context) async {
    final file = await _pickFile([backupFileExtension]);
    if (file == null || file.path == null) return;

    if (!context.mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.importBackup),
        content: Text(context.l10n.thisWillReplaceYourExistingDataWithTheBackupYourCurrentDataWillBeMovedToABackupFolder),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(context.l10n.cancel)),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(context.l10n.import)),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    context.read<ArchiveBloc>().add(ArchiveEvent.importArchive(file.path!));
  }

  Future<void> _importDives(BuildContext context) async {
    final file = await _pickFile(['ssrf', 'xml', 'uddf', 'json']);
    if (file == null || file.path == null) return;
    if (!context.mounted) return;

    context.read<DiveListBloc>().add(DiveListEvent.importDives(file.path!));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.importingDives)));
  }

  Future<void> _importEquipment(BuildContext context) async {
    final file = await _pickFile(['csv']);
    if (file == null || file.path == null) return;
    if (!context.mounted) return;

    context.read<EquipmentListBloc>().add(EquipmentListEvent.importEquipment(file.path!));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.importingEquipment)));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ArchiveBloc, ArchiveState>(
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.errorDetails(localizeError(context.l10n, state.error!)))));
        } else if (state.exportReadyPath != null && !state.exportComplete) {
          _showSaveDialog(context, state);
        } else if (state.exportComplete) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.exportComplete)));
        } else if (state.importComplete) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.importComplete)));
        }
      },
      builder: (context, state) {
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              icon: const Icon(Icons.file_upload_outlined, size: 16),
              label: Text(context.l10n.importLogFile),
              onPressed: state.working ? null : () => _importDives(context),
            ),
            OutlinedButton.icon(
              icon: const Icon(Icons.file_upload_outlined, size: 16),
              label: Text(context.l10n.importEquipment),
              onPressed: state.working ? null : () => _importEquipment(context),
            ),
            OutlinedButton.icon(
              icon: const Icon(Icons.file_download_outlined, size: 16),
              label: Text(context.l10n.exportSubsurfaceFile),
              onPressed: state.working ? null : () => context.read<ArchiveBloc>().add(ArchiveEvent.exportSsrf()),
            ),
            OutlinedButton.icon(
              icon: const Icon(Icons.file_download_outlined, size: 16),
              label: Text(context.l10n.exportUDDFFile),
              onPressed: state.working ? null : () => context.read<ArchiveBloc>().add(ArchiveEvent.exportUddf()),
            ),
            OutlinedButton.icon(
              icon: const Icon(Icons.file_upload_outlined, size: 16),
              label: Text(context.l10n.importDatabaseBackup),
              onPressed: state.working ? null : () => _importBackup(context),
            ),
            OutlinedButton.icon(
              icon: const Icon(Icons.file_download_outlined, size: 16),
              label: Text(context.l10n.exportDatabaseBackup),
              onPressed: state.working ? null : () => context.read<ArchiveBloc>().add(ArchiveEvent.exportArchive()),
            ),
            if (state.working) const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
          ],
        );
      },
    );
  }
}
