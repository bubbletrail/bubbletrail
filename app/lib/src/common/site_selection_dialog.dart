import 'package:btcountries/btcountries.dart';
import 'package:btl10n/btl10n.dart';
import 'package:btproto/btproto.dart';
import 'package:material_ui/material_ui.dart';

import 'common.dart';

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

    return AlertDialog(
      title: Text(context.l10n.selectDiveSite),
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
              ...countries.map((country) => _buildCountryTile(context, country)),
            ],
          ),
        ),
      ),
      actions: [TextButton(onPressed: () => Navigator.of(context).pop(SelectionResult<Site>.cancelled()), child: Text(context.l10n.cancel))],
    );
  }

  Widget _buildCountryTile(BuildContext context, String country) {
    final locations = _hierarchy.locationsFor(country);
    final displayName = country.isEmpty ? context.l10n.unknown : countryDisplayName(country, l10n: context.l10n);

    return ExpansionTile(
      leading: CountryFlag(code: country),
      title: Text(displayName),
      initiallyExpanded: selectedSite?.country == country,
      children: locations
          .map((location) => Padding(padding: const EdgeInsets.only(left: 16.0), child: _buildLocationTile(context, country, location)))
          .toList(),
    );
  }

  Widget _buildLocationTile(BuildContext context, String country, String location) {
    final sites = _hierarchy.sitesFor(country, location);

    return ExpansionTile(
      leading: const Icon(Icons.map_outlined),
      title: Text(location.isEmpty ? context.l10n.noLocation : location),
      initiallyExpanded: selectedSite?.country == country && selectedSite?.location == location,
      children: sites.map((site) => Padding(padding: const EdgeInsets.only(left: 16.0), child: _buildSiteTile(context, site))).toList(),
    );
  }

  Widget _buildSiteTile(BuildContext context, Site site) {
    return ListTile(
      leading: const Icon(Icons.location_on_outlined),
      title: Text(site.name),
      selected: selectedSite?.id == site.id,
      onTap: () => Navigator.of(context).pop(SelectionResult.selected(site)),
    );
  }
}
