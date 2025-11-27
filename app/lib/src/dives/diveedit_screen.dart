import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../ssrf/ssrf.dart';
import '../bloc/divelist_bloc.dart';

class DiveEditScreen extends StatefulWidget {
  final String? diveID;

  const DiveEditScreen({super.key, required this.diveID});

  @override
  State<DiveEditScreen> createState() => _DiveEditScreenState();
}

class _DiveEditScreenState extends State<DiveEditScreen> {
  late final Dive dive;
  late final TextEditingController _numberController;
  late final TextEditingController _dateController;
  late final TextEditingController _timeController;
  late final TextEditingController _durationController;
  late final TextEditingController _divemasterController;
  late final TextEditingController _buddiesController;
  late final TextEditingController _notesController;
  late final TextEditingController _tagsController;
  late int? _rating;

  @override
  void initState() {
    super.initState();
    if (widget.diveID == null) {
      dive = Dive(number: 0, start: DateTime.now(), duration: 0);
    } else {
      dive = (context.read<DiveListBloc>().state as DiveListLoaded).dives.firstWhere((d) => d.id == widget.diveID);
    }
    _numberController = TextEditingController(text: dive.number.toString());
    _dateController = TextEditingController(text: DateFormat('yyyy-MM-dd').format(dive.start));
    _timeController = TextEditingController(text: DateFormat('HH:mm:ss').format(dive.start));
    _durationController = TextEditingController(text: (dive.duration / 60).toStringAsFixed(1));
    _divemasterController = TextEditingController(text: dive.divemaster ?? '');
    _buddiesController = TextEditingController(text: dive.buddies.join(', '));
    _notesController = TextEditingController(text: dive.notes ?? '');
    _tagsController = TextEditingController(text: dive.tags.join(', '));
    _rating = dive.rating;
  }

  @override
  void dispose() {
    _numberController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _durationController.dispose();
    _divemasterController.dispose();
    _buddiesController.dispose();
    _notesController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _saveDive() {
    try {
      // Parse date and time
      final dateParts = _dateController.text.split('-');
      final timeParts = _timeController.text.split(':');

      if (dateParts.length != 3 || timeParts.length != 3) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid date or time format')));
        return;
      }

      final year = int.parse(dateParts[0]);
      final month = int.parse(dateParts[1]);
      final day = int.parse(dateParts[2]);
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      final second = int.parse(timeParts[2]);

      final start = DateTime(year, month, day, hour, minute, second);
      final durationMinutes = double.parse(_durationController.text);

      // Update dive properties
      dive.number = int.parse(_numberController.text);
      dive.start = start;
      dive.duration = durationMinutes * 60;
      dive.rating = _rating;
      dive.divemaster = _divemasterController.text.trim().isEmpty ? null : _divemasterController.text.trim();
      dive.notes = _notesController.text.trim().isEmpty ? null : _notesController.text.trim();

      // Update buddies
      final buddiesText = _buddiesController.text.trim();
      dive.buddies = buddiesText.isEmpty ? {} : buddiesText.split(',').map((b) => b.trim()).where((b) => b.isNotEmpty).toSet();

      // Update tags
      final tagsText = _tagsController.text.trim();
      dive.tags = tagsText.isEmpty ? {} : tagsText.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toSet();

      // Send update event to bloc
      context.read<DiveListBloc>().add(UpdateDive(dive));

      // Navigate back
      context.pop();

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dive updated successfully')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving dive: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Dive #${dive.number}'),
        actions: [IconButton(icon: const Icon(Icons.save), onPressed: _saveDive, tooltip: 'Save')],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _numberController,
              decoration: const InputDecoration(labelText: 'Dive Number', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _dateController,
              decoration: const InputDecoration(labelText: 'Date (yyyy-MM-dd)', border: OutlineInputBorder(), helperText: 'Format: yyyy-MM-dd'),
              keyboardType: TextInputType.datetime,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _timeController,
              decoration: const InputDecoration(labelText: 'Time (HH:mm:ss)', border: OutlineInputBorder(), helperText: 'Format: HH:mm:ss'),
              keyboardType: TextInputType.datetime,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _durationController,
              decoration: const InputDecoration(labelText: 'Duration (minutes)', border: OutlineInputBorder()),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            Text('Rating', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: List.generate(5, (index) {
                final starValue = index + 1;
                return IconButton(
                  icon: Icon(_rating != null && starValue <= _rating! ? Icons.star : Icons.star_border, color: Colors.amber, size: 32),
                  onPressed: () {
                    setState(() {
                      _rating = starValue == _rating ? null : starValue;
                    });
                  },
                );
              }),
            ),
            if (_rating != null)
              TextButton(
                onPressed: () {
                  setState(() {
                    _rating = null;
                  });
                },
                child: const Text('Clear rating'),
              ),
            const SizedBox(height: 16),
            TextField(
              controller: _tagsController,
              decoration: const InputDecoration(labelText: 'Tags', border: OutlineInputBorder(), helperText: 'Comma-separated'),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _divemasterController,
              decoration: const InputDecoration(labelText: 'Divemaster', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _buddiesController,
              decoration: const InputDecoration(labelText: 'Buddies', border: OutlineInputBorder(), helperText: 'Comma-separated'),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notes', border: OutlineInputBorder()),
              maxLines: 6,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveDive,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('Save Changes', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
