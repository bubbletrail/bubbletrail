import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/divelist_bloc.dart';
import '../bloc/divesitedetails_bloc.dart';
import '../common/common.dart';
import '../ssrf/ssrf.dart' as ssrf;

class DivesiteEditScreen extends StatefulWidget {
  const DivesiteEditScreen({super.key});

  @override
  State<DivesiteEditScreen> createState() => _DivesiteEditScreenState();
}

class _DivesiteEditScreenState extends State<DivesiteEditScreen> {
  late final ssrf.Divesite _originalDivesite;
  late final bool _isNew;
  late final TextEditingController _nameController;
  late final TextEditingController _countryController;
  late final TextEditingController _locationController;
  late final TextEditingController _bodyOfWaterController;
  late final TextEditingController _difficultyController;
  late final TextEditingController _latController;
  late final TextEditingController _lonController;

  @override
  void initState() {
    super.initState();
    final state = context.read<DivesiteDetailsBloc>().state as DivesiteDetailsLoaded;
    _originalDivesite = state.divesite;
    _isNew = state.isNew;
    _nameController = TextEditingController(text: _originalDivesite.name);
    _countryController = TextEditingController(text: _originalDivesite.country ?? '');
    _locationController = TextEditingController(text: _originalDivesite.location ?? '');
    _bodyOfWaterController = TextEditingController(text: _originalDivesite.bodyOfWater ?? '');
    _difficultyController = TextEditingController(text: _originalDivesite.difficulty ?? '');
    _latController = TextEditingController(text: _originalDivesite.position?.lat.toString() ?? '');
    _lonController = TextEditingController(text: _originalDivesite.position?.lon.toString() ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _countryController.dispose();
    _locationController.dispose();
    _bodyOfWaterController.dispose();
    _difficultyController.dispose();
    _latController.dispose();
    _lonController.dispose();
    super.dispose();
  }

  void _saveDivesite() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Name is required')));
      return;
    }

    try {
      // Parse GPS position if provided
      ssrf.GPSPosition? position;
      final latText = _latController.text.trim();
      final lonText = _lonController.text.trim();
      if (latText.isNotEmpty && lonText.isNotEmpty) {
        final lat = double.tryParse(latText);
        final lon = double.tryParse(lonText);
        if (lat != null && lon != null) {
          position = ssrf.GPSPosition(lat, lon);
        }
      }

      final updatedDivesite = ssrf.Divesite(
        uuid: _originalDivesite.uuid,
        name: name,
        position: position,
        country: _countryController.text.trim().isEmpty ? null : _countryController.text.trim(),
        location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
        bodyOfWater: _bodyOfWaterController.text.trim().isEmpty ? null : _bodyOfWaterController.text.trim(),
        difficulty: _difficultyController.text.trim().isEmpty ? null : _difficultyController.text.trim(),
      );

      // Send update event to bloc
      context.read<DivesiteDetailsBloc>().add(UpdateDivesiteDetails(updatedDivesite));

      // Reload dive list to reflect changes
      context.read<DiveListBloc>().add(const LoadDives());

      // Navigate back
      context.pop();

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_isNew ? 'Dive site created successfully' : 'Dive site updated successfully')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving dive site: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: Text(_isNew ? 'New Dive Site' : 'Edit ${_originalDivesite.name}'),
      actions: [IconButton(icon: const Icon(Icons.save), onPressed: _saveDivesite, tooltip: 'Save')],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name *', border: OutlineInputBorder()),
              textCapitalization: TextCapitalization.words,
            ),
            TextField(
              controller: _countryController,
              decoration: const InputDecoration(labelText: 'Country', border: OutlineInputBorder()),
              textCapitalization: TextCapitalization.words,
            ),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: 'Location', border: OutlineInputBorder()),
              textCapitalization: TextCapitalization.words,
            ),
            TextField(
              controller: _bodyOfWaterController,
              decoration: const InputDecoration(labelText: 'Body of Water', border: OutlineInputBorder()),
              textCapitalization: TextCapitalization.words,
            ),
            TextField(
              controller: _difficultyController,
              decoration: const InputDecoration(labelText: 'Difficulty', border: OutlineInputBorder()),
            ),
            Row(
              spacing: 16,
              children: [
                Expanded(
                  child: TextField(
                    controller: _latController,
                    decoration: const InputDecoration(labelText: 'Latitude', border: OutlineInputBorder()),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _lonController,
                    decoration: const InputDecoration(labelText: 'Longitude', border: OutlineInputBorder()),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                  ),
                ),
              ],
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveDivesite,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: Text(_isNew ? 'Create Dive Site' : 'Save Changes', style: const TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
