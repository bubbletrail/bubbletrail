import 'dart:math';

const int numTissueCompartments = 16;

/// ZHL-16c nitrogen half-times in minutes.
const List<double> n2HalfTimes = [5.0, 8.0, 12.5, 18.5, 27.0, 38.3, 54.3, 77.0, 109.0, 146.0, 187.0, 239.0, 305.0, 390.0, 498.0, 635.0];

/// ZHL-16c nitrogen a coefficients (bar).
const List<double> n2ACoefficients = [1.1696, 1.0, 0.8618, 0.7562, 0.62, 0.5043, 0.441, 0.4, 0.375, 0.35, 0.3295, 0.3065, 0.2835, 0.261, 0.248, 0.2327];

/// ZHL-16c nitrogen b coefficients (dimensionless).
const List<double> n2BCoefficients = [
  0.5578,
  0.6514,
  0.7222,
  0.7825,
  0.8126,
  0.8434,
  0.8693,
  0.8910,
  0.9092,
  0.9222,
  0.9319,
  0.9403,
  0.9477,
  0.9544,
  0.9602,
  0.9653,
];

/// ZHL-16c helium half-times in minutes.
const List<double> heHalfTimes = [1.88, 3.02, 4.72, 6.99, 10.21, 14.48, 20.53, 29.11, 41.20, 55.19, 70.69, 90.34, 115.29, 147.42, 188.24, 240.03];

/// ZHL-16c helium a coefficients (bar).
const List<double> heACoefficients = [
  1.6189,
  1.3830,
  1.1919,
  1.0458,
  0.9220,
  0.8205,
  0.7305,
  0.6502,
  0.5950,
  0.5545,
  0.5333,
  0.5189,
  0.5181,
  0.5176,
  0.5172,
  0.5119,
];

/// ZHL-16c helium b coefficients (dimensionless).
const List<double> heBCoefficients = [
  0.4770,
  0.5747,
  0.6527,
  0.7223,
  0.7582,
  0.7957,
  0.8279,
  0.8553,
  0.8757,
  0.8903,
  0.8997,
  0.9073,
  0.9122,
  0.9171,
  0.9217,
  0.9267,
];

/// Standard atmospheric pressure at sea level in bar.
const double atmPressure = 1.01325;

/// Water vapor pressure in the lungs (bar) at 37°C.
const double waterVaporPressure = 0.0627;

/// Nitrogen fraction in air.
const double airN2Fraction = 0.79;

/// Oxygen fraction in air.
const double airO2Fraction = 0.21;

/// Depth increment for decompression stops in meters.
const double stopDepthIncrement = 3.0;

/// Gas mixture definition.
class GasMix {
  /// Oxygen fraction (0.0 to 1.0).
  final double oxygen;

  /// Helium fraction (0.0 to 1.0).
  final double helium;

  const GasMix({required this.oxygen, this.helium = 0.0});

  /// Standard air mixture.
  static const air = GasMix(oxygen: airO2Fraction);

  /// Pure oxygen.
  static const pureOxygen = GasMix(oxygen: 1.0);

  /// Nitrogen fraction (remainder after O2 and He).
  double get nitrogen => 1.0 - oxygen - helium;

  /// Create a nitrox mix with the given oxygen percentage.
  factory GasMix.nitrox(int oxygenPercent) {
    return GasMix(oxygen: oxygenPercent / 100.0);
  }

  /// Create a trimix with given oxygen and helium percentages.
  factory GasMix.trimix(int oxygenPercent, int heliumPercent) {
    return GasMix(oxygen: oxygenPercent / 100.0, helium: heliumPercent / 100.0);
  }

  @override
  String toString() {
    if (helium > 0) {
      return 'Tx${(oxygen * 100).round()}/${(helium * 100).round()}';
    } else if ((oxygen * 100).round() == 21) {
      return 'Air';
    } else {
      return 'EAN${(oxygen * 100).round()}';
    }
  }
}

/// Configuration for the Buhlmann algorithm.
class BuhlmannConfig {
  /// Low gradient factor (at depth) as percentage (0-100).
  final int gfLow;

  /// High gradient factor (at surface) as percentage (0-100).
  final int gfHigh;

  /// Last decompression stop depth in meters (typically 3 or 6).
  final double lastStopDepth;

  /// Surface pressure in bar.
  final double surfacePressure;

  const BuhlmannConfig({this.gfLow = 100, this.gfHigh = 100, this.lastStopDepth = 3.0, this.surfacePressure = atmPressure});

