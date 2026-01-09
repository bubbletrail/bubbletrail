import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

import '../bloc/preferences_bloc.dart';
import '../common/common.dart';
import '../services/log_buffer.dart';

class LogsScreen extends StatefulWidget {
  const LogsScreen({super.key});

  @override
  State<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> {
  late List<LogRecord> _records;
  StreamSubscription<List<LogRecord>>? _subscription;
  Level _minLevel = .ALL;

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

  List<LogRecord> get _filteredRecords {
    return _records.where((r) => r.level >= _minLevel).toList();
  }

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<PreferencesBloc>().state.preferences;
    final filtered = _filteredRecords;
    return ScreenScaffold(
      title: const Text('Logs'),
      actions: [
        PopupMenuButton<Level>(
          icon: const Icon(Icons.filter_list),
          tooltip: 'Filter by level',
          onSelected: (level) {
            setState(() {
              _minLevel = level;
            });
          },
          itemBuilder: (context) => [
            _buildLevelMenuItem(.ALL, 'All'),
            _buildLevelMenuItem(.FINE, 'Debug+'),
            _buildLevelMenuItem(.INFO, 'Info+'),
            _buildLevelMenuItem(.WARNING, 'Warning+'),
            _buildLevelMenuItem(.SEVERE, 'Severe'),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.copy),
          tooltip: 'Copy all logs',
          onPressed: _records.isEmpty
              ? null
              : () {
                  final text = _records.map((r) => formatLogLine(prefs.timeFormat, r)).join('\n');
                  Clipboard.setData(ClipboardData(text: text));
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Copied ${_records.length} log entries'), duration: const Duration(seconds: 1)));
                },
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline),
          tooltip: 'Clear logs',
          onPressed: () {
            LogBuffer.instance.clear();
          },
        ),
      ],
      body: filtered.isEmpty
          ? const Center(child: Text('No log entries'))
          : ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final record = filtered[index];
                return _LogEntryTile(record: record, timeFormat: prefs.timeFormat);
              },
            ),
    );
  }

  PopupMenuItem<Level> _buildLevelMenuItem(Level level, String label) {
    return PopupMenuItem(
      value: level,
      child: Row(children: [if (_minLevel == level) const Icon(Icons.check, size: 18) else const SizedBox(width: 18), const SizedBox(width: 8), Text(label)]),
    );
  }
}

class _LogEntryTile extends StatelessWidget {
  final LogRecord record;
  final TimeFormatPref timeFormat;

  const _LogEntryTile({required this.record, required this.timeFormat});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final levelColor = getLogLevelColor(record.level, theme);
    final logLine = formatLogLine(timeFormat, record);

    return InkWell(
      child: Padding(
        padding: const .symmetric(horizontal: 12),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            Text(
              logLine,
              style: theme.textTheme.bodyMedium?.copyWith(fontFamily: 'courier', color: levelColor),
            ),
            if (record.error != null)
              Text(
                'Error: ${record.error}',
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error, fontFamily: 'courier'),
              ),
          ],
        ),
      ),
    );
  }
}
