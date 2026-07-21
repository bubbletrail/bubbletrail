import 'package:btcountries/btcountries.dart';
import 'package:flutter/material.dart';

import '../common/common.dart';

// The scalar text facts about a dive site, edited together in one sheet.
class SiteDetails {
  final String name;
  final String country;
  final String location;
  final String bodyOfWater;
  final String difficulty;

  const SiteDetails({required this.name, required this.country, required this.location, required this.bodyOfWater, required this.difficulty});
}

// Shows an editor for a site's descriptive fields: name (required), country,
// location, body of water and difficulty. On mobile this is a bottom sheet, on
// desktop a modal dialog. Returns the edited values, or null if cancelled.
Future<SiteDetails?> showSiteDetailsEditor({required BuildContext context, required SiteDetails initial}) {
  return showAdaptiveModal<SiteDetails>(
    context: context,
    builder: (context) => _SiteDetailsEditor(initial: initial),
  );
}

class _SiteDetailsEditor extends StatefulWidget {
  final SiteDetails initial;

  const _SiteDetailsEditor({required this.initial});

  @override
  State<_SiteDetailsEditor> createState() => _SiteDetailsEditorState();
}

class _SiteDetailsEditorState extends State<_SiteDetailsEditor> {
  late final TextEditingController _nameController;
  late final TextEditingController _locationController;
  late final TextEditingController _bodyOfWaterController;
  late final TextEditingController _difficultyController;
  late String _countryCode;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initial.name);
    _locationController = TextEditingController(text: widget.initial.location);
    _bodyOfWaterController = TextEditingController(text: widget.initial.bodyOfWater);
    _difficultyController = TextEditingController(text: widget.initial.difficulty);
    _countryCode = widget.initial.country;
    // Rebuild so the Done button enables/disables as the name is filled in.
    _nameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _bodyOfWaterController.dispose();
    _difficultyController.dispose();
    super.dispose();
  }

  Future<void> _selectCountry() async {
    final result = await showCountryPickerDialog(context: context, selectedCode: _countryCode, noneOption: 'No country');
    if (result != null) setState(() => _countryCode = result);
  }

  void _done() {
    Navigator.of(context).pop(
      SiteDetails(
        name: _nameController.text.trim(),
        country: _countryCode,
        location: _locationController.text.trim(),
        bodyOfWater: _bodyOfWaterController.text.trim(),
        difficulty: _difficultyController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canSave = _nameController.text.trim().isNotEmpty;
    return SafeArea(
      child: Padding(
        padding: const .all(16.0),
        child: Column(
          mainAxisSize: .min,
          crossAxisAlignment: .stretch,
          spacing: 16,
          children: [
            Text('Site details', style: Theme.of(context).textTheme.titleMedium),
            TextField(
              controller: _nameController,
              autofocus: widget.initial.name.isEmpty,
              decoration: const InputDecoration(labelText: 'Name *', border: OutlineInputBorder()),
              textCapitalization: .words,
            ),
            Row(
              spacing: 16,
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _selectCountry,
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'Country', border: OutlineInputBorder()),
                      child: Row(
                        spacing: 8,
                        children: [
                          CountryFlag(code: _countryCode),
                          Expanded(
                            child: Text(
                              _countryCode.isEmpty ? 'Select country' : countryDisplayName(_countryCode),
                              style: _countryCode.isEmpty ? TextStyle(color: Theme.of(context).hintColor) : null,
                              overflow: .ellipsis,
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _locationController,
                    decoration: const InputDecoration(labelText: 'Location', border: OutlineInputBorder()),
                    textCapitalization: .words,
                  ),
                ),
              ],
            ),
            Row(
              spacing: 16,
              children: [
                Expanded(
                  child: TextField(
                    controller: _bodyOfWaterController,
                    decoration: const InputDecoration(labelText: 'Body of water', border: OutlineInputBorder()),
                    textCapitalization: .words,
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _difficultyController,
                    decoration: const InputDecoration(labelText: 'Difficulty', border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: .end,
              spacing: 8,
              children: [
                TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                FilledButton(onPressed: canSave ? _done : null, child: const Text('Done')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