  /// Default configuration without gradient factors.
  static const defaultConfig = BuhlmannConfig();

  /// Conservative configuration with GF 30/70.
  static const conservative = BuhlmannConfig(gfLow: 30, gfHigh: 70);

  /// Moderate configuration with GF 40/85.
  static const moderate = BuhlmannConfig(gfLow: 40, gfHigh: 85);
}

/// Tissue compartment state.
class TissueState {
  /// Nitrogen partial pressure in each compartment (bar).
  final List<double> n2Pressures;

  /// Helium partial pressure in each compartment (bar).
  final List<double> hePressures;

  TissueState({List<double>? n2Pressures, List<double>? hePressures})
    : n2Pressures = n2Pressures ?? List.filled(numTissueCompartments, 0.0),
      hePressures = hePressures ?? List.filled(numTissueCompartments, 0.0);

  /// Create a copy of this state.
  TissueState copy() {
    return TissueState(n2Pressures: List.from(n2Pressures), hePressures: List.from(hePressures));
  }

  /// Total inert gas pressure in a compartment.
  double totalInertPressure(int compartment) {
    return n2Pressures[compartment] + hePressures[compartment];
  }

  /// Get the combined a coefficient for a compartment based on gas loadings.
  double combinedACoefficient(int compartment) {
    final n2 = n2Pressures[compartment];
    final he = hePressures[compartment];
    final total = n2 + he;
    if (total <= 0) return n2ACoefficients[compartment];
    return (n2 * n2ACoefficients[compartment] + he * heACoefficients[compartment]) / total;
  }

  /// Get the combined b coefficient for a compartment based on gas loadings.
  double combinedBCoefficient(int compartment) {
    final n2 = n2Pressures[compartment];
    final he = hePressures[compartment];
    final total = n2 + he;
    if (total <= 0) return n2BCoefficients[compartment];
    return (n2 * n2BCoefficients[compartment] + he * heBCoefficients[compartment]) / total;
  }
}

/// Buhlmann decompression calculator.
class BuhlmannDeco {
  final BuhlmannConfig config;
  final TissueState tissues;

  /// First decompression stop depth encountered (for GF interpolation).
  double? _firstStopDepth;

  BuhlmannDeco({BuhlmannConfig? config, TissueState? tissues}) : config = config ?? BuhlmannConfig.defaultConfig, tissues = tissues ?? TissueState() {
    // Initialize tissues to surface equilibrium if not provided
    if (tissues == null) {
      _initializeSurfaceEquilibrium();
    }
  }

  /// Initialize tissues to surface equilibrium breathing air.
  void _initializeSurfaceEquilibrium() {
    final inspiredN2 = _inspiredGasPressure(config.surfacePressure, GasMix.air);
    for (var i = 0; i < numTissueCompartments; i++) {
      tissues.n2Pressures[i] = inspiredN2.n2;
      tissues.hePressures[i] = inspiredN2.he;
    }
  }

  /// Reset to surface equilibrium.
  void reset() {
    _firstStopDepth = null;
    _initializeSurfaceEquilibrium();
  }

  /// Convert depth in meters to absolute pressure in bar.
  double depthToPressure(double depthMeters) {
    return config.surfacePressure + depthMeters / 10.0;
  }

  /// Convert absolute pressure in bar to depth in meters.
  double pressureToDepth(double pressureBar) {
    return (pressureBar - config.surfacePressure) * 10.0;
  }

  /// Calculate inspired gas partial pressures accounting for water vapor.
  ({double n2, double he}) _inspiredGasPressure(double ambientPressure, GasMix gas) {
    final alveolarPressure = ambientPressure - waterVaporPressure;
    return (n2: alveolarPressure * gas.nitrogen, he: alveolarPressure * gas.helium);
  }

  /// Calculate the tissue loading constant k = ln(2) / half-time.
  double _tissueConstant(double halfTime) {
    return log(2) / halfTime;
  }

  /// Calculate new tissue pressure using the Schreiner equation.
  ///
  /// P_t = P_i + (P_0 - P_i) * (1 - e^(-k*t))
  ///
  /// Where:
  /// - P_t = final tissue pressure
  /// - P_i = inspired gas pressure
  /// - P_0 = initial tissue pressure
  /// - k = tissue constant (ln(2) / half-time)
  /// - t = time in minutes
  double _schreinerEquation(double initialPressure, double inspiredPressure, double halfTime, double timeMinutes) {
    final k = _tissueConstant(halfTime);
    return inspiredPressure + (initialPressure - inspiredPressure) * exp(-k * timeMinutes);
  }

