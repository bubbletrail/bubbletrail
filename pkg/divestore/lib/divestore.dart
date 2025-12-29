import 'package:divestore/gen/gen.dart';

export '../gen/gen.dart';
export 'store/store.dart';
export 'xml.dart';

class Ssrf {
  final List<Dive> dives;
  final List<Site> sites;
  Ssrf({List<Dive>? dives, List<Site>? sites}) : dives = dives ?? [], sites = sites ?? [];
}

/// Converts a Log from a dive computer into a Dive.
///
/// Maps available fields from the dive computer data to the Dive structure:
/// - Copies dive number, start time, duration, depths
/// - Converts tank information to cylinders with gas mix data
/// - Extracts events from samples
/// - Stores the original Log in logs
Dive convertDcDive(Log dl) {
  final dive = Dive()..logs.add(dl);

  if (dl.hasNumber()) {
    dive.number = dl.number;
  }
  if (dl.hasDateTime()) {
    dive.start = dl.dateTime;
  }

  if (dl.hasDiveTime()) {
    dive.duration = dl.diveTime;
  }
  if (dl.hasMaxDepth()) {
    dive.maxDepth = dl.maxDepth;
  }
  if (dl.hasAvgDepth()) {
    dive.meanDepth = dl.avgDepth;
  }

  // Convert tanks to cylinders
  for (var i = 0; i < dl.tanks.length; i++) {
    final tank = dl.tanks[i];
    final diveCylinder = DiveCylinder();

    // Set pressures
    if (tank.hasBeginPressure()) {
      diveCylinder.beginPressure = tank.beginPressure;
    }
    if (tank.hasEndPressure()) {
      diveCylinder.endPressure = tank.endPressure;
    }

    // Get gas mix info if available
    if (tank.hasGasMixIndex() && tank.gasMixIndex < dl.gasMixes.length) {
      final gasMix = dl.gasMixes[tank.gasMixIndex];
      if (gasMix.hasOxygen()) {
        diveCylinder.oxygen = gasMix.oxygen;
      }
      if (gasMix.hasHelium()) {
        diveCylinder.helium = gasMix.helium;
      }
    }

    dive.cylinders.add(diveCylinder);
  }

  // Extract events from samples
  for (final sample in dl.samples) {
    for (final event in sample.events) {
      dive.events.add(event);
    }
  }

  return dive;
}
