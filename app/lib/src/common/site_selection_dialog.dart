import 'package:btcountries/btcountries.dart';
import 'package:btproto/btproto.dart';
import 'package:flutter/material.dart';

import 'dialogs.dart';
import 'site_grouping.dart';

// Shows a hierarchical dialog for selecting a dive site.
Future<SelectionResult<Site>> showSiteSelectionDialog({
  required BuildContext context,
  required List<Site> sites,
  Site? selectedSite,
  String? noneOption,
}) async {
  final res = await showDialog<SelectionResult<Site>>(
    context: context,
    builder: (dialogContext) => _SiteSelectionDialog(sites: sites, selectedSite: selectedSite, noneOption: noneOption),
  );
  if (res == null) {
    return SelectionResult<Site>.cancelled();
  }
  return res;
}

class _SiteSelectionDialog extends StatelessWidget {
  final List<Site> sites;
  final Site? selectedSite;
  final String? noneOption;
  final SiteHierarchy _hierarchy;

  _SiteSelectionDialog({required this.sites, required this.selectedSite, required this.noneOption}) : _hierarchy = SiteHierarchy(sites);

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
                  onTap: () => Navigator.of(context).pop(SelectionResult<Site>.none()),
                ),
              ...countries.map((country) => _buildCountryTile(context, country, theme)),
            ],
          ),
        ),
      ),
      actions: [TextButton(onPressed: () => Navigator.of(context).pop(SelectionResult<Site>.cancelled()), child: const Text('Cancel'))],
    );
  }

  Widget _buildCountryTile(BuildContext context, String country, ThemeData theme) {
    final locations = _hierarchy.locationsFor(country);
    final displayName = countryDisplayName(country);

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

    return ExpansionTile(
      leading: Icon(Icons.map_outlined),
      title: Text(location),
      initiallyExpanded: selectedSite?.country == country && selectedSite?.location == location,
      children: sites.map((site) => Padding(padding: const EdgeInsets.only(left: 16.0), child: _buildSiteTile(context, site, theme))).toList(),
    );
  }

  Widget _buildSiteTile(BuildContext context, Site site, ThemeData theme) {
    return ListTile(
      leading: Icon(Icons.location_on_outlined),
      title: Text(site.name),
      selected: selectedSite?.id == site.id,
      onTap: () => Navigator.of(context).pop(SelectionResult.selected(site)),
    );
  }
}
