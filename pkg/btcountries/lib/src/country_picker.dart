import 'package:flutter/material.dart';

import 'countries.dart';
import 'country_flag.dart';

// Shows a searchable dialog for selecting a country.
Future<String?> showCountryPickerDialog({required BuildContext context, String? selectedCode, String? noneOption}) async {
  return await showDialog<String?>(
    context: context,
    builder: (dialogContext) => _CountryPickerDialog(selectedCode: selectedCode, noneOption: noneOption),
  );
}

class _CountryPickerDialog extends StatefulWidget {
  final String? selectedCode;
  final String? noneOption;

  const _CountryPickerDialog({required this.selectedCode, required this.noneOption});

  @override
  State<_CountryPickerDialog> createState() => _CountryPickerDialogState();
}

class _CountryPickerDialogState extends State<_CountryPickerDialog> {
  final _searchController = TextEditingController();
  List<Country> _filteredCountries = countries;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredCountries = countries;
      } else {
        _filteredCountries = countries.where((c) => c.name.toLowerCase().contains(query) || c.code.toLowerCase().contains(query)).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select country'),
      content: SizedBox(
        width: .maxFinite,
        height: 400,
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(hintText: 'Search...', prefixIcon: Icon(Icons.search), border: OutlineInputBorder()),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredCountries.length + (widget.noneOption != null ? 1 : 0),
                itemBuilder: (context, index) {
                  if (widget.noneOption != null && index == 0) {
                    return ListTile(
                      leading: const Icon(Icons.close),
                      title: Text(widget.noneOption!),
                      selected: widget.selectedCode == null,
                      onTap: () => Navigator.of(context).pop(null),
                    );
                  }
                  final country = _filteredCountries[widget.noneOption != null ? index - 1 : index];
                  final isSelected = widget.selectedCode?.toUpperCase() == country.code;
                  return ListTile(
                    leading: CountryFlag(code: country.code, size: 24),
                    title: Text(country.name),
                    trailing: Text(country.code, style: TextStyle(color: Theme.of(context).hintColor)),
                    selected: isSelected,
                    onTap: () => Navigator.of(context).pop(country.code),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [TextButton(onPressed: () => Navigator.of(context).pop(null), child: const Text('Cancel'))],
    );
  }
}
