import 'dart:convert';

import 'package:crypto/crypto.dart';

import 'gen/gen.dart';
import 'recalculate.dart';

export 'gen/gen.dart';
export 'recalculate.dart';
export 'store/store.dart';
export 'uddf.dart';
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

  // Calculate a unique yet repeatable dive ID, if we have all the
  // information required. Any given dive computer identified by model &
  // serial should only have one dive starting at a given point in time.
  if (dl.hasModel() && dl.hasSerial() && dl.hasDateTime()) {
    final unique = 'DC${dl.model}/${dl.serial}@${dl.dateTime.seconds}';
    final hash = sha256.convert(utf8.encode(unique));
    dive.id = hash.toString().substring(0, 32).toLowerCase();
  }

  if (dl.hasNumber()) {
    dive.number = dl.number;
  }
  if (dl.hasDateTime()) {
    dive.start = dl.dateTime;
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
    if (tank.gasMixIndex < dl.gasMixes.length) {
      final gasMix = dl.gasMixes[tank.gasMixIndex];
      diveCylinder.oxygen = gasMix.oxygen;
      diveCylinder.helium = gasMix.helium;
    }

    dive.cylinders.add(diveCylinder);
  }

  // Collect events
  for (final sample in dl.samples) {
    for (final event in sample.events) {
      dive.events.add(event);
    }
  }

  dive.recalculateMedata();

  return dive;
}
