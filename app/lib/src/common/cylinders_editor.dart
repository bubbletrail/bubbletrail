import 'package:btproto/btproto.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import 'adaptive_modal.dart';
import 'duration_picker.dart';
import 'measurement_editor.dart';

// The result of editing a dive's cylinders: the cylinders themselves plus the
// gas-change events (already renumbered to the new cylinder indices, sorted by
// time). Any non-gas-change events are the caller's responsibility to keep.
class CylindersEdit {
  final List<DiveCylinder> cylinders;
  final List<SampleEvent> gasChangeEvents;

  const CylindersEdit({required this.cylinders, required this.gasChangeEvents});
}

// Shows an editor for a dive's cylinders, gas mixes and gas switches. On mobile
// this is a bottom sheet, on desktop a modal dialog. [durationSeconds] bounds
// the gas-change times. Returns the updated cylinders/events, or null if
// cancelled.
Future<CylindersEdit?> showCylindersEditor({
  required BuildContext context,
  required List<DiveCylinder> cylinders,
  required List<Cylinder> availableCylinders,
  required int durationSeconds,
  required List<SampleEvent> gasChangeEvents,
}) {
  return showAdaptiveModal<CylindersEdit>(
    context: context,
    builder: (context) =>
        _CylindersEditor(cylinders: cylinders, availableCylinders: availableCylinders, durationSeconds: durationSeconds, gasChangeEvents: gasChangeEvents),
  );
}

class _CylinderRow {
  final int? originalIndex;
  String cylinderId;
  Cylinder? cylinder;
  final TextEditingController oxygen;
  final TextEditingController helium;
  double? beginPressure;
  double? endPressure;
  // Times (seconds into the dive) at which the dive switches to this cylinder.
  final List<int> switchTimes = [];

  _CylinderRow({
    required this.originalIndex,
    required this.cylinderId,
    required this.cylinder,
    required int oxygen,
    required int helium,
    this.beginPressure,
    this.endPressure,
  }) : oxygen = TextEditingController(text: oxygen.toString()),
       helium = TextEditingController(text: helium.toString());

  void dispose() {
    oxygen.dispose();
    helium.dispose();
  }

  DiveCylinder toCylinder() {
    return DiveCylinder(
      cylinderId: cylinderId,
      cylinder: cylinder,
      oxygen: (int.tryParse(oxygen.text) ?? 0) / 100,
      helium: (int.tryParse(helium.text) ?? 0) / 100,
      beginPressure: beginPressure,
      endPressure: endPressure,
    );
  }
}

class _CylindersEditor extends StatefulWidget {
  final List<DiveCylinder> cylinders;
  final List<Cylinder> availableCylinders;
  final int durationSeconds;
  final List<SampleEvent> gasChangeEvents;

  const _CylindersEditor({required this.cylinders, required this.availableCylinders, required this.durationSeconds, required this.gasChangeEvents});

  @override
  State<_CylindersEditor> createState() => _CylindersEditorState();
}

class _CylindersEditorState extends State<_CylindersEditor> {
  late final List<_CylinderRow> _rows;

  @override
  void initState() {
    super.initState();
    _rows = widget.cylinders.indexed
        .map(
          (e) => _CylinderRow(
            originalIndex: e.$1,
            cylinderId: e.$2.cylinderId,
            cylinder: e.$2.hasCylinder() ? e.$2.cylinder : null,
            oxygen: (e.$2.oxygen * 100).round(),
            helium: (e.$2.helium * 100).round(),
            beginPressure: e.$2.hasBeginPressure() ? e.$2.beginPressure : null,
            endPressure: e.$2.hasEndPressure() ? e.$2.endPressure : null,
          ),
        )
        .toList();

    // Attach existing gas switches to their cylinder rows by original index.
    for (final event in widget.gasChangeEvents) {
      _rows.firstWhereOrNull((r) => r.originalIndex == event.value)?.switchTimes.add(event.time);
    }
    for (final row in _rows) {
      row.switchTimes.sort();
    }
  }

  @override
  void dispose() {
    for (final r in _rows) {
      r.dispose();
    }
    super.dispose();
  }

  void _add() {
    final first = widget.availableCylinders.first;
    setState(() {
      _rows.add(_CylinderRow(originalIndex: null, cylinderId: first.id, cylinder: first, oxygen: 21, helium: 0));
    });
  }

  void _remove(int index) => setState(() => _rows.removeAt(index).dispose());

  Future<void> _addGasChange(_CylinderRow row) async {
    final maxSeconds = widget.durationSeconds > 0 ? widget.durationSeconds : 7200;
    final result = await showDialog<int>(
      context: context,
      builder: (context) => DurationPickerDialog(initialSeconds: 0, maxSeconds: maxSeconds, title: 'Gas change time'),
    );
    if (result != null) {
      setState(() {
        row.switchTimes
          ..add(result)
          ..sort();
      });
    }
  }

