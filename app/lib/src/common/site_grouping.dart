import 'package:btcountries/btcountries.dart';
import 'package:btproto/btproto.dart';
import 'package:collection/collection.dart';

class SiteHierarchy {
  final Map<String, Map<String, List<Site>>> hierarchy;

  SiteHierarchy(List<Site> sites) : hierarchy = _buildHierarchy(sites);

  static Map<String, Map<String, List<Site>>> _buildHierarchy(List<Site> sites) {
    final byCountry = sites.groupListsBy((s) => matchCountryCode(s.country) ?? 'Unknown');
    return byCountry.map((country, countrySites) {
      final byLocation = countrySites.groupListsBy((s) => s.location.isEmpty ? '' : s.location);
      for (final sites in byLocation.values) {
        sites.sort((a, b) => a.name.compareTo(b.name));
      }
      return MapEntry(country, byLocation);
    });
  }

  List<String> get countries {
    final keys = hierarchy.keys.toList();
    keys.sort((a, b) => countryDisplayName(a).compareTo(countryDisplayName(b)));
    return keys;
  }

  List<String> locationsFor(String country) {
    final keys = hierarchy[country]?.keys.toList() ?? [];
    keys.sort((a, b) => a.compareTo(b));
    return keys;
  }

  List<Site> sitesFor(String country, String location) => hierarchy[country]?[location] ?? [];
}
