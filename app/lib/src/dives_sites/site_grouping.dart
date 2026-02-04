import 'package:btproto/btproto.dart';
import 'package:collection/collection.dart';

import '../common/countries.dart';

class SiteHierarchy {
  // Keyed by raw country value (code or legacy freetext)
  final Map<String, Map<String, List<Site>>> hierarchy;

  SiteHierarchy(List<Site> sites) : hierarchy = _buildHierarchy(sites);

  static Map<String, Map<String, List<Site>>> _buildHierarchy(List<Site> sites) {
    final byCountry = sites.groupListsBy((s) => s.country.isEmpty ? '' : s.country);
    return byCountry.map((country, countrySites) {
      final byLocation = countrySites.groupListsBy((s) => s.location.isEmpty ? '' : s.location);
      // Sort sites within each location by name
      for (final sites in byLocation.values) {
        sites.sort((a, b) => a.name.compareTo(b.name));
      }
      return MapEntry(country, byLocation);
    });
  }

  // Returns raw country keys, sorted by display name
  List<String> get countries {
    final keys = hierarchy.keys.toList();
    keys.sort((a, b) => _displayName(a).compareTo(_displayName(b)));
    return keys;
  }

  // Returns raw location keys, sorted
  List<String> locationsFor(String country) {
    final keys = hierarchy[country]?.keys.toList() ?? [];
    keys.sort((a, b) => _locationDisplayName(a).compareTo(_locationDisplayName(b)));
    return keys;
  }

  List<Site> sitesFor(String country, String location) => hierarchy[country]?[location] ?? [];

  // Find which country/location a site belongs to (returns raw keys)
  (String country, String location)? findSite(Site site) {
    for (final country in hierarchy.keys) {
      for (final location in hierarchy[country]!.keys) {
        if (hierarchy[country]![location]!.any((s) => s.id == site.id)) {
          return (country, location);
        }
      }
    }
    return null;
  }

  // Get display name for a country key
  static String countryDisplayNameFor(String key) => _displayName(key);

  // Get display name for a location key
  static String locationDisplayNameFor(String key) => _locationDisplayName(key);

  // Get flag asset path for a country key (null if no flag available)
  static String? countryFlagAssetFor(String key) {
    if (key.isEmpty) return null;
    // Try as code first
    final asset = countryFlagAsset(key);
    if (asset != null) return asset;
    // Try to match freetext to code
    final code = matchCountryCode(key);
    if (code != null) return countryFlagAsset(code);
    return null;
  }

  static String _displayName(String key) {
    if (key.isEmpty) return 'Unknown country';
    return countryDisplayName(key);
  }

  static String _locationDisplayName(String key) {
    if (key.isEmpty) return 'Unknown location';
    return key;
  }
}