  CylindersEdit _result() {
    final cylinders = _rows.map((r) => r.toCylinder()).toList();
    final events = <SampleEvent>[];
    for (final (index, row) in _rows.indexed) {
      for (final time in row.switchTimes) {
        events.add(SampleEvent(type: SampleEventType.SAMPLE_EVENT_TYPE_GAS_CHANGE, time: time, value: index));
      }
    }
    events.sort((a, b) => a.time.compareTo(b.time));
    return CylindersEdit(cylinders: cylinders, gasChangeEvents: events);
  }

  // The type options for a row: the globally available cylinders, plus the
  // row's own cylinder if it's no longer in that list.
  List<Cylinder> _optionsFor(_CylinderRow row) {
    final options = [...widget.availableCylinders];
    if (row.cylinder != null && !options.any((c) => c.id == row.cylinderId)) {
      options.insert(0, row.cylinder!);
    }
    return options;
  }

  static String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final canAdd = widget.availableCylinders.isNotEmpty;
    return SafeArea(
      child: Padding(
        padding: const .all(16.0),
        child: Column(
          mainAxisSize: .min,
          crossAxisAlignment: .stretch,
          spacing: 16,
          children: [
            Text('Cylinders', style: Theme.of(context).textTheme.titleMedium),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  spacing: 8,
                  children: [
                    for (final (index, row) in _rows.indexed)
                      Card(
                        key: ObjectKey(row),
                        margin: .zero,
                        child: Padding(
                          padding: const .all(12),
                          child: Column(
                            crossAxisAlignment: .start,
                            spacing: 12,
                            children: [
                              Row(
                                spacing: 8,
                                children: [
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      initialValue: _optionsFor(row).any((c) => c.id == row.cylinderId) ? row.cylinderId : null,
                                      decoration: const InputDecoration(labelText: 'Cylinder', border: OutlineInputBorder(), isDense: true),
                                      items: _optionsFor(row)
                                          .map((c) => DropdownMenuItem(value: c.id, child: Text(c.description.isNotEmpty ? c.description : 'Cylinder ${c.id}')))
                                          .toList(),
                                      onChanged: (id) {
                                        if (id == null) return;
                                        setState(() {
                                          row.cylinderId = id;
                                          row.cylinder = _optionsFor(row).firstWhere((c) => c.id == id);
                                        });
                                      },
                                    ),
                                  ),
                                  IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => _remove(index), tooltip: 'Remove'),
                                ],
                              ),
                              Row(
                                spacing: 16,
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: row.oxygen,
                                      decoration: const InputDecoration(labelText: 'Oxygen %', border: OutlineInputBorder(), isDense: true),
                                      keyboardType: const .numberWithOptions(decimal: true),
                                    ),
                                  ),
                                  Expanded(
                                    child: TextField(
                                      controller: row.helium,
                                      decoration: const InputDecoration(labelText: 'Helium %', border: OutlineInputBorder(), isDense: true),
                                      keyboardType: const .numberWithOptions(decimal: true),
                                    ),
                                  ),
                                ],
                              ),
                              PressureEditor(label: 'Start pressure', initialValue: row.beginPressure, onChanged: (value) => row.beginPressure = value),
                              PressureEditor(label: 'End pressure', initialValue: row.endPressure, onChanged: (value) => row.endPressure = value),
                              _GasChanges(
                                row: row,
                                formatTime: _formatTime,
                                onAdd: () => _addGasChange(row),
                                onRemove: (i) => setState(() => row.switchTimes.removeAt(i)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (canAdd)
                      Align(
                        alignment: .centerLeft,
                        child: TextButton.icon(onPressed: _add, icon: const Icon(Icons.add), label: const Text('Add cylinder')),
                      )
                    else
                      Text('No cylinders defined. Add cylinders in Equipment first.', style: TextStyle(color: Theme.of(context).hintColor)),
                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: .end,
              spacing: 8,
              children: [
                TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                FilledButton(onPressed: () => Navigator.of(context).pop(_result()), child: const Text('Done')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// The gas-switch list for a single cylinder: each time the dive switches to it,
// plus a control to add another.
class _GasChanges extends StatelessWidget {
  final _CylinderRow row;
  final String Function(int) formatTime;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  const _GasChanges({required this.row, required this.formatTime, required this.onAdd, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text('Gas changes', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: .bold)),
        for (final (i, time) in row.switchTimes.indexed)
          Padding(
            padding: const .only(left: 8, top: 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(time == 0 ? '• Start of dive' : '• ${formatTime(time)} switch to this cylinder', style: Theme.of(context).textTheme.bodySmall),
                ),
                InkWell(onTap: () => onRemove(i), child: const Icon(Icons.close, size: 14)),
              ],
            ),
          ),
        TextButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add, size: 14),
          label: const Text('Add gas change'),
          style: TextButton.styleFrom(padding: .zero, minimumSize: const Size(0, 32)),
        ),
      ],
    );
  }
}
