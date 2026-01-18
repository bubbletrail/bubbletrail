import 'dart:math';

import 'constants.dart';
export 'constants.dart' show atmPressure;

const int generation = 1; // increase when bugs are fixed to force recalc

// Gas mixture definition.
class GasMix {
  final double oxygen;
  final double helium;

  const GasMix({required this.oxygen, this.helium = 0.0});

  static const air = GasMix(oxygen: 0.21);
  double get nitrogen => 1.0 - oxygen - helium;

  factory GasMix.nitrox(int oxygenPercent) {
    return GasMix(oxygen: oxygenPercent / 100.0);
  }

  factory GasMix.trimix(int oxygenPercent, int heliumPercent) {
    return GasMix(oxygen: oxygenPercent / 100.0, helium: heliumPercent / 100.0);
  }
}

// Configuration for the Buhlmann algorithm.
class BuhlmannConfig {
  final int gfLow;
  final int gfHigh;
  final double surfacePressure;

  const BuhlmannConfig({this.gfLow = 100, this.gfHigh = 100, this.surfacePressure = atmPressure});

  static const defaultConfig = BuhlmannConfig();
}

// Tissue compartment state.
class TissueState {
  final List<double> n2Pressures;
  final List<double> hePressures;

  TissueState({List<double>? n2Pressures, List<double>? hePressures})
    : n2Pressures = n2Pressures ?? List.filled(numTissueCompartments, 0.0),
      hePressures = hePressures ?? List.filled(numTissueCompartments, 0.0);

  TissueState copy() {
    return TissueState(n2Pressures: List.from(n2Pressures), hePressures: List.from(hePressures));
  }

  double totalInertPressure(int compartment) {
    return n2Pressures[compartment] + hePressures[compartment];
  }

  double combinedACoefficient(int compartment) {
    final n2 = n2Pressures[compartment];
    final he = hePressures[compartment];
    final total = n2 + he;
    if (total <= 0) return n2ACoefficients[compartment];
    return (n2 * n2ACoefficients[compartment] + he * heACoefficients[compartment]) / total;
  }

  double combinedBCoefficient(int compartment) {
    final n2 = n2Pressures[compartment];
    final he = hePressures[compartment];
    final total = n2 + he;
    if (total <= 0) return n2BCoefficients[compartment];
    return (n2 * n2BCoefficients[compartment] + he * heBCoefficients[compartment]) / total;
  }
}

class BuhlmannDeco {
  final BuhlmannConfig config;
  final TissueState tissues;

  // First decompression stop depth encountered (for GF interpolation).
  double _firstStopDepth;

  BuhlmannDeco({BuhlmannConfig? config, TissueState? tissues}) : config = config ?? BuhlmannConfig(), tissues = tissues ?? TissueState(), _firstStopDepth = 0 {
    if (tissues == null) {
      _initializeSurfaceEquilibrium();
    }
  }

  void reset() {
    _firstStopDepth = 0;
    _initializeSurfaceEquilibrium();
  }

  double depthToPressure(double depthMeters) {
    return config.surfacePressure + depthMeters / 10.0;
  }

  double pressureToDepth(double pressureBar) {
    return (pressureBar - config.surfacePressure) * 10.0;
  }

  // Add a segment at constant depth.
  void addSegment(double depthMeters, GasMix gas, double timeSeconds) {
    final timeMinutes = timeSeconds / 60.0;
    final ambientPressure = depthToPressure(depthMeters);
    final inspired = _inspiredGasPressure(ambientPressure, gas);

    for (var i = 0; i < numTissueCompartments; i++) {
      tissues.n2Pressures[i] = _schreinerEquation(tissues.n2Pressures[i], inspired.n2, n2HalfTimes[i], timeMinutes);
      tissues.hePressures[i] = _schreinerEquation(tissues.hePressures[i], inspired.he, heHalfTimes[i], timeMinutes);
    }
  }

  // Calculate the overall ceiling depth in meters.
  double ceilingDepth({int? gf}) {
    var maxCeiling = 0.0;

    if (gf == null) {
      gf = config.gfLow;
    }

    for (var i = 0; i < numTissueCompartments; i++) {
      final ceiling = _compartmentCeiling(i, gf / 100.0);
      if (ceiling > maxCeiling) {
        maxCeiling = ceiling;
      }
    }

    return pressureToDepth(maxCeiling);
  }

  // Calculate the display ceiling with smooth GF transition.
  double displayCeiling() {
    // This method:
    // 1. Enters deco when surface GF exceeds gfHigh (ceiling at gfHigh > 0)
    // 2. Tracks first stop depth (maximum ceiling seen at gfLow)
    // 3. Smoothly interpolates GF from firstStop (gfLow) to surface
    //    (gfHigh)

    // Check if in deco using gfHigh
    final ceilingAtGfHigh = ceilingDepth(gf: config.gfHigh);
    if (ceilingAtGfHigh <= 0) {
      return 0;
    }

    // Update first stop tracking (maximum ceiling seen at gfLow)
    final ceilingAtGfLow = ceilingDepth(gf: config.gfLow);
    _firstStopDepth = max(_firstStopDepth, ceilingAtGfLow);

    // Binary search for the ceiling with interpolated GF
    // We want the shallowest depth where all tissues are within the GF limit
    var lo = 0.0;
    var hi = _firstStopDepth;

    for (var i = 0; i < 20; i++) {
      if (hi - lo < 0.1) break;
      final depth = (lo + hi) / 2;
      if (_withinGfLimit(depth, _firstStopDepth)) {
        hi = depth;
      } else {
        lo = depth;
      }
    }

    return max(lo, 0);
  }

