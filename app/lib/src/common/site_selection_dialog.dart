import 'package:btcountries/btcountries.dart';
import 'package:btproto/btproto.dart';
import 'package:flutter/material.dart';

import '../dives_sites/site_grouping.dart';
import 'dialogs.dart';

// Shows a hierarchical dialog for selecting a dive site.
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

class _HierarchicalSiteSelectionDialog extends StatelessWidget {
  final List<Site> sites;
  final Site? selectedSite;
  final String? noneOption;
  final Object cancelledSentinel;
  final SiteHierarchy _hierarchy;

  _HierarchicalSiteSelectionDialog({required this.sites, required this.selectedSite, required this.noneOption, required this.cancelledSentinel})
    : _hierarchy = SiteHierarchy(sites);

  @override
  Widget build(BuildContext context) {
    final countries = _hierarchy.countries;
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Select dive site'),
      content: SizedBox(
        width: .maxFinite,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ListView(
            shrinkWrap: true,
            children: [
              if (noneOption != null)
                ListTile(
                  leading: const Icon(Icons.close),
                  title: Text(noneOption!),
                  selected: selectedSite == null,
                  onTap: () => Navigator.of(context).pop(null),
                ),
              ...countries.map((country) => _buildCountryTile(context, country, theme)),
            ],
          ),
        ),
      ),
      actions: [TextButton(onPressed: () => Navigator.of(context).pop(cancelledSentinel), child: const Text('Cancel'))],
    );
  }

  Widget _buildCountryTile(BuildContext context, String country, ThemeData theme) {
    final locations = _hierarchy.locationsFor(country);
    final displayName = SiteHierarchy.countryDisplayNameFor(country);

    return ExpansionTile(
      leading: CountryFlag(code: country),
      title: Text(displayName),
      initiallyExpanded: selectedSite?.country == country,
      children: locations
          .map((location) => Padding(padding: const EdgeInsets.only(left: 16.0), child: _buildLocationTile(context, country, location, theme)))
          .toList(),
    );
  }

  Widget _buildLocationTile(BuildContext context, String country, String location, ThemeData theme) {
    final sites = _hierarchy.sitesFor(country, location);
    final displayName = SiteHierarchy.locationDisplayNameFor(location);

    return ExpansionTile(
      leading: Icon(Icons.map_outlined),
      title: Text(displayName),
      initiallyExpanded: selectedSite?.country == country && selectedSite?.location == location,
      children: sites.map((site) => Padding(padding: const EdgeInsets.only(left: 16.0), child: _buildSiteTile(context, site, theme))).toList(),
    );
  }

  Widget _buildSiteTile(BuildContext context, Site site, ThemeData theme) {
    return ListTile(
      leading: Icon(Icons.location_on_outlined),
      title: Text(site.name),
      selected: selectedSite?.id == site.id,
      onTap: () => Navigator.of(context).pop(site),
    );
  }
}
