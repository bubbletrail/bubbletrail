import 'package:flutter/material.dart';

import 'adaptive_modal.dart';
import 'duration_picker.dart';
import 'measurement_editor.dart';
import 'units.dart';

// The basic, manually entered facts about a dive.
class DiveBasics {
  final DateTime start;
  final int durationSeconds;
  final double maxDepth;

  const DiveBasics({required this.start, required this.durationSeconds, required this.maxDepth});
}

// Shows an editor for the raw dive facts: start date/time, and (for manually
// entered dives) duration and max depth. On mobile this is a bottom sheet, on
// desktop a modal dialog. Returns the edited values, or null if cancelled.
//
// When [canEditDepthDuration] is false the dive has a real computer profile,
// so duration and depth are read-only and derived from the samples.
Future<DiveBasics?> showDiveBasicsEditor({
  required BuildContext context,
  required DateTime start,
  required int durationSeconds,
  required double maxDepth,
  required bool canEditDepthDuration,
}) {
  return showAdaptiveModal<DiveBasics>(
    context: context,
    builder: (context) => _DiveBasicsEditor(start: start, durationSeconds: durationSeconds, maxDepth: maxDepth, canEditDepthDuration: canEditDepthDuration),
  );
}

class _DiveBasicsEditor extends StatefulWidget {
  final DateTime start;
  final int durationSeconds;
  final double maxDepth;
  final bool canEditDepthDuration;

  const _DiveBasicsEditor({required this.start, required this.durationSeconds, required this.maxDepth, required this.canEditDepthDuration});

  @override
  State<_DiveBasicsEditor> createState() => _DiveBasicsEditorState();
}

class _DiveBasicsEditorState extends State<_DiveBasicsEditor> {
  late DateTime _start;
  late int _durationSeconds;
  late double _maxDepth;

  @override
  void initState() {
    super.initState();
    _start = widget.start;
    _durationSeconds = widget.durationSeconds;
    _maxDepth = widget.maxDepth;
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(context: context, initialDate: _start, firstDate: DateTime(1900), lastDate: DateTime(2100));
    if (picked != null) {
      setState(() => _start = DateTime(picked.year, picked.month, picked.day, _start.hour, _start.minute, _start.second));
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(context: context, initialTime: .fromDateTime(_start));
    if (picked != null) {
      setState(() => _start = DateTime(_start.year, _start.month, _start.day, picked.hour, picked.minute));
    }
  }

  Future<void> _selectDuration() async {
    final result = await showDialog<int>(
      context: context,
      builder: (context) => DurationPickerDialog(initialSeconds: _durationSeconds),
    );
    if (result != null) setState(() => _durationSeconds = result);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const .all(16.0),
        child: Column(
          mainAxisSize: .min,
          crossAxisAlignment: .stretch,
          spacing: 16,
          children: [
            Text('Dive details', style: Theme.of(context).textTheme.titleMedium),
            Row(
              spacing: 16,
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _selectDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'Date', border: OutlineInputBorder(), suffixIcon: Icon(Icons.calendar_today)),
                      child: DateText(_start),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: _selectTime,
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'Time', border: OutlineInputBorder(), suffixIcon: Icon(Icons.access_time)),
                      child: TimeText(_start),
                    ),
                  ),
                ),
              ],
            ),
            if (widget.canEditDepthDuration)
              Row(
                spacing: 16,
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _selectDuration,
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Duration', border: OutlineInputBorder(), suffixIcon: Icon(Icons.timer)),
                        child: DurationText(_durationSeconds),
                      ),
                    ),
                  ),
                  Expanded(
                    child: DepthEditor(
                      label: 'Max depth',
                      initialValue: _maxDepth,
                      onChanged: (val) {
                        if (val != null) _maxDepth = val;
                      },
                    ),
                  ),
                ],
              ),
            Row(
              mainAxisAlignment: .end,
              spacing: 8,
              children: [
                TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(DiveBasics(start: _start, durationSeconds: _durationSeconds, maxDepth: _maxDepth)),
                  child: const Text('Done'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
