import 'dart:convert';

import 'computerdive.dart';
import 'types.dart';

/// Converts a libdivecomputer ComputerDive to a Dive for storage.
///
/// The [diveNumber] parameter sets the dive number. Dives from the computer
/// arrive in reverse chronological order, so callers may need to renumber
/// after import.
///
/// The [model] and [serial] parameters set the dive computer identity on
/// the ComputerDive if not already set.
Dive convertDcDive(ComputerDive dcDive, {int diveNumber = 0, String? model, String? serial}) {
  final dive = Dive(
    number: diveNumber,
    start: dcDive.dateTime ?? DateTime.now(),
    duration: dcDive.diveTime ?? 0,
    maxDepth: dcDive.maxDepth,
    meanDepth: dcDive.avgDepth,
  );

  // Convert cylinders from tanks + gas mixes
  dive.cylinders = _convertCylinders(dcDive);

  // Attach the computer dive with identity info if provided
  if (dcDive.samples.isNotEmpty || dcDive.maxDepth != null) {
    final computerDive = (model != null || serial != null)
        ? ComputerDive(
            model: model ?? dcDive.model,
            serial: serial ?? dcDive.serial,
            dateTime: dcDive.dateTime,
            diveTime: dcDive.diveTime,
            number: dcDive.number,
            maxDepth: dcDive.maxDepth,
            avgDepth: dcDive.avgDepth,
            surfaceTemperature: dcDive.surfaceTemperature,
            minTemperature: dcDive.minTemperature,
            maxTemperature: dcDive.maxTemperature,
            salinity: dcDive.salinity,
            atmosphericPressure: dcDive.atmosphericPressure,
            diveMode: dcDive.diveMode,
            decoModel: dcDive.decoModel,
            location: dcDive.location,
            gasMixes: dcDive.gasMixes,
            tanks: dcDive.tanks,
            samples: dcDive.samples,
            events: dcDive.events,
            fingerprint: dcDive.fingerprint,
          )
        : dcDive;
    dive.computerDives.add(computerDive);
  }

  return dive;
}

/// Converts libdivecomputer tanks and gas mixes to DiveCylinders.
List<DiveCylinder> _convertCylinders(ComputerDive dcDive) {
  final cylinders = <DiveCylinder>[];

  for (var i = 0; i < dcDive.tanks.length; i++) {
    final tank = dcDive.tanks[i];

    // Get gas mix for this tank if available
    double? o2;
    double? he;
    if (tank.gasMixIndex != null && tank.gasMixIndex! < dcDive.gasMixes.length) {
      final gasMix = dcDive.gasMixes[tank.gasMixIndex!];
      o2 = gasMix.oxygen * 100; // Convert fraction to percentage
      he = gasMix.helium * 100;
    }

    cylinders.add(
      DiveCylinder(
        cylinderId: i + 1, // 1-indexed cylinder IDs
        start: tank.beginPressure,
        end: tank.endPressure,
        o2: o2,
        he: he,
      ),
    );
  }

  // If no tanks but gas mixes exist, create cylinders from gas mixes
  if (cylinders.isEmpty && dcDive.gasMixes.isNotEmpty) {
    for (var i = 0; i < dcDive.gasMixes.length; i++) {
      final gasMix = dcDive.gasMixes[i];
      cylinders.add(DiveCylinder(cylinderId: i + 1, o2: gasMix.oxygen * 100, he: gasMix.helium * 100));
    }
  }

  return cylinders;
}

/// Extracts the fingerprint from a dive's computer dive data.
/// Returns null if no fingerprint is stored.
List<int>? extractFingerprint(Dive dive) {
  for (final cd in dive.computerDives) {
    final fpData = cd.fingerprint;
    if (fpData != null) {
      try {
        return base64Decode(fpData);
      } catch (_) {
        // Invalid base64, skip
      }
    }
  }
  return null;
}
