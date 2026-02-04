import 'package:btproto/btproto.dart';
import 'package:flutter/material.dart';

import '../dives_sites/site_grouping.dart';
import 'country_picker.dart';
import 'dialogs.dart';

/// Shows a hierarchical dialog for selecting a dive site.
///
/// Sites are grouped by country, then by location. The dialog auto-expands
/// to show the currently selected site if one is provided.
Future<SelectionResult<Site>> showHierarchicalSiteSelectionDialog({
  required BuildContext context,
  required List<Site> sites,
  Site? selectedSite,
  String? noneOption,
}) async {
  const cancelledSentinel = Object();

  final result = await showDialog<Object?>(
    context: context,
    builder: (dialogContext) =>
        _HierarchicalSiteSelectionDialog(sites: sites, selectedSite: selectedSite, noneOption: noneOption, cancelledSentinel: cancelledSentinel),
  );

  if (identical(result, cancelledSentinel)) {
    return const SelectionResult.cancelled();
  }
  return .selected(result as Site?);
}

class _HierarchicalSiteSelectionDialog extends StatefulWidget {
  final List<Site> sites;
  final Site? selectedSite;
  final String? noneOption;
  final Object cancelledSentinel;

  const _HierarchicalSiteSelectionDialog({required this.sites, required this.selectedSite, required this.noneOption, required this.cancelledSentinel});

  @override
  State<_HierarchicalSiteSelectionDialog> createState() => _HierarchicalSiteSelectionDialogState();
}

class _HierarchicalSiteSelectionDialogState extends State<_HierarchicalSiteSelectionDialog> {
  late final SiteHierarchy _hierarchy;
  late final Set<String> _expandedCountries;
  late final Set<(String, String)> _expandedLocations;

  @override
  void initState() {
    super.initState();
    _hierarchy = SiteHierarchy(widget.sites);
    _expandedCountries = {};
    _expandedLocations = {};

    // Auto-expand to show currently selected site
    if (widget.selectedSite != null) {
      final found = _hierarchy.findSite(widget.selectedSite!);
      if (found != null) {
        _expandedCountries.add(found.$1);
        _expandedLocations.add(found);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final countries = _hierarchy.countries;
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Select dive site'),
      content: SizedBox(
        width: .maxFinite,
        child: ListView(
          shrinkWrap: true,
          children: [
            if (widget.noneOption != null)
              ListTile(
                leading: const Icon(Icons.close),
                title: Text(widget.noneOption!),
                selected: widget.selectedSite == null,
                onTap: () => Navigator.of(context).pop(null),
              ),
            ...countries.map((country) => _buildCountryTile(country, theme)),
          ],
        ),
      ),
      actions: [TextButton(onPressed: () => Navigator.of(context).pop(widget.cancelledSentinel), child: const Text('Cancel'))],
    );
  }

  Widget _buildCountryTile(String country, ThemeData theme) {
    final isExpanded = _expandedCountries.contains(country);
    final locations = _hierarchy.locationsFor(country);
    final displayName = SiteHierarchy.countryDisplayNameFor(country);
    final flagAsset = SiteHierarchy.countryFlagAssetFor(country);

    return Column(
      crossAxisAlignment: .start,
      children: [
        ListTile(
          leading: flagAsset != null
              ? Row(
                  mainAxisSize: .min,
                  children: [
                    Icon(isExpanded ? Icons.expand_less : Icons.expand_more, size: 20),
                    const SizedBox(width: 4),
                    CountryFlag(code: country, size: 24),
                  ],
                )
              : Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
          title: Text(displayName, style: const TextStyle(fontWeight: .bold)),
          onTap: () {
            setState(() {
              if (isExpanded) {
                _expandedCountries.remove(country);
              } else {
                _expandedCountries.add(country);
              }
            });
          },
        ),
        if (isExpanded)
          Padding(
            padding: const .only(left: 16),
            child: Column(children: locations.map((location) => _buildLocationTile(country, location, theme)).toList()),
          ),
      ],
    );
  }

  Widget _buildLocationTile(String country, String location, ThemeData theme) {
    final key = (country, location);
    final isExpanded = _expandedLocations.contains(key);
    final sites = _hierarchy.sitesFor(country, location);
    final displayName = SiteHierarchy.locationDisplayNameFor(location);

    return Column(
      crossAxisAlignment: .start,
      children: [
        ListTile(
          leading: Icon(isExpanded ? Icons.expand_less : Icons.expand_more, size: 20),
          title: Text(displayName, style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
          dense: true,
          onTap: () {
            setState(() {
              if (isExpanded) {
                _expandedLocations.remove(key);
              } else {
                _expandedLocations.add(key);
              }
            });
          },
        ),
        if (isExpanded)
          Padding(
            padding: const .only(left: 16),
            child: Column(children: sites.map((site) => _buildSiteTile(site, theme)).toList()),
          ),
      ],
    );
  }

  Widget _buildSiteTile(Site site, ThemeData theme) {
    final isSelected = widget.selectedSite?.id == site.id;

    return ListTile(
      leading: Icon(Icons.location_on_outlined, size: 20, color: isSelected ? theme.colorScheme.primary : null),
      title: Text(site.name),
      selected: isSelected,
      dense: true,
      onTap: () => Navigator.of(context).pop(site),
    );
  }
}
