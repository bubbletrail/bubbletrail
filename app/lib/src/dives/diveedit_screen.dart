import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../bloc/divedetails_bloc.dart';
import '../common/common_widgets.dart';
import '../ssrf/ssrf.dart' as ssrf;

class DiveEditScreen extends StatefulWidget {
  const DiveEditScreen({super.key});

  @override
  State<DiveEditScreen> createState() => _DiveEditScreenState();
}

class _DiveEditScreenState extends State<DiveEditScreen> {
  late final ssrf.Dive dive;
  late final TextEditingController _durationController;
  late final TextEditingController _divemasterController;
  late final TextEditingController _buddiesController;
  late final TextEditingController _notesController;
  late final TextEditingController _tagsController;
  late DateTime _selectedDateTime;
  late int? _rating;

  @override
  void initState() {
    super.initState();
    dive = (context.read<DiveDetailsBloc>().state as DiveDetailsLoaded).dive;
    _selectedDateTime = dive.start;
    _durationController = TextEditingController(text: (dive.duration / 60).toStringAsFixed(1));
    _divemasterController = TextEditingController(text: dive.divemaster ?? '');
    _buddiesController = TextEditingController(text: dive.buddies.join(', '));
    _notesController = TextEditingController(text: dive.notes ?? '');
    _tagsController = TextEditingController(text: dive.tags.join(', '));
    _rating = dive.rating;
  }

  @override
  void dispose() {
    _durationController.dispose();
    _divemasterController.dispose();
    _buddiesController.dispose();
    _notesController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(context: context, initialDate: _selectedDateTime, firstDate: DateTime(1900), lastDate: DateTime(2100));
    if (picked != null) {
      setState(() {
        _selectedDateTime = DateTime(picked.year, picked.month, picked.day, _selectedDateTime.hour, _selectedDateTime.minute, _selectedDateTime.second);
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_selectedDateTime));
    if (picked != null) {
      setState(() {
        _selectedDateTime = DateTime(_selectedDateTime.year, _selectedDateTime.month, _selectedDateTime.day, picked.hour, picked.minute, 0);
      });
    }
  }

  void _saveDive() {
    try {
      final durationMinutes = double.parse(_durationController.text);

      // Update dive properties
      dive.start = _selectedDateTime;
      dive.duration = (durationMinutes * 60).toInt();
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
      context.read<DiveDetailsBloc>().add(UpdateDiveDetails(dive));

      // Navigate back
      context.pop();

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dive updated successfully')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving dive: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: Text('Edit Dive #${dive.number}'),
      actions: [IconButton(icon: const Icon(Icons.save), onPressed: _saveDive, tooltip: 'Save')],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
            Row(
              spacing: 16,
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _selectDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'Date', border: OutlineInputBorder(), suffixIcon: Icon(Icons.calendar_today)),
                      child: Text(DateFormat.yMd().format(_selectedDateTime)),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: _selectTime,
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'Time', border: OutlineInputBorder(), suffixIcon: Icon(Icons.access_time)),
                      child: Text(DateFormat.Hms().format(_selectedDateTime)),
                    ),
                  ),
                ),
              ],
            ),
            TextField(
              controller: _durationController,
              decoration: const InputDecoration(labelText: 'Duration (minutes)', border: OutlineInputBorder()),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
              ],
            ),
            TextField(
              controller: _tagsController,
              decoration: const InputDecoration(labelText: 'Tags', border: OutlineInputBorder(), helperText: 'Comma-separated'),
              maxLines: 2,
            ),
            TextField(
              controller: _divemasterController,
              decoration: const InputDecoration(labelText: 'Divemaster', border: OutlineInputBorder()),
            ),
            TextField(
              controller: _buddiesController,
              decoration: const InputDecoration(labelText: 'Buddies', border: OutlineInputBorder(), helperText: 'Comma-separated'),
              maxLines: 2,
            ),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notes', border: OutlineInputBorder()),
              maxLines: 6,
            ),
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
