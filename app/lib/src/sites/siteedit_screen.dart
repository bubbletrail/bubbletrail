import 'package:chips_input_autocomplete/chips_input_autocomplete.dart';
import 'package:divestore/divestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/divelist_bloc.dart';
import '../bloc/sitedetails_bloc.dart';
import '../common/common.dart';

class SiteEditScreen extends StatefulWidget {
  const SiteEditScreen({super.key});

  @override
  State<SiteEditScreen> createState() => _SiteEditScreenState();
}

class _SiteEditScreenState extends State<SiteEditScreen> {
  late final Site _originalSite;
  late final bool _isNew;
  late final TextEditingController _nameController;
  late final TextEditingController _countryController;
  late final TextEditingController _locationController;
  late final TextEditingController _bodyOfWaterController;
  late final TextEditingController _difficultyController;
  late final TextEditingController _latController;
  late final TextEditingController _lonController;
  late final ChipsAutocompleteController _tagsController;

  @override
  void initState() {
    super.initState();
    final state = context.read<SiteDetailsBloc>().state as SiteDetailsLoaded;
    _originalSite = state.site;
    _isNew = state.isNew;
    _nameController = TextEditingController(text: _originalSite.name);
    _countryController = TextEditingController(text: _originalSite.country);
    _locationController = TextEditingController(text: _originalSite.location);
    _bodyOfWaterController = TextEditingController(text: _originalSite.bodyOfWater);
    _difficultyController = TextEditingController(text: _originalSite.difficulty);
    _latController = TextEditingController(text: _originalSite.hasPosition() ? _originalSite.position.latitude.toString() : '');
    _lonController = TextEditingController(text: _originalSite.hasPosition() ? _originalSite.position.longitude.toString() : '');
    _tagsController = ChipsAutocompleteController();
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
    // _tagsController.dispose();
    super.dispose();
  }

  void _saveSite() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Name is required')));
      return;
    }

    try {
      // Parse GPS position if provided
      Position? position;
      final latText = _latController.text.trim();
      final lonText = _lonController.text.trim();
      if (latText.isNotEmpty && lonText.isNotEmpty) {
        final lat = double.tryParse(latText);
        final lon = double.tryParse(lonText);
        if (lat != null && lon != null) {
          position = Position(latitude: lat, longitude: lon);
        }
      }

      final updatedSite = Site(
        id: _originalSite.id,
        name: name,
        position: position,
        country: _countryController.text.trim(),
        location: _locationController.text.trim(),
        bodyOfWater: _bodyOfWaterController.text.trim(),
        difficulty: _difficultyController.text.trim(),
        tags: _tagsController.chips,
      );

      // Send update event to bloc
      context.read<SiteDetailsBloc>().add(UpdateSiteDetails(updatedSite));

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
      title: Text(_isNew ? 'New Dive Site' : 'Edit ${_originalSite.name}'),
      actions: [IconButton(icon: const Icon(Icons.save), onPressed: _saveSite, tooltip: 'Save')],
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
            Builder(
              builder: (context) {
                final diveListState = context.watch<DiveListBloc>().state;
                final suggestions = diveListState is DiveListLoaded ? diveListState.tags.toList() : <String>[];
                suggestions.sort();
                return ChipsInputAutocomplete(
                  controller: _tagsController,
                  options: suggestions,
                  initialChips: _originalSite.tags.toList(),
                  decorationTextField: const InputDecoration(labelText: 'Tags', border: OutlineInputBorder()),
                  addChipOnSelection: true,
                  placeChipsSectionAbove: false,
                  paddingInsideWidgetContainer: EdgeInsets.zero,
                  secondaryTheme: true,
                );
              },
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
                onPressed: _saveSite,
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
