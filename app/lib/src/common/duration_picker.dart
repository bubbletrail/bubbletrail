import 'package:flutter/material.dart';

/// A dialog for picking a duration with text fields and a slider
class DurationPickerDialog extends StatefulWidget {
  final int initialSeconds;
  final int maxSeconds;
  final String title;

  const DurationPickerDialog({
    super.key,
    required this.initialSeconds,
    this.maxSeconds = 7200, // 2 hours default
    this.title = 'Duration',
  });

  @override
  State<DurationPickerDialog> createState() => _DurationPickerDialogState();
}

class _DurationPickerDialogState extends State<DurationPickerDialog> {
  late final TextEditingController _minutesController;
  late final TextEditingController _secondsController;
  late int _currentSeconds;

  @override
  void initState() {
    super.initState();
    _currentSeconds = widget.initialSeconds.clamp(0, widget.maxSeconds);
    _minutesController = TextEditingController(text: (_currentSeconds ~/ 60).toString());
    _secondsController = TextEditingController(text: (_currentSeconds % 60).toString());
  }

  @override
  void dispose() {
    _minutesController.dispose();
    _secondsController.dispose();
    super.dispose();
  }

  void _updateFromTextFields() {
    final minutes = int.tryParse(_minutesController.text) ?? 0;
    final seconds = int.tryParse(_secondsController.text) ?? 0;
    final total = (minutes * 60 + seconds).clamp(0, widget.maxSeconds);
    setState(() {
      _currentSeconds = total;
    });
  }

  void _updateFromSlider(double value) {
    final seconds = (value * 15).round(); // 15-second steps
    setState(() {
      _currentSeconds = seconds;
      _minutesController.text = (seconds ~/ 60).toString();
      _secondsController.text = (seconds % 60).toString();
    });
  }

  String get _sliderLabel {
    final minutes = _currentSeconds ~/ 60;
    final seconds = _currentSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final maxDivisions = widget.maxSeconds ~/ 15;

    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: .min,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _minutesController,
                  decoration: const InputDecoration(labelText: 'Minutes', border: OutlineInputBorder()),
                  keyboardType: .number,
                  onChanged: (_) => _updateFromTextFields(),
                ),
              ),
              const Padding(padding: .symmetric(horizontal: 8), child: Text(':')),
              Expanded(
                child: TextField(
                  controller: _secondsController,
                  decoration: const InputDecoration(labelText: 'Seconds', border: OutlineInputBorder()),
                  keyboardType: .number,
                  onChanged: (_) => _updateFromTextFields(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(_sliderLabel, style: Theme.of(context).textTheme.headlineSmall),
          Slider(
            value: (_currentSeconds / 15).clamp(0, maxDivisions.toDouble()),
            min: 0,
            max: maxDivisions.toDouble(),
            divisions: maxDivisions,
            onChanged: _updateFromSlider,
          ),
          Text('0 - ${widget.maxSeconds ~/ 60} min', style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(null), child: const Text('Cancel')),
        TextButton(onPressed: () => Navigator.of(context).pop(_currentSeconds), child: const Text('OK')),
      ],
    );
  }
}
