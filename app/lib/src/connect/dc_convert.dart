import 'package:btproto/btproto.dart';

import '../services/store/store.dart';

// Converts a Log from a dive computer into a Dive.
//
// Maps available fields from the dive computer data to the Dive structure:
// - Copies dive number, start time, duration, depths
// - Converts tank information to cylinders with gas mix data
// - Extracts events from samples
// - Stores the original Log in logs
Dive convertDcDive(Log dl) {
  final dive = Dive()..logs.add(dl);

  if (dl.hasUniqueID()) {
    dive.id = dl.uniqueID;
  }

  if (dl.hasDateTime()) {
    dive.start = dl.dateTime;
  }

  final gasMixtoCylinderIdx = <int, int>{};

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
      gasMixtoCylinderIdx[tank.gasMixIndex] = i;
    }

    dive.cylinders.add(diveCylinder);
  }

  // Make sure every gas mix has a tank
  for (final (idx, gm) in dl.gasMixes.indexed) {
    if (gasMixtoCylinderIdx.containsKey(idx)) continue;
    final foundIdx = dive.cylinders.indexWhere((dc) => dc.oxygen == gm.oxygen && dc.helium == gm.helium);
    if (foundIdx >= 0) {
      gasMixtoCylinderIdx[idx] = foundIdx;
    } else {
      gasMixtoCylinderIdx[idx] = dive.cylinders.length;
      dive.cylinders.add(DiveCylinder(oxygen: gm.oxygen, helium: gm.helium));
    }
  }

  dive.rebuildEvents(gasMixtoCylinderIdx: gasMixtoCylinderIdx);

  dive.recalculateMetadata();

  return dive;
}
