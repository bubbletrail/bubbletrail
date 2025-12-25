import 'dart:convert';

import 'package:divestore/divestore.dart' as ds;

import 'types.dart';

/// Converts a libdivecomputer Dive to an SSRF Dive for storage.
///
/// The [diveNumber] parameter sets the dive number. Dives from the computer
/// arrive in reverse chronological order, so callers may need to renumber
/// after import.
///
/// If [diveComputerId] is provided, a DiveComputerLog will be created with
/// that ID. Otherwise, a placeholder ID of 0 is used.
Dive convertDcDive(ds.Dive dcDive, {int diveNumber = 0, int diveComputerId = 0}) {
  final dive = Dive(
    number: diveNumber,
    start: dcDive.dateTime ?? DateTime.now(),
    duration: dcDive.diveTime ?? 0,
    maxDepth: dcDive.maxDepth,
    meanDepth: dcDive.avgDepth,
  );

  // Convert cylinders from tanks + gas mixes
  dive.cylinders = _convertCylinders(dcDive);

  // Create dive computer log with samples
  if (dcDive.samples.isNotEmpty || dcDive.maxDepth != null) {
    dive.divecomputers.add(_createDiveComputerLog(dcDive, diveComputerId));
  }

  return dive;
}

/// Converts libdivecomputer tanks and gas mixes to SSRF DiveCylinders.
List<DiveCylinder> _convertCylinders(ds.Dive dcDive) {
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

/// Creates a DiveComputerLog from the libdivecomputer dive data.
DiveComputerLog _createDiveComputerLog(ds.Dive dcDive, int diveComputerId) {
  // Convert samples
  final samples = <Sample>[];
  for (final dcSample in dcDive.samples) {
    // Skip samples without depth data
    if (dcSample.depth == null) continue;

    // Get first tank pressure if available
    double? pressure;
    if (dcSample.pressures?.isNotEmpty == true) {
      pressure = dcSample.pressures!.first.pressure;
    }

    samples.add(Sample(time: dcSample.time.toInt(), depth: dcSample.depth!, temp: dcSample.temperature, pressure: pressure));
  }

  // Convert events XXX broken
  // final events = <Event>[];
  // for (final dcSample in dcDive.samples) {
  //   for (final dcEvent in dcSample.events ?? []) {
  //     events.add(Event(time: dcSample.time.toInt(), type: dcEvent.type.index, value: dcEvent.value, name: dcEvent.type.name));
  //   }
  // }
  // XXX

  // Build environment
  Environment? environment;
  if (dcDive.surfaceTemperature != null || dcDive.minTemperature != null) {
    environment = Environment(airTemperature: dcDive.surfaceTemperature, waterTemperature: dcDive.minTemperature);
  }

  // Build extradata from dive info
  final extradata = <String, String>{};
  if (dcDive.diveMode != null) {
    extradata['divemode'] = dcDive.diveMode!.name;
  }
  if (dcDive.decoModel != null) {
    extradata['decomodel'] = dcDive.decoModel.toString();
  }
  if (dcDive.salinity != null) {
    extradata['salinity'] = dcDive.salinity!.type.name;
    extradata['density'] = dcDive.salinity!.density.toString();
  }
  if (dcDive.atmosphericPressure != null) {
    extradata['atmospheric'] = dcDive.atmosphericPressure!.toString();
  }
  if (dcDive.fingerprint != null) {
    extradata['fingerprint'] = dcDive.fingerprint ?? '';
  }

  return DiveComputerLog(
    diveComputerId: diveComputerId,
    maxDepth: dcDive.maxDepth ?? 0,
    meanDepth: dcDive.avgDepth ?? 0,
    environment: environment,
    samples: samples,
    // events: events,
    extradata: extradata,
  );
}

/// Extracts the fingerprint from an SSRF dive's computer log extradata.
/// Returns null if no fingerprint is stored.
List<int>? extractFingerprint(Dive dive) {
  for (final log in dive.divecomputers) {
    final fpData = log.extradata['fingerprint'];
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
