import 'package:chips_input_autocomplete/chips_input_autocomplete.dart';
import 'package:divestore/divestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/divelist_bloc.dart';
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
    final state = context.read<DiveListBloc>().state as DiveListLoaded;
    _originalSite = state.selectedSite!;
    _isNew = state.isNewSite;
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

  bool _saveSite() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Name is required')));
      return false;
    }

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
    context.read<DiveListBloc>().add(UpdateSite(updatedSite));

    return true;
  }

  void _saveAndPop() {
    if (_saveSite()) {
      context.pop();
    }
  }

  void _cancel() {
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _saveAndPop();
        }
      },
      child: ScreenScaffold(
        title: Text(_isNew ? 'New Dive Site' : 'Edit ${_originalSite.name}'),
        actions: [IconButton(icon: const Icon(Icons.close), onPressed: _cancel, tooltip: 'Discard changes')],
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
            ],
          ),
        ),
      ),
    );
  }
}