  /// Add a segment at constant depth.
  ///
  /// [depthMeters] - depth in meters
  /// [gas] - breathing gas mixture
  /// [timeSeconds] - time at depth in seconds
  void addSegment(double depthMeters, GasMix gas, double timeSeconds) {
    final timeMinutes = timeSeconds / 60.0;
    final ambientPressure = depthToPressure(depthMeters);
    final inspired = _inspiredGasPressure(ambientPressure, gas);

    for (var i = 0; i < numTissueCompartments; i++) {
      tissues.n2Pressures[i] = _schreinerEquation(tissues.n2Pressures[i], inspired.n2, n2HalfTimes[i], timeMinutes);
      tissues.hePressures[i] = _schreinerEquation(tissues.hePressures[i], inspired.he, heHalfTimes[i], timeMinutes);
    }
  }

  /// Calculate the M-value (maximum tolerable tissue pressure) for a compartment
  /// at a given ambient pressure.
  double mValue(int compartment, double ambientPressure) {
    final a = tissues.combinedACoefficient(compartment);
    final b = tissues.combinedBCoefficient(compartment);
    return a + ambientPressure / b;
  }

  /// Calculate the GF limit at a given depth, interpolating between
  /// GF_low at the first stop and GF_high at the surface.
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

  /// Check if all tissues are within the GF limit at the given depth.
  bool _withinGfLimit(double depth, double firstStop) {
    final gfLimit = _gfLimitAtDepth(depth, firstStop);
    final ambientPressure = depthToPressure(depth);

    for (var i = 0; i < numTissueCompartments; i++) {
      final totalInert = tissues.totalInertPressure(i);
      final mVal = mValue(i, ambientPressure);
      final gf = (totalInert - ambientPressure) / (mVal - ambientPressure);
      if (gf > gfLimit) {
        return false;
      }
    }
    return true;
  }

  /// Calculate the ceiling (minimum ambient pressure) for a compartment
  /// with gradient factor applied.
  double _compartmentCeiling(int compartment, double gf) {
    final totalInert = tissues.totalInertPressure(compartment);
    final a = tissues.combinedACoefficient(compartment);
    final b = tissues.combinedBCoefficient(compartment);

    // Ceiling = (P_tissue - a * gf) * b / (gf + b * (1 - gf))
    // This is the ambient pressure at which tissue pressure equals
    // the M-value adjusted by gradient factor.
    return (totalInert - a * gf) * b / (gf + b * (1 - gf));
  }

  /// Calculate the overall ceiling depth in meters.
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

  /// Calculate the display ceiling with smooth GF transition.
  ///
  /// This method:
  /// 1. Enters deco when surface GF exceeds gfHigh (ceiling at gfHigh > 0)
  /// 2. Tracks first stop depth (maximum ceiling seen at gfLow)
  /// 3. Smoothly interpolates GF from firstStop (gfLow) to surface (gfHigh)
  ///
  /// The key property is continuity: when we first enter deco, the ceiling
  /// is at the gfHigh depth. As firstStop gets established (deeper), the
  /// ceiling smoothly transitions toward using gfLow at firstStop.
  double displayCeiling() {
    // Calculate ceiling at gfLow (potential first stop depth)
    final ceilingAtGfLow = ceilingDepth(gf: config.gfLow);

    // Update first stop tracking (maximum ceiling seen at gfLow)
    if (ceilingAtGfLow > 0) {
      _firstStopDepth = max(_firstStopDepth ?? 0, ceilingAtGfLow);
    }

    // Check if in deco using gfHigh
    final ceilingAtGfHigh = ceilingDepth(gf: config.gfHigh);
    if (ceilingAtGfHigh <= 0) {
      return 0;
    }

    // First stop depth for interpolation
    final firstStop = _firstStopDepth ?? 0;

    // If first stop is at or shallower than gfHigh ceiling, use gfHigh ceiling
    // This ensures continuity when first entering deco
    if (firstStop <= ceilingAtGfHigh) {
      return ceilingAtGfHigh;
    }

    // Binary search for the ceiling with interpolated GF
    // We want the shallowest depth where all tissues are within the GF limit
    var lo = 0.0;
    var hi = firstStop;

    for (var i = 0; i < 20; i++) {
      final depth = (lo + hi) / 2;
      if (_withinGfLimit(depth, firstStop)) {
        hi = depth;
      } else {
        lo = depth;
      }
    }

    return max(lo, 0);
  }

