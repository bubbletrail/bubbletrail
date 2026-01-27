import 'package:btbuhlmann/btbuhlmann.dart' as buhlmann;
import 'package:btstore/btstore.dart';

// Duration after which we consider tissues to be fully off-gassed.
const tissueResetDuration = Duration(hours: 24);

// Convert proto Tissues to buhlmann TissueState.
buhlmann.TissueState? protoToTissueState(Tissues? tissues) {
  if (tissues == null || tissues.n2Pressures.isEmpty) return null;
  final n2s = tissues.n2Pressures.length == buhlmann.numTissueCompartments ? tissues.n2Pressures.toList() : null;
  final hes = tissues.hePressures.length == buhlmann.numTissueCompartments ? tissues.hePressures.toList() : null;
  return buhlmann.TissueState(n2Pressures: n2s, hePressures: hes);
}

// Convert buhlmann TissueState to proto Tissues.
Tissues tissueStateToProto(buhlmann.TissueState tissues, DateTime timestamp, String chainId) {
  final hes = tissues.hePressures.any((p) => p != 0) ? tissues.hePressures : null;
  return Tissues(n2Pressures: tissues.n2Pressures, hePressures: hes, timestamp: .fromDateTime(timestamp), chainId: chainId, generation: buhlmann.generation);
}

// Build gas mixes from dive cylinders.
List<buhlmann.GasMix> buildGasMixes(Dive dive) {
  if (dive.cylinders.isEmpty) {
    return [buhlmann.GasMix.air];
  }
  return dive.cylinders.map((cyl) => buhlmann.GasMix(oxygen: cyl.oxygen, helium: cyl.helium)).toList();
}

// Build sorted gas switch events from dive events.
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

// Process dive samples with tissue tracking, calling the callback for each
// sample. This is useful for calculating ceiling/GF at each point during a
// dive. Returns the final tissue state and end surface GF.
(buhlmann.TissueState, double) calculateDiveTissues({
  required Dive dive,
  required buhlmann.TissueState? startTissues,
  buhlmann.BuhlmannConfig config = buhlmann.BuhlmannConfig.defaultConfig,
  void Function(LogSample sample, buhlmann.BuhlmannDeco deco)? onSample,
}) {
  final deco = buhlmann.BuhlmannDeco(config: config, tissues: startTissues);

  final gasMixes = buildGasMixes(dive);
  final gasSwitches = buildGasSwitches(dive, gasMixes.length);

  var currentGas = gasMixes[0];
  var nextSwitchIdx = 0;
  var prevTime = 0.0;

  final samples = dive.logs.isNotEmpty ? dive.logs.first.samples : <LogSample>[];

  var endSurfGF = 0.0;
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
    if (sample.depth > 0) endSurfGF = deco.surfaceGradientFactor();

    // Callback with current state
    onSample?.call(sample, deco);
  }

  return (deco.tissues, endSurfGF);
}
