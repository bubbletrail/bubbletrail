import 'package:buhlmann/buhlmann.dart' as buhlmann;
import 'package:divestore/divestore.dart';

/// Duration after which we consider tissues to be fully off-gassed.
const tissueResetDuration = Duration(hours: 24);

/// Get the start tissues for a dive.
///
/// Returns the stored start_tissues if available, otherwise null.
/// Use [calculateAndStoreStartTissues] to calculate if not stored.
Tissues? getStartTissues(Dive dive) {
  if (dive.hasStartTissues() && dive.startTissues.n2Pressures.isNotEmpty) {
    return dive.startTissues;
  }
  return null;
}

/// Calculate the start tissues for a dive, accounting for the previous dive
/// and surface interval off-gassing.
///
/// [dive] - the dive to calculate start tissues for
/// [prevDive] - the chronologically previous dive (if any)
///
/// Returns null if tissues should be clean (no previous dive within 24h).
Tissues? calculateStartTissuesFromPrevious(Dive dive, Dive? prevDive) {
  if (prevDive == null) return null;

  final diveStart = dive.start.toDateTime();
  final prevDiveEnd = prevDive.start.toDateTime().add(Duration(seconds: prevDive.duration));

  // Too long ago - tissues have reset
  if (diveStart.difference(prevDiveEnd) > tissueResetDuration) return null;

  // No end tissues stored on previous dive
  if (!prevDive.hasEndTissues()) return null;

  // Simulate surface interval off-gassing
  final surfaceInterval = diveStart.difference(prevDiveEnd).inSeconds.toDouble();
  if (surfaceInterval <= 0) {
    return prevDive.endTissues;
  }

  final tissues = protoToTissueState(prevDive.endTissues);
  if (tissues == null) return null;

  final deco = buhlmann.BuhlmannDeco(tissues: tissues);
  deco.addSegment(0, buhlmann.GasMix.air, surfaceInterval);

  return tissueStateToProto(deco.tissues);
}

/// Find the chronologically previous dive.
Dive? findPreviousDive(Dive dive, List<Dive> allDives) {
  final diveStart = dive.start.toDateTime();
  Dive? prevDive;
  DateTime? prevDiveEnd;

  for (final d in allDives) {
    if (d.id == dive.id) continue;
    final dStart = d.start.toDateTime();
    final dEnd = dStart.add(Duration(seconds: d.duration));

    // Must end before this dive starts
    if (dEnd.isAfter(diveStart)) continue;

    // Find the most recent one
    if (prevDiveEnd == null || dEnd.isAfter(prevDiveEnd)) {
      prevDive = d;
      prevDiveEnd = dEnd;
    }
  }

  return prevDive;
}

/// Convert proto Tissues to buhlmann TissueState.
buhlmann.TissueState? protoToTissueState(Tissues? tissues) {
  if (tissues == null || tissues.n2Pressures.isEmpty) return null;
  return buhlmann.TissueState(n2Pressures: tissues.n2Pressures.toList(), hePressures: tissues.hePressures.toList());
}

/// Convert buhlmann TissueState to proto Tissues.
Tissues tissueStateToProto(buhlmann.TissueState tissues) {
  return Tissues(n2Pressures: tissues.n2Pressures, hePressures: tissues.hePressures);
}

/// Build gas mixes from dive cylinders.
List<buhlmann.GasMix> buildGasMixes(Dive dive) {
  if (dive.cylinders.isEmpty) {
    return [buhlmann.GasMix.air];
  }
  return dive.cylinders.map((cyl) => buhlmann.GasMix(oxygen: cyl.oxygen, helium: cyl.helium)).toList();
}

/// Build sorted gas switch events from dive events.
List<({int time, int gasIndex})> buildGasSwitches(Dive dive, int maxGasIndex) {
  final switches = <({int time, int gasIndex})>[];
  for (final event in dive.events) {
    if (event.type == SampleEventType.SAMPLE_EVENT_TYPE_GAS_CHANGE && event.value < maxGasIndex) {
      switches.add((time: event.time, gasIndex: event.value));
    }
  }
  switches.sort((a, b) => a.time.compareTo(b.time));
  return switches;
}

/// Calculate end tissues for a dive given starting tissues.
/// Returns the tissue state at the end of the dive.
buhlmann.TissueState calculateDiveTissues(Dive dive, buhlmann.TissueState? startTissues) {
  final deco = buhlmann.BuhlmannDeco(tissues: startTissues);

  final gasMixes = buildGasMixes(dive);
  final gasSwitches = buildGasSwitches(dive, gasMixes.length);

  // Process dive profile
  var currentGas = gasMixes[0];
  var nextSwitchIdx = 0;
  var prevTime = 0.0;

  // Get samples from dive log
  final samples = dive.logs.isNotEmpty ? dive.logs.first.samples : <LogSample>[];

  for (final sample in samples) {
    // Check for gas switches
    while (nextSwitchIdx < gasSwitches.length && gasSwitches[nextSwitchIdx].time <= sample.time) {
      currentGas = gasMixes[gasSwitches[nextSwitchIdx].gasIndex];
      nextSwitchIdx++;
    }

    // Add segment
    final timeDelta = sample.time - prevTime;
    if (timeDelta > 0 && sample.hasDepth()) {
      deco.addSegment(sample.depth, currentGas, timeDelta);
    }
    prevTime = sample.time.toDouble();
  }

  return deco.tissues;
}

/// Process dive samples with tissue tracking, calling the callback for each sample.
/// This is useful for calculating ceiling/GF at each point during a dive.
void processDiveWithTissues({
  required Dive dive,
  required buhlmann.TissueState? startTissues,
  required buhlmann.BuhlmannConfig config,
  required void Function(LogSample sample, buhlmann.BuhlmannDeco deco) onSample,
}) {
  final deco = buhlmann.BuhlmannDeco(config: config, tissues: startTissues);

  final gasMixes = buildGasMixes(dive);
  final gasSwitches = buildGasSwitches(dive, gasMixes.length);

  var currentGas = gasMixes[0];
  var nextSwitchIdx = 0;
  var prevTime = 0.0;

  final samples = dive.logs.isNotEmpty ? dive.logs.first.samples : <LogSample>[];

  for (final sample in samples) {
    // Check for gas switches
    while (nextSwitchIdx < gasSwitches.length && gasSwitches[nextSwitchIdx].time <= sample.time) {
      currentGas = gasMixes[gasSwitches[nextSwitchIdx].gasIndex];
      nextSwitchIdx++;
    }

    // Add segment
    final timeDelta = sample.time - prevTime;
    if (timeDelta > 0 && sample.hasDepth()) {
      deco.addSegment(sample.depth, currentGas, timeDelta);
    }
    prevTime = sample.time.toDouble();

    // Callback with current state
    onSample(sample, deco);
  }
}
