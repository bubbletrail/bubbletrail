import 'package:btproto/btproto.dart';
import 'package:lat_lng_to_timezone/lat_lng_to_timezone.dart' as tzmap;
// latest_all covers every IANA zone; the plain "latest" bundle omits many.
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

// Dive timestamps are stored in UTC but shown and edited in the dive site's
// local timezone. The zone is derived from the site position (offline, via a
// hardcoded lat/long polygon map) and the actual offset for a given instant
// comes from the IANA database (so daylight saving is handled correctly).

// Initialise the IANA timezone database. Must be called once at startup before
// any of the conversion helpers below.
void initialiseTimeZones() => tzdata.initializeTimeZones();

// The IANA timezone name for a site: the stored value if present, otherwise
// derived from its position. Returns an empty string when there is no site or
// it has no position (in which case timestamps are shown as UTC).
String siteTimeZone(Site? site) {
  if (site == null) return '';
  if (site.timezone.isNotEmpty) return site.timezone;
  return timeZoneForPosition(site.hasPosition() ? site.position : null);
}

// Derive an IANA timezone name from a position, or '' if there is none.
String timeZoneForPosition(Position? position) {
  if (position == null) return '';
  return tzmap.latLngToTimezoneString(position.latitude, position.longitude);
}

// Convert a UTC instant into [ianaName]. Returns null when the zone is
// empty/unknown, so callers can fall back to displaying the instant as-is
// (i.e. in UTC). The returned TZDateTime exposes the local wall clock via its
// field getters, plus the zone abbreviation (timeZoneName) and offset.
tz.TZDateTime? inZone(DateTime utc, String? ianaName) {
  if (ianaName == null || ianaName.isEmpty) return null;
  try {
    return tz.TZDateTime.from(utc, tz.getLocation(ianaName));
  } catch (_) {
    // Unknown zone name; fall back to as-is display.
    return null;
  }
}

// Interpret the wall-clock fields of [wall] as a local time in [ianaName] and
// return the corresponding UTC instant. When the zone is empty/unknown the
// wall clock is treated as UTC, matching how such times are displayed.
DateTime wallClockToUtc(DateTime wall, String? ianaName) {
  if (ianaName != null && ianaName.isNotEmpty) {
    try {
      final loc = tz.getLocation(ianaName);
      return tz.TZDateTime(loc, wall.year, wall.month, wall.day, wall.hour, wall.minute, wall.second).toUtc();
    } catch (_) {
      // Fall through to the UTC interpretation below.
    }
  }
  return DateTime.utc(wall.year, wall.month, wall.day, wall.hour, wall.minute, wall.second);
}
