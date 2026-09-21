import 'package:btcountries/btcountries.dart';
import 'package:flutter/material.dart';

// Three single-select dropdowns (year, country, tag) shown above the mobile
// dive list. Each starts with a null-valued "All" entry to clear that filter.
class MobileDiveFilterBar extends StatelessWidget {
  final int? selectedYear;
  final String? selectedCountry;
  final String? selectedTag;
  final List<int> years;
  final List<String> countries;
  final List<String> tags;
  final ValueChanged<int?> onYearChanged;
  final ValueChanged<String?> onCountryChanged;
  final ValueChanged<String?> onTagChanged;

  const MobileDiveFilterBar({
    super.key,
    required this.selectedYear,
    required this.selectedCountry,
    required this.selectedTag,
    required this.years,
    required this.countries,
    required this.tags,
    required this.onYearChanged,
    required this.onCountryChanged,
    required this.onTagChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .symmetric(horizontal: 8.0, vertical: 8.0),
      child: Row(
        spacing: 8,
        children: [
          Expanded(
            child: _dropdown<int>(
              value: selectedYear,
              label: 'Year',
              allLabel: 'All years',
              items: years.map((y) => DropdownMenuItem(value: y, child: Text('$y'))).toList(),
              onChanged: onYearChanged,
            ),
          ),
          Expanded(
            child: _dropdown<String>(
              value: selectedCountry,
              label: 'Country',
              allLabel: 'All countries',
              items: countries
                  .map(
                    (c) => DropdownMenuItem(
                      value: c,
                      child: Text(countryDisplayName(c), overflow: .ellipsis),
                    ),
                  )
                  .toList(),
              onChanged: onCountryChanged,
            ),
          ),
          Expanded(
            child: _dropdown<String>(
              value: selectedTag,
              label: 'Tag',
              allLabel: 'All tags',
              items: tags
                  .map(
                    (t) => DropdownMenuItem(
                      value: t,
                      child: Text(t, overflow: .ellipsis),
                    ),
                  )
                  .toList(),
              onChanged: onTagChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _dropdown<T>({
    required T? value,
    required String label,
    required String allLabel,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder(), contentPadding: const .symmetric(horizontal: 12, vertical: 12)),
      items: [
        DropdownMenuItem<T>(value: null, child: Text(allLabel)),
        ...items,
      ],
      onChanged: onChanged,
    );
  }
}