  // Initialize tissues to surface equilibrium breathing air.
  void _initializeSurfaceEquilibrium() {
    final inspiredN2 = _inspiredGasPressure(config.surfacePressure, GasMix.air);
    for (var i = 0; i < numTissueCompartments; i++) {
      tissues.n2Pressures[i] = inspiredN2.n2;
      tissues.hePressures[i] = inspiredN2.he;
    }
  }

  // Calculate inspired gas partial pressures accounting for water vapor.
  ({double n2, double he}) _inspiredGasPressure(double ambientPressure, GasMix gas) {
    final alveolarPressure = ambientPressure - waterVaporPressure;
    return (n2: alveolarPressure * gas.nitrogen, he: alveolarPressure * gas.helium);
  }

  final _log2 = log(2);

  // Calculate the tissue loading constant k = ln(2) / half-time.
  double _tissueConstant(double halfTime) {
    return _log2 / halfTime;
  }

  // Calculate new tissue pressure using the Schreiner equation.
  double _schreinerEquation(double initialPressure, double inspiredPressure, double halfTime, double timeMinutes) {
    final k = _tissueConstant(halfTime);
    return inspiredPressure + (initialPressure - inspiredPressure) * exp(-k * timeMinutes);
  }

  // Calculate the M-value (maximum tolerable tissue pressure) for a compartment
  // at a given ambient pressure.
  double _mValue(int compartment, double ambientPressure) {
    final a = tissues.combinedACoefficient(compartment);
    final b = tissues.combinedBCoefficient(compartment);
    return a + ambientPressure / b;
  }

  // Calculate the ceiling (minimum ambient pressure) for a compartment
  // with gradient factor applied.
  double _compartmentCeiling(int compartment, double gf) {
    final totalInert = tissues.totalInertPressure(compartment);
    final a = tissues.combinedACoefficient(compartment);
    final b = tissues.combinedBCoefficient(compartment);

    // Ceiling = (P_tissue - a * gf) * b / (gf + b * (1 - gf))
    // This is the ambient pressure at which tissue pressure equals
    // the M-value adjusted by gradient factor.
    return (totalInert - a * gf) * b / (gf + b * (1 - gf));
  }

  // Check if all tissues are within the GF limit at the given depth.
  bool _withinGfLimit(double depth, double firstStop) {
    final gfLimit = _gfLimitAtDepth(depth, firstStop);
    final ambientPressure = depthToPressure(depth);

    for (var i = 0; i < numTissueCompartments; i++) {
      final totalInert = tissues.totalInertPressure(i);
      final mVal = _mValue(i, ambientPressure);
      final gf = (totalInert - ambientPressure) / (mVal - ambientPressure);
      if (gf > gfLimit) {
        return false;
      }
    }
    return true;
  }

  // Calculate the GF limit at a given depth, interpolating between
  // gfLow at the first stop and gfHigh at the surface.
  double _gfLimitAtDepth(double depthMeters, double firstStop) {
    final gfLow = config.gfLow / 100.0;
    final gfHigh = config.gfHigh / 100.0;

    if (firstStop <= 0) {
      // No first stop established - use gfHigh everywhere
      return gfHigh;
    }

    if (depthMeters >= firstStop) {
      return gfLow;
    }

    // Linear interpolation from firstStop (gfLow) to surface (gfHigh)
    final fraction = 1 - depthMeters / firstStop;
    return gfLow + (gfHigh - gfLow) * fraction;
  }

  // Check if currently in decompression (surface GF > gfHigh).
  bool inDeco() {
    return ceilingDepth(gf: config.gfHigh) > 0;
  }

  // Calculate the no-decompression limit (NDL) in seconds.
  // Returns null if already in decompression.
  double? ndl(double depthMeters, GasMix gas, {double maxNdl = 59940}) {
    // Check if we're already in deco (surface GF > gfHigh)
    if (inDeco()) return null;

    final testDeco = BuhlmannDeco(config: config, tissues: tissues.copy());

    var time = 0.0;
    const timeStep = 60.0; // 60 second (1 minute) steps

    while (time < maxNdl) {
      testDeco.addSegment(depthMeters, gas, timeStep);
      time += timeStep;

      // Check if a deco stop is now required (surface GF > gfHigh)
      if (testDeco.inDeco()) {
        return time - timeStep;
      }
    }

    return maxNdl;
  }

  // Calculate the gradient factor at a given ambient pressure.
  double gradientFactor(double ambientPressure) {
    var maxGF = double.negativeInfinity;

    for (var i = 0; i < numTissueCompartments; i++) {
      final totalInert = tissues.totalInertPressure(i);
      final mVal = _mValue(i, ambientPressure);
      final gf = (totalInert - ambientPressure) / (mVal - ambientPressure) * 100;
      if (gf > maxGF) {
        maxGF = gf;
      }
    }

    return maxGF;
  }

  // Calculate the surface gradient factor (SurfGF).
  double surfaceGradientFactor() {
    return gradientFactor(config.surfacePressure);
  }

  // Get the leading (most saturated) tissue compartment index.
  int leadingTissue(double ambientPressure) {
    var maxSaturation = 0.0;
    var leading = 0;

    for (var i = 0; i < numTissueCompartments; i++) {
      final totalInert = tissues.totalInertPressure(i);
      final mVal = _mValue(i, ambientPressure);
      final saturation = totalInert / mVal;
      if (saturation > maxSaturation) {
        maxSaturation = saturation;
        leading = i;
      }
    }

    return leading;
  }
}
