import 'package:btl10n/btl10n.dart';
import 'package:flutter/material.dart';

import 'countries.dart';
import 'country_flag.dart';

// Shows a searchable dialog for selecting a country.
Future<String?> showCountryPickerDialog({required BuildContext context, String? selectedCode, String? noneOption}) {
  return showDialog<String?>(
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
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.toLowerCase();
    final filteredCountries =
        countries
            .where((country) => localizedCountryName(context.l10n, country.code).toLowerCase().contains(query) || country.code.toLowerCase().contains(query))
            .toList()
          ..sort((a, b) => localizedCountryName(context.l10n, a.code).compareTo(localizedCountryName(context.l10n, b.code)));
    return AlertDialog(
      title: Text(context.l10n.selectCountry),
      content: SizedBox(
        width: .maxFinite,
        height: 400,
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(hintText: context.l10n.searchCountries, prefixIcon: Icon(Icons.search), border: OutlineInputBorder()),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: filteredCountries.length + (widget.noneOption != null ? 1 : 0),
                itemBuilder: (context, index) {
                  if (widget.noneOption != null && index == 0) {
                    return ListTile(
                      leading: const Icon(Icons.close),
                      title: Text(widget.noneOption!),
                      selected: widget.selectedCode == null,
                      onTap: () => Navigator.of(context).pop(''),
                    );
                  }
                  final country = filteredCountries[widget.noneOption != null ? index - 1 : index];
                  final isSelected = widget.selectedCode?.toUpperCase() == country.code;
                  return ListTile(
                    leading: CountryFlag(code: country.code, size: 24),
                    title: Text(localizedCountryName(context.l10n, country.code)),
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
      actions: [TextButton(onPressed: () => Navigator.of(context).pop(null), child: Text(context.l10n.cancel))],
    );
  }
}