  /// Check if currently in decompression (surface GF > gfHigh).
  bool inDeco() {
    return ceilingDepth(gf: config.gfHigh) > 0;
  }

  /// Get the next decompression stop depth, rounded up to stop increment.
  double nextStopDepth() {
    final ceiling = displayCeiling();
    if (ceiling <= 0) return 0;

    // Round up to nearest stop depth
    var stopDepth = (ceiling / stopDepthIncrement).ceil() * stopDepthIncrement;

    // Enforce minimum last stop depth
    if (stopDepth < config.lastStopDepth && ceiling > 0) {
      stopDepth = config.lastStopDepth;
    }

    return stopDepth;
  }

  /// Calculate the no-decompression limit (NDL) in seconds.
  /// Returns null if already in decompression.
  ///
  /// [depthMeters] - depth to calculate NDL for
  /// [gas] - breathing gas mixture
  /// [maxNdl] - maximum NDL to calculate in seconds (default 59940 = 999 min)
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

  /// Calculate tissue saturation as a percentage of the M-value.
  /// 100% means the tissue is at its M-value limit.
  ///
  /// Note: This is NOT the same as gradient factor. Use [gradientFactor] for GF.
  double tissuesSaturation(double ambientPressure) {
    var maxSaturation = 0.0;

    for (var i = 0; i < numTissueCompartments; i++) {
      final totalInert = tissues.totalInertPressure(i);
      final mVal = mValue(i, ambientPressure);
      final saturation = totalInert / mVal * 100;
      if (saturation > maxSaturation) {
        maxSaturation = saturation;
      }
    }

    return maxSaturation;
  }

  /// Calculate the gradient factor at a given ambient pressure.
  ///
  /// GF represents how much of the supersaturation headroom is being used:
  /// - GF = 0% means tissue pressure equals ambient pressure (no supersaturation)
  /// - GF = 100% means tissue pressure equals M-value (at the limit)
  /// - GF > 100% means tissue pressure exceeds M-value (decompression violation)
  ///
  /// Formula: GF = (P_tissue - P_amb) / (M - P_amb) * 100
  ///
  /// Returns the highest GF across all tissue compartments (the limiting tissue).
  double gradientFactor(double ambientPressure) {
    var maxGF = double.negativeInfinity;

    for (var i = 0; i < numTissueCompartments; i++) {
      final totalInert = tissues.totalInertPressure(i);
      final mVal = mValue(i, ambientPressure);
      final gf = (totalInert - ambientPressure) / (mVal - ambientPressure) * 100;
      if (gf > maxGF) {
        maxGF = gf;
      }
    }

    return maxGF;
  }

  /// Calculate the surface gradient factor (SurfGF).
  ///
  /// This is the GF you would have if you ascended directly to the surface.
  /// Commonly displayed on dive computers to show decompression status.
  double surfaceGradientFactor() {
    return gradientFactor(config.surfacePressure);
  }

  /// Get the leading (most saturated) tissue compartment index.
  int leadingTissue(double ambientPressure) {
    var maxSaturation = 0.0;
    var leading = 0;

    for (var i = 0; i < numTissueCompartments; i++) {
      final totalInert = tissues.totalInertPressure(i);
      final mVal = mValue(i, ambientPressure);
      final saturation = totalInert / mVal;
      if (saturation > maxSaturation) {
        maxSaturation = saturation;
        leading = i;
      }
    }

    return leading;
  }

  /// Set the first stop depth for GF interpolation.
  void setFirstStopDepth(double depth) {
    _firstStopDepth = depth;
  }
}

/// A decompression stop.
class DecoStop {
  /// Stop depth in meters.
  final double depth;

  /// Time at stop in seconds.
  final double time;

  const DecoStop({required this.depth, required this.time});

  @override
  String toString() => '${depth.toStringAsFixed(0)}m for ${(time / 60).round()}min';
}

/// Decompression status at a point in a dive.
class DecoStatus {
  /// True if currently in decompression.
  final bool inDeco;

  /// No-decompression limit in seconds (null if in deco).
  final int? ndl;

  /// Ceiling depth in meters.
  final double ceiling;

  /// Time to surface in seconds.
  final int? tts;

  /// Tissue saturation percentage.
  final double saturation;

  const DecoStatus({required this.inDeco, this.ndl, required this.ceiling, this.tts, required this.saturation});
}
