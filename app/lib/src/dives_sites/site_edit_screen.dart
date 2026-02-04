import 'package:chips_input_autocomplete/chips_input_autocomplete.dart';
import 'package:btproto/btproto.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../common/common.dart';
import 'dive_list_bloc.dart';
import 'site_details_bloc.dart';
import 'site_map.dart';

class SiteEditScreen extends StatefulWidget {
  const SiteEditScreen({super.key});

  @override
  State<SiteEditScreen> createState() => _SiteEditScreenState();
}

class _SiteEditScreenState extends State<SiteEditScreen> {
  late final Site _originalSite;
  late final bool _isNew;
  late final TextEditingController _nameController;
  late String _countryCode;
  late final TextEditingController _locationController;
  late final TextEditingController _bodyOfWaterController;
  late final TextEditingController _difficultyController;
  late final TextEditingController _latController;
  late final TextEditingController _lonController;
  late final TextEditingController _notesController;
  late final ChipsAutocompleteController _tagsController;
  LatLng? _markerPosition;

  @override
  void initState() {
    super.initState();
    final state = context.read<SiteDetailsBloc>().state as SiteDetailsLoaded;
    _originalSite = state.site;
    _isNew = _originalSite.id.isEmpty;
    _nameController = TextEditingController(text: _originalSite.name);
    _countryCode = normalizeCountry(_originalSite.country);
    _locationController = TextEditingController(text: _originalSite.location);
    _bodyOfWaterController = TextEditingController(text: _originalSite.bodyOfWater);
    _difficultyController = TextEditingController(text: _originalSite.difficulty);
    _latController = TextEditingController(text: _originalSite.hasPosition() ? _originalSite.position.latitude.toString() : '');
    _lonController = TextEditingController(text: _originalSite.hasPosition() ? _originalSite.position.longitude.toString() : '');
    _notesController = TextEditingController(text: _originalSite.notes);
    _tagsController = ChipsAutocompleteController();
    if (_originalSite.hasPosition()) {
      _markerPosition = LatLng(_originalSite.position.latitude, _originalSite.position.longitude);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _bodyOfWaterController.dispose();
    _difficultyController.dispose();
    _latController.dispose();
    _lonController.dispose();
    _notesController.dispose();
    // _tagsController.dispose();
    super.dispose();
  }

  void _saveSite() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Name is required')));
      return;
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
      country: _countryCode,
      location: _locationController.text.trim(),
      bodyOfWater: _bodyOfWaterController.text.trim(),
      difficulty: _difficultyController.text.trim(),
      tags: _tagsController.chips,
      notes: _notesController.text.trim(),
    );

    context.read<SiteDetailsBloc>().add(SiteDetailsEvent.saveAndClose(updatedSite));
  }

  void _cancel() {
    context.read<SiteDetailsBloc>().add(SiteDetailsEvent.close());
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    setState(() {
      _markerPosition = point;
      _latController.text = point.latitude.toStringAsFixed(6);
      _lonController.text = point.longitude.toStringAsFixed(6);
    });
  }

  Future<void> _selectCountry() async {
    final result = await showCountryPickerDialog(context: context, selectedCode: isCountryCode(_countryCode) ? _countryCode : null, noneOption: 'No country');

    if (!result.cancelled) {
      setState(() {
        _countryCode = result.value ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SiteDetailsBloc, SiteDetailsState>(
      listener: (context, state) {
        if (state is SiteDetailsClosed) {
          // Pop when the bloc considers us done
          context.pop();
        }
      },
      child: PopScope(
        canPop: false, // Block pop on left chevron
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            // Catch the attempt to pop and save
            _saveSite();
          }
        },
        child: ScreenScaffold(
          title: Text(_isNew ? 'New dive site' : 'Edit ${_originalSite.name}'),
          actions: [IconButton(icon: const Icon(Icons.close), onPressed: _cancel, tooltip: 'Discard changes')],
          body: SingleChildScrollView(
            padding: const .all(16.0),
            child: Column(
              crossAxisAlignment: .start,
              spacing: 16,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name *', border: OutlineInputBorder()),
                  textCapitalization: .words,
                ),
                InkWell(
                  onTap: _selectCountry,
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Country', border: OutlineInputBorder()),
                    child: Row(
                      children: [
                        if (_countryCode.isNotEmpty && isCountryCode(_countryCode)) ...[CountryFlag(code: _countryCode), const SizedBox(width: 12)],
                        Expanded(
                          child: Text(
                            _countryCode.isEmpty ? 'Select country' : countryDisplayName(_countryCode),
                            style: _countryCode.isEmpty ? TextStyle(color: Theme.of(context).hintColor) : null,
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),
                TextField(
                  controller: _locationController,
                  decoration: const InputDecoration(labelText: 'Location', border: OutlineInputBorder()),
                  textCapitalization: .words,
                ),
                TextField(
                  controller: _bodyOfWaterController,
                  decoration: const InputDecoration(labelText: 'Body of water', border: OutlineInputBorder()),
                  textCapitalization: .words,
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
                      paddingInsideWidgetContainer: .zero,
                      secondaryTheme: true,
                    );
                  },
                ),
                TextField(
                  controller: _notesController,
                  decoration: const InputDecoration(labelText: 'Notes', border: OutlineInputBorder(), alignLabelWithHint: true),
                  maxLines: 4,
                  textCapitalization: .sentences,
                ),
                Row(
                  spacing: 16,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _latController,
                        decoration: const InputDecoration(labelText: 'Latitude', border: OutlineInputBorder()),
                        keyboardType: const .numberWithOptions(decimal: true, signed: true),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _lonController,
                        decoration: const InputDecoration(labelText: 'Longitude', border: OutlineInputBorder()),
                        keyboardType: const .numberWithOptions(decimal: true, signed: true),
                      ),
                    ),
                  ],
                ),
                AspectRatio(
                  aspectRatio: 2,
                  child: ClipRRect(
                    borderRadius: .circular(12),
                    child: SiteMap(position: _markerPosition ?? LatLng(0, 0), onTap: _onMapTap, alwaysCenterPosition: false),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
