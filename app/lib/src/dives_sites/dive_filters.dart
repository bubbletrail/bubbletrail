import 'package:btcountries/btcountries.dart';
import 'package:btproto/btproto.dart';

// A dive matches unless a set filter value excludes it. Country and tag
// filters resolve through the dive's site (via [sitesByUuid]), so a dive
// with no site never matches a country or tag filter.
List<Dive> filterDives(List<Dive> dives, Map<String, Site> sitesByUuid, {int? year, String? country, String? tag}) {
  return dives.where((dive) {
    if (year != null && dive.start.toDateTime().year != year) return false;
    final site = dive.siteId.isEmpty ? null : sitesByUuid[dive.siteId];
    if (country != null && site?.country != country) return false;
    if (tag != null && !dive.tags.contains(tag) && !(site?.tags.contains(tag) ?? false)) return false;
    return true;
  }).toList();
}

List<int> availableDiveYears(List<Dive> dives) => dives.map((d) => d.start.toDateTime().year).toSet().toList()..sort((a, b) => b.compareTo(a));

List<String> availableDiveCountries(List<Dive> dives, Map<String, Site> sitesByUuid) {
  final countries = dives.map((d) => d.siteId.isEmpty ? null : sitesByUuid[d.siteId]?.country).whereType<String>().where((c) => c.isNotEmpty).toSet().toList();
  countries.sort((a, b) => countryDisplayName(a).compareTo(countryDisplayName(b)));
  return countries;
}

Set<String> availableDiveTags(List<Dive> dives, Map<String, Site> sitesByUuid) {
  final tags = <String>{};
  for (final dive in dives) {
    tags.addAll(dive.tags);
    final site = dive.siteId.isEmpty ? null : sitesByUuid[dive.siteId];
    if (site != null) tags.addAll(site.tags);
  }
  return tags;
}
