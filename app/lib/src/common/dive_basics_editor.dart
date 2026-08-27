import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'adaptive_modal.dart';
import 'duration_picker.dart';
import 'measurement_editor.dart';
import 'timezone.dart';
import 'units.dart';

// The basic, manually entered facts about a dive. [start] is a UTC instant.
class DiveBasics {
  final int number;
  final DateTime start;
  final int durationSeconds;
  final double maxDepth;

  const DiveBasics({required this.number, required this.start, required this.durationSeconds, required this.maxDepth});
}

// Shows an editor for the raw dive facts: start date/time, and (for manually
// entered dives) duration and max depth. On mobile this is a bottom sheet, on
// desktop a modal dialog. Returns the edited values, or null if cancelled.
//
// [start] is the UTC instant of the dive. When [timezone] (an IANA name) is
// given the date/time are shown and edited in that zone and converted back to
// UTC on save; otherwise UTC is used throughout.
//
// When [canEditDepthDuration] is false the dive has a real computer profile,
// so duration and depth are read-only and derived from the samples.
Future<DiveBasics?> showDiveBasicsEditor({
  required BuildContext context,
  required int number,
  required DateTime start,
  String? timezone,
  required int durationSeconds,
  required double maxDepth,
  required bool canEditDepthDuration,
}) {
  return showAdaptiveModal<DiveBasics>(
    context: context,
    builder: (context) => _DiveBasicsEditor(
      number: number,
      start: start,
      timezone: timezone,
      durationSeconds: durationSeconds,
      maxDepth: maxDepth,
      canEditDepthDuration: canEditDepthDuration,
    ),
  );
}

class _DiveBasicsEditor extends StatefulWidget {
  final int number;
  final DateTime start;
  final String? timezone;
  final int durationSeconds;
  final double maxDepth;
  final bool canEditDepthDuration;

  const _DiveBasicsEditor({
    required this.number,
    required this.start,
    this.timezone,
    required this.durationSeconds,
    required this.maxDepth,
    required this.canEditDepthDuration,
  });

  @override
  State<_DiveBasicsEditor> createState() => _DiveBasicsEditorState();
}

class _DiveBasicsEditorState extends State<_DiveBasicsEditor> {
  // The wall clock in the site's zone, held as a plain DateTime whose fields
  // are the local values. Converted back to a UTC instant on save.
  late DateTime _start;
  late int _durationSeconds;
  late double _maxDepth;
  late final TextEditingController _numberController;

  @override
  void initState() {
    super.initState();
    final zoned = inZone(widget.start, widget.timezone) ?? widget.start;
    _start = DateTime(zoned.year, zoned.month, zoned.day, zoned.hour, zoned.minute, zoned.second);
    _durationSeconds = widget.durationSeconds;
    _maxDepth = widget.maxDepth;
    _numberController = TextEditingController(text: '${widget.number}');
  }

  @override
  void dispose() {
    _numberController.dispose();
    super.dispose();
  }

  // Falls back to the original number when the field is empty or unparseable.
  int get _number => int.tryParse(_numberController.text.trim()) ?? widget.number;

  // Abbreviation of the site's zone at the currently selected time, or null.
  String? get _zoneAbbreviation => inZone(wallClockToUtc(_start, widget.timezone), widget.timezone)?.timeZoneName;

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
            if (_zoneAbbreviation != null)
              Text('Times shown in $_zoneAbbreviation', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor)),
            TextField(
              controller: _numberController,
              decoration: const InputDecoration(labelText: 'Dive number', border: OutlineInputBorder(), suffixIcon: Icon(Icons.tag)),
              keyboardType: .number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
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
                  onPressed: () => Navigator.of(
                    context,
                  ).pop(DiveBasics(number: _number, start: wallClockToUtc(_start, widget.timezone), durationSeconds: _durationSeconds, maxDepth: _maxDepth)),
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
