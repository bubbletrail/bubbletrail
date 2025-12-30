import 'dart:math';

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

  // Process samples, calculating depths, durations, etc.

  double maxDepth = 0.0;
  double totDepth = 0.0;
  double prevDepth = 0.0;
  double prevTime = 0.0;
  double duration = 0;

  for (final sample in dl.samples) {
    maxDepth = max(maxDepth, sample.depth);
    totDepth += (sample.depth + prevDepth) / 2 * (sample.time - prevTime);
    if (sample.depth > 0) {
      duration = sample.time;
    }
    for (final event in sample.events) {
      dive.events.add(event);
    }
  }

  dive.duration = duration.round();
  dive.maxDepth = maxDepth;
  dive.meanDepth = totDepth / duration;

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

  return dive;
}
